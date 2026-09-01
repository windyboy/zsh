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
# Note: zshenv should have already set this via typeset -gx
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
# NOTE: sourced BEFORE modules — keep it to `export`s and feature toggles
# (e.g. ZSH_ENABLE_PLUGINS, which plugins.zsh reads at module load).
# PATH additions go in the per-host file below (add_to_path needs modules).
if [[ -z "$ZSH_LOCAL_ENV_LOADED" ]]; then
    if simple_source "$ZSH_CONFIG_DIR/env/local/environment.env" "local environment variables"; then
        export ZSH_LOCAL_ENV_LOADED=1
    fi
fi

# Load core modules (order cannot be changed)
# env is the PATH/runtime-defaults module (add_to_path, PAGER/LANG, NVM lazy loader).
local module_list=(colors core env navigation plugins completion aliases keybindings utils)

for mod in "${module_list[@]}"; do
    simple_source "$ZSH_CONFIG_DIR/modules/${mod}.zsh" "$mod module"
done
unset module_list mod

# Load theme configuration (ensure no xtrace to avoid candidate='' output)
setopt no_xtrace 2>/dev/null
simple_source "$ZSH_CONFIG_DIR/themes/prompt.zsh" "theme configuration"

# Load local personalization configuration (optional)
simple_source "$ZSH_CONFIG_DIR/local.zsh" "local configuration"

# Load per-host personalization (optional): env/local/hosts/<hostname>.env
# Lets a single framework repo carry different settings per server without
# committing machine-specific config. Only activates if the host file exists.
# Loaded AFTER modules, so PATH additions can use add_to_path (env.zsh).
local host_name="${HOST:-$(hostname 2>/dev/null)}"
local host_env_file="$ZSH_CONFIG_DIR/env/local/hosts/${host_name}.env"
if [[ -f "$host_env_file" ]]; then
    simple_source "$host_env_file" "host environment ($host_name)"
fi
unset host_name host_env_file

# Enhanced loading summary. Shell-local (not exported): perf/validation helpers run
# in-shell, and exporting would leak a float into every child process (W1N-221).
ZSH_STARTUP_TIME=$(printf "%.3f" $(( EPOCHREALTIME - ZSH_STARTUP_START )))
# Startup banner is opt-in (set ZSH_PROFILE=1, e.g. in env/local); use `perf --startup` for real timing.
[[ "${ZSH_PROFILE:-0}" == "1" ]] && echo "✅ ZSH config loaded in ${ZSH_STARTUP_TIME}s (${#ZSH_MODULES_LOADED[@]} modules)" >&2

# NVM lazy loader lives in modules/env.zsh (single definition; W1N-221)

# Ensure script returns success
true

# bun completions (W1N-221: $HOME-based so it resolves on macOS and Linux;
# the old hardcoded /home/windy path never matched on this Mac). Guarded with
# if so a missing bun install cannot set the zshrc's exit status (CI runners
# have no ~/.bun; a bare `[ -s ] && source` returns 1 and fails `source zshrc`).
if [ -s "${BUN_INSTALL:-$HOME/.bun}/_bun" ]; then
    source "${BUN_INSTALL:-$HOME/.bun}/_bun"
fi

# NOTE: the 'forge initialize' block that used to live here was removed.
# `forge zsh theme` installs a second prompt engine on top of oh-my-posh that
# re-renders the prompt while you type, garbling the input line (duplicated
# characters). Running `forge zsh setup` will re-add the block and the bug.
