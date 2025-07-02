#!/usr/bin/env zsh
# =============================================================================
# Security Module - Essential Security Features
# =============================================================================

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

# Don't execute commands with syntax errors (commented out - not a valid option)
# setopt NO_EXEC

# Don't allow empty commands (commented out - not a valid option)
# setopt NO_EMPTY_CMDS

# =============================================================================
# HISTORY SECURITY
# =============================================================================

# Don't save commands starting with space
setopt HIST_IGNORE_SPACE

# Don't save duplicate commands
setopt HIST_IGNORE_ALL_DUPS

# Don't save commands with leading space (for sensitive data)
setopt HIST_IGNORE_SPACE

# =============================================================================
# ENVIRONMENT SECURITY
# =============================================================================

# Prevent unset variables from being used
# setopt NO_UNSET  # Commented out as it may break some plugins

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
# SECURITY FUNCTIONS
# =============================================================================

# Check for suspicious files
check_suspicious_files() {
    echo "🔍 Checking for suspicious files..."
    
    # Check for files with unusual permissions
    find . -type f -perm /0111 -ls 2>/dev/null | head -10
    
    # Check for hidden files
    find . -name ".*" -type f -ls 2>/dev/null | head -10
    
    # Check for files with no extension
    find . -type f ! -name "*.*" -ls 2>/dev/null | head -10
}

# Secure file operations
secure_rm() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: secure_rm <file1> [file2] ..."
        return 1
    fi
    
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            echo "Securely removing: $file"
            # Overwrite with zeros before deletion
            dd if=/dev/zero of="$file" bs=1M count=1 2>/dev/null
            rm -f "$file"
        else
            echo "File not found: $file"
        fi
    done
}

# Check for security issues
security_audit() {
    echo "🔒 Security Audit"
    echo "================"
    
    # Check file permissions
    echo "📁 Checking file permissions..."
    find ~/.config/zsh -type f -exec ls -la {} \; 2>/dev/null | grep -E "^-rwx|^-rw-rw-rw"
    
    # Check for world-writable files
    echo "🌍 Checking world-writable files..."
    find ~/.config/zsh -type f -perm -002 -ls 2>/dev/null
    
    # Check for setuid/setgid files
    echo "🔐 Checking setuid/setgid files..."
    find ~/.config/zsh -type f -perm -4000 -o -perm -2000 -ls 2>/dev/null
}

# =============================================================================
# SECURITY ALIASES
# =============================================================================

# Secure file viewing
alias view='view -R'  # Read-only mode

# Secure file editing
alias vi='vi -R'      # Read-only mode for unknown files

# Secure directory listing
alias lsa='ls -la --time-style=long-iso'

# =============================================================================
# SECURITY ENVIRONMENT VARIABLES
# =============================================================================

# Secure umask
umask 022

# Secure file creation
export TMPDIR="/tmp/$(whoami)-$(date +%s)"

# =============================================================================
# SECURITY VALIDATION
# =============================================================================

validate_security_config() {
    local errors=0
    
    # Check if security options are set
    if [[ ! -o NO_CLOBBER ]]; then
        echo "❌ NO_CLOBBER not set"
        ((errors++))
    fi
    
    if [[ ! -o RM_STAR_WAIT ]]; then
        echo "❌ RM_STAR_WAIT not set"
        ((errors++))
    fi
    
    if [[ ! -o PIPE_FAIL ]]; then
        echo "❌ PIPE_FAIL not set"
        ((errors++))
    fi
    
    if (( errors == 0 )); then
        echo "✅ Security configuration validated"
        return 0
    else
        echo "❌ Security configuration has $errors issues"
        return 1
    fi
}

# Export security functions
export -f check_suspicious_files secure_rm security_audit validate_security_config 2>/dev/null || true 