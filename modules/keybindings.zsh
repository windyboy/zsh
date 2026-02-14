#!/usr/bin/env zsh
# =============================================================================
# Keybindings Module
# =============================================================================

# Use emacs mode by default
bindkey -e

# Basic bindings
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey '^I' complete-word
bindkey '^[[Z' reverse-menu-complete

# Quick edit shortcut (Alt+E)
bindkey -s '\ee' 'code .\n'

ZSH_MODULES_LOADED+=(keybindings)
