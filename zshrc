#!/usr/bin/env zsh
# =============================================================================
# Main ZSH Configuration - Simplified Modular Loader
# Version: loaded from VERSION
# =============================================================================

setopt no_xtrace 2>/dev/null

# Start a fresh, shell-local timer for every zshrc load.  Do not inherit a
# parent shell's timing state when launching nested shells.
zmodload zsh/datetime
typeset +gx ZSH_STARTUP_START=$EPOCHREALTIME

# Validate critical environment variables
if [[ -z "$HOME" ]]; then
    echo "[zshrc] Error: HOME environment variable is not set" >&2
    return 1 2>/dev/null || exit 1
fi

# Set ZSH configuration root directory (compatible with direct calls)
# Note: zshenv should have already set this via typeset -grx
if [[ -z "$ZSH_CONFIG_DIR" ]]; then
    export ZSH_CONFIG_DIR="$HOME/.config/zsh"
    echo "[zshrc] Warning: ZSH_CONFIG_DIR was not set by zshenv, using default" >&2
fi

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
        # Load file and report errors instead of silencing them
        source "$file" || {
            echo "❌ Error: Failed to load $description" >&2
            return 1
        }
        return 0
    else
        return 1
    fi
}

# Load environment variables first (core environment setup)
# Note: zshenv is normally loaded by ZSH itself via ZDOTDIR.
# Only source it manually if it wasn't auto-loaded (e.g., ZDOTDIR changed).
if [[ -z "$ZSH_ENV_LOADED" ]]; then
    simple_source "$ZSH_CONFIG_DIR/zshenv" "environment variables"
fi

# Load user local environment overrides when available
if [[ -z "$ZSH_LOCAL_ENV_LOADED" ]]; then
    if simple_source "$ZSH_CONFIG_DIR/env/local/environment.env" "local environment variables"; then
        export ZSH_LOCAL_ENV_LOADED=1
    fi
fi

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

# Load theme configuration (ensure no xtrace to avoid candidate='' output)
setopt no_xtrace 2>/dev/null
simple_source "$ZSH_CONFIG_DIR/themes/prompt.zsh" "theme configuration"

# Load local personalization configuration (optional)
simple_source "$ZSH_CONFIG_DIR/local.zsh" "local configuration"

# Load per-host personalization (optional): env/local/hosts/<hostname>.env
# Lets a single framework repo carry different settings per server without
# committing machine-specific config. Only activates if the host file exists.
local host_name="${HOST:-$(hostname 2>/dev/null)}"
local host_env_file="$ZSH_CONFIG_DIR/env/local/hosts/${host_name}.env"
if [[ -f "$host_env_file" ]]; then
    simple_source "$host_env_file" "host environment ($host_name)"
fi

# Enhanced loading summary. Export so perf/validation helpers can read it.
export ZSH_STARTUP_TIME=$(printf "%.3f" $(( EPOCHREALTIME - ZSH_STARTUP_START )))
echo "✅ ZSH config loaded in ${ZSH_STARTUP_TIME}s (${#ZSH_MODULES_LOADED[@]} modules)" >&2

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

# Ensure script returns success
true
