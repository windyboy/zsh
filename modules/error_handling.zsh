#!/usr/bin/env zsh
# =============================================================================
# Error Handling & Recovery Module
# =============================================================================

# Error handling configuration
ERROR_LOG="${ZSH_CACHE_DIR}/error.log"
ERROR_RECOVERY_MODE=false

# Simple error handling
init_error_handling() {
    # Create error log directory
    [[ ! -d "$ERROR_LOG:h" ]] && mkdir -p "$ERROR_LOG:h"
    
    # Only set error trap if not already set and not in recovery mode
    if [[ -z "$ERROR_RECOVERY_MODE" ]] && [[ -z "$ZSH_ERROR_TRAP_SET" ]]; then
        # Use a more gentle error trap that doesn't stop execution
        trap 'echo "Warning: Error in line $LINENO" >&2' ERR
        export ZSH_ERROR_TRAP_SET=1
    fi
}

# Simple error logging
log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$ERROR_LOG"
    # Only show error message if not in quiet mode
    [[ -z "$ZSH_QUIET" ]] && echo "❌ $message" >&2
}

# Simple error handler
_handle_error() {
    local exit_code="$1"
    local line_number="$2"
    
    log_error "Error occurred (exit code: $exit_code, line: $line_number)"
    
    # Simple recovery for common errors
    case "$exit_code" in
        127) # Command not found
            log_error "Command not found - check PATH"
            ;;
        126) # Command not executable
            log_error "Command not executable - check permissions"
            ;;
    esac
}

# Check for PATH issues
_check_path_issues() {
    if [[ -z "$PATH" ]]; then
        log_error "PATH is empty!"
        export PATH="/usr/local/bin:/usr/bin:/bin"
    fi
}

# Safe source function
safe_source() {
    local file="$1"
    
    if [[ -f "$file" ]] && [[ -r "$file" ]]; then
        # Temporarily disable error trap during sourcing
        local old_trap=$(trap -p ERR 2>/dev/null || echo "")
        trap - ERR
        
        source "$file" 2>/dev/null
        local result=$?
        
        # Restore error trap if it existed
        if [[ -n "$old_trap" ]]; then
            eval "$old_trap"
        fi
        
        return $result
    fi
    return 1
}

# Configuration validation
validate_configuration() {
    local errors=0
    
    # Check essential directories
    local required_dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    for dir in "${required_dirs[@]}"; do
        [[ -d "$dir" ]] || { log_error "Missing directory: $dir"; ((errors++)); }
    done
    
    # Check essential files
    local required_files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/zshenv")
    for file in "${required_files[@]}"; do
        [[ -f "$file" ]] || { log_error "Missing file: $file"; ((errors++)); }
    done
    
    if (( errors == 0 )); then
        echo "✅ Configuration validation passed"
        return 0
    else
        echo "❌ Configuration validation failed ($errors errors)"
        return 1
    fi
}

# Simple recovery mode
enter_recovery_mode() {
    echo "🚨 Entering recovery mode"
    export PATH="/usr/local/bin:/usr/bin:/bin"
    PROMPT='%F{red}[RECOVERY]%f %n@%m:%F{cyan}%~%f %# '
}

# Exit recovery mode
exit_recovery_mode() {
    echo "✅ Exiting recovery mode"
    source "$ZSH_CONFIG_DIR/zshrc"
}

# Error reporting function
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

# Initialize error handling
init_error_handling

# Export functions
export -f safe_source validate_configuration enter_recovery_mode exit_recovery_mode report_errors clear_error_log 2>/dev/null || true 