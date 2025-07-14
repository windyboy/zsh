#!/usr/bin/env zsh
# =============================================================================
# Security Module - Unified Module System Integration
# Version: 3.0 - Comprehensive Security Features
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Security configuration
SECURITY_LOG="${ZSH_CACHE_DIR}/security.log"
SECURITY_AUDIT_FILE="${ZSH_CACHE_DIR}/security_audit.json"

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize security module
init_security() {
    # Log security module initialization (log function will ensure directory)
    log_security_event "Security module initialized"
}

# =============================================================================
# FILE SYSTEM SECURITY
# =============================================================================

# Prevent accidental file overwrites
setopt NO_CLOBBER

# Confirm before removing files with wildcards
setopt RM_STAR_WAIT

# Prevent accidental directory removal
alias rm='rm -i'
alias rmdir='rmdir -i'

# =============================================================================
# COMMAND EXECUTION SECURITY
# =============================================================================

# Fail on any command in pipeline that fails
setopt PIPE_FAIL

# =============================================================================
# HISTORY SECURITY
# =============================================================================

# Don't save commands starting with space
setopt HIST_IGNORE_SPACE

# Don't save duplicate commands
setopt HIST_IGNORE_ALL_DUPS

# =============================================================================
# NETWORK SECURITY
# =============================================================================

# Secure SSH configuration
alias ssh='ssh -o StrictHostKeyChecking=yes'

# Secure SCP
alias scp='scp -o StrictHostKeyChecking=yes'

# =============================================================================
# DEVELOPMENT SECURITY
# =============================================================================

# Git security
alias git='git -c core.fileMode=false'

# Docker security
if command -v docker >/dev/null 2>&1; then
    alias docker='docker --tlsverify'
fi

# =============================================================================
# SECURITY LOGGING
# =============================================================================

# Log security events
log_security_event() {
    local event="$1"
    local level="${2:-info}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Always ensure log directory exists before writing
    [[ ! -d "${SECURITY_LOG:h}" ]] && mkdir -p "${SECURITY_LOG:h}"
    echo "[$timestamp] [$level] $event" >> "$SECURITY_LOG"
}

# =============================================================================
# SECURITY FUNCTIONS
# =============================================================================

# Check for suspicious files
check_suspicious_files() {
    log_security_event "Starting suspicious file check"
    
    echo "🔍 Checking for suspicious files..."
    
    # Check for files with unusual permissions
    find . -type f -perm /0111 -ls 2>/dev/null | head -10
    
    # Check for hidden files
    find . -name ".*" -type f -ls 2>/dev/null | head -10
    
    # Check for files with no extension
    find . -type f ! -name "*.*" -ls 2>/dev/null | head -10
    
    log_security_event "Suspicious file check completed"
}

# Secure file operations
secure_rm() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: secure_rm <file1> [file2] ..."
        return 1
    fi
    
    log_security_event "Secure deletion started"
    
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            echo "Securely removing: $file"
            # Overwrite with zeros before deletion
            dd if=/dev/zero of="$file" bs=1M count=1 2>/dev/null
            rm -f "$file"
            log_security_event "Securely deleted: $file"
        else
            echo "File not found: $file"
            log_security_event "Failed to delete (not found): $file" "warning"
        fi
    done
}

# Security audit
security_audit() {
    log_security_event "Security audit started"
    
    echo "🔒 Security Audit"
    echo "================"
    
    local issues=0
    
    # Check file permissions
    echo "📁 Checking file permissions..."
    local world_writable=$(find ~/.config/zsh -type f -perm -002 2>/dev/null | wc -l)
    if (( world_writable > 0 )); then
        echo "⚠️  Found $world_writable world-writable files"
        ((issues++))
    fi
    
    # Check for setuid/setgid files
    echo "🔐 Checking setuid/setgid files..."
    local setuid_files=$(find ~/.config/zsh -type f -perm -4000 -o -perm -2000 2>/dev/null | wc -l)
    if (( setuid_files > 0 )); then
        echo "⚠️  Found $setuid_files setuid/setgid files"
        ((issues++))
    fi
    
    # Check security options
    echo "🛡️  Checking security options..."
    local security_options=("NO_CLOBBER" "RM_STAR_WAIT" "PIPE_FAIL")
    for opt in "${security_options[@]}"; do
        if [[ ! -o "$opt" ]]; then
            echo "❌ Security option not set: $opt"
            ((issues++))
        fi
    done
    
    # Check PATH security
    echo "🛣️  Checking PATH security..."
    if [[ "$PATH" == *"::"* ]]; then
        echo "⚠️  PATH contains empty entries"
        ((issues++))
    fi
    
    if (( issues == 0 )); then
        echo "✅ Security audit passed"
        log_security_event "Security audit passed"
    else
        echo "❌ Security audit failed ($issues issues)"
        log_security_event "Security audit failed with $issues issues" "warning"
    fi
    
    return $issues
}

