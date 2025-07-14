#!/usr/bin/env zsh
# =============================================================================
# ZSH Plugins Module - Enhanced with Community Plugins
# Version: 3.1 - Community-Recommended Plugins
# =============================================================================

# Add completions to FPATH
if [[ ":$FPATH:" != *":$ZSH_CONFIG_DIR/completions:"* ]]; then 
    export FPATH="$ZSH_CONFIG_DIR/completions:$FPATH"
fi

# =============================================================================
# ZINIT SETUP
# =============================================================================

# Only load zinit if not already loaded
if [[ -z "$ZINIT" ]]; then
    local ZINIT_HOME="${HOME}/.local/share/zinit"
    local ZINIT_BIN="${HOME}/.local/share/zinit/zinit.git"
    
    # Install zinit if not present
    if [[ ! -f "$ZINIT_BIN/zinit.zsh" ]]; then
        echo "📦 Installing zinit..."
        mkdir -p "$ZINIT_HOME"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_BIN"
    fi
    
    # Load zinit
    source "$ZINIT_BIN/zinit.zsh" 2>/dev/null
    
    # Configure zinit
    ZINIT[MUTE_WARNINGS]=1 2>/dev/null || true
    ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1 2>/dev/null || true
    ZINIT[COMPINIT_OPTS]="-C" 2>/dev/null || true
    ZINIT[NO_ALIASES]=1 2>/dev/null || true
    
    # Initialize completion
    autoload -Uz _zinit 2>/dev/null || true
    (( ${+_comps} )) && _comps[zinit]=_zinit 2>/dev/null || true
fi

# =============================================================================
# CORE PLUGINS (Essential)
# =============================================================================

# Only load plugins in interactive shells
if [[ -o interactive ]]; then
    # Syntax highlighting (must be loaded last)
    zinit ice wait"0" lucid
    zinit light zdharma-continuum/fast-syntax-highlighting 2>/dev/null || true
    
    # Auto suggestions
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-autosuggestions 2>/dev/null || true
    
    # FZF tab completion (lazy load)
    zinit ice wait"0" lucid
    zinit light Aloxaf/fzf-tab 2>/dev/null || true
    
    # Enhanced completions
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-completions 2>/dev/null || true
    
    # Git integration
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
    
    # History management
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-history-substring-search 2>/dev/null || true
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/history/history.plugin.zsh
fi

# =============================================================================
# ENHANCED PLUGINS (Optional but Recommended)
# =============================================================================

# Only load enhanced plugins if explicitly enabled
if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
    # Multi-word history search
    zinit ice wait"0" lucid
    zinit light zdharma-continuum/history-search-multi-word 2>/dev/null || true
    
    # Alias tips
    zinit ice wait"0" lucid
    zinit light zdharma-continuum/alias-tips 2>/dev/null || true
    
    # Auto environment
    zinit ice wait"0" lucid
    zinit light Tarrasch/zsh-autoenv 2>/dev/null || true
    
    # Smart directory jumping (z)
    zinit ice wait"0" lucid
    zinit light agkozak/zsh-z 2>/dev/null || true
    
    # Git prompt (if not using a theme)
    if [[ -z "$ZSH_THEME" ]]; then
        zinit ice wait"0" lucid
        zinit light zsh-users/zsh-git-prompt 2>/dev/null || true
    fi
fi

# =============================================================================
# SYSTEM TOOLS CONFIGURATION
# =============================================================================

# FZF configuration
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || ls -la {}'"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    
    # Load FZF key bindings
    for fzf_binding in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/local/opt/fzf/shell/key-bindings.zsh ~/.fzf/shell/key-bindings.zsh; do
        [[ -f "$fzf_binding" ]] && source "$fzf_binding" && break
    done
fi

# Zoxide smart navigation
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Enhanced directory listing with eza
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza -T --icons --group-directories-first'
fi

# =============================================================================
# PLUGIN CONFIGURATION
# =============================================================================

# Auto-suggestions optimization
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-add-eol)
export ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-char vi-forward-char)
export ZSH_AUTOSUGGEST_EXECUTE_WIDGETS=(accept-line)

# FZF tab completion configuration
if command -v bat >/dev/null 2>&1; then
    local preview_cmd='bat --color=always --style=numbers --line-range=:500'
else
    local preview_cmd='ls -la'
fi

# Unified FZF tab configuration
zstyle ':fzf-tab:complete:*' fzf-flags --preview-window=right:60%:wrap --timeout=3
zstyle ':fzf-tab:complete:*:*' fzf-preview "timeout 2s $preview_cmd \$realpath 2>/dev/null || ls -la \$realpath 2>/dev/null || echo \$realpath"
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' continuous-trigger 'space'
zstyle ':fzf-tab:*' accept-line 'ctrl-space'

# Ensure default completion works alongside FZF-tab
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Key bindings
bindkey '^T' fzf-tab-complete
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^R' history-incremental-search-backward

# =============================================================================
# ENHANCED PLUGIN CONFIGURATIONS
# =============================================================================

# Alias tips configuration
if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
    export ZSH_PLUGINS_ALIAS_TIPS_TEXT="💡 Tip: "
    export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDES="_ vi vim nvim"
fi

# Z (smart directory jumping) configuration
if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
    export ZSHZ_DATA="${ZSH_CACHE_DIR}/z"
    export ZSHZ_ECHO=1
    export ZSHZ_TILDE=1
fi

# Autoenv configuration
if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
    export AUTOENV_AUTH_FILE="${ZSH_CACHE_DIR}/autoenv_auth"
    export AUTOENV_FILE_ENTER=".env"
    export AUTOENV_FILE_LEAVE=".env.leave"
fi

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Plugin status checker
check_plugins() {
    echo "🔌 Plugin Status:"
    echo "================="
    
    local plugins=(
        "fzf:Fuzzy Finder"
        "zoxide:Smart Navigation"
        "eza:Enhanced ls"
        "bat:Code Preview"
        "zsh-autosuggestions:Auto Suggestions"
        "fast-syntax-highlighting:Syntax Highlighting"
        "fzf-tab:FZF Tab Completion"
        "zsh-completions:Enhanced Completions"
        "git:Git Integration"
        "history:History Management"
        "zsh-history-substring-search:Better History Search"
    )
    
    # Add enhanced plugins if enabled
    if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
        plugins+=(
            "history-search-multi-word:Multi-word History Search"
            "alias-tips:Alias Tips"
            "zsh-autoenv:Auto Environment"
            "zsh-z:Smart Directory Jumping"
            "zsh-git-prompt:Git Prompt"
        )
    fi
    
    for plugin in "${plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        
        if command -v "$name" >/dev/null 2>&1; then
            echo "✅ $desc"
        else
            echo "❌ $desc (not installed)"
        fi
    done
    
    echo ""
    echo "🔌 Zinit Status:"
    if [[ -n "$ZINIT" ]]; then
        echo "✅ Zinit loaded"
        if [[ -d "${ZINIT[HOME_DIR]}/plugins" ]]; then
            echo "📦 Plugins:"
            ls "${ZINIT[HOME_DIR]}/plugins" | sed 's/^/  • /'
        fi
    else
        echo "❌ Zinit not loaded"
    fi
    
    # Show enhanced plugins status
    if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
        echo ""
        echo "🚀 Enhanced plugins enabled"
    else
        echo ""
        echo "💡 Enable enhanced plugins with: export ZSH_LOAD_ENHANCED_PLUGINS=1"
    fi
}

# Export functions
export -f check_plugins 2>/dev/null || true
