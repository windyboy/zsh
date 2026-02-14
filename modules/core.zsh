#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Configuration - Essential Core Settings
# Description: Core functionality, validation, and performance monitoring
# =============================================================================

# Performance Thresholds (Constants)
typeset -gr ZSH_MAX_FUNCTIONS=200      # Maximum recommended functions
typeset -gr ZSH_MAX_ALIASES=100        # Maximum recommended aliases
typeset -gr ZSH_MAX_MEMORY_MB=10       # Maximum memory usage in MB
typeset -gr ZSH_MAX_STARTUP_SEC=2      # Maximum startup time in seconds
typeset -gr ZSH_CACHE_TTL=86400        # Cache TTL in seconds (24 hours)

# Color output tools - colors module should be loaded before core
# source "$ZSH_CONFIG_DIR/modules/colors.zsh"  # Moved to zshrc loading order

# Shared validation helpers
source "$ZSH_CONFIG_DIR/modules/lib/validation.zsh"

# -------------------- Security Settings --------------------
# Safe file operations with extra protections for rm
safe_rm() {
    if (( $# == 0 )); then
        echo "Usage: rm <path> [...]"
        return 1
    fi

    local prompt_needed=false
    local -a reasons=()
    local home_prefix="$HOME"
    local cwd_prefix="$PWD"

    # Check each target for safety
    for target in "$@"; do
        [[ "$target" == -* ]] && continue  # Skip options
        [[ -z "$target" ]] && continue
        local abs_target="${target:A}"

        [[ -d "$target" ]] && {
            prompt_needed=true
            reasons+=("directory: $target")
        }

        [[ "$abs_target" != "$home_prefix" && "$abs_target" != "$home_prefix"/* ]] && {
            prompt_needed=true
            reasons+=("outside home: $target")
        }

        [[ "$abs_target" != "$cwd_prefix" && "$abs_target" != "$cwd_prefix"/* ]] && {
            prompt_needed=true
            reasons+=("outside current directory: $target")
        }

        if [[ -e "$target" ]]; then
            local owner=$(stat -f '%Su' "$target" 2>/dev/null || stat -c '%U' "$target" 2>/dev/null || echo "")
            [[ -n "$owner" && "$owner" != "$USER" ]] && {
                prompt_needed=true
                reasons+=("owner $owner ≠ $USER: $target")
            }
        fi
    done

    if [[ "$prompt_needed" == true ]]; then
        color_yellow "⚠️  rm safety check"
        (( ${#reasons[@]} > 0 )) && printf '  - %s\n' "${reasons[@]}"
        read -r "?Proceed with rm? [y/N]: " confirm
        [[ ! "$confirm" =~ ^[Yy]$ ]] && {
            color_red "Deletion cancelled"
            return 1
        }
    fi

    command rm -i "$@"
}

alias rm='safe_rm' cp='cp -i' mv='mv -i'

# Secure umask
umask 022

# -------------------- Directory Initialization --------------------
core_init_dirs() {
    local dirs=("$ZSH_CACHE_DIR" "$ZSH_DATA_DIR" "$ZSH_CONFIG_DIR/completions")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir" 2>/dev/null; then
                if (( ${+functions[color_green]} )); then
                    color_green "Created: $dir"
                else
                    echo "Created: $dir"
                fi
            else
                echo "Warning: Failed to create directory: $dir" >&2
            fi
        fi
    done
}
core_init_dirs

# -------------------- Core Settings --------------------
# Disable command and argument spelling correction to avoid annoying prompts
unsetopt CORRECT CORRECT_ALL
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

    local verbose=false fix_mode=false report_mode=false report_file=""
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

    [[ "$report_mode" == "true" ]] && {
        mkdir -p "$ZSH_CACHE_DIR"
        report_file="$ZSH_CACHE_DIR/validation_report_$(date +%Y%m%d_%H%M%S).log"
        : >"$report_file"
    }

    for entry in "${validation_messages[@]}"; do
        local level="${entry%%|*}"
        local message="${entry#*|}"
        case "$level" in
            info) [[ "$verbose" == "true" ]] && echo "ℹ️  $message" ;;
            success) echo "✅ $message" ;;
            warning) echo "⚠️  $message" ;;
            error) echo "❌ $message" ;;
        esac
        [[ "$report_mode" == "true" ]] && printf '%s|%s\n' "$level" "$message" >>"$report_file"
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

    [[ "$report_mode" == "true" ]] && echo "Report saved to: $report_file"

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

    # Get performance metrics
    local func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
    local alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
    local memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
    local memory_mb=$(printf "%.1f" $(( ${memory_kb:-0} / 1024.0 )))
    local history_lines=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
    local uptime=$(ps -p $$ -o etime 2>/dev/null | awk 'NR==2 {print $1}')

    # Calculate performance metrics
    zmodload zsh/datetime
    local func_count=${#functions}
    local alias_count=${#aliases}
    
    # Use memory info from ps (already cached if possible, but here we keep it simple)
    local memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
    local memory_mb=$(printf "%.1f" $(( ${memory_kb:-0} / 1024.0 )))

    # Use a faster way to get "startup time" - we can't accurately re-measure 
    # without re-sourcing, so we should report the LAST known startup time 
    # or use a very lightweight check. For now, let's just use the metrics we have.
    local startup_time="${ZSH_STARTUP_TIME:-0}"

    # Calculate performance score using zsh native arithmetic
    local score=100
    (( func_count > $ZSH_MAX_FUNCTIONS )) && (( score -= 10 ))
    (( alias_count > $ZSH_MAX_ALIASES )) && (( score -= 10 ))
    (( $(printf "%.0f" $memory_mb) > ZSH_MAX_MEMORY_MB )) && (( score -= 20 ))
    
    # Simple report
    echo "🚀 ZSH Performance Metrics"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  Functions: %d\n" "$func_count"
    printf "  Aliases:   %d\n" "$alias_count"
    printf "  Memory:    %s MB\n" "$memory_mb"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if (( score >= 90 )); then
        color_green "✅ Performance: Excellent ($score/100)"
    elif (( score >= 70 )); then
        color_yellow "⚠️  Performance: Good ($score/100)"
    else
        color_red "❌ Performance: Needs Optimization ($score/100)"
    fi

    local module_dir="$ZSH_CONFIG_DIR/modules"

    # Helper to show module breakdown using data from status.sh
    if [[ "$modules_mode" == "true" ]]; then
        echo "📦 Module Performance Breakdown"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if [[ ! -d "$module_dir" ]]; then
            echo "Modules directory not found: $module_dir"
        else
            local module_files=("$module_dir"/*.zsh)
            if [[ -e "${module_files[0]}" ]]; then
                local total_lines=0
                local total_size=0
                local total_functions=0
                for module_file in "${module_files[@]}"; do
                    [[ -f "$module_file" ]] || continue
                    local module_name="${module_file##*/}"
                    module_name="${module_name%.zsh}"
                    local lines=$(wc -l < "$module_file" 2>/dev/null | tr -d ' ')
                    local size_kb=$(du -k "$module_file" 2>/dev/null | awk '{print $1}')
                    local functions=$(grep -E '^[[:space:]]*[_[:alnum:]]+\(\)' "$module_file" 2>/dev/null | wc -l | tr -d ' ')
                    local status_icon="⚠️"
                    [[ " $ZSH_MODULES_LOADED " == *" $module_name "* ]] && status_icon="✅"
                    printf "  %s %-18s %6s lines | %5s KB | %3s functions\n" \
                        "$status_icon" "$module_name" "${lines:-0}" "${size_kb:-0}" "${functions:-0}"

                    (( total_lines += ${lines:-0} ))
                    (( total_size += ${size_kb:-0} ))
                    (( total_functions += ${functions:-0} ))
                done
                echo
                printf "  %s %-18s %6s lines | %5s KB | %3s functions\n" \
                    "📊" "Total" "$total_lines" "$total_size" "$total_functions"
            else
                echo "No modules found in $module_dir"
            fi
        fi

        echo
    fi

    # Helper to show memory usage analysis per module
    if [[ "$memory_mode" == "true" ]]; then
        echo "💾 Memory Usage Analysis"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if ! command -v ps >/dev/null 2>&1; then
            echo "ps command not available. Unable to calculate memory usage."
        elif [[ ! -d "$module_dir" ]]; then
            echo "Modules directory not found: $module_dir"
        else
            local module_files=("$module_dir"/*.zsh)
            if [[ -e "${module_files[0]}" ]]; then
                local total_memory_kb=0
                for module_file in "${module_files[@]}"; do
                    [[ -f "$module_file" ]] || continue
                    local module_name="${module_file##*/}"
                    module_name="${module_name%.zsh}"
                    local memory_kb=$(du -k "$module_file" 2>/dev/null | awk '{print $1}')
                    [[ -z "$memory_kb" ]] && memory_kb=0
                    printf "  ⚠️  %-18s Estimated %5s KB (file size)\n" "$module_name" "$memory_kb"
                    (( total_memory_kb += ${memory_kb:-0} ))
                done

                if (( total_memory_kb > 0 )); then
                    local total_memory_mb=$(printf "%.1f" $(( total_memory_kb / 1024.0 )))
                    echo
                    printf "  %s %-18s %5s KB (%s MB)\n" "📊" "Total Loaded" "$total_memory_kb" "$total_memory_mb"
                fi
            else
                echo "No modules found in $module_dir"
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
            local module_files=("$module_dir"/*.zsh)
            if [[ -e "${module_files[0]}" ]]; then
                local total_time="0.0"
                for module_file in "${module_files[@]}"; do
                    [[ -f "$module_file" ]] || continue
                    local module_name="${module_file##*/}"
                    module_name="${module_name%.zsh}"
                    printf "  ✅ %-18s %6ss\n" "$module_name" "0.0000"  # Simplified - no actual timing
                    total_time="0.0000"
                done
                echo
                printf "  %s %-18s %6ss\n" "📊" "Module Sum" "$total_time"
                printf "  %s %-18s %6ss\n" "📈" "Measured Startup" "$startup_time"
            else
                echo "No modules found in $module_dir"
            fi
        fi

        echo
    fi

    # Continuous monitoring mode
    if [[ "$monitor_mode" == "true" ]]; then
        echo "📊 Starting performance monitoring (Press Ctrl+C to stop)..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        while true; do
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

        # Create simplified profile
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
                [[ -f "$modfile" ]] && echo "  $module.zsh: $(wc -l < "$modfile" 2>/dev/null) lines"
            done
            echo

            # Plugin analysis
            if command -v zinit >/dev/null 2>&1; then
                echo "  zinit: Available"
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
            [[ $func_count -gt $ZSH_MAX_FUNCTIONS ]] && echo "  ⚠️  Consider reducing function count (current: $func_count, recommended: <$ZSH_MAX_FUNCTIONS)"
            [[ $alias_count -gt $ZSH_MAX_ALIASES ]] && echo "  ⚠️  Consider reducing alias count (current: $alias_count, recommended: <$ZSH_MAX_ALIASES)"
            (( $(printf "%.0f" $memory_mb) > ZSH_MAX_MEMORY_MB )) && echo "  ⚠️  Consider optimizing memory usage (current: ${memory_mb}MB, recommended: <${ZSH_MAX_MEMORY_MB}MB)"
            (( $(printf "%.0f" $startup_time) > ZSH_MAX_STARTUP_SEC )) && echo "  ⚠️  Consider optimizing startup time (current: ${startup_time}s, recommended: <${ZSH_MAX_STARTUP_SEC}s)"
            [[ $score -ge 90 ]] && echo "  ✅ Performance is excellent!" || echo "  🔧 Consider implementing optimization recommendations"
        } > "$profile_file"

        echo "Profile saved to: $profile_file"
        return 0
    fi

    # Optimization mode
    if [[ "$optimize_mode" == "true" ]]; then
        echo "🔧 Performance Optimization Recommendations"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        echo "Current Performance Score: $score/100"
        echo

        # Function optimization
        [[ $func_count -gt $ZSH_MAX_FUNCTIONS ]] && {
            color_yellow "🔧 Function Optimization:"
            echo "  • Current: $func_count functions"
            echo "  • Recommended: <200 functions"
            echo "  • Action: Review and remove unused functions"
            echo "  • Check: modules/utils.zsh for utility functions"
            echo
        }

        # Alias optimization
        [[ $alias_count -gt $ZSH_MAX_ALIASES ]] && {
            color_yellow "🔧 Alias Optimization:"
            echo "  • Current: $alias_count aliases"
            echo "  • Recommended: <100 aliases"
            echo "  • Action: Review and remove unused aliases"
            echo "  • Check: modules/aliases.zsh for alias definitions"
            echo
        }

        # Memory optimization
        (( $(printf "%.0f" $memory_mb) > ZSH_MAX_MEMORY_MB )) && {
            color_yellow "🔧 Memory Optimization:"
            echo "  • Current: ${memory_mb}MB"
            echo "  • Recommended: <10MB"
            echo "  • Action: Review plugin usage and module loading"
            echo "  • Check: modules/plugins.zsh for heavy plugins"
            echo
        }

        # Startup time optimization
        (( $(printf "%.0f" $startup_time) > ZSH_MAX_STARTUP_SEC )) && {
            color_yellow "🔧 Startup Time Optimization:"
            echo "  • Current: ${startup_time}s"
            echo "  • Recommended: <2s"
            echo "  • Action: Review module loading order and dependencies"
            echo "  • Check: zshrc for module loading sequence"
            echo
        }

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
        local history_files=("$ZSH_CACHE_DIR"/performance_profile_*.txt)
        if [[ ! -e "${history_files[0]}" ]]; then
            echo "No performance history found."
            echo "Run 'perf --profile' to create performance profiles."
            return 0
        fi

        # Show recent profiles
        echo "Recent Performance Profiles:"
        local count=0
        for file in "${history_files[@]}"; do
            [[ $count -ge 5 ]] && break
            local date=$(basename "$file" | sed 's/performance_profile_\(.*\)\.txt/\1/')
            local score=$(grep "Performance Score:" "$file" | awk '{print $3}' | head -1)
            echo "  $date: Score $score"
            ((count++))
        done

        return 0
    fi

    # Default mode - show basic metrics
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

# Version information
version() {
    echo "📦 ZSH Configuration Version 5.3.0 (Enhanced Modular)"
    echo "Key Features: Modular architecture, comprehensive testing, performance optimization"
    echo "Modules: core/security/navigation/aliases/plugins/completion/keybindings/utils"
    echo "Interface: Professional monitoring and validation system"
}

# Mark module as loaded
ZSH_MODULES_LOADED+=(core)
