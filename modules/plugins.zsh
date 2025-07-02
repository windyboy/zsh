#!/usr/bin/env zsh
# =============================================================================
# ZSH Plugins Module - Plugin Management
# =============================================================================

# Source zinit for plugin management
if [[ -f "$ZSH_CONFIG_DIR/modules/zinit.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/zinit.zsh"
fi

# Add completions to FPATH
if [[ ":$FPATH:" != *":$ZSH_CONFIG_DIR/completions:"* ]]; then 
    export FPATH="$ZSH_CONFIG_DIR/completions:$FPATH"
fi

# =============================================================================
# ESSENTIAL PLUGINS (Manual Installation)
# =============================================================================

# FZF - Essential for workflow (if available)
if command -v fzf >/dev/null 2>&1; then
    # FZF configuration
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    
    # FZF key bindings
    if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    elif [[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]]; then
        source /usr/local/opt/fzf/shell/key-bindings.zsh
    elif [[ -f ~/.fzf/shell/key-bindings.zsh ]]; then
        source ~/.fzf/shell/key-bindings.zsh
    fi
fi

# Zoxide - Smart directory navigation (if available)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Enhanced directory listings with eza (if available)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza -T --icons --group-directories-first'
fi

# =============================================================================
# PLUGIN CONFIGURATION
# =============================================================================

# Auto-suggestions configuration (if available)
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
fi

# Syntax highlighting (if available)
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# =============================================================================
# PLUGIN STATUS
# =============================================================================

# Function to check plugin status
check_plugins() {
    echo "🔌 Plugin Status:"
    echo "================="
    
    local plugins=(
        "fzf:Fuzzy Finder"
        "zoxide:Smart Navigation"
        "eza:Enhanced ls"
        "zsh-autosuggestions:Auto Suggestions"
        "zsh-syntax-highlighting:Syntax Highlighting"
    )
    
    for plugin in "${plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        
        if command -v "$name" >/dev/null 2>&1 || [[ -f "/usr/share/zsh-$name/zsh-$name.zsh" ]]; then
            echo "✅ $desc"
        else
            echo "❌ $desc (not installed)"
        fi
    done
}

# Export plugin functions
export -f check_plugins 2>/dev/null || true
