#!/usr/bin/env zsh
# =============================================================================
# Aliases Module
# =============================================================================

# System
# ls color flag differs by platform: BSD ls (macOS) colors with -G, while on
# GNU ls -G means --no-group (hides the group column) and color needs --color.
if [[ "$OSTYPE" == darwin* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias ll='ls -lh'
alias la='ls -A'
alias grep='grep --color=auto'

# Development
alias g='git'
alias d='docker'
alias dc='docker-compose'

# Config
alias zconf='${EDITOR:-code} $ZSH_CONFIG_DIR'
# Re-read local feature toggles as well as the main configuration.
# Delegates to reload() so module tracking is reset identically.
alias zreload='reload'

ZSH_MODULES_LOADED+=(aliases)
