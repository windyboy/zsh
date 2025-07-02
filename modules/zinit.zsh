#!/usr/bin/env zsh
# =============================================================================
# Zinit Configuration - Modern Setup
# =============================================================================

# Only load zinit if it's not already loaded
if [[ -z "$ZINIT" ]]; then
    # Modern zinit configuration using hash array
    declare -A ZINIT
    
    # Set custom paths (optional - zinit will use defaults if not set)
    ZINIT[HOME_DIR]="${HOME}/.local/share/zinit"
    ZINIT[BIN_DIR]="${HOME}/.local/share/zinit/zinit.git"
    
    # Install zinit if not present
    if [[ ! -f "${ZINIT[BIN_DIR]}/zinit.zsh" ]]; then
        echo "📦 Installing zinit..."
        mkdir -p "${ZINIT[HOME_DIR]}"
        git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT[BIN_DIR]}"
    fi
    
    # Load zinit
    source "${ZINIT[BIN_DIR]}/zinit.zsh"
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