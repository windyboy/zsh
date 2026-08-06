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

    # plugins/core.list is the declarative registry: one spec per line.
    # owner/repo entries load via `zinit light` (turbo wait"0"), OMZP::/OMZL::
    # entries via `zinit snippet` (wait"1").
    local registry="$ZSH_CONFIG_DIR/plugins/core.list"
    if [[ ! -f "$registry" ]]; then
        color_yellow "⚠️ plugin registry missing: $registry"
        return 1
    fi

    local spec
    while IFS= read -r spec; do
        [[ -z "${spec//[[:space:]]/}" || "$spec" == \#* ]] && continue
        case "$spec" in
            OMZP::*|OMZL::*)
                zinit ice wait"1" lucid; zinit snippet "$spec" ;;
            *)
                zinit ice wait"0" lucid; zinit light "$spec" ;;
        esac
    done < "$registry"
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