# =============================================================================
# SECURITY ALIASES
# =============================================================================

# Secure file viewing
alias view='view -R'

# Secure file editing
alias vi='vi -R'

# Secure directory listing
alias lsa='ls -la --time-style=long-iso'

# =============================================================================
# SECURITY ENVIRONMENT
# =============================================================================

# Secure umask
umask 022

# Secure file creation
export TMPDIR="/tmp/$(whoami)-$(date +%s)"

# =============================================================================
# SECURITY VALIDATION
# =============================================================================

# Validate security configuration
validate_security_config() {
    local errors=0
    
    # Check security options
    local required_options=("NO_CLOBBER" "RM_STAR_WAIT" "PIPE_FAIL")
    
    for opt in "${required_options[@]}"; do
        if [[ ! -o "$opt" ]]; then
            echo "❌ $opt not set"
            ((errors++))
        fi
    done
    
    # Check security aliases
    local required_aliases=("rm" "rmdir" "ssh" "scp")
    for alias_name in "${required_aliases[@]}"; do
        if ! alias "$alias_name" >/dev/null 2>&1; then
            echo "❌ Security alias not set: $alias_name"
            ((errors++))
        fi
    done
    
    if (( errors == 0 )); then
        echo "✅ Security configuration validated"
        log_security_event "Security configuration validated"
        return 0
    else
        echo "❌ Security configuration has $errors issues"
        log_security_event "Security configuration validation failed with $errors issues" "warning"
        return 1
    fi
}

# =============================================================================
# MODULE-SPECIFIC SECURITY
# =============================================================================

# Plugin security validation
validate_plugin_security() {
    local plugin="$1"
    log_security_event "Validating plugin security: $plugin"
    
    case "$plugin" in
        "zinit")
            # Check zinit installation
            if [[ ! -d "$HOME/.local/share/zinit" ]]; then
                log_security_event "Zinit not properly installed" "warning"
                return 1
            fi
            ;;
        "fzf")
            # Check fzf installation
            if ! command -v fzf >/dev/null 2>&1; then
                log_security_event "FZF not installed" "warning"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Completion security validation
validate_completion_security() {
    log_security_event "Validating completion security"
    
    # Check completion cache permissions
    local comp_cache="$ZSH_CACHE_DIR/zcompdump"
    if [[ -f "$comp_cache" ]]; then
        local perms=$(stat -c "%a" "$comp_cache" 2>/dev/null || stat -f "%Lp" "$comp_cache" 2>/dev/null)
        if [[ "$perms" != "600" ]]; then
            log_security_event "Completion cache has insecure permissions: $perms" "warning"
            return 1
        fi
    fi
    
    return 0
}

# =============================================================================
# SECURITY MONITORING
# =============================================================================

# Monitor security events
monitor_security() {
    echo "🔍 Security Monitoring"
    echo "====================="
    
    # Recent security events
    if [[ -f "$SECURITY_LOG" ]]; then
        echo "Recent security events:"
        tail -5 "$SECURITY_LOG" | sed 's/^/  /'
    fi
    
    # Security audit summary
    if [[ -f "$SECURITY_AUDIT_FILE" ]]; then
        echo "Last security audit:"
        cat "$SECURITY_AUDIT_FILE" | head -10
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize security module
init_security

# Export security functions
export -f check_suspicious_files secure_rm security_audit validate_security_config validate_plugin_security validate_completion_security monitor_security 2>/dev/null || true 