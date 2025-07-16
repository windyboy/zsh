#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Configuration - Simplified Unified Module
# Version: 4.0 - Simplified and Optimized
# =============================================================================

# =============================================================================
# ENVIRONMENT SETUP
# =============================================================================

# XDG Base Directory Specification
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}"
export ZSH_DATA_DIR="${ZSH_DATA_DIR:-$HOME/.local/share/zsh}"

# Performance tracking
export ZSH_PERF_START=$EPOCHREALTIME
export ZSH_VERBOSE="${ZSH_VERBOSE:-0}"
export ZSH_QUIET="${ZSH_QUIET:-0}"

# Module tracking
export ZSH_MODULES_LOADED=""

# =============================================================================
# UNIFIED LOGGING SYSTEM
# =============================================================================

# Load unified logging system
if [[ -f "$ZSH_CONFIG_DIR/modules/logging.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/logging.zsh"
fi

# Initialize directories
init_directories() {
    local dirs=(
        "$ZSH_CACHE_DIR"
        "$ZSH_DATA_DIR"
        "$ZSH_CONFIG_DIR"
        "$ZSH_CONFIG_DIR/custom"
        "$ZSH_CONFIG_DIR/completions"
    )
    
    for dir in "${dirs[@]}"; do
        [[ ! -d "$dir" ]] && mkdir -p "$dir" && success "Created directory: $dir"
    done
}

# =============================================================================
# SAFE OPERATIONS
# =============================================================================

# Safe source function
safe_source() {
    local file="$1"
    local module="${2:-unknown}"
    
    if [[ -f "$file" ]] && [[ -r "$file" ]]; then
        source "$file" 2>/dev/null
        local result=$?
        
        if [[ $result -ne 0 ]]; then
            error "Failed to source: $file"
        fi
        
        return $result
    else
        error "Cannot read file: $file"
        return 1
    fi
}

# Safe module loading
load_module() {
    local module="$1"
    local module_file="$ZSH_CONFIG_DIR/${module}.zsh"
    
    if [[ -f "$module_file" ]]; then
        if safe_source "$module_file" "$module"; then
            export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED $module"
            success "Module loaded: $module"
            return 0
        else
            error "Failed to load module: $module"
            return 1
        fi
    else
        error "Module not found: $module_file"
        return 1
    fi
}

# =============================================================================
# ERROR HANDLING
# =============================================================================

# Load error handling module
if [[ -f "$ZSH_CONFIG_DIR/modules/errors.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/errors.zsh"
fi

# =============================================================================
# SECURITY SETTINGS
# =============================================================================

# File system security
setopt NO_CLOBBER
setopt RM_STAR_WAIT

# Command execution security
setopt PIPE_FAIL

# History security
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS

# Secure aliases
alias rm='rm -i'
alias rmdir='rmdir -i'
alias ssh='ssh -o StrictHostKeyChecking=yes'
alias scp='scp -o StrictHostKeyChecking=yes'

# Secure umask
umask 022

# =============================================================================
# HISTORY CONFIGURATION
# =============================================================================

# History options
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_SAVE_NO_DUPS
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

# Disable annoying options
unsetopt BEEP
unsetopt CASE_GLOB
unsetopt FLOW_CONTROL

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
# PERFORMANCE MONITORING
# =============================================================================

# Load performance module
if [[ -f "$ZSH_CONFIG_DIR/modules/performance.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/performance.zsh"
fi

# Performance analysis (legacy function for compatibility)
perf() {
    show_performance_dashboard
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Configuration reload
unalias reload 2>/dev/null
reload() {
    echo "🔄 Reloading ZSH configuration..."
    source ~/.zshrc
    echo "✅ Configuration reloaded"
}

# Configuration validation
validate() {
    local errors=0
    
    # Check directories
    local required_dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "❌ Missing directory: $dir"
            ((errors++))
        fi
    done
    
    # Check files
    local required_files=("$ZSH_CONFIG_DIR/zshrc")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "❌ Missing file: $file"
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

# Status check
status() {
    echo "📊 ZSH Status"
    echo "============="
    echo "Config directory: $ZSH_CONFIG_DIR"
    echo "Cache directory: $ZSH_CACHE_DIR"
    echo "Data directory: $ZSH_DATA_DIR"
    echo "Loaded modules: $ZSH_MODULES_LOADED"
    echo "Verbose mode: $ZSH_VERBOSE"
}

# Error reporting
errors() {
    local error_log="$ZSH_CACHE_DIR/system.log"
    if [[ -f "$error_log" ]]; then
        echo "=== Recent Errors ==="
        grep "\[error\]" "$error_log" | tail -10
    else
        echo "No errors found"
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize core module
init_directories
init_error_handling

# Mark core module as loaded
export ZSH_MODULES_LOADED="core"

success "Core module initialized" 