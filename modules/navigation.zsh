#!/usr/bin/env zsh
# =============================================================================
# Navigation Module
# =============================================================================

# Settings
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS CDABLE_VARS
setopt EXTENDED_GLOB NO_CASE_GLOB

# Aliases
alias -g ...='../..' ....='../../..' .....='../../../..'
alias -g G='| grep' L='| less' H='| head' T='| tail'

# Functions
mkcd() {
    [[ -n "$1" ]] || return 1
    mkdir -p "$1" && cd "$1"
}

up() {
    local levels="${1:-1}"
    local path=""
    for ((i=1; i<=levels; i++)); do path="../$path"; done
    cd "$path"
}

ZSH_MODULES_LOADED+=(navigation)
