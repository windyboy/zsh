#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Settings - Enhanced
# =============================================================================

# Ensure directories exist
[[ ! -d "$HISTFILE:h" ]] && mkdir -p "$HISTFILE:h"

# ===== History Configuration (Enhanced) =====
# History options (existing settings)
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# New: History optimization options
setopt HIST_EXPIRE_DUPS_FIRST    # Delete old duplicates first
setopt HIST_VERIFY               # Show command before history expansion

# ===== Directory Navigation (Enhanced) =====
# Directory options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# New: Directory navigation enhancement
setopt CDABLE_VARS               # Allow cd to variables

# ===== Global Pattern Matching (Enhanced) =====
# Globbing options
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT

# ===== Spell Correction (Enhanced) =====
# Correction options
setopt CORRECT
setopt CORRECT_ALL

# ===== Job Control (Enhanced) =====
# Job control options
setopt NO_HUP
setopt NO_CHECK_JOBS

# ===== Other Useful Options (Enhanced) =====
# Other useful options
setopt AUTO_PARAM_KEYS
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt HASH_LIST_ALL
setopt INTERACTIVE_COMMENTS

# ===== Disable Annoying Options =====
# Disable annoying options
unsetopt BEEP
unsetopt CASE_GLOB
unsetopt FLOW_CONTROL

# ===== New: Error Handling and Security Options =====
# Basic error handling
setopt PIPE_FAIL                 # Return non-zero status if any command in pipeline fails
# setopt ERR_EXIT                # Exit on error in scripts (not enabled for interactive shells)
# setopt NO_UNSET                # Error on undefined variables (may affect some plugins)

# Security options
setopt NO_CLOBBER                # Prevent overwriting existing files with redirection (use >| to force)
setopt RM_STAR_WAIT              # Wait 10 seconds for confirmation when using rm *

# New: Other practical options
setopt MULTIOS                   # Allow multiple redirections
setopt NOTIFY                    # Report background job status changes immediately

# ===== New: Global Aliases =====
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

# Pipeline-related global aliases
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sort'
alias -g U='| uniq'
alias -g C='| wc -l'

# ===== New: Error Recovery Function =====
recover_from_error() {
    echo "❌ Error occurred in zsh configuration"
    echo "🔧 Try: source ~/.zshrc to reload configuration"
    echo "🆘 Or: zsh -f to start with minimal configuration"
    echo "📋 Or: zsh-check to validate configuration"
}

# ===== New: Core Configuration Validation =====
validate_core_config() {
    local errors=0
    
    # Check history file directory
    if [[ ! -d "$HISTFILE:h" ]]; then
        echo "❌ History directory missing: $HISTFILE:h"
        ((errors++))
    fi
    
    # Check key options
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
