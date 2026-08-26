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
# the old hardcoded /home/windy path never matched on this Mac)
[ -s "${BUN_INSTALL:-$HOME/.bun}/_bun" ] && source "${BUN_INSTALL:-$HOME/.bun}/_bun"

# >>> forge initialize >>>
# !! Contents within this block are managed by 'forge zsh setup' !!
# !! Do not edit manually - changes will be overwritten !!

# Add required zsh plugins if not already present
if [[ ! " ${plugins[@]} " =~ " zsh-autosuggestions " ]]; then
    plugins+=(zsh-autosuggestions)
fi
if [[ ! " ${plugins[@]} " =~ " zsh-syntax-highlighting " ]]; then
    plugins+=(zsh-syntax-highlighting)
fi

# Load forge shell plugin (commands, completions, keybindings) if not already loaded
# Timeout-guarded + failure marker (W1N-221): forge zsh plugin/theme can hang on a
# stalled backend call. On timeout, write a marker and skip for 60 min so fresh
# shells stay fast; success removes the marker. (`forge zsh setup` regenerates this.)
if [[ -z "$_FORGE_PLUGIN_LOADED" ]]; then
    local _forge_marker="${ZSH_CACHE_DIR}/forge-plugin-failed"
    if [[ ! -f "$_forge_marker" ]] || [[ -z "$(find "$_forge_marker" -mmin -60 2>/dev/null)" ]]; then
        if _forge_plugin="$(timeout 3 forge zsh plugin 2>/dev/null)"; then
            [[ -n "$_forge_plugin" ]] && eval "$_forge_plugin"
            rm -f "$_forge_marker" 2>/dev/null
            _FORGE_PLUGIN_LOADED=1
        else
            mkdir -p "${ZSH_CACHE_DIR}" 2>/dev/null
            touch "$_forge_marker" 2>/dev/null
        fi
        unset _forge_plugin
    fi
    unset _forge_marker
fi

# Load forge shell theme (prompt with AI context) if not already loaded
if [[ -z "$_FORGE_THEME_LOADED" ]]; then
    local _forge_theme_marker="${ZSH_CACHE_DIR}/forge-theme-failed"
    if [[ ! -f "$_forge_theme_marker" ]] || [[ -z "$(find "$_forge_theme_marker" -mmin -60 2>/dev/null)" ]]; then
        if _forge_theme="$(timeout 3 forge zsh theme 2>/dev/null)"; then
            [[ -n "$_forge_theme" ]] && eval "$_forge_theme"
            rm -f "$_forge_theme_marker" 2>/dev/null
            _FORGE_THEME_LOADED=1
        else
            mkdir -p "${ZSH_CACHE_DIR}" 2>/dev/null
            touch "$_forge_theme_marker" 2>/dev/null
        fi
        unset _forge_theme
    fi
    unset _forge_theme_marker
fi

# Editor for editing prompts (set during setup)
# To change: update FORGE_EDITOR or remove to use $EDITOR
export FORGE_EDITOR="nvim"
# <<< forge initialize <<<
