#!/usr/bin/env zsh
# =============================================================================
# Unified Error Handling System
# =============================================================================

# Load logging system
if [[ -f "$ZSH_CONFIG_DIR/modules/logging.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/logging.zsh"
fi

# Error types
typeset -A ERROR_TYPES
ERROR_TYPES=(
    "CONFIG" "Configuration error"
    "PERMISSION" "Permission denied"
    "NOT_FOUND" "File or directory not found"
    "SYNTAX" "Syntax error"
    "DEPENDENCY" "Missing dependency"
    "NETWORK" "Network error"
    "TIMEOUT" "Operation timeout"
    "UNKNOWN" "Unknown error"
)

# Error severity levels
typeset -A ERROR_LEVELS
ERROR_LEVELS=(
    "LOW" "Low severity"
    "MEDIUM" "Medium severity"
    "HIGH" "High severity"
    "CRITICAL" "Critical error"
)

# Error log file
ERROR_LOG_FILE="$ZSH_CACHE_DIR/errors.log"

# Initialize error handling
init_error_handling() {
    # Create error log directory
    [[ ! -d "${ERROR_LOG_FILE:h}" ]] && mkdir -p "${ERROR_LOG_FILE:h}" 2>/dev/null
    
    # Set up error trap (only for critical errors)
    if [[ -z "$ZSH_ERROR_TRAP_SET" ]]; then
        # Only trap critical errors to avoid interfering with normal operations
        export ZSH_ERROR_TRAP_SET=1
    fi
}

# Log error with context
log_error() {
    local error_type="$1"
    local message="$2"
    local severity="${3:-MEDIUM}"
    local module="${4:-unknown}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get error type description
    local type_desc="${ERROR_TYPES[$error_type]:-$error_type}"
    local level_desc="${ERROR_LEVELS[$severity]:-$severity}"
    
    # Log to file
    echo "[$timestamp] [$severity] [$error_type] [$module] $message" >> "$ERROR_LOG_FILE" 2>/dev/null
    
    # Display error based on severity
    case "$severity" in
        "LOW")
            warning "[$module] $message"
            ;;
        "MEDIUM")
            error "[$module] $message"
            ;;
        "HIGH"|"CRITICAL")
            error "❌ CRITICAL: [$module] $message"
            ;;
    esac
}

# Handle specific error types
handle_config_error() {
    local message="$1"
    local module="${2:-config}"
    log_error "CONFIG" "$message" "MEDIUM" "$module"
}

handle_permission_error() {
    local message="$1"
    local module="${2:-system}"
    log_error "PERMISSION" "$message" "HIGH" "$module"
}

handle_not_found_error() {
    local message="$1"
    local module="${2:-file}"
    log_error "NOT_FOUND" "$message" "MEDIUM" "$module"
}

handle_syntax_error() {
    local message="$1"
    local module="${2:-syntax}"
    log_error "SYNTAX" "$message" "HIGH" "$module"
}

handle_dependency_error() {
    local message="$1"
    local module="${2:-dependency}"
    log_error "DEPENDENCY" "$message" "MEDIUM" "$module"
}

# Safe operation wrapper
safe_operation() {
    local operation="$1"
    local description="${2:-Operation}"
    local module="${3:-unknown}"
    
    if eval "$operation" 2>/dev/null; then
        return 0
    else
        local exit_code=$?
        log_error "UNKNOWN" "$description failed (exit code: $exit_code)" "MEDIUM" "$module"
        return $exit_code
    fi
}

# Check for errors in recent operations
check_recent_errors() {
    local hours="${1:-24}"
    local error_log="$ZSH_CACHE_DIR/errors.log"
    
    if [[ ! -f "$error_log" ]]; then
        echo "No error log found"
        return 0
    fi
    
    echo "🔍 Recent Errors (last $hours hours):"
    echo "=================================="
    
    local error_count=0
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            echo "  $line"
            ((error_count++))
        fi
    done < <(tail -n 50 "$error_log" | grep "$(date -d "$hours hours ago" '+%Y-%m-%d')" 2>/dev/null || echo "")
    
    if [[ $error_count -eq 0 ]]; then
        success "No errors found in the last $hours hours"
    else
        warning "$error_count errors found"
    fi
}

# Clear error log
clear_error_log() {
    local error_log="$ZSH_CACHE_DIR/errors.log"
    
    if [[ -f "$error_log" ]]; then
        rm "$error_log"
        success "Error log cleared"
    else
        log "No error log to clear"
    fi
}

# Get error statistics
error_stats() {
    local error_log="$ZSH_CACHE_DIR/errors.log"
    
    if [[ ! -f "$error_log" ]]; then
        echo "No error log found"
        return 0
    fi
    
    echo "📊 Error Statistics"
    echo "=================="
    
    # Count by type
    echo "By Type:"
    for type in "${(@k)ERROR_TYPES}"; do
        local count=$(grep -c "\[$type\]" "$error_log" 2>/dev/null || echo "0")
        if [[ $count -gt 0 ]]; then
            echo "  $type: $count"
        fi
    done
    
    echo ""
    echo "By Severity:"
    for level in "${(@k)ERROR_LEVELS}"; do
        local count=$(grep -c "\[$level\]" "$error_log" 2>/dev/null || echo "0")
        if [[ $count -gt 0 ]]; then
            echo "  $level: $count"
        fi
    done
    
    echo ""
    local total_errors=$(wc -l < "$error_log" 2>/dev/null || echo "0")
    echo "Total errors: $total_errors"
}

# Recovery mode functions
enter_recovery_mode() {
    export ZSH_RECOVERY_MODE=1
    export PATH="/usr/local/bin:/usr/bin:/bin"
    PROMPT='%F{red}[RECOVERY]%f %n@%m:%F{cyan}%~%f %# '
    
    log_error "UNKNOWN" "Entered recovery mode" "HIGH" "system"
    echo "🚨 Entered recovery mode"
    echo "   - Limited PATH: $PATH"
    echo "   - Basic prompt enabled"
    echo "   - Run 'exit_recovery_mode' to exit"
}

exit_recovery_mode() {
    if [[ -n "$ZSH_RECOVERY_MODE" ]]; then
        unset ZSH_RECOVERY_MODE
        source ~/.zshrc
        success "Exited recovery mode"
    else
        log "Not in recovery mode"
    fi
}

# Initialize error handling
init_error_handling 