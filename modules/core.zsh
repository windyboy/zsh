#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Configuration - Essential Core Settings
# Description: Core functionality, validation, and performance monitoring
# =============================================================================

# Performance Thresholds (Constants)
(( ${+ZSH_MAX_FUNCTIONS} ))   || typeset -g ZSH_MAX_FUNCTIONS=200      # Maximum recommended functions
(( ${+ZSH_MAX_ALIASES} ))     || typeset -g ZSH_MAX_ALIASES=100        # Maximum recommended aliases
(( ${+ZSH_MAX_MEMORY_MB} ))    || typeset -g ZSH_MAX_MEMORY_MB=10       # Maximum memory usage in MB
(( ${+ZSH_MAX_STARTUP_SEC} ))  || typeset -g ZSH_MAX_STARTUP_SEC=2      # Maximum startup time in seconds
(( ${+ZSH_CACHE_TTL} ))        || typeset -g ZSH_CACHE_TTL=86400        # Cache TTL in seconds (24 hours)

# Color output tools - colors module should be loaded before core
# source "$ZSH_CONFIG_DIR/modules/colors.zsh"  # Moved to zshrc loading order

# Shared validation helpers
source "$ZSH_CONFIG_DIR/modules/lib/validation.zsh"

# -------------------- Security Settings --------------------
# Safe file operations with extra protections for rm
safe_rm() {
    (( $# )) || { echo "Usage: rm <path> [...]"; return 1 }

    local -a reasons=()
    local target abs_target confirm owner
    zmodload -F zsh/stat b:zstat 2>/dev/null

    for target in "$@"; do
        [[ "$target" == -* || ! -e "$target" ]] && continue
        abs_target="${target:A}"

        [[ -d "$target" ]] && reasons+=("directory: $target")
        [[ "$abs_target" != "$HOME"/* && "$abs_target" != "$HOME" ]] && reasons+=("outside home: $target")
        [[ "$abs_target" != "$PWD"/* && "$abs_target" != "$PWD" ]] && reasons+=("outside current directory: $target")

        if zstat -H owner +owner "$target" 2>/dev/null; then
            [[ "$owner" != "$USER" ]] && reasons+=("owner $owner ≠ $USER: $target")
        fi
    done

    if (( ${#reasons} )); then
        color_yellow "⚠️  rm safety check"
        printf '  - %s\n' "${reasons[@]}"
        read -r "?Proceed with rm? [y/N]: " confirm
        [[ "$confirm" != [Yy]* ]] && { color_red "Deletion cancelled"; return 1 }
    fi

    command rm -i "$@"
}

alias rm='safe_rm' cp='cp -i' mv='mv -i'

# Secure umask
umask 022

# -------------------- Directory Initialization --------------------
core_init_dirs() {
    local dir dirs=("$ZSH_CACHE_DIR" "$ZSH_DATA_DIR" "$ZSH_CONFIG_DIR/completions")
    for dir in $dirs; do
        [[ -d "$dir" ]] && continue
        if mkdir -p "$dir" 2>/dev/null; then
            (( ${+functions[color_green]} )) && color_green "Created: $dir" || echo "Created: $dir"
        else
            echo "Warning: Failed to create directory: $dir" >&2
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
    case "$1" in
        -h|--help)
            echo "Usage: reload [--module <name>] [--config]"
            echo "  reload                # Reload all configuration (default)"
            echo "  reload --module <mod> # Reload a specific module"
            echo "  reload --config       # Reload zshrc/zshenv only"
            return 0
            ;;
        --module)
            [[ -z "$2" ]] && { color_red "❌ Module name required"; return 1 }
            local modfile="$ZSH_CONFIG_DIR/modules/$2.zsh"
            if [[ -f "$modfile" ]]; then
                source "$modfile" && color_green "✅ Reloaded module: $2"
            else
                color_red "❌ Module not found: $2"
                return 1
            fi
            ;;
        --config)
            source "$ZSH_CONFIG_DIR/zshenv"
            source "$ZSH_CONFIG_DIR/zshrc"
            color_green "✅ Reloaded zshrc and zshenv"
            ;;
        *)
            echo "🔄 Reloading all ZSH configuration..."
            source "$ZSH_CONFIG_DIR/zshrc"
            color_green "✅ Configuration reloaded"
            ;;
    esac
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
    printf "  %-18s %s\n" "ZSH Version:" "$(zsh --version | cut -d' ' -f2)"
    printf "  %-18s %s\n" "Config Dir:" "$ZSH_CONFIG_DIR"
    printf "  %-18s %s\n" "Cache Dir:" "$ZSH_CACHE_DIR"
    printf "  %-18s %s\n" "Data Dir:" "$ZSH_DATA_DIR"
    # Filter unique modules and handle potential space-separated string elements
    local -a unique_mods
    unique_mods=(${(u)ZSH_MODULES_LOADED})
    printf "  %-18s %s\n" "Loaded Modules:" "${(j:, :)unique_mods}"
}

# Performance check
perf() {
    local -A opts
    zparseopts -D -E -A opts h -help modules memory startup m -monitor p -profile o -optimize history

    if [[ -n "${opts[(i)-h]}" || -n "${opts[(i)--help]}" ]]; then
        echo "Usage: perf [options]"
        echo "Options: --modules, --memory, --startup, --monitor (-m), --profile (-p), --optimize (-o), --history"
        return 0
    fi

    # Core metrics
    local func_count=${#functions} alias_count=${#aliases}
    local memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {print $1}')
    local memory_mb=$(printf "%.1f" $(( ${memory_kb:-0} / 1024.0 )))
    local startup_time="${ZSH_STARTUP_TIME:-0}"
    local score=100
    (( func_count > ZSH_MAX_FUNCTIONS )) && (( score -= 10 ))
    (( alias_count > ZSH_MAX_ALIASES ))   && (( score -= 10 ))
    (( ${memory_mb%.*} > ZSH_MAX_MEMORY_MB )) && (( score -= 20 ))
    (( ${startup_time%.*} >= ZSH_MAX_STARTUP_SEC )) && (( score -= 20 ))

    # Default report
    if (( $# == 0 )); then
        echo "🚀 ZSH Performance: $score/100"
        printf "  %-12s %d (max %d)\n" "Functions:" "$func_count" "$ZSH_MAX_FUNCTIONS"
        printf "  %-12s %d (max %d)\n" "Aliases:" "$alias_count" "$ZSH_MAX_ALIASES"
        printf "  %-12s %s MB (max %d)\n" "Memory:" "$memory_mb" "$ZSH_MAX_MEMORY_MB"
        printf "  %-12s %s s (max %d)\n" "Startup:" "$startup_time" "$ZSH_MAX_STARTUP_SEC"
        
        if (( score >= 90 )); then color_green "Excellent performance"
        elif (( score >= 70 )); then color_yellow "Good performance"
        else color_red "Needs optimization"; fi
        return
    fi

    # Module breakdown
    if [[ -n "${opts[(i)--modules]}" ]]; then
        echo "📦 Module Breakdown"
        for modfile in "$ZSH_CONFIG_DIR"/modules/*.zsh; do
            local mod="${${modfile:t}%.zsh}"
            local lines=$(wc -l < "$modfile")
            local funcs=$(grep -E '^[[:space:]]*[_[:alnum:]]+\(\)' "$modfile" | wc -l)
            local icon="⚠️"
            [[ " ${ZSH_MODULES_LOADED[*]} " == *" $mod "* ]] && icon="✅"
            printf "  %s %-15s %4d lines | %3d funcs\n" "$icon" "$mod" "$lines" "$funcs"
        done
    fi

    # Memory details
    if [[ -n "${opts[(i)--memory]}" ]]; then
        echo "💾 Memory Analysis"
        ps -p $$ -o rss,vsz,pmem,args 2>/dev/null
    fi

    # Monitor mode
    if [[ -n "${opts[(i)-m]}" || -n "${opts[(i)--monitor]}" ]]; then
        echo "📊 Monitoring (Ctrl+C to stop)..."
        while true; do
            printf "\r[%s] Score: %d | Memory: %sMB | Funcs: %d" "$(date +%T)" "$score" "$memory_mb" "$func_count"
            sleep 2
        done
    fi

    # Profile mode
    if [[ -n "${opts[(i)-p]}" || -n "${opts[(i)--profile]}" ]]; then
        local pfile="$ZSH_CACHE_DIR/perf_$(date +%Y%m%d_%H%M%S).log"
        {
            echo "ZSH Perf Profile - $(date)"
            echo "Score: $score"
            echo "Metrics: $func_count funcs, $alias_count aliases, $memory_mb MB, $startup_time s"
        } > "$pfile"
        echo "Profile saved: $pfile"
    fi

    # Optimize mode
    if [[ -n "${opts[(i)-o]}" || -n "${opts[(i)--optimize]}" ]]; then
        echo "🔧 Recommendations"
        (( func_count > ZSH_MAX_FUNCTIONS )) && echo "  - Reduce functions (current $func_count > $ZSH_MAX_FUNCTIONS)"
        (( alias_count > ZSH_MAX_ALIASES )) && echo "  - Reduce aliases (current $alias_count > $ZSH_MAX_ALIASES)"
        (( ${memory_mb%.*} > ZSH_MAX_MEMORY_MB )) && echo "  - Reduce memory usage (current $memory_mb > $ZSH_MAX_MEMORY_MB)"
        (( score >= 90 )) && color_green "No major optimizations needed."
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
