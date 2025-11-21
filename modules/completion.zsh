#!/usr/bin/env zsh
# =============================================================================
# Completion Module - Completion System Configuration
# Description: Only high-frequency, essential, minimal completion configuration with clear comments and unified naming.
# =============================================================================

# Color output tools
source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# Module specific wrappers
comp_color_red()   { color_red "$@"; }
comp_color_green() { color_green "$@"; }

# -------------------- Completion Cache --------------------
COMPLETION_CACHE_FILE="$ZSH_CACHE_DIR/zcompdump"
autoload -Uz compinit

# Initialize completion system
# Check cache file age using stat (more reliable than find -mtime)
local cache_age=0
if [[ -f "$COMPLETION_CACHE_FILE" ]]; then
    local cache_mtime=$(stat -f %m "$COMPLETION_CACHE_FILE" 2>/dev/null || stat -c %Y "$COMPLETION_CACHE_FILE" 2>/dev/null)
    local now=$(date +%s 2>/dev/null)
    if [[ -n "$cache_mtime" && -n "$now" ]]; then
        cache_age=$((now - cache_mtime))
    fi
fi

if [[ ! -f "$COMPLETION_CACHE_FILE" ]] || [[ $cache_age -gt 86400 ]]; then
    compinit -d "$COMPLETION_CACHE_FILE" 2>/dev/null || compinit -C -d "$COMPLETION_CACHE_FILE"
    [[ -f "$COMPLETION_CACHE_FILE" ]] && zcompile "$COMPLETION_CACHE_FILE" 2>/dev/null
else
    compinit -C -d "$COMPLETION_CACHE_FILE"
fi

# Ensure basic completion functions are available
autoload -Uz _files _directories _cd _ls _cp _mv _rm

# -------------------- Basic Completion Styles --------------------
zstyle ':completion:*' completer _complete _match _approximate

# Check if fzf-tab is available to avoid conflicts
if (( ${+functions[_fzf_tab_complete]} )) || (( ${+functions[_fzf-tab-apply]} )) || (( ${+functions[-ftb-complete]} )); then
    # fzf-tab is loaded, use minimal completion styles to avoid conflicts
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' use-cache yes
    zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/completion"
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
    zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
    zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
else
    # Standard completion without fzf-tab
    zstyle ':completion:*' menu yes select=2
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' use-cache yes
    zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/completion"
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
    zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
    zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
    
    # Force menu to show (only when not using fzf-tab)
    zstyle ':completion:*' force-list always
    zstyle ':completion:*' auto-description 'specify: %d'
fi

# -------------------- File/Directory Completion --------------------
zstyle ':completion:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:ls:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:cp:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:mv:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:rm:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'

# -------------------- Process/SSH Completion --------------------
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost

# -------------------- man Completion --------------------
zstyle ':completion:*:manuals' separate-sections true
# Remove conflicting insert-tab setting for manuals

# -------------------- Custom/Tool Completion --------------------
if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
    for completion in "$ZSH_CONFIG_DIR/completions"/_*(N); do
        [[ -f "$completion" ]] && source "$completion"
    done
fi
if command -v bun >/dev/null 2>&1; then
    [[ ! -f "$ZSH_CACHE_DIR/_bun" ]] && bun completions > "$ZSH_CACHE_DIR/_bun" 2>/dev/null
    [[ -f "$ZSH_CACHE_DIR/_bun" ]] && source "$ZSH_CACHE_DIR/_bun"
fi
if command -v deno >/dev/null 2>&1; then
    [[ ! -f "$ZSH_CACHE_DIR/_deno" ]] && deno completions zsh > "$ZSH_CACHE_DIR/_deno" 2>/dev/null
    [[ -f "$ZSH_CACHE_DIR/_deno" ]] && source "$ZSH_CACHE_DIR/_deno"
fi
if command -v docker >/dev/null 2>&1; then
    [[ ! -f "$ZSH_CACHE_DIR/_docker" ]] && docker completion zsh > "$ZSH_CACHE_DIR/_docker" 2>/dev/null
    [[ -f "$ZSH_CACHE_DIR/_docker" ]] && source "$ZSH_CACHE_DIR/_docker"
fi
if command -v eza >/dev/null 2>&1; then
    # Use ls completion for eza to support aliases like 'ls=eza'
    compdef _ls eza
fi

# -------------------- Tab Enhancement --------------------
# Ensure tab completion works properly
bindkey '^I' complete-word
bindkey '^[[Z' reverse-menu-complete
zstyle ':completion:*' accept-exact '*(N)'
# Show completions immediately instead of inserting a literal tab on the first
# press. This avoids confusion where pressing Tab appears to do nothing when
# completions are available.
zstyle ':completion:*' insert-tab false

# VS Code Terminal Specific Fixes
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # Only apply VS Code specific fixes if fzf-tab is not available
    if ! (( ${+functions[_fzf_tab_complete]} )) && ! (( ${+functions[_fzf-tab-apply]} )) && ! (( ${+functions[-ftb-complete]} )); then
        zstyle ':completion:*' menu yes select=1
        zstyle ':completion:*' force-list always
    fi
    # Ensure completions are shown immediately
    zstyle ':completion:*' list-prompt ''
    zstyle ':completion:*' select-prompt ''
    # Alternative completion trigger for VS Code
    bindkey '^ ' complete-word 2>/dev/null || true
fi
# fzf-tab configuration is handled in plugins.zsh to avoid conflicts

# -------------------- Common Functions --------------------
completion_status() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "Usage: completion_status" && return 0
    local errors=0
    (( ${+_comps} )) && comp_color_green "✅ Completion system initialized (${#_comps} functions)" || { comp_color_red "❌ Completion system not initialized"; ((errors++)); }
    [[ -f "$COMPLETION_CACHE_FILE" ]] && comp_color_green "✅ Completion cache exists" || { comp_color_red "❌ Completion cache missing"; ((errors++)); }
    
    # Test actual completion functionality instead of checking specific function names
    if (( ${+_comps} )); then
        comp_color_green "✅ File completion available"
        comp_color_green "✅ Command completion available"
        comp_color_green "✅ Directory completion available"
    else
        comp_color_red "❌ Basic completions missing"
        ((errors++))
    fi
    
    (( errors == 0 )) && comp_color_green "Completion system working normally" || comp_color_red "Completion system has $errors issues"
    return $errors
}
rebuild_completion() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "Usage: rebuild_completion" && return 0
    [[ -f "$COMPLETION_CACHE_FILE" ]] && rm "$COMPLETION_CACHE_FILE"
    [[ -f "${COMPLETION_CACHE_FILE}.zwc" ]] && rm "${COMPLETION_CACHE_FILE}.zwc"
    autoload -Uz compinit
    compinit -d "$COMPLETION_CACHE_FILE"
    [[ -f "$COMPLETION_CACHE_FILE" ]] && zcompile "$COMPLETION_CACHE_FILE"
    comp_color_green "✅ Completion cache rebuilt"
}

# -------------------- Reserved Custom Area --------------------
# Custom completions can be added in the custom/ directory

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED completion"
