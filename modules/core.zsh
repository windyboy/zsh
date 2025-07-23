#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Configuration - Environment Core Settings
# Description: Only essential, high-frequency, minimal core environment configuration with clear comments and unified naming.
# =============================================================================

# Color output tools
# Load centralized color functions if available
if [[ -f "$HOME/.config/zsh/modules/colors.zsh" ]]; then
    source "$HOME/.config/zsh/modules/colors.zsh"
else
    # Fallback color functions
    color_red()   { echo -e "\033[31m$1\033[0m"; }
    color_green() { echo -e "\033[32m$1\033[0m"; }
fi

# -------------------- Module Loading Status --------------------
export ZSH_MODULES_LOADED=""

# -------------------- Directory Initialization --------------------
core_init_dirs() {
    local dirs=("$ZSH_CACHE_DIR" "$ZSH_DATA_DIR" "$ZSH_CONFIG_DIR/custom" "$ZSH_CONFIG_DIR/completions")
    for dir in "${dirs[@]}"; do
        [[ ! -d "$dir" ]] && mkdir -p "$dir" 2>/dev/null && core_color_green "Created: $dir"
    done
}
core_init_dirs

# -------------------- Security/History/Navigation --------------------
setopt NO_CLOBBER RM_STAR_WAIT PIPE_FAIL
setopt HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS
alias rm='rm -i' cp='cp -i' mv='mv -i'
umask 022
setopt APPEND_HISTORY SHARE_HISTORY HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_VERIFY
# History configuration is now handled by environment variables
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT CDABLE_VARS
setopt EXTENDED_GLOB NO_CASE_GLOB NUMERIC_GLOB_SORT
setopt CORRECT CORRECT_ALL
setopt NO_HUP NO_CHECK_JOBS
setopt AUTO_PARAM_KEYS AUTO_PARAM_SLASH COMPLETE_IN_WORD HASH_LIST_ALL
setopt INTERACTIVE_COMMENTS MULTIOS NOTIFY
unsetopt BEEP CASE_GLOB FLOW_CONTROL

# -------------------- Global Aliases --------------------
alias -g ...='../..' ....='../../..' .....='../../../..' ......='../../../../..'
alias -g G='| grep' L='| less' H='| head' T='| tail' S='| sort' U='| uniq' C='| wc -l'

# -------------------- Common Functions --------------------
# Reload configuration
reload() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "Usage: reload" && return 0
    echo "🔄 Reloading ZSH configuration..."
    source ~/.zshrc && core_color_green "✅ Configuration reloaded"
}
# Configuration validation
validate() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "Usage: validate" && return 0
    local errors=0
    local required_dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    local core_files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/modules/core.zsh")
    for dir in "${required_dirs[@]}"; do [[ ! -d "$dir" ]] && core_color_red "❌ Missing directory: $dir" && ((errors++)); done
    for file in "${core_files[@]}"; do [[ ! -f "$file" ]] && core_color_red "❌ Missing file: $file" && ((errors++)); done
    (( errors == 0 )) && core_color_green "Configuration validation passed" || core_color_red "Configuration validation failed: $errors errors"
    return $errors
}
# System status
status() {
    echo "📊 Status"
    echo "ZSH Version: $(zsh --version | head -1)"
    echo "Config Directory: $ZSH_CONFIG_DIR"
    echo "Cache Directory: $ZSH_CACHE_DIR"
    echo "Data Directory: $ZSH_DATA_DIR"
    echo "Loaded Modules: $ZSH_MODULES_LOADED"
}
# Performance check
perf() {
    local func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
    local alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
    local memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
    echo "Functions: ${func_count:-0}"
    echo "Aliases: ${alias_count:-0}"
    [[ -n "$memory_kb" && "$memory_kb" =~ ^[0-9]+$ ]] && echo "Memory: $(echo "scale=1; $memory_kb / 1024" | bc 2>/dev/null) MB" || echo "Memory: Unknown"
    [[ -f "$HISTFILE" ]] && echo "History: $(wc -l < "$HISTFILE" 2>/dev/null) lines"
    (( func_count < 100 )) && core_color_green "Performance: Excellent" || (( func_count < 200 )) && echo "Performance: Good" || core_color_red "Performance: Optimization recommended"
}
# Version information
version() {
    echo "📦 ZSH Configuration Version 4.3.0 (Personal Minimal)"
    echo "Key Features: Minimal architecture, core functionality, performance optimization, personal experience"
    echo "Modules: core/aliases/plugins/completion/keybindings/utils"
    echo "Interface: Complete English localization with beautiful status monitoring"
}

# -------------------- Reserved Custom Area --------------------
# Custom functions/variables can be added in the custom/ directory

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED core"
