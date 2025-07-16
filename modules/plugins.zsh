#!/usr/bin/env zsh
# =============================================================================
# Plugins Module - Simplified Plugin Management
# Version: 4.0 - Streamlined Plugin System
# =============================================================================

# =============================================================================
# ZINIT SETUP
# =============================================================================

# Load tools detection module
if [[ -f "$ZSH_CONFIG_DIR/modules/tools.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/tools.zsh"
fi

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
    
    # Enhanced completions
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-completions 2>/dev/null || true
    
    # Git integration
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
    
    # History management
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/history/history.plugin.zsh
fi

# =============================================================================
# OPTIONAL PLUGINS (Conditional)
# =============================================================================

# FZF tab completion (if fzf is available)
if has_tool fzf; then
    zinit ice wait"0" lucid
    zinit light Aloxaf/fzf-tab 2>/dev/null || true
fi

# History substring search (if not conflicting)
if ! bindkey | grep -q '\^\[\[A.*history-substring-search-up'; then
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-history-substring-search 2>/dev/null || true
fi

# =============================================================================
# SYSTEM TOOLS CONFIGURATION
# =============================================================================

# FZF configuration
if has_tool fzf; then
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || ls -la {}'"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    
    # Load FZF key bindings
    for fzf_binding in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/local/opt/fzf/shell/key-bindings.zsh ~/.fzf/shell/key-bindings.zsh; do
        [[ -f "$fzf_binding" ]] && source "$fzf_binding" && break
    done
fi

# Zoxide smart navigation
if has_tool zoxide; then
    eval "$(zoxide init zsh)"
fi

# Enhanced directory listing with eza
# Note: ls aliases are defined in aliases.zsh to avoid conflicts
if has_tool eza; then
    # Only define additional eza aliases not covered in aliases.zsh
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

# FZF tab configuration
if (( ${+_comps[fzf-tab]} )); then
    zstyle ':fzf-tab:complete:*' fzf-flags --preview-window=right:60%:wrap --timeout=3
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' continuous-trigger 'space'
    zstyle ':fzf-tab:*' accept-line 'ctrl-space'
fi

# =============================================================================
# PLUGIN KEY BINDINGS
# =============================================================================

# Configure plugin key bindings
_configure_plugin_keybindings() {
    # History substring search
    if ! bindkey | grep -q '\^\[\[A.*history-substring-search-up'; then
        bindkey '^[[A' history-substring-search-up 2>/dev/null || true
    fi
    
    if ! bindkey | grep -q '\^\[\[B.*history-substring-search-down'; then
        bindkey '^[[B' history-substring-search-down 2>/dev/null || true
    fi
    
    # FZF tab completion
    if ! bindkey | grep -q '\^T.*fzf-tab-complete'; then
        bindkey '^T' fzf-tab-complete 2>/dev/null || true
    fi
}

# Configure plugin key bindings
_configure_plugin_keybindings

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Plugin status checker
plugins() {
    echo "🔌 Plugin Status:"
    echo "================="
    
    local plugins=(
        "fzf:Fuzzy Finder"
        "zoxide:Smart Navigation"
        "eza:Enhanced ls"
        "zsh-autosuggestions:Auto Suggestions"
        "fast-syntax-highlighting:Syntax Highlighting"
        "fzf-tab:FZF Tab Completion"
        "zsh-completions:Enhanced Completions"
        "git:Git Integration"
        "history:History Management"
    )
    
    for plugin in "${plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        
        if command -v "$name" >/dev/null 2>&1 || [[ -n "$(alias "$name" 2>/dev/null)" ]]; then
            echo "✅ $name - $desc"
        else
            echo "❌ $name - $desc"
        fi
    done
}

# Plugin conflict detection
check_conflicts() {
    echo "🔍 Checking for plugin conflicts..."
    
    local conflicts=0
    
    # Check for duplicate key bindings
    local bindings=$(bindkey | awk '{print $2}' | sort | uniq -d)
    if [[ -n "$bindings" ]]; then
        echo "⚠️  Duplicate key bindings found:"
        echo "$bindings"
        ((conflicts++))
    fi
    
    # Check for duplicate aliases
    local aliases=$(alias | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$aliases" ]]; then
        echo "⚠️  Duplicate aliases found:"
        echo "$aliases"
        ((conflicts++))
    fi
    
    if (( conflicts == 0 )); then
        echo "✅ No conflicts detected"
    else
        echo "❌ $conflicts conflicts found"
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Mark plugins module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED plugins"

log "Plugins module initialized" "success" "plugins" 