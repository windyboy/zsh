#!/usr/bin/env zsh
# =============================================================================
# Colors Module - Standardized Color Output
# =============================================================================

# Standard colors
color_red()    { echo -e "\033[31m$*\033[0m"; }
color_green()  { echo -e "\033[32m$*\033[0m"; }
color_yellow() { echo -e "\033[33m$*\033[0m"; }
color_blue()   { echo -e "\033[34m$*\033[0m"; }

# Logging levels
zsh_info()  { color_green "ℹ️  $*"; }
zsh_warn()  { color_yellow "⚠️  $*"; }
zsh_error() { color_red "❌ $*"; return 1; }

ZSH_MODULES_LOADED+=(colors)
