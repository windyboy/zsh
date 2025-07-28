#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Configuration - Environment Core Settings
# Description: Only essential, high-frequency, minimal core environment configuration with clear comments and unified naming.
# =============================================================================

# Color output tools
# Load centralized color functions
source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# Module specific wrappers
core_color_red()   { color_red "$@"; }
core_color_green() { color_green "$@"; }

# -------------------- Module Loading Status --------------------
export ZSH_MODULES_LOADED=""

# -------------------- Directory Initialization --------------------
core_init_dirs() {
    local dirs=("$ZSH_CACHE_DIR" "$ZSH_DATA_DIR" "$ZSH_CONFIG_DIR/custom" "$ZSH_CONFIG_DIR/completions")
    for dir in "${dirs[@]}"; do
        [[ ! -d "$dir" ]] && mkdir -p "$dir" 2>/dev/null && color_green "Created: $dir"
    done
}
core_init_dirs

# -------------------- Security/History/Navigation --------------------
setopt NO_CLOBBER RM_STAR_WAIT PIPE_FAIL
setopt HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS
alias rm='rm -i' cp='cp -i' mv='mv -i'
umask 022
setopt APPEND_HISTORY SHARE_HISTORY HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_VERIFY
# History configuration is now handled by environment variables
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT CDABLE_VARS
setopt EXTENDED_GLOB NO_CASE_GLOB NUMERIC_GLOB_SORT
setopt CORRECT CORRECT_ALL
setopt NO_HUP NO_CHECK_JOBS
setopt AUTO_PARAM_KEYS AUTO_PARAM_SLASH COMPLETE_IN_WORD HASH_LIST_ALL
setopt INTERACTIVE_COMMENTS MULTIOS NOTIFY
unsetopt BEEP CASE_GLOB FLOW_CONTROL

# -------------------- Global Aliases --------------------
alias -g ...='../..' ....='../../..' .....='../../../..' ......='../../../../..'
alias -g G='| grep' L='| less' H='| head' T='| tail' S='| sort' U='| uniq' C='| wc -l'

