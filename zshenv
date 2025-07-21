#!/usr/bin/env zsh
# =============================================================================
# ZSH Environment Variables - Core Configuration
# =============================================================================

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# ZSH specific paths
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
export ZSH_DATA_DIR="${XDG_DATA_HOME}/zsh"

# History configuration
export HISTFILE="${ZSH_DATA_DIR}/history"
export HISTSIZE=50000
export SAVEHIST=50000

# Terminal settings
export TERM=xterm-256color
export COLORTERM=truecolor

# Development tools
export EDITOR="${EDITOR:-code}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"

# PATH configuration is now handled by the dedicated path module
# Load optional configurations (for environment variables only)
if [[ -f "$ZSH_CONFIG_DIR/env/development.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/env/development.zsh"
fi

if [[ -f "$ZSH_CONFIG_DIR/env/local.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/env/local.zsh"
fi
