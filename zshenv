#!/usr/bin/env zsh
# =============================================================================
# ZSH Core Environment Variables
# Description: System core environment variables, not managed by templates
# =============================================================================

# =============================================================================
# XDG Base Directory Specification
# Description: Follow XDG standards, define standard locations for user config, cache, and data
# =============================================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# =============================================================================
# ZSH Specific Paths
# Description: Define core paths for ZSH configuration system
# =============================================================================
export ZSH_CONFIG_DIR="${XDG_CONFIG_HOME}/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
export ZSH_DATA_DIR="${XDG_DATA_HOME}/zsh"
export ZDOTDIR="${ZSH_CONFIG_DIR}"

# =============================================================================
# Plugin Manager Configuration
# Description: Set ZINIT_HOME for plugin management
# =============================================================================
export ZINIT_HOME="${XDG_DATA_HOME}/zinit"

# =============================================================================
# History Configuration
# Description: Configure ZSH command history behavior and storage
# =============================================================================
export HISTFILE="${ZSH_DATA_DIR}/history"
export HISTSIZE=50000
export SAVEHIST=50000

# =============================================================================
# Terminal Settings
# Description: Configure terminal display and color support
# =============================================================================
export TERM=xterm-256color
export COLORTERM=truecolor

# =============================================================================
# Development Tools
# Description: Configure default editors for common development tools
# =============================================================================
export EDITOR="${EDITOR:-code}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"

# =============================================================================
# User Environment Configuration Loading
# Description: Load user-specific environment variable configuration
# =============================================================================
# Ensure ZSH_CONFIG_DIR is set
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

if [[ -f "$ZSH_CONFIG_DIR/env/local/environment.env" ]]; then
    source "$ZSH_CONFIG_DIR/env/local/environment.env" 2>/dev/null || true
elif [[ -f "$ZSH_CONFIG_DIR/env/templates/environment.env.template" ]]; then
    : # Template exists but not loaded
fi

# =============================================================================
# Backward Compatibility Support
# Description: Maintain compatibility with old configuration files
# =============================================================================
if [[ -f "$ZSH_CONFIG_DIR/env/local.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/env/local.zsh" 2>/dev/null || true
fi

# =============================================================================
# Configuration Validation
# Description: Validate that critical environment variables are correctly set
# =============================================================================
# Simplified validation: only check if critical variables exist
# [[ -z "$ZSH_CONFIG_DIR" ]] && echo "⚠️  Warning: ZSH_CONFIG_DIR not set"
# [[ -z "$ZSH_CACHE_DIR" ]] && echo "⚠️  Warning: ZSH_CACHE_DIR not set"
# [[ -z "$ZSH_DATA_DIR" ]] && echo "⚠️  Warning: ZSH_DATA_DIR not set"

# =============================================================================
# End of File Marker
# Description: This file is responsible for setting core environment variables
# =============================================================================