# -------------------- Common Functions --------------------
# Reload configuration
reload() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: reload [--module <name>] [--config]"
        echo "  reload                # Reload all configuration (default)"
        echo "  reload --module <mod> # Reload a specific module (core/plugins/...)"
        echo "  reload --config       # Reload zshrc/zshenv only"
        return 0
    fi
    if [[ "$1" == "--module" && -n "$2" ]]; then
        local modfile="$ZSH_CONFIG_DIR/modules/${2}.zsh"
        if [[ -f "$modfile" ]]; then
            source "$modfile"
            color_green "✅ Reloaded module: $2"
        else
            color_red "❌ Module not found: $2"
        fi
        return
    fi
    if [[ "$1" == "--config" ]]; then
        source "$ZSH_CONFIG_DIR/zshenv"
        source "$ZSH_CONFIG_DIR/zshrc"
        color_green "✅ Reloaded zshrc and zshenv"
        return
    fi
    echo "🔄 Reloading all ZSH configuration..."
    source "$ZSH_CONFIG_DIR/zshrc"
    color_green "✅ Configuration reloaded"
}
# Configuration validation
validate() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && {
        echo "Usage: validate [options]"
        echo "Options:"
        echo "  --verbose, -v    Show detailed validation information"
        echo "  --fix, -f        Attempt to fix common issues automatically"
        echo "  --report, -r     Generate detailed validation report"
        echo "  --all, -a        Run all validation checks (default)"
        echo
        echo "Examples:"
        echo "  validate         # Basic validation"
        echo "  validate -v      # Detailed validation"
        echo "  validate --fix   # Fix common issues"
        echo "  validate --report # Generate report"
        return 0
    }
    
    local verbose=false
    local fix_mode=false
    local report_mode=false
    local validation_errors=0
    local validation_warnings=0
    local report_file=""
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose|-v)
                verbose=true
                shift
                ;;
            --fix|-f)
                fix_mode=true
                shift
                ;;
            --report|-r)
                report_mode=true
                report_file="$ZSH_CACHE_DIR/validation_report_$(date +%Y%m%d_%H%M%S).txt"
                shift
                ;;
            --all|-a)
                # Default behavior, no additional action needed
                shift
                ;;
            *)
                color_red "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    # Initialize report if needed
    if [[ "$report_mode" == "true" ]]; then
        mkdir -p "$ZSH_CACHE_DIR"
        echo "ZSH Configuration Validation Report" > "$report_file"
        echo "Generated: $(date)" >> "$report_file"
        echo "================================================" >> "$report_file"
        echo >> "$report_file"
    fi
    
    # Helper function to log validation results
    log_validation() {
        local level="$1"
        local message="$2"
        local details="$3"
        
        case "$level" in
            "error")
                ((validation_errors++))
                color_red "❌ $message"
                [[ -n "$details" ]] && echo "   $details"
                ;;
            "warning")
                ((validation_warnings++))
                color_yellow "⚠️  $message"
                [[ -n "$details" ]] && echo "   $details"
                ;;
            "success")
                color_green "✅ $message"
                ;;
            "info")
                [[ "$verbose" == "true" ]] && echo "ℹ️  $message"
                ;;
        esac
        
        # Add to report if in report mode
        if [[ "$report_mode" == "true" ]]; then
            echo "[$level] $message" >> "$report_file"
            [[ -n "$details" ]] && echo "   $details" >> "$report_file"
        fi
    }
    
    # Helper function to attempt fixes
    attempt_fix() {
        local issue="$1"
        local fix_command="$2"
        
        if [[ "$fix_mode" == "true" ]]; then
            log_validation "info" "Attempting to fix: $issue"
            if eval "$fix_command"; then
                log_validation "success" "Fixed: $issue"
                return 0
            else
                log_validation "warning" "Failed to fix: $issue"
                return 1
            fi
        fi
        return 1
    }
    
    echo "🔍 Validating ZSH configuration..."
    [[ "$verbose" == "true" ]] && echo "Verbose mode enabled"
    [[ "$fix_mode" == "true" ]] && echo "Fix mode enabled"
    [[ "$report_mode" == "true" ]] && echo "Report will be saved to: $report_file"
    echo
    
    # 1. Check required directories
    log_validation "info" "Checking required directories..."
    local required_dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_validation "error" "Missing directory: $dir"
            attempt_fix "Create missing directory" "mkdir -p \"$dir\""
        else
            log_validation "success" "Directory exists: $dir"
        fi
    done
    
    # 2. Check required files
    log_validation "info" "Checking required files..."
    local required_files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/modules/core.zsh")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_validation "error" "Missing file: $file"
        else
            log_validation "success" "File exists: $file"
            # Check file permissions
            local perms=$(stat -c %a "$file" 2>/dev/null || stat -f %Lp "$file" 2>/dev/null)
            if [[ $perms -gt 644 ]]; then
                log_validation "warning" "Insecure permissions on $file: $perms"
                attempt_fix "Fix file permissions" "chmod 644 \"$file\""
            fi
        fi
    done
    
    # 3. Check environment variables
    log_validation "info" "Checking environment variables..."
    local required_vars=("ZSH_CONFIG_DIR" "ZSH_CACHE_DIR" "ZSH_DATA_DIR")
    for var in "${required_vars[@]}"; do
        local value=""
        case "$var" in
            "ZSH_CONFIG_DIR") value="$ZSH_CONFIG_DIR" ;;
            "ZSH_CACHE_DIR") value="$ZSH_CACHE_DIR" ;;
            "ZSH_DATA_DIR") value="$ZSH_DATA_DIR" ;;
        esac
        if [[ -z "$value" ]]; then
            log_validation "error" "Environment variable not set: $var"
        else
            log_validation "success" "Environment variable set: $var=$value"
        fi
    done
    
    # 4. Check module loading
    log_validation "info" "Checking module loading..."
    local modules=("core" "aliases" "plugins" "completion" "keybindings" "utils")
    for module in "${modules[@]}"; do
        local modfile="$ZSH_CONFIG_DIR/modules/${module}.zsh"
        if [[ -f "$modfile" ]]; then
            if [[ -n "$ZSH_MODULES_LOADED" && "$ZSH_MODULES_LOADED" == *"$module"* ]]; then
                log_validation "success" "Module loaded: $module"
            else
                log_validation "warning" "Module file exists but not loaded: $module"
            fi
        else
            log_validation "error" "Module file missing: $modfile"
        fi
    done
    
    # 5. Check plugin system
    log_validation "info" "Checking plugin system..."
    if command -v zinit >/dev/null 2>&1; then
        log_validation "success" "zinit plugin manager available"
    else
        log_validation "warning" "zinit plugin manager not found"
        if [[ "$fix_mode" == "true" ]]; then
            log_validation "info" "Attempting to install zinit..."
            local zinit_dir="$HOME/.local/share/zsh/zinit/zinit.git"
            if git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir" 2>/dev/null; then
                log_validation "success" "zinit installed successfully"
            else
                log_validation "error" "Failed to install zinit"
            fi
        fi
    fi
    
    # 6. Check completion system
    log_validation "info" "Checking completion system..."
    if compdef >/dev/null 2>&1; then
        log_validation "success" "Completion system working"
    else
        log_validation "error" "Completion system not working"
    fi
    
    # 7. Check for common issues
    log_validation "info" "Checking for common issues..."
    
    # Check for duplicate aliases
    local duplicate_aliases=$(alias | cut -d= -f1 | sed 's/^alias //g' | sort | uniq -d)
    if [[ -n "$duplicate_aliases" ]]; then
        log_validation "warning" "Duplicate aliases found: $duplicate_aliases"
    else
        log_validation "success" "No duplicate aliases"
    fi
    
    # Check for key binding conflicts
    local ctrl_t_bindings=$(bindkey | grep '^\^T' | wc -l)
    if [[ $ctrl_t_bindings -gt 1 ]]; then
        log_validation "warning" "Ctrl+T bound multiple times ($ctrl_t_bindings bindings)"
    fi
    
    # Check for dangerous aliases
    if alias | grep -q '^alias rm=' && ! alias rm | grep -q 'rm -i'; then
        log_validation "warning" "Dangerous rm alias found (not using -i flag)"
        attempt_fix "Fix dangerous rm alias" "alias rm='rm -i'"
    fi
    
    # 8. Check performance metrics
    log_validation "info" "Checking performance metrics..."
    local func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
    local alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
    local memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
    local memory_mb=$(echo "scale=1; ${memory_kb:-0} / 1024" | bc 2>/dev/null || echo "0")
    
    if [[ $func_count -gt 200 ]]; then
        log_validation "warning" "High function count: $func_count (recommended: <200)"
    else
        log_validation "success" "Function count: $func_count"
    fi
    
    if [[ $alias_count -gt 100 ]]; then
        log_validation "warning" "High alias count: $alias_count (recommended: <100)"
    else
        log_validation "success" "Alias count: $alias_count"
    fi
    
    if [[ $(echo "$memory_mb > 10" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        log_validation "warning" "High memory usage: ${memory_mb}MB (recommended: <10MB)"
    else
        log_validation "success" "Memory usage: ${memory_mb}MB"
    fi
    
    # 9. Check startup time
    log_validation "info" "Checking startup time..."
    local start_time=$(date +%s.%N)
    source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local startup_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    
    if [[ $(echo "$startup_time > 2" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        log_validation "warning" "Slow startup time: ${startup_time}s (recommended: <2s)"
    else
        log_validation "success" "Startup time: ${startup_time}s"
    fi
    
    # 10. Check for syntax errors
    log_validation "info" "Checking for syntax errors..."
    local syntax_errors=0
    for module in "${modules[@]}"; do
        local modfile="$ZSH_CONFIG_DIR/modules/${module}.zsh"
        if [[ -f "$modfile" ]]; then
            if zsh -n "$modfile" 2>/dev/null; then
                log_validation "success" "Syntax OK: $module.zsh"
            else
                log_validation "error" "Syntax error in: $module.zsh"
                ((syntax_errors++))
            fi
        fi
    done
    
    # Summary
    echo
    log_validation "info" "Validation Summary:"
    printf "  %s %-20s %s\n" "❌" "Errors:" "$validation_errors"
    printf "  %s %-20s %s\n" "⚠️" "Warnings:" "$validation_warnings"
    
    if [[ $validation_errors -eq 0 && $validation_warnings -eq 0 ]]; then
        log_validation "success" "Configuration validation passed!"
        [[ "$report_mode" == "true" ]] && echo "Report saved to: $report_file"
        return 0
    elif [[ $validation_errors -eq 0 ]]; then
        log_validation "warning" "Configuration has warnings but no errors"
        [[ "$report_mode" == "true" ]] && echo "Report saved to: $report_file"
        return 0
    else
        log_validation "error" "Configuration validation failed: $validation_errors errors"
        [[ "$report_mode" == "true" ]] && echo "Report saved to: $report_file"
        return 1
    fi
}
# System status
status() {
    echo "📊 Status"
    echo "ZSH Version: $(zsh --version | head -1)"
    echo "Config Directory: $ZSH_CONFIG_DIR"
    echo "Cache Directory: $ZSH_CACHE_DIR"
    echo "Data Directory: $ZSH_DATA_DIR"
    echo "Loaded Modules: $ZSH_MODULES_LOADED"
}
# Performance check
perf() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && {
        echo "Usage: perf [options]"
        echo "Options:"
        echo "  --monitor, -m    Start continuous performance monitoring"
        echo "  --profile, -p    Generate detailed performance profile"
        echo "  --optimize, -o   Show optimization recommendations"
        echo "  --history, -h    Show performance history"
        echo "  --all, -a        Show all performance metrics (default)"
        echo
        echo "Examples:"
        echo "  perf             # Show basic performance metrics"
        echo "  perf --monitor   # Start continuous monitoring"
        echo "  perf --profile   # Generate detailed profile"
        echo "  perf --optimize  # Show optimization tips"
        return 0
    }
    
    local monitor_mode=false
    local profile_mode=false
    local optimize_mode=false
    local history_mode=false
    local profile_file=""
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --monitor|-m)
                monitor_mode=true
                shift
                ;;
            --profile|-p)
                profile_mode=true
                profile_file="$ZSH_CACHE_DIR/performance_profile_$(date +%Y%m%d_%H%M%S).txt"
                shift
                ;;
            --optimize|-o)
                optimize_mode=true
                shift
                ;;
            --history|-h)
                history_mode=true
                shift
                ;;
            --all|-a)
                # Default behavior, no additional action needed
                shift
                ;;
            *)
                color_red "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    # Helper function to get performance metrics
    get_performance_metrics() {
        local func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
        local alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
        local memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
        local memory_mb=$(echo "scale=1; ${memory_kb:-0} / 1024" | bc 2>/dev/null || echo "0")
        local history_lines=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
        local uptime=$(ps -p $$ -o etime 2>/dev/null | awk 'NR==2 {print $1}')
        
        # Calculate startup time
        local start_time=$(date +%s.%N)
        source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1
        local end_time=$(date +%s.%N)
        local startup_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
        
        # Calculate performance score
        local score=100
        [[ $func_count -gt 200 ]] && ((score -= 10))
        [[ $alias_count -gt 100 ]] && ((score -= 10))
        [[ $(echo "$memory_mb > 10" | bc 2>/dev/null || echo "0") -eq 1 ]] && ((score -= 20))
        [[ $(echo "$startup_time > 2" | bc 2>/dev/null || echo "0") -eq 1 ]] && ((score -= 20))
        
        echo "$func_count|$alias_count|$memory_mb|$startup_time|$history_lines|$uptime|$score"
    }
    
    # Helper function to display metrics
    display_metrics() {
        local metrics="$1"
        IFS='|' read -r func_count alias_count memory_mb startup_time history_lines uptime score <<< "$metrics"
        
        echo "📊 Performance Metrics"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        printf "  %s %-20s %s\n" "🔧" "Functions:" "$func_count"
        printf "  %s %-20s %s\n" "⚡" "Aliases:" "$alias_count"
        printf "  %s %-20s %s\n" "💾" "Memory:" "${memory_mb}MB"
        printf "  %s %-20s %s\n" "🚀" "Startup:" "${startup_time}s"
        printf "  %s %-20s %s\n" "📚" "History:" "$history_lines lines"
        printf "  %s %-20s %s\n" "⏱️" "Uptime:" "$uptime"
        printf "  %s %-20s %s\n" "📈" "Score:" "$score/100"
        
        # Performance rating
        if [[ $score -ge 90 ]]; then
            color_green "Performance: Excellent"
        elif [[ $score -ge 70 ]]; then
            color_yellow "Performance: Good"
        elif [[ $score -ge 50 ]]; then
            color_yellow "Performance: Fair"
        else
            color_red "Performance: Needs optimization"
        fi
    }
    
    # Continuous monitoring mode
    if [[ "$monitor_mode" == "true" ]]; then
        echo "📊 Starting performance monitoring (Press Ctrl+C to stop)..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        while true; do
            local metrics=$(get_performance_metrics)
            IFS='|' read -r func_count alias_count memory_mb startup_time history_lines uptime score <<< "$metrics"
            
            printf "\r[%s] Score: %s/100 | Memory: %sMB | Functions: %s | Aliases: %s" \
                "$(date '+%H:%M:%S')" "$score" "$memory_mb" "$func_count" "$alias_count"
            
            sleep 5
        done
        return 0
    fi
    
    # Profile mode
    if [[ "$profile_mode" == "true" ]]; then
        echo "📊 Generating performance profile..."
        mkdir -p "$ZSH_CACHE_DIR"
        
        # Create detailed profile
        {
            echo "ZSH Configuration Performance Profile"
            echo "Generated: $(date)"
            echo "================================================"
            echo
            
            # System information
            echo "System Information:"
            echo "  OS: $(uname -s) $(uname -r)"
            echo "  Architecture: $(uname -m)"
            echo "  ZSH Version: $(zsh --version | head -1)"
            echo "  Shell PID: $$"
            echo
            
            # Performance metrics
            local metrics=$(get_performance_metrics)
            IFS='|' read -r func_count alias_count memory_mb startup_time history_lines uptime score <<< "$metrics"
            
            echo "Performance Metrics:"
            echo "  Functions: $func_count"
            echo "  Aliases: $alias_count"
            echo "  Memory Usage: ${memory_mb}MB"
            echo "  Startup Time: ${startup_time}s"
            echo "  History Lines: $history_lines"
            echo "  Uptime: $uptime"
            echo "  Performance Score: $score/100"
            echo
            
            # Module analysis
            echo "Module Analysis:"
            local modules=("core" "aliases" "plugins" "completion" "keybindings" "utils")
            for module in "${modules[@]}"; do
                local modfile="$ZSH_CONFIG_DIR/modules/${module}.zsh"
                if [[ -f "$modfile" ]]; then
                    local lines=$(wc -l < "$modfile" 2>/dev/null)
                    echo "  $module.zsh: $lines lines"
                fi
            done
            echo
            
            # Plugin analysis
            echo "Plugin Analysis:"
            if command -v zinit >/dev/null 2>&1; then
                echo "  zinit: Available"
                # Count loaded plugins
                local plugin_count=$(zinit list 2>/dev/null | grep -c '^[[:space:]]*[a-zA-Z]' || echo "0")
                echo "  Loaded Plugins: $plugin_count"
            else
                echo "  zinit: Not available"
            fi
            echo
            
            # Environment variables
            echo "Environment Variables:"
            echo "  ZSH_CONFIG_DIR: $ZSH_CONFIG_DIR"
            echo "  ZSH_CACHE_DIR: $ZSH_CACHE_DIR"
            echo "  ZSH_DATA_DIR: $ZSH_DATA_DIR"
            echo "  HISTSIZE: $HISTSIZE"
            echo "  SAVEHIST: $SAVEHIST"
            echo
            
            # Recommendations
            echo "Recommendations:"
            if [[ $func_count -gt 200 ]]; then
                echo "  ⚠️  Consider reducing function count (current: $func_count, recommended: <200)"
            fi
            if [[ $alias_count -gt 100 ]]; then
                echo "  ⚠️  Consider reducing alias count (current: $alias_count, recommended: <100)"
            fi
            if [[ $(echo "$memory_mb > 10" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
                echo "  ⚠️  Consider optimizing memory usage (current: ${memory_mb}MB, recommended: <10MB)"
            fi
            if [[ $(echo "$startup_time > 2" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
                echo "  ⚠️  Consider optimizing startup time (current: ${startup_time}s, recommended: <2s)"
            fi
            if [[ $score -ge 90 ]]; then
                echo "  ✅ Performance is excellent!"
            elif [[ $score -ge 70 ]]; then
                echo "  ✅ Performance is good"
            else
                echo "  🔧 Consider implementing optimization recommendations"
            fi
            
        } > "$profile_file"
        
        echo "Profile saved to: $profile_file"
        return 0
    fi
    
    # Optimization mode
    if [[ "$optimize_mode" == "true" ]]; then
        echo "🔧 Performance Optimization Recommendations"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        local metrics=$(get_performance_metrics)
        IFS='|' read -r func_count alias_count memory_mb startup_time history_lines uptime score <<< "$metrics"
        
        echo "Current Performance Score: $score/100"
        echo
        
        # Function optimization
        if [[ $func_count -gt 200 ]]; then
            color_yellow "🔧 Function Optimization:"
            echo "  • Current: $func_count functions"
            echo "  • Recommended: <200 functions"
            echo "  • Action: Review and remove unused functions"
            echo "  • Check: modules/utils.zsh for utility functions"
            echo
        fi
        
        # Alias optimization
        if [[ $alias_count -gt 100 ]]; then
            color_yellow "🔧 Alias Optimization:"
            echo "  • Current: $alias_count aliases"
            echo "  • Recommended: <100 aliases"
            echo "  • Action: Review and remove unused aliases"
            echo "  • Check: modules/aliases.zsh for alias definitions"
            echo
        fi
        
        # Memory optimization
        if [[ $(echo "$memory_mb > 10" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
            color_yellow "🔧 Memory Optimization:"
            echo "  • Current: ${memory_mb}MB"
            echo "  • Recommended: <10MB"
            echo "  • Action: Review plugin usage and module loading"
            echo "  • Check: modules/plugins.zsh for heavy plugins"
            echo
        fi
        
        # Startup time optimization
        if [[ $(echo "$startup_time > 2" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
            color_yellow "🔧 Startup Time Optimization:"
            echo "  • Current: ${startup_time}s"
            echo "  • Recommended: <2s"
            echo "  • Action: Review module loading order and dependencies"
            echo "  • Check: zshrc for module loading sequence"
            echo
        fi
        
        # General recommendations
        if [[ $score -ge 90 ]]; then
            color_green "✅ Performance is excellent! No optimizations needed."
        elif [[ $score -ge 70 ]]; then
            color_yellow "✅ Performance is good. Minor optimizations may help."
        else
            color_red "🔧 Performance needs improvement. Implement the above recommendations."
        fi
        
        echo
        echo "💡 Additional Tips:"
        echo "  • Use 'validate --fix' to automatically fix common issues"
        echo "  • Use 'test.sh' to run comprehensive tests"
        echo "  • Review plugin usage with 'plugins' command"
        echo "  • Monitor performance with 'perf --monitor'"
        
        return 0
    fi
    
    # History mode
    if [[ "$history_mode" == "true" ]]; then
        echo "📚 Performance History"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Look for performance history files
        local history_files=($ZSH_CACHE_DIR/performance_profile_*.txt)
        if [[ ${#history_files[@]} -eq 0 ]]; then
            echo "No performance history found."
            echo "Run 'perf --profile' to create performance profiles."
            return 0
        fi
        
        # Show recent profiles
        echo "Recent Performance Profiles:"
        for file in "${history_files[@]: -5}"; do
            local date=$(basename "$file" | sed 's/performance_profile_\(.*\)\.txt/\1/')
            local score=$(grep "Performance Score:" "$file" | awk '{print $3}' | head -1)
            echo "  $date: Score $score"
        done
        
        return 0
    fi
    
    # Default mode - show basic metrics
    local metrics=$(get_performance_metrics)
    display_metrics "$metrics"
}
# Version information
version() {
    echo "📦 ZSH Configuration Version 4.3.0 (Personal Minimal)"
    echo "Key Features: Minimal architecture, core functionality, performance optimization, personal experience"
    echo "Modules: core/aliases/plugins/completion/keybindings/utils"
    echo "Interface: Complete English localization with beautiful status monitoring"
}

# -------------------- Reserved Custom Area --------------------
# Custom functions/variables can be added in the custom/ directory

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED core"
