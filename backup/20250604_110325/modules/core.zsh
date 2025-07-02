#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Settings
# =============================================================================

# Ensure directories exist
[[ ! -d "$HISTFILE:h" ]] && mkdir -p "$HISTFILE:h"

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

# Directory options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Globbing options
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT

# Correction options
setopt CORRECT
setopt CORRECT_ALL

# Job control options
setopt NO_HUP
setopt NO_CHECK_JOBS

# Other useful options
setopt AUTO_PARAM_KEYS
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt HASH_LIST_ALL
setopt INTERACTIVE_COMMENTS

# Disable annoying options
unsetopt BEEP
unsetopt CASE_GLOB
unsetopt FLOW_CONTROL
