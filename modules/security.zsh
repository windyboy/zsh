#!/usr/bin/env zsh
# =============================================================================
# Security Module - Security Settings and History Management
# Description: Security configurations, history settings, and safe defaults
# =============================================================================

# Color output tools
source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# Module specific wrappers
security_color_red()   { color_red "$@"; }
security_color_green() { color_green "$@"; }

# -------------------- Security Settings --------------------
# Safe file operations
alias rm='rm -i' cp='cp -i' mv='mv -i'

# Secure umask
umask 022

# Prevent accidental overwrites
setopt NO_CLOBBER RM_STAR_WAIT PIPE_FAIL

# -------------------- History Configuration --------------------
# History file location (set in zshenv)
# export HISTFILE="${ZSH_DATA_DIR}/history"

# History behavior
setopt HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS
setopt APPEND_HISTORY SHARE_HISTORY HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_VERIFY

# History size (set in zshenv)
# export HISTSIZE=50000
# export SAVEHIST=50000

# -------------------- Security Functions --------------------
# Check for dangerous aliases
security_check_aliases() {
    local dangerous_aliases=()
    
    # Check for unsafe rm alias
    if alias | grep -q '^alias rm=' && ! alias rm | grep -q 'rm -i'; then
        dangerous_aliases+=("rm (not using -i flag)")
    fi
    
    # Check for eval usage
    if alias | grep -q 'eval'; then
        dangerous_aliases+=("eval usage detected")
    fi
    
    # Report dangerous aliases
    if [[ ${#dangerous_aliases[@]} -gt 0 ]]; then
        security_color_red "⚠️  Dangerous aliases detected:"
        for alias in "${dangerous_aliases[@]}"; do
            echo "  - $alias"
        done
        return 1
    else
        security_color_green "✅ All aliases are safe"
        return 0
    fi
}

# Validate file permissions
security_check_permissions() {
    local files=(
        "$ZSH_CONFIG_DIR/zshrc"
        "$ZSH_CONFIG_DIR/zshenv"
        "$ZSH_CONFIG_DIR/modules/core.zsh"
        "$ZSH_CONFIG_DIR/modules/security.zsh"
        "$ZSH_CONFIG_DIR/modules/navigation.zsh"
    )
    
    local insecure_files=()
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            local perms=$(stat -c %a "$file" 2>/dev/null || stat -f %Lp "$file" 2>/dev/null)
            if [[ $perms -gt 644 ]]; then
                insecure_files+=("$file ($perms)")
            fi
        fi
    done
    
    if [[ ${#insecure_files[@]} -gt 0 ]]; then
        security_color_red "⚠️  Insecure file permissions detected:"
        for file in "${insecure_files[@]}"; do
            echo "  - $file"
        done
        return 1
    else
        security_color_green "✅ All file permissions are secure"
        return 0
    fi
}

# Fix security issues
security_fix_issues() {
    security_color_green "🔧 Fixing security issues..."
    
    # Fix file permissions
    local files=(
        "$ZSH_CONFIG_DIR/zshrc"
        "$ZSH_CONFIG_DIR/zshenv"
        "$ZSH_CONFIG_DIR/modules/core.zsh"
        "$ZSH_CONFIG_DIR/modules/security.zsh"
        "$ZSH_CONFIG_DIR/modules/navigation.zsh"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            chmod 644 "$file" 2>/dev/null && echo "  ✅ Fixed permissions: $file"
        fi
    done
    
    # Ensure safe aliases
    alias rm='rm -i' 2>/dev/null && echo "  ✅ Ensured safe rm alias"
    
    security_color_green "✅ Security fixes applied"
}

# Security validation
security_validate() {
    local errors=0
    
    security_color_green "🔒 Security Validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check aliases
    if ! security_check_aliases; then
        ((errors++))
    fi
    
    # Check permissions
    if ! security_check_permissions; then
        ((errors++))
    fi
    
    # Check history configuration
    if [[ -z "$HISTFILE" ]]; then
        security_color_red "❌ HISTFILE not set"
        ((errors++))
    else
        security_color_green "✅ HISTFILE: $HISTFILE"
    fi
    
    if [[ -z "$HISTSIZE" ]]; then
        security_color_red "❌ HISTSIZE not set"
        ((errors++))
    else
        security_color_green "✅ HISTSIZE: $HISTSIZE"
    fi
    
    echo
    if [[ $errors -eq 0 ]]; then
        security_color_green "✅ Security validation passed"
        return 0
    else
        security_color_red "❌ Security validation failed: $errors errors"
        return 1
    fi
}

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED security" 