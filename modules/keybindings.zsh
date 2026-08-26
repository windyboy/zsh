#!/usr/bin/env zsh
# =============================================================================
# Keybindings Module
# =============================================================================

# Use emacs mode by default
bindkey -e

# Basic bindings
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
# Terminals commonly send either DEL (^?) or BS (^H) for Backspace.  Bind
# both explicitly so a fresh Linux/SSH session does not depend on its tty
# erase setting or terminal profile.
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^[[3~' delete-char
bindkey '^I' complete-word
bindkey '^[[Z' reverse-menu-complete

# Quick edit shortcut (Alt+E) — uses $EDITOR, falling back to VS Code
bindkey -s '\ee' '${EDITOR:-code} .\n'

ZSH_MODULES_LOADED+=(keybindings)
