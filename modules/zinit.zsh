#!/usr/bin/env zsh
# =============================================================================
# Zinit Configuration - Modern Setup
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
            echo "�� Updating zinit..."
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
# Essential Plugins (Lazy Loaded for Performance)
# =============================================================================

# Only load plugins if we're in an interactive shell
if [[ -o interactive ]]; then
    # Syntax highlighting (must be loaded last)
    zinit light zdharma-continuum/fast-syntax-highlighting 2>/dev/null || true

    # Auto suggestions
    zinit light zsh-users/zsh-autosuggestions 2>/dev/null || true

    # FZF tab completion (lazy load)
    zinit ice wait'0' lucid
    zinit light Aloxaf/fzf-tab 2>/dev/null || true
fi

# =============================================================================
# Plugin Configuration
# =============================================================================

# FZF tab configuration
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath'

# Auto suggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"

# =============================================================================
# Utility Functions
# =============================================================================

# Function to check zinit plugin status
check_zinit_plugins() {
    echo "🔌 Zinit Plugin Status:"
    echo "======================="
    
    local plugins=(
        "fast-syntax-highlighting:Syntax Highlighting"
        "zsh-autosuggestions:Auto Suggestions"
        "fzf-tab:FZF Tab Completion"
    )
    
    for plugin in "${plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        
        if [[ -d "${ZINIT[HOME_DIR]}/plugins" ]] && ls "${ZINIT[HOME_DIR]}/plugins" | grep -q "$name"; then
            echo "✅ $desc"
        else
            echo "❌ $desc (not installed)"
        fi
    done
}

# Function to debug zinit configuration
debug_zinit_config() {
    echo "🔍 Zinit Configuration Debug Info:"
    echo "=================================="
    echo "ZINIT[HOME_DIR]: ${ZINIT[HOME_DIR]}"
    echo "ZINIT[BIN_DIR]: ${ZINIT[BIN_DIR]}"
    echo "ZPFX: $ZPFX"
    echo ""
    echo "Available plugins in ${ZINIT[HOME_DIR]}/plugins:"
    if [[ -d "${ZINIT[HOME_DIR]}/plugins" ]]; then
        ls -la "${ZINIT[HOME_DIR]}/plugins" | head -10
    else
        echo "❌ Plugins directory not found"
    fi
}

# Make functions available (zsh-compatible way)
autoload -Uz check_zinit_plugins debug_zinit_config 