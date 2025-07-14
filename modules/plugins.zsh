#!/usr/bin/env zsh
# =============================================================================
# ZSH Plugins Module - Zinit-Based Plugin Management
# Version: 2.1 - Simplified Zinit-Focused Approach
# =============================================================================

# Add completions to FPATH
if [[ ":$FPATH:" != *":$ZSH_CONFIG_DIR/completions:"* ]]; then 
    export FPATH="$ZSH_CONFIG_DIR/completions:$FPATH"
fi

# =============================================================================
# ZINIT PLUGIN MANAGEMENT
# =============================================================================

# Only load zinit if it's not already loaded
if [[ -z "$ZINIT" ]]; then
    # Set zinit paths first
    local ZINIT_HOME="${HOME}/.local/share/zinit"
    local ZINIT_BIN="${HOME}/.local/share/zinit/zinit.git"
    
    # Install or update zinit
    if [[ ! -f "$ZINIT_BIN/zinit.zsh" ]]; then
        echo "📦 Installing zinit..."
        mkdir -p "$ZINIT_HOME"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_BIN"
    else
        # Update zinit to latest version (only if ZINIT_AUTO_UPDATE is set and not '0')
        if [[ -n "$ZINIT_AUTO_UPDATE" && "$ZINIT_AUTO_UPDATE" != "0" ]]; then
            echo "🔄 Updating zinit..."
            (cd "$ZINIT_BIN" && git pull origin main >/dev/null 2>&1)
        fi
    fi
    
    # Load zinit first (suppress warnings during loading)
    source "$ZINIT_BIN/zinit.zsh" 2>/dev/null
    
    # Now configure zinit after it's loaded
    ZINIT[MUTE_WARNINGS]=1 2>/dev/null || true
    ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1 2>/dev/null || true
    ZINIT[COMPINIT_OPTS]="-C" 2>/dev/null || true
    ZINIT[NO_ALIASES]=1 2>/dev/null || true
    
    # Initialize zinit properly
    autoload -Uz _zinit 2>/dev/null || true
    (( ${+_comps} )) && _comps[zinit]=_zinit 2>/dev/null || true
fi

# =============================================================================
# ESSENTIAL ZINIT PLUGINS
# =============================================================================

# Only load plugins if we're in an interactive shell
if [[ -o interactive ]]; then
    # Syntax highlighting (must be loaded last)
    zinit light zdharma-continuum/fast-syntax-highlighting 2>/dev/null || true

    # Auto suggestions
    zinit light zsh-users/zsh-autosuggestions 2>/dev/null || true

    # FZF tab completion (lazy load) - FIXED: Don't override default tab completion
    zinit ice wait'0' lucid
    zinit light Aloxaf/fzf-tab 2>/dev/null || true

    # Enhanced completion menu navigation
    # DISABLED: This plugin can cause hanging issues
    # zinit ice wait'0' lucid
    # zinit light marlonrichert/zsh-autocomplete 2>/dev/null || true

    # Git status in prompt (lightweight)
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh

    # Better history search (Ctrl+R replacement)
    zinit ice wait'0' lucid
    zinit light zsh-users/zsh-history-substring-search 2>/dev/null || true

    # History management
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/history/history.plugin.zsh
fi

# =============================================================================
# SYSTEM PLUGINS (Fallback)
# =============================================================================

# FZF - Essential for workflow (if available)
if command -v fzf >/dev/null 2>&1; then
    # FZF configuration
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    
    # FZF key bindings (fallback if not loaded via zinit)
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

# Auto-suggestions configuration (optimized for performance)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
export ZSH_AUTOSUGGEST_STRATEGY=(history)  # Use only history for better performance
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-add-eol)
export ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-char vi-forward-char)
export ZSH_AUTOSUGGEST_EXECUTE_WIDGETS=(accept-line)

# FZF tab configuration - RE-ENABLED WITH SAFE CONFIG
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 2s bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || echo "Preview not available"; else bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || echo "Preview not available"; fi'

