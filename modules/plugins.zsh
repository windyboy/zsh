#!/usr/bin/env zsh
# =============================================================================
# Plugins Module - Efficient Plugin Management
# =============================================================================

source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# -------------------- Plugin Initialization --------------------
plugin_init() {
    (( ${+functions[zinit]} )) && return 0
    local ZINIT_BIN="${ZINIT_HOME}/zinit.git"

    if [[ ! -f "$ZINIT_BIN/zinit.zsh" ]]; then
        # Network side effects only in interactive shells: CI/scripts that
        # source zshrc must never git clone.
        [[ -o interactive ]] || return 1
        color_yellow "📦 Installing zinit..."
        if ! git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_BIN"; then
            color_red "❌ zinit clone failed. Check network/proxy, then rerun: git clone https://github.com/zdharma-continuum/zinit.git $ZINIT_BIN"
            return 1
        fi
    fi

    source "$ZINIT_BIN/zinit.zsh" || { color_red "❌ Failed to source $ZINIT_BIN/zinit.zsh"; return 1 }
    return 0
}

# -------------------- Plugin Loading --------------------
# Registry entries load synchronously (no turbo/deferred wait): the plugins
# module runs BEFORE completion.zsh, so zsh-completions' fpath additions land
# before compinit and its completions actually register. Turbo deferred loads
# past compinit and left them inert; local.zsh direct-sourcing of the same
# plugins (the old workaround) is removed — the registry is the single load
# path.
plugins_load() {
    if (( ! ZSH_ENABLE_PLUGINS )); then
        # Plugins are opt-in (ZSH_ENABLE_PLUGINS defaults off), but a silent
        # skip made fresh installs look broken — nothing downloaded, nothing
        # reported. Surface the reason once per machine (cache marker), then
        # stay quiet.
        if [[ -o interactive ]]; then
            local hint_marker="$ZSH_CACHE_DIR/.plugins-disabled-hint"
            if [[ ! -f "$hint_marker" ]]; then
                mkdir -p "$ZSH_CACHE_DIR" 2>/dev/null
                touch "$hint_marker" 2>/dev/null
                color_yellow "ℹ️ Plugins are disabled (default). Enable: set ZSH_ENABLE_PLUGINS=1 in env/local/environment.env and start a new shell — zinit and plugins/core.list install automatically."
            fi
        fi
        return 0
    fi
    [[ ! -o interactive ]] && return 0
    plugin_init || return 1

    # plugins/core.list is the declarative registry: one spec per line.
    # owner/repo entries load via `zinit light`; OMZP::/OMZL:: entries via
    # `zinit snippet`. Both synchronously, before compinit runs.
    local registry="$ZSH_CONFIG_DIR/plugins/core.list"
    if [[ ! -f "$registry" ]]; then
        color_yellow "⚠️ plugin registry missing: $registry"
        return 1
    fi

    local spec
    while IFS= read -r spec; do
        spec="${spec//[[:space:]]/}"
        [[ -z "$spec" || "$spec" == \#* ]] && continue
        case "$spec" in
            OMZP::*|OMZL::*)
                zinit ice lucid; zinit snippet "$spec" ;;
            *)
                zinit ice lucid; zinit light "$spec" ;;
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

# -------------------- History Substring Search Bindings --------------------
# zsh-history-substring-search ships no default keybindings (upstream README
# requires explicit bindings). It loads via the registry in plugins_load above
# (synchronously during zshrc), so the widgets already exist at the first
# precmd; the hook binds ↑/↓ then and stays a no-op fallback if the load failed.
_zsh_bind_hss() {
    (( ${+widgets[history-substring-search-up]} && ${+widgets[history-substring-search-down]} )) || return 0
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    add-zsh-hook -d precmd _zsh_bind_hss
}
if (( ZSH_ENABLE_PLUGINS )) && [[ -o interactive ]]; then
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _zsh_bind_hss
fi

# Mark module as loaded
ZSH_MODULES_LOADED+=(plugins)
