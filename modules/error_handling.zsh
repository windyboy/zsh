#!/usr/bin/env zsh
# =============================================================================
# Error Handling & Recovery Module
# Version: 3.0 - Unified Module System Integration
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Error handling configuration
ERROR_LOG="${ZSH_CACHE_DIR}/error.log"
ERROR_RECOVERY_MODE=false

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize error handling
init_error_handling() {
    # Log error handling initialization (log function will ensure directory)
    log_error "Error handling module initialized" "init"
    if [[ -z "$ERROR_RECOVERY_MODE" ]] && [[ -z "$ZSH_ERROR_TRAP_SET" ]]; then
        trap 'echo "Warning: Error in line $LINENO" >&2' ERR
        export ZSH_ERROR_TRAP_SET=1
    fi
}

# =============================================================================
# ERROR LOGGING
# =============================================================================

# Log error message
log_error() {
    local message="$1"
    local module="${2:-unknown}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Always ensure log directory exists before writing
    [[ ! -d "${ERROR_LOG:h}" ]] && mkdir -p "${ERROR_LOG:h}"
    echo "[$timestamp] [$module] $message" >> "$ERROR_LOG"
    [[ -z "$ZSH_QUIET" ]] && echo "❌ [$module] $message" >&2
}

# Handle specific errors
_handle_error() {
    local exit_code="$1"
    local line_number="$2"
    local module="${3:-unknown}"
    
    log_error "Error occurred (exit code: $exit_code, line: $line_number)" "$module"
    
    case "$exit_code" in
        127) log_error "Command not found - check PATH" "$module" ;;
        126) log_error "Command not executable - check permissions" "$module" ;;
    esac
}

# =============================================================================
# PATH VALIDATION
# =============================================================================

# Check for PATH issues
_check_path_issues() {
    if [[ -z "$PATH" ]]; then
        log_error "PATH is empty!" "core"
        export PATH="/usr/local/bin:/usr/bin:/bin"
    fi
}

# =============================================================================
# SAFE OPERATIONS
# =============================================================================

# Safe source function
safe_source() {
    local file="$1"
    local module="${2:-unknown}"
    
    if [[ -f "$file" ]] && [[ -r "$file" ]]; then
        local old_trap=$(trap -p ERR 2>/dev/null || echo "")
        trap - ERR
        
        source "$file" 2>/dev/null
        local result=$?
        
        if [[ $result -ne 0 ]]; then
            log_error "Failed to source: $file" "$module"
        fi
        
        if [[ -n "$old_trap" ]]; then
            eval "$old_trap"
        fi
        
        return $result
    else
        log_error "Cannot read file: $file" "$module"
        return 1
    fi
}

# Safe module loading
safe_load_module() {
    local module="$1"
    local module_file="${ZSH_CONFIG_DIR}/modules/${module}.zsh"
    
    if [[ -f "$module_file" ]]; then
        if safe_source "$module_file" "$module"; then
            export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED $module"
            return 0
        else
            log_error "Failed to load module: $module" "core"
            return 1
        fi
    else
        log_error "Module not found: $module_file" "core"
        return 1
    fi
}

# =============================================================================
# CONFIGURATION VALIDATION
# =============================================================================

# Validate configuration
validate_configuration() {
    local errors=0
    
    # Check directories
    local required_dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_error "Missing directory: $dir" "validation"
            ((errors++))
        fi
    done
    
    # Check files
    local required_files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/zshenv")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Missing file: $file" "validation"
            ((errors++))
        fi
    done
    
    if (( errors == 0 )); then
        echo "✅ Configuration validation passed"
        return 0
    else
        echo "❌ Configuration validation failed ($errors errors)"
        return 1
    fi
}

# =============================================================================
# RECOVERY MODE
# =============================================================================

# Enter recovery mode
enter_recovery_mode() {
    echo "🚨 Entering recovery mode"
    export PATH="/usr/local/bin:/usr/bin:/bin"
    export ERROR_RECOVERY_MODE=true
    PROMPT='%F{red}[RECOVERY]%f %n@%m:%F{cyan}%~%f %# '
}

# Exit recovery mode
exit_recovery_mode() {
    echo "✅ Exiting recovery mode"
    export ERROR_RECOVERY_MODE=false
    source "$ZSH_CONFIG_DIR/zshrc"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Report recent errors
report_errors() {
    if [[ -f "$ERROR_LOG" ]]; then
        echo "=== Recent Errors ==="
        tail -10 "$ERROR_LOG" 2>/dev/null || echo "No errors found"
    else
        echo "No errors found"
    fi
}

# Clear error log
clear_error_log() {
    [[ -f "$ERROR_LOG" ]] && rm "$ERROR_LOG"
    echo "Error log cleared"
}

# Module error summary
module_error_summary() {
    if [[ -f "$ERROR_LOG" ]]; then
        echo "=== Module Error Summary ==="
        grep -o '\[[^]]*\]' "$ERROR_LOG" | sort | uniq -c | sort -nr
    else
        echo "No errors found"
    fi
}

# =============================================================================
# MODULE-SPECIFIC ERROR HANDLING
# =============================================================================

# Handle plugin errors
handle_plugin_error() {
    local plugin="$1"
    local error="$2"
    log_error "Plugin error: $error" "plugins"
    
    case "$plugin" in
        "zinit")
            echo "💡 Try: rm -rf ~/.local/share/zinit && restart shell"
            ;;
        "fzf")
            echo "💡 Try: brew install fzf (macOS) or apt install fzf (Linux)"
            ;;
        *)
            echo "💡 Check plugin installation and configuration"
            ;;
    esac
}

# Handle completion errors
handle_completion_error() {
    local error="$1"
    log_error "Completion error: $error" "completion"
    
    echo "💡 Try: rm ~/.cache/zsh/zcompdump* && restart shell"
}

# Handle performance errors
handle_performance_error() {
    local error="$1"
    log_error "Performance error: $error" "performance"
    
    echo "💡 Try: ./optimize_performance.zsh optimize"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize error handling
init_error_handling

# Export functions
export -f safe_source safe_load_module validate_configuration enter_recovery_mode exit_recovery_mode report_errors clear_error_log module_error_summary handle_plugin_error handle_completion_error handle_performance_error 2>/dev/null || true 