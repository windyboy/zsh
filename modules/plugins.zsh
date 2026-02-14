#!/usr/bin/env zsh
# =============================================================================
# Plugins Module - Efficient Plugin Management
# =============================================================================

source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# -------------------- Plugin Initialization --------------------
plugin_init() {
    [[ -n "$ZINIT" ]] && return 0
    local ZINIT_BIN="${ZINIT_HOME}/zinit.git"
    
    if [[ ! -f "$ZINIT_BIN/zinit.zsh" ]]; then
        color_yellow "📦 Installing zinit..."
        mkdir -p "$ZINIT_HOME"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_BIN" 2>/dev/null
    fi

    source "$ZINIT_BIN/zinit.zsh" 2>/dev/null && return 0
    return 1
}

# -------------------- Plugin Loading --------------------
plugins_load() {
    (( ZSH_ENABLE_PLUGINS )) || return 0
    plugin_init || return 1
    [[ ! -o interactive ]] && return 0

    # 1. Critical plugins (Async but fast)
    local -a plugins=(
        zdharma-continuum/fast-syntax-highlighting
        zsh-users/zsh-autosuggestions
        zsh-users/zsh-completions
        zsh-users/zsh-history-substring-search
        Aloxaf/fzf-tab
    )

    for p in "${plugins[@]}"; do
        zinit ice wait"0" lucid
        zinit light "$p"
    done

    # 2. Tools & Snippets
    zinit ice wait"1" lucid; zinit snippet OMZP::extract
}

# -------------------- Tool Configs --------------------
# Lazy load zoxide
z() {
    unfunction z
    if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
        z "$@"
    else
        color_red "zoxide not found"
        return 1
    fi
}

# fzf-tab configuration
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la "$realpath" 2>/dev/null'
zstyle ':fzf-tab:complete:*:*' fzf-flags --preview-window=right:60%:wrap

# Initialize
plugins_load

# Mark module as loaded
ZSH_MODULES_LOADED+=(plugins)
