#!/usr/bin/env zsh
# =============================================================================
# Color Utilities Module - Centralized Color Output Functions
# Description: Provides consistent color output functions for all modules
# =============================================================================

# -------------------- Color Functions --------------------
# Red text output
color_red() { echo -e "\033[31m$1\033[0m"; }

# Green text output  
color_green() { echo -e "\033[32m$1\033[0m"; }

# Yellow text output
color_yellow() { echo -e "\033[33m$1\033[0m"; }

# Blue text output
color_blue() { echo -e "\033[34m$1\033[0m"; }

# Magenta text output
color_magenta() { echo -e "\033[35m$1\033[0m"; }

# Cyan text output
color_cyan() { echo -e "\033[36m$1\033[0m"; }

# White text output
color_white() { echo -e "\033[37m$1\033[0m"; }

# Bold text output
color_bold() { echo -e "\033[1m$1\033[0m"; }

# Underlined text output
color_underline() { echo -e "\033[4m$1\033[0m"; }

# -------------------- Status Functions --------------------
# Success message (green)
success() { color_green "✅ $1"; }

# Error message (red)
error() { color_red "❌ $1"; }

# Warning message (yellow)
warning() { color_yellow "⚠️  $1"; }

# Info message (blue)
info() { color_blue "ℹ️  $1"; }

# -------------------- Module Loading Check --------------------
# Check if colors module is already loaded
if [[ -z "$ZSH_COLORS_LOADED" ]]; then
    export ZSH_COLORS_LOADED=1
    echo "INFO: Colors module initialized"
fi 