#!/usr/bin/env zsh
# =============================================================================
# Main ZSH Configuration - Simplified Modular Loader
# Version: 5.0 - Enhanced with Testing and Monitoring
# =============================================================================

# Set ZSH configuration root directory (compatible with direct calls)
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

# Minimum required version
autoload -Uz is-at-least
if ! is-at-least 5.8 $ZSH_VERSION; then
    echo "[zshrc] Warning: ZSH 5.8+ recommended. Current: $ZSH_VERSION" >&2
fi

# Load environment variables first (core environment setup)
if [[ -f "$ZSH_CONFIG_DIR/zshenv" ]]; then
    source "$ZSH_CONFIG_DIR/zshenv"
fi

# Load core modules (order cannot be changed)
for mod in core security navigation path plugins completion aliases keybindings utils; do
    local modfile="$ZSH_CONFIG_DIR/modules/${mod}.zsh"
    if [[ -f "$modfile" ]]; then
        source "$modfile"
    else
        echo "[zshrc] Warning: module not found: $modfile" >&2
    fi
done

# Load theme configuration
if [[ -f "$ZSH_CONFIG_DIR/themes/prompt.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/themes/prompt.zsh"
fi

# Load user custom extensions (optional)
if [[ -d "$ZSH_CONFIG_DIR/modules/custom" ]]; then
    for custom in "$ZSH_CONFIG_DIR/modules/custom"/*.zsh(N); do
        [[ -f "$custom" ]] && source "$custom"
    done
fi

# Load local personalization configuration (optional)
if [[ -f "$ZSH_CONFIG_DIR/local.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/local.zsh"
fi

# End message
echo "INFO: zshrc loaded all modules and custom configs"
