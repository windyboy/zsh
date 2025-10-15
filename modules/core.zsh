#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Configuration - Essential Core Settings
# Description: Core functionality, validation, and performance monitoring
# =============================================================================

# Color output tools - colors module should be loaded before core
# source "$ZSH_CONFIG_DIR/modules/colors.zsh"  # Moved to zshrc loading order

# Module specific wrappers
core_color_red()   { color_red "$@"; }
core_color_green() { color_green "$@"; }

# Shared validation helpers
source "$ZSH_CONFIG_DIR/modules/lib/validation.zsh"

# -------------------- Security Settings --------------------
# Safe file operations (merged from security.zsh)
alias rm='rm -i' cp='cp -i' mv='mv -i'

# Secure umask
umask 022

# -------------------- Module Loading Status --------------------
export ZSH_MODULES_LOADED=""

# -------------------- Directory Initialization --------------------
core_init_dirs() {
    local dirs=("$ZSH_CACHE_DIR" "$ZSH_DATA_DIR" "$ZSH_CONFIG_DIR/completions")
    for dir in "${dirs[@]}"; do
        [[ ! -d "$dir" ]] && mkdir -p "$dir" 2>/dev/null && color_green "Created: $dir"
    done
}
core_init_dirs

# -------------------- Core Settings --------------------
setopt CORRECT CORRECT_ALL
setopt NO_HUP NO_CHECK_JOBS
setopt AUTO_PARAM_KEYS AUTO_PARAM_SLASH COMPLETE_IN_WORD HASH_LIST_ALL
setopt INTERACTIVE_COMMENTS MULTIOS NOTIFY
setopt NO_CLOBBER RM_STAR_WAIT PIPE_FAIL
unsetopt BEEP CASE_GLOB FLOW_CONTROL

# -------------------- Enhanced Error Handling --------------------
# Safe source function with error handling
safe_source() {
    local file="$1"
    local description="${2:-$file}"
    
    if [[ -f "$file" ]]; then
        if source "$file" 2>/dev/null; then
            color_green "✅ Loaded: $description" >&2
            return 0
        else
            color_yellow "⚠️  Warning: Failed to load $description" >&2
            return 1
        fi
    else
        color_yellow "⚠️  Warning: File not found: $description" >&2
        return 1
    fi
}

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
        echo "  --report, -r     Write validation output to a report file"
        echo "  --all, -a        Run all validation checks (default)"
        echo
        echo "Examples:"
        echo "  validate         # Basic validation"
        echo "  validate -v      # Detailed validation"
        echo "  validate --fix   # Fix common issues"
        echo "  validate --report # Generate report file"
        return 0
    }

    local verbose=false
    local fix_mode=false
    local report_mode=false
    local report_file=""
    local -a validation_messages=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose|-v) verbose=true; shift ;;
            --fix|-f) fix_mode=true; shift ;;
            --report|-r) report_mode=true; shift ;;
            --all|-a) shift ;;
            *) echo "Unknown option: $1"; return 1 ;;
        esac
    done

    echo "🔍 Configuration Validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    validation_run validation_messages "$fix_mode"
    local run_status=$?

    if [[ "$report_mode" == "true" ]]; then
        mkdir -p "$ZSH_CACHE_DIR"
        report_file="$ZSH_CACHE_DIR/validation_report_$(date +%Y%m%d_%H%M%S).log"
        : >"$report_file"
    fi

    local entry
    for entry in "${validation_messages[@]}"; do
        local level="${entry%%|*}"
        local message="${entry#*|}"
        case "$level" in
            info) [[ "$verbose" == "true" ]] && echo "ℹ️  $message" ;;
            success) echo "✅ $message" ;;
            warning) echo "⚠️  $message" ;;
            error) echo "❌ $message" ;;
        esac
        if [[ "$report_mode" == "true" ]]; then
            printf '%s|%s\n' "$level" "$message" >>"$report_file"
        fi
    done

    echo
    echo "Validation Summary:"
    printf "  %s %-20s %s\n" "❌" "Errors:" "$VALIDATION_ERRORS"
    printf "  %s %-20s %s\n" "⚠️" "Warnings:" "$VALIDATION_WARNINGS"

    if [[ $VALIDATION_ERRORS -eq 0 && $VALIDATION_WARNINGS -eq 0 ]]; then
        echo "✅ Configuration validation passed!"
    elif [[ $VALIDATION_ERRORS -eq 0 ]]; then
        echo "⚠️  Configuration has warnings but no errors"
    else
        echo "❌ Configuration validation failed: $VALIDATION_ERRORS error(s)"
    fi

    if [[ "$report_mode" == "true" ]]; then
        echo "Report saved to: $report_file"
    fi

    return $run_status
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
        echo "  --modules        Show per-module performance breakdown"
        echo "  --memory         Display memory usage analysis"
        echo "  --startup        Show startup time analysis"
        echo "  --monitor, -m    Start continuous performance monitoring"
        echo "  --profile, -p    Generate detailed performance profile"
        echo "  --optimize, -o   Show optimization recommendations"
        echo "  --history, -h    Show performance history"
        return 0
    }

    local monitor_mode=false
    local profile_mode=false
    local optimize_mode=false
    local history_mode=false
    local modules_mode=false
    local memory_mode=false
    local startup_mode=false
    local profile_file="$ZSH_CACHE_DIR/performance_profile_$(date +%Y%m%d_%H%M%S).txt"

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --modules) modules_mode=true; shift ;;
            --memory) memory_mode=true; shift ;;
            --startup) startup_mode=true; shift ;;
            --monitor|-m) monitor_mode=true; shift ;;
            --profile|-p) profile_mode=true; shift ;;
            --optimize|-o) optimize_mode=true; shift ;;
            --history|-h) history_mode=true; shift ;;
            *) echo "Unknown option: $1"; return 1 ;;
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

    local module_dir="$ZSH_CONFIG_DIR/modules"

    # Helper to show module breakdown using data from status.sh
    if [[ "$modules_mode" == "true" ]]; then
        echo "📦 Module Performance Breakdown"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if [[ ! -d "$module_dir" ]]; then
            echo "Modules directory not found: $module_dir"
        else
            emulate -L zsh
            setopt localoptions null_glob extendedglob
            local module_files=($module_dir/*.zsh(N))
            if (( ${#module_files[@]} == 0 )); then
                echo "No modules found in $module_dir"
            else
                local total_lines=0
                local total_size=0
                local total_functions=0
                for module_file in "${module_files[@]}"; do
                    local module_name="${module_file##*/}"
                    module_name="${module_name%.zsh}"
                    local lines=$(wc -l < "$module_file" 2>/dev/null | tr -d ' ')
                    local size_kb=$(du -k "$module_file" 2>/dev/null | awk '{print $1}')
                    local functions=$(grep -E '^[[:space:]]*[_[:alnum:]]+\(\)' "$module_file" 2>/dev/null | wc -l | tr -d ' ')
                    local status_icon="⚠️"
                    if [[ " $ZSH_MODULES_LOADED " == *" $module_name "* ]]; then
                        status_icon="✅"
                    fi
                    printf "  %s %-18s %6s lines | %5s KB | %3s functions\n" \
                        "$status_icon" "$module_name" "${lines:-0}" "${size_kb:-0}" "${functions:-0}"

                    (( total_lines += ${lines:-0} ))
                    (( total_size += ${size_kb:-0} ))
                    (( total_functions += ${functions:-0} ))
                done
                echo
                printf "  %s %-18s %6s lines | %5s KB | %3s functions\n" \
                    "📊" "Total" "$total_lines" "$total_size" "$total_functions"
            fi
        fi

        echo
    fi

    # Helper to show memory usage analysis per module
    if [[ "$memory_mode" == "true" ]]; then
        echo "💾 Memory Usage Analysis"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        local ps_available=true
        command -v ps >/dev/null 2>&1 || ps_available=false

        if [[ "$ps_available" == "false" ]]; then
            echo "ps command not available. Unable to calculate memory usage."
        elif [[ ! -d "$module_dir" ]]; then
            echo "Modules directory not found: $module_dir"
        else
            emulate -L zsh
            setopt localoptions null_glob extendedglob
            local module_files=($module_dir/*.zsh(N))
            if (( ${#module_files[@]} == 0 )); then
                echo "No modules found in $module_dir"
            else
                local total_memory_kb=0
                for module_file in "${module_files[@]}"; do
                    local module_name="${module_file##*/}"
                    module_name="${module_name%.zsh}"
                    local memory_kb=""
                    if command -v zsh >/dev/null 2>&1; then
                        memory_kb=$(zsh -f -c '
                            typeset module="$1"
                            typeset start
                            start=$(ps -p $$ -o rss= 2>/dev/null | tr -d " ")
                            [[ -z "$start" ]] && start=0
                            source "$module" >/dev/null 2>&1
                            typeset finish
                            finish=$(ps -p $$ -o rss= 2>/dev/null | tr -d " ")
                            [[ -z "$finish" ]] && finish="$start"
                            typeset diff=$(( finish - start ))
                            (( diff < 0 )) && diff=0
                            printf "%s" "$diff"
                        ' "$module_file" 2>/dev/null)
                    fi

                    if [[ -z "$memory_kb" ]]; then
                        memory_kb=$(du -k "$module_file" 2>/dev/null | awk '{print $1}')
                        [[ -z "$memory_kb" ]] && memory_kb=0
                        printf "  ⚠️  %-18s Estimated %5s KB (file size)\n" "$module_name" "$memory_kb"
                    else
                        local memory_mb=$(echo "scale=1; ${memory_kb:-0} / 1024" | bc 2>/dev/null || echo "0")
                        printf "  ✅ %-18s %5s KB (%s MB)\n" "$module_name" "$memory_kb" "$memory_mb"
                        (( total_memory_kb += ${memory_kb:-0} ))
                    fi
                done

                if (( total_memory_kb > 0 )); then
                    local total_memory_mb=$(echo "scale=1; ${total_memory_kb} / 1024" | bc 2>/dev/null || echo "0")
                    echo
                    printf "  %s %-18s %5s KB (%s MB)\n" "📊" "Total Loaded" "$total_memory_kb" "$total_memory_mb"
                fi
            fi
        fi

        echo
    fi

    # Helper to show startup time analysis
    if [[ "$startup_mode" == "true" ]]; then
        echo "🚀 Startup Time Analysis"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if [[ ! -d "$module_dir" ]]; then
            echo "Modules directory not found: $module_dir"
        else
            local module_times=""
            if command -v zsh >/dev/null 2>&1; then
                module_times=$(MODULE_DIR="$module_dir" zsh -f <<'EOF'
zmodload zsh/datetime 2>/dev/null
zmodload zsh/mathfunc 2>/dev/null
setopt null_glob
for module_file in $MODULE_DIR/*.zsh(N); do
    typeset start=$EPOCHREALTIME
    source "$module_file" >/dev/null 2>&1
    typeset finish=$EPOCHREALTIME
    typeset duration=$(( finish - start ))
    printf "%s|%.4f\n" "${module_file:t:r}" "$duration"
done
EOF
)
            fi

            if [[ -z "$module_times" ]]; then
                echo "Unable to calculate startup times (requires zsh with datetime module)."
            else
                local total_time="0.0"
                while IFS='|' read -r module_name module_time; do
                    [[ -z "$module_name" ]] && continue
                    printf "  ✅ %-18s %6ss\n" "$module_name" "$module_time"
                    total_time=$(echo "scale=4; $total_time + $module_time" | bc 2>/dev/null || echo "$total_time")
                done <<< "$module_times"

                local metrics=$(get_performance_metrics)
                IFS='|' read -r _ _ _ startup_time _ _ _ <<< "$metrics"
                echo
                printf "  %s %-18s %6ss\n" "📊" "Module Sum" "$total_time"
                printf "  %s %-18s %6ss\n" "📈" "Measured Startup" "$startup_time"
            fi
        fi

        echo
    fi
    
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
            local modules=("core" "navigation" "aliases" "plugins" "completion" "keybindings" "utils")
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
    echo "📦 ZSH Configuration Version 5.3.0 (Enhanced Modular)"
    echo "Key Features: Modular architecture, comprehensive testing, performance optimization"
    echo "Modules: core/security/navigation/aliases/plugins/completion/keybindings/utils"
    echo "Interface: Professional monitoring and validation system"
}

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED core"
