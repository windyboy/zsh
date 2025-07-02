#!/usr/bin/env zsh
# Minimal zsh configuration for performance testing

# Basic settings
export HISTFILE="${HOME}/.local/share/zsh/history"
export HISTSIZE=1000
export SAVEHIST=1000

# Basic completion
autoload -Uz compinit
compinit -C

# Basic prompt
PS1='%n@%m %~ %# '

echo "Minimal configuration loaded"
