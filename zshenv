#!/usr/bin/env zsh
# =============================================================================
# ZSH Core Environment Variables
# =============================================================================

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# ZSH Specific Paths (Set once, exported globally)
# Note: Using typeset -gx instead of -grx to allow reloading without errors
[[ -z "$ZSH_CONFIG_DIR" ]] && typeset -gx ZSH_CONFIG_DIR="${XDG_CONFIG_HOME}/zsh"
[[ -z "$ZSH_CACHE_DIR" ]] && typeset -gx ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
[[ -z "$ZSH_DATA_DIR" ]] && typeset -gx ZSH_DATA_DIR="${XDG_DATA_HOME}/zsh"
[[ -z "$ZINIT_HOME" ]] && typeset -gx ZINIT_HOME="${XDG_DATA_HOME}/zinit"
export ZDOTDIR="${ZSH_CONFIG_DIR}"

# History Configuration
export HISTFILE="${ZSH_DATA_DIR}/history"
export HISTSIZE=50000
export SAVEHIST=50000

# Terminal Settings
export TERM=xterm-256color
export COLORTERM=truecolor
export EDITOR="${EDITOR:-code}"
export VISUAL="${VISUAL:-$EDITOR}"

# Initialize module tracking
typeset -gax ZSH_MODULES_LOADED=()

# Record startup time for performance monitoring
zmodload zsh/datetime
export ZSH_STARTUP_START=$EPOCHREALTIME

# Mark environment as loaded to prevent duplicate loading
export ZSH_ENV_LOADED=1
