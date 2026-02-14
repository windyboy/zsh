#!/usr/bin/env zsh
# =============================================================================
# Aliases Module
# =============================================================================

# System
alias ls='ls -G'
alias ll='ls -lh'
alias la='ls -A'
alias grep='grep --color=auto'

# Development
alias g='git'
alias d='docker'
alias dc='docker-compose'

# Config
alias zconf='code $ZSH_CONFIG_DIR'
alias zreload='source $ZSH_CONFIG_DIR/zshrc'

ZSH_MODULES_LOADED+=(aliases)