# Enhanced FZF configuration for better navigation - RE-ENABLED WITH SAFE CONFIG
zstyle ':fzf-tab:complete:*' fzf-flags --preview-window=right:60%:wrap --timeout=3
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 2s bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || timeout 1s ls -la $realpath 2>/dev/null || echo $realpath; else bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || ls -la $realpath 2>/dev/null || echo $realpath; fi'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 1s ls -la $realpath 2>/dev/null || echo "Directory preview not available"; else ls -la $realpath 2>/dev/null || echo "Directory preview not available"; fi'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 1s ls -la $realpath 2>/dev/null || echo "File preview not available"; else ls -la $realpath 2>/dev/null || echo "File preview not available"; fi'

# Enhanced file and directory completion with FZF - RE-ENABLED WITH SAFE CONFIG
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 1s ls -la $realpath 2>/dev/null || echo "Directory: $realpath"; else ls -la $realpath 2>/dev/null || echo "Directory: $realpath"; fi'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 1s ls -la $realpath 2>/dev/null || echo "File: $realpath"; else ls -la $realpath 2>/dev/null || echo "File: $realpath"; fi'
zstyle ':fzf-tab:complete:cp:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 1s ls -la $realpath 2>/dev/null || echo "File: $realpath"; else ls -la $realpath 2>/dev/null || echo "File: $realpath"; fi'
zstyle ':fzf-tab:complete:mv:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 1s ls -la $realpath 2>/dev/null || echo "File: $realpath"; else ls -la $realpath 2>/dev/null || echo "File: $realpath"; fi'
zstyle ':fzf-tab:complete:rm:*' fzf-preview 'if command -v timeout >/dev/null 2>&1; then timeout 1s ls -la $realpath 2>/dev/null || echo "File: $realpath"; else ls -la $realpath 2>/dev/null || echo "File: $realpath"; fi'

# Show file types and sizes in FZF completion - RE-ENABLED WITH SAFE CONFIG
zstyle ':fzf-tab:complete:*' fzf-preview 'if [[ -d $realpath ]]; then
    echo "📁 Directory: $realpath"
    if command -v timeout >/dev/null 2>&1; then timeout 1s ls -la "$realpath" | head -10 2>/dev/null || echo "Contents not available"; else ls -la "$realpath" | head -10 2>/dev/null || echo "Contents not available"; fi
elif [[ -f $realpath ]]; then
    echo "📄 File: $realpath"
    if command -v timeout >/dev/null 2>&1; then timeout 1s ls -lh "$realpath" 2>/dev/null || echo "File info not available"; else ls -lh "$realpath" 2>/dev/null || echo "File info not available"; fi
else
    echo "❓ Unknown: $realpath"
fi'

# FZF-tab fallback configuration - ensure basic completion still works - RE-ENABLED
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' continuous-trigger 'space'
zstyle ':fzf-tab:*' accept-line 'ctrl-space'

# IMPORTANT: Ensure default completion still works alongside FZF-tab
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# FZF-tab configuration - Don't override default tab completion
# Use Ctrl+T for fzf-tab instead of Tab
bindkey '^T' fzf-tab-complete

# History substring search key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^R' history-incremental-search-backward

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
        "fast-syntax-highlighting:Syntax Highlighting"
        "fzf-tab:FZF Tab Completion"
        "git:Git Integration"
        "gitfast:Git Aliases"
        "history:History Management"
        "zsh-history-substring-search:Better History Search"
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
    
    # Check Zinit status
    echo ""
    echo "🔌 Zinit Status:"
    if [[ -n "$ZINIT" ]]; then
        echo "✅ Zinit loaded"
        echo "📦 Plugins managed by Zinit:"
        if [[ -d "${ZINIT[HOME_DIR]}/plugins" ]]; then
            ls "${ZINIT[HOME_DIR]}/plugins" | sed 's/^/  • /'
        else
            echo "  No plugins found"
        fi
    else
        echo "❌ Zinit not loaded"
    fi
}

# Export plugin functions
export -f check_plugins 2>/dev/null || true
