#!/usr/bin/env zsh
# =============================================================================
# Completion Module - Completion System Configuration
# Description: Only high-frequency, essential, minimal completion configuration with clear comments and unified naming.
# =============================================================================

# Color output tools
comp_color_red()   { echo -e "\033[31m$1\033[0m"; }
comp_color_green() { echo -e "\033[32m$1\033[0m"; }

# -------------------- Completion Cache --------------------
COMPLETION_CACHE_FILE="$ZSH_CACHE_DIR/zcompdump"
autoload -Uz compinit
if [[ ! -f "$COMPLETION_CACHE_FILE" ]] || [[ $(find "$COMPLETION_CACHE_FILE" -mtime +1 2>/dev/null) ]]; then
    compinit -d "$COMPLETION_CACHE_FILE" 2>/dev/null || compinit -C -d "$COMPLETION_CACHE_FILE"
    [[ -f "$COMPLETION_CACHE_FILE" ]] && zcompile "$COMPLETION_CACHE_FILE" 2>/dev/null
else
    compinit -C -d "$COMPLETION_CACHE_FILE"
fi
autoload -Uz _files _cd _ls _cp _mv _rm

# Ensure completion system is properly initialized
autoload -Uz compinit
compinit -d "$COMPLETION_CACHE_FILE"

# -------------------- Basic Completion Styles --------------------
zstyle ':completion:*' completer _complete _match _approximate
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

# Force menu to show
zstyle ':completion:*' force-list always
zstyle ':completion:*' auto-description 'specify: %d'

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
zstyle ':completion:*:manuals.*' insert-tab true

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

# -------------------- Tab Enhancement --------------------
# Ensure tab completion works properly
bindkey '^I' complete-word
bindkey '^[[Z' reverse-menu-complete
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' insert-tab pending
if (( ${+_comps[fzf-tab]} )); then
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' continuous-trigger 'space'
    zstyle ':fzf-tab:*' accept-line 'ctrl-space'
fi

# -------------------- Common Functions --------------------
completion_status() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "Usage: completion_status" && return 0
    local errors=0
    (( ${+_comps} )) && comp_color_green "✅ Completion system initialized" || { comp_color_red "❌ Completion system not initialized"; ((errors++)); }
    [[ -f "$COMPLETION_CACHE_FILE" ]] && comp_color_green "✅ Completion cache exists" || { comp_color_red "❌ Completion cache missing"; ((errors++)); }
    local completion_functions=("_files" "_cd" "_ls" "_cp" "_mv" "_rm")
    for func in "${completion_functions[@]}"; do
        (( ${+_comps[$func]} )) && comp_color_green "✅ $func completion available" || { comp_color_red "❌ $func completion missing"; ((errors++)); }
    done
    (( errors == 0 )) && comp_color_green "Completion system normal" || comp_color_red "Completion system has $errors issues"
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
echo "INFO: Completion module initialized" 