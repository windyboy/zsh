#!/usr/bin/env zsh
# =============================================================================
# Main ZSH Configuration - Simplified Modular Loader
# Version: 5.3.1 - Enhanced with Testing and Monitoring
# =============================================================================

# Validate critical environment variables
if [[ -z "$HOME" ]]; then
    echo "[zshrc] Error: HOME environment variable is not set" >&2
    return 1 2>/dev/null || exit 1
fi

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
            source "$file" || true
            return 0
        else
            # For other files, source directly and capture any errors
            source "$file" 2>/dev/null || true
            return 0
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

# Lazy load NVM to improve startup time
export NVM_DIR="$HOME/.config/nvm"
nvm() {
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
        if [[ -s "$NVM_DIR/bash_completion" ]]; then
            source "$NVM_DIR/bash_completion"
        fi
        nvm "$@"
    else
        echo "NVM not installed. Install from https://github.com/nvm-sh/nvm" >&2
        return 1
    fi
}

# Lazy load bun to improve startup time
bun() {
    if [[ -s "$HOME/.bun/_bun" ]]; then
        source "$HOME/.bun/_bun"
        # Add to PATH if not already present
        if [[ -n "$BUN_INSTALL" ]] && [[ -d "$BUN_INSTALL/bin" ]]; then
            case ":$PATH:" in
                *:"$BUN_INSTALL/bin":*)
                    ;;  # Already in PATH, skip
                *)
                    export PATH="$BUN_INSTALL/bin:$PATH"
                    ;;
            esac
        elif [[ -d "$HOME/.bun/bin" ]]; then
            export BUN_INSTALL="$HOME/.bun"
            case ":$PATH:" in
                *:"$BUN_INSTALL/bin":*)
                    ;;  # Already in PATH, skip
                *)
                    export PATH="$BUN_INSTALL/bin:$PATH"
                    ;;
            esac
        fi
        bun "$@"
    else
        echo "Bun not installed. Install from https://bun.sh" >&2
        return 1
    fi
}

# Ensure script returns success
true
