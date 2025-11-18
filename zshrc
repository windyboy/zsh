#!/usr/bin/env zsh
# =============================================================================
# Main ZSH Configuration - Simplified Modular Loader
# Version: 5.3.1 - Enhanced with Testing and Monitoring
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
local module_list=(colors core navigation path plugins completion aliases keybindings utils)
local total_modules=${#module_list[@]}

for mod in "${module_list[@]}"; do
    local modfile="$ZSH_CONFIG_DIR/modules/${mod}.zsh"
    if simple_source "$modfile" "$mod module"; then
        ((loaded_modules++))
    fi
done

# Load theme configuration
simple_source "$ZSH_CONFIG_DIR/themes/prompt.zsh" "theme configuration"

# Load local personalization configuration (optional)
simple_source "$ZSH_CONFIG_DIR/local.zsh" "local configuration"

# Enhanced loading summary
echo "✅ ZSH config loaded ($loaded_modules/$total_modules modules + extras)" >&2

# Load NVM configuration
export NVM_DIR="$HOME/.config/nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # Load NVM only when the script is present to avoid affecting the caller's status
    source "$NVM_DIR/nvm.sh"
fi

if [[ -s "$NVM_DIR/bash_completion" ]]; then
    # Load the complementary bash completion when available without altering exit codes
    source "$NVM_DIR/bash_completion"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
