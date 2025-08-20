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

# Simple source function for initial loading
simple_source() {
    local file="$1"
    local description="${2:-$file}"
    
    if [[ -f "$file" ]]; then
        # Special handling for theme configuration to allow Oh My Posh output
        if [[ "$description" == "theme configuration" ]]; then
            if source "$file"; then
                echo "✅ Loaded: $description" >&2
                return 0
            else
                return 1
            fi
        else
            # For other files, source directly and capture any errors
            if source "$file" 2>/dev/null; then
                echo "✅ Loaded: $description" >&2
                return 0
            else
                return 1
            fi
        fi
    else
        return 1
    fi
}

# Load environment variables first (core environment setup)
simple_source "$ZSH_CONFIG_DIR/zshenv" "environment variables"

# Load core modules (order cannot be changed)
local loaded_modules=0
local module_list=(colors core security navigation path plugins completion aliases keybindings utils)
local total_modules=${#module_list[@]}

for mod in "${module_list[@]}"; do
    local modfile="$ZSH_CONFIG_DIR/modules/${mod}.zsh"
    if simple_source "$modfile" "$mod module"; then
        ((loaded_modules++))
    fi
done

# Load theme configuration
simple_source "$ZSH_CONFIG_DIR/themes/prompt.zsh" "theme configuration"

# Load user custom extensions (optional)
if [[ -d "$ZSH_CONFIG_DIR/modules/custom" ]]; then
    for custom in "$ZSH_CONFIG_DIR/modules/custom"/*.zsh(N); do
        [[ -f "$custom" ]] && simple_source "$custom" "custom module: ${custom##*/}"
    done
fi

# Load local personalization configuration (optional)
simple_source "$ZSH_CONFIG_DIR/local.zsh" "local configuration"

# Enhanced loading summary
echo "✅ ZSH config loaded ($loaded_modules/$total_modules modules + extras)" >&2

# Load NVM configuration
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
