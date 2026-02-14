#!/usr/bin/env zsh
# =============================================================================
# Completion Module - Completion System Configuration
# =============================================================================

# Color output tools
source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# -------------------- fpath Setup --------------------
# Set fpath before compinit (The proper ZSH way)
[[ -d "$ZSH_CONFIG_DIR/completions" ]] && fpath=("$ZSH_CONFIG_DIR/completions" $fpath)

# Handle tool completions via fpath/autoload
for tool in bun deno docker; do
    local cache_file="$ZSH_CACHE_DIR/_$tool"
    if command -v $tool >/dev/null 2>&1; then
        if [[ ! -f "$cache_file" ]]; then
            case $tool in
                bun) bun completions > "$cache_file" 2>/dev/null ;;
                deno) deno completions zsh > "$cache_file" 2>/dev/null ;;
                docker) docker completion zsh > "$cache_file" 2>/dev/null ;;
            esac
        fi
    fi
done

[[ -d "$ZSH_CACHE_DIR" ]] && fpath=("$ZSH_CACHE_DIR" $fpath)

# -------------------- compinit Initialization --------------------
COMPLETION_CACHE_FILE="$ZSH_CACHE_DIR/zcompdump"
autoload -Uz compinit

# Check cache file age
local cache_age=0
if [[ -f "$COMPLETION_CACHE_FILE" ]]; then
    local cache_mtime=$(stat -f %m "$COMPLETION_CACHE_FILE" 2>/dev/null || stat -c %Y "$COMPLETION_CACHE_FILE" 2>/dev/null)
    local now=$(date +%s 2>/dev/null)
    if [[ "$cache_mtime" =~ ^[0-9]+$ ]] && [[ "$now" =~ ^[0-9]+$ ]]; then
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
autoload -Uz _files _directories _cd _ls _cp _mv _rm _complete _ignored _approximate _match

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

# -------------------- Tool Integration --------------------
if command -v eza >/dev/null 2>&1; then
    compdef _ls eza
fi

# -------------------- Tab Enhancement --------------------
bindkey '^I' complete-word
bindkey '^[[Z' reverse-menu-complete
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' insert-tab false

# VS Code Terminal Specific Fixes
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    if ! (( ${+functions[_fzf_tab_complete]} )) && ! (( ${+functions[_fzf-tab-apply]} )) && ! (( ${+functions[-ftb-complete]} )); then
        zstyle ':completion:*' menu yes select=1
        zstyle ':completion:*' force-list always
    fi
    zstyle ':completion:*' list-prompt ''
    zstyle ':completion:*' select-prompt ''
    bindkey '^ ' complete-word 2>/dev/null || true
fi

# -------------------- Utility Functions --------------------
completion_status() {
    local errors=0
    (( ${+_comps} )) && color_green "✅ Completion system initialized (${#_comps} functions)" || { color_red "❌ Completion system not initialized"; ((errors++)); }
    [[ -f "$COMPLETION_CACHE_FILE" ]] && color_green "✅ Completion cache exists" || { color_red "❌ Completion cache missing"; ((errors++)); }
    (( errors == 0 )) && color_green "Completion system working normally" || color_red "Completion system has $errors issues"
    return $errors
}

rebuild_completion() {
    rm -f "$COMPLETION_CACHE_FILE" "${COMPLETION_CACHE_FILE}.zwc"
    autoload -Uz compinit
    compinit -d "$COMPLETION_CACHE_FILE"
    [[ -f "$COMPLETION_CACHE_FILE" ]] && zcompile "$COMPLETION_CACHE_FILE"
    color_green "✅ Completion cache rebuilt"
}

# Mark module as loaded
ZSH_MODULES_LOADED+=(completion)
