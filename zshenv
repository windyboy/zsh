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
# TERM and COLORTERM are intentionally not set: the terminal emulator (or
# SSH client) declares them. Forcing truecolor here made Oh My Posh emit
# 24-bit CSI that a typical Ubuntu console/SSH session does not treat as
# zero-width, so ZLE painted each keystroke in the wrong column.
# `code` is absent on typical Linux/SSH hosts; fall back to vi (POSIX) so
# git commit and editor widgets never break there.
if [[ -z "$EDITOR" ]]; then
    if (( ${+commands[code]} )); then
        export EDITOR=code
    else
        export EDITOR=vi
    fi
fi
export VISUAL="${VISUAL:-$EDITOR}"

# Initialize module tracking
typeset -gax ZSH_MODULES_LOADED=()

# Shell-local load guard: do not export so nested shells re-run zshenv cleanly
# instead of inheriting a parent's ZSH_ENV_LOADED=1.
typeset +gx ZSH_ENV_LOADED=1
