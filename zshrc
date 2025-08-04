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
                echo "⚠️  Warning: Failed to load $description" >&2
                return 1
            fi
        else
            # For other files, capture stderr to see what's happening
            local stderr_output
            stderr_output=$(source "$file" 2>&1)
            local exit_code=$?
            
            if [[ $exit_code -eq 0 ]]; then
                echo "✅ Loaded: $description" >&2
                return 0
            else
                echo "⚠️  Warning: Failed to load $description (exit code: $exit_code)" >&2
                [[ -n "$stderr_output" ]] && echo "Error output: $stderr_output" >&2
                return 1
            fi
        fi
    else
        echo "⚠️  Warning: File not found: $description" >&2
        return 1
    fi
}

# Load environment variables first (core environment setup)
simple_source "$ZSH_CONFIG_DIR/zshenv" "environment variables"

# Load core modules (order cannot be changed)
local loaded_modules=0
local module_list=(core security navigation path plugins completion aliases keybindings utils colors)
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
if [[ $loaded_modules -eq $total_modules ]]; then
    echo "✅ All modules loaded successfully ($loaded_modules/$total_modules)" >&2
else
    echo "⚠️  Partially loaded: $loaded_modules/$total_modules modules" >&2
fi 