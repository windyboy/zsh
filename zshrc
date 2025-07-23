#!/usr/bin/env zsh
# =============================================================================
# Main ZSH Configuration - Simplified Modular Loader
# Version: 4.1 - Streamlined for Personal Use
# =============================================================================

# Load environment variables first (core environment setup)
if [[ -f "$HOME/.config/zsh/zshenv" ]]; then
    source "$HOME/.config/zsh/zshenv"
fi

# Set ZSH configuration root directory (compatible with direct calls)
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

# Load core modules (order cannot be changed)
for mod in core path plugins completion aliases keybindings utils; do
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
