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
        # Update zinit to latest version
        echo "🔄 Updating zinit..."
        (cd "$ZINIT_BIN" && git pull origin main >/dev/null 2>&1)
    fi
    
    # Load zinit first
    source "$ZINIT_BIN/zinit.zsh"
    
    # Now configure zinit after it's loaded
    ZINIT[MUTE_WARNINGS]=1
    ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1
    ZINIT[COMPINIT_OPTS]="-C"
    ZINIT[NO_ALIASES]=1
    
    # Initialize zinit properly
    autoload -Uz _zinit
    (( ${+_comps} )) && _comps[zinit]=_zinit
fi

# =============================================================================
# Essential Plugins
# =============================================================================

# Syntax highlighting (must be loaded last)
zinit light zdharma-continuum/fast-syntax-highlighting

# Auto suggestions
zinit light zsh-users/zsh-autosuggestions

# FZF tab completion
zinit light Aloxaf/fzf-tab

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