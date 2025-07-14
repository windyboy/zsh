#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Settings - Foundation Module
# Version: 3.0 - Unified Module System Foundation
# =============================================================================

# =============================================================================
# MODULE SYSTEM INITIALIZATION
# =============================================================================

# Module tracking
export ZSH_MODULES_LOADED=""
export ZSH_MODULE_LOAD_START=$EPOCHREALTIME

# Module loading helper
load_module() {
    local module="$1"
    local module_file="${ZSH_CONFIG_DIR}/modules/${module}.zsh"
    
    if [[ -f "$module_file" ]]; then
        source "$module_file"
        export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED $module"
        return 0
    else
        echo "⚠️  Module not found: $module_file" >&2
        return 1
    fi
}

# Module status checker
module_loaded() {
    [[ " $ZSH_MODULES_LOADED " == *" $1 "* ]]
}

# =============================================================================
# DIRECTORY SETUP
# =============================================================================

# Ensure history directory exists
[[ ! -d "$HISTFILE:h" ]] && mkdir -p "$HISTFILE:h"

# =============================================================================
# HISTORY CONFIGURATION
# =============================================================================

# History options
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_VERIFY

# =============================================================================
# DIRECTORY NAVIGATION
# =============================================================================

# Directory options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt CDABLE_VARS

# =============================================================================
# GLOBBING AND PATTERN MATCHING
# =============================================================================

# Globbing options
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT

# =============================================================================
# SPELL CORRECTION
# =============================================================================

# Correction options
setopt CORRECT
setopt CORRECT_ALL

# =============================================================================
# JOB CONTROL
# =============================================================================

# Job control options
setopt NO_HUP
setopt NO_CHECK_JOBS

# =============================================================================
# OTHER USEFUL OPTIONS
# =============================================================================

# General options
setopt AUTO_PARAM_KEYS
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt HASH_LIST_ALL
setopt INTERACTIVE_COMMENTS
setopt MULTIOS
setopt NOTIFY

# =============================================================================
# DISABLED OPTIONS
# =============================================================================

# Disable annoying options
unsetopt BEEP
unsetopt CASE_GLOB
unsetopt FLOW_CONTROL

# =============================================================================
# SECURITY AND ERROR HANDLING
# =============================================================================

# Security options
setopt NO_CLOBBER
setopt RM_STAR_WAIT

# Error handling
setopt PIPE_FAIL

# =============================================================================
# GLOBAL ALIASES
# =============================================================================

# Directory navigation
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

# Pipeline shortcuts
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sort'
alias -g U='| uniq'
alias -g C='| wc -l'

# =============================================================================
# CORE UTILITY FUNCTIONS
# =============================================================================

# Error recovery
recover_from_error() {
    echo "❌ Error in zsh configuration"
    echo "🔧 Try: source ~/.zshrc"
    echo "🆘 Or: zsh -f for minimal config"
}

# Core configuration validation
validate_core_config() {
    local errors=0
    
    # Check history directory
    if [[ ! -d "$HISTFILE:h" ]]; then
        echo "❌ History directory missing: $HISTFILE:h"
        ((errors++))
    fi
    
    # Check required options
    local required_options=(
        "EXTENDED_HISTORY"
        "SHARE_HISTORY" 
        "AUTO_CD"
        "EXTENDED_GLOB"
    )
    
    for opt in "${required_options[@]}"; do
        if [[ ! -o "$opt" ]]; then
            echo "❌ Required option not set: $opt"
            ((errors++))
        fi
    done
    
    return $errors
}

# Module system validation
validate_module_system() {
    local errors=0
    
    # Check if modules are loaded
    if [[ -z "$ZSH_MODULES_LOADED" ]]; then
        echo "❌ No modules loaded"
        ((errors++))
    fi
    
    # Check essential modules
    local essential_modules=("core" "error_handling" "security")
    for module in "${essential_modules[@]}"; do
        if ! module_loaded "$module"; then
            echo "❌ Essential module not loaded: $module"
            ((errors++))
        fi
    done
    
    return $errors
}

# =============================================================================
# MODULE SYSTEM UTILITIES
# =============================================================================

# List loaded modules
list_modules() {
    echo "📦 Loaded modules:"
    for module in $ZSH_MODULES_LOADED; do
        echo "  • $module"
    done
}

# Check module dependencies
check_module_dependencies() {
    echo "🔍 Checking module dependencies..."
    
    # Core dependencies
    if ! module_loaded "core"; then
        echo "❌ Core module not loaded"
        return 1
    fi
    
    # Plugin dependencies
    if module_loaded "plugins" && ! command -v zinit >/dev/null 2>&1; then
        echo "⚠️  Plugins module loaded but zinit not found"
    fi
    
    # Completion dependencies
    if module_loaded "completion" && ! autoload -Uz compinit 2>/dev/null; then
        echo "⚠️  Completion module loaded but compinit not available"
    fi
    
    echo "✅ Module dependencies checked"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Mark core module as loaded
export ZSH_MODULES_LOADED="core"

# Export functions
export -f recover_from_error validate_core_config validate_module_system list_modules check_module_dependencies module_loaded 2>/dev/null || true
