#!/usr/bin/env zsh
# =============================================================================
# Aliases and Functions Module - Common Aliases and High-Frequency Functions
# Description: Only high-frequency, essential, memorable commands with unified lowercase naming and clear comments.
# =============================================================================

# -------------------- File/Directory Operations --------------------
# Directory navigation
alias ..='cd ..' ...='cd ../..' ....='cd ../../..' ~='cd ~' -- -='cd -'

# File operations (safe mode - defined in core.zsh)
# alias cp='cp -i' mv='mv -i' rm='rm -i'

# Clear screen, disk, memory
alias c='clear' df='df -h' du='du -h' top='htop'

# -------------------- ls/eza Unified Style --------------------
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -la --color=always --group-directories-first --icons'
    alias la='eza -a --color=always --group-directories-first --icons'
else
    alias ls='ls --color=auto' ll='ls -la --color=auto' la='ls -A --color=auto'
fi

# -------------------- Git Shortcuts --------------------
alias g='git' ga='git add' gc='git commit -v' gd='git diff' gl='git pull' gp='git push' gst='git status' glog='git log --oneline --decorate --graph'

# -------------------- Node/Python Shortcuts --------------------
if command -v npm >/dev/null 2>&1; then
    alias ni='npm install' nr='npm run' ns='npm start' nt='npm test'
fi
if command -v python3 >/dev/null 2>&1; then
    alias py='python3' pip='pip3'
fi

# -------------------- Quick Edit/Navigation --------------------
# Quick edit configuration
alias zshrc='${EDITOR:-code} ~/.config/zsh/zshrc'
alias zshenv='${EDITOR:-code} ~/.config/zsh/zshenv'
# Quick navigation
alias projects='cd ~/Projects' downloads='cd ~/Downloads' documents='cd ~/Documents'

# -------------------- Time --------------------
alias now='date +"%T"' nowdate='date +"%d-%m-%Y"'

# -------------------- High-Frequency Functions --------------------
# Create directory and enter
mkcd() {
    [[ $# -eq 0 ]] && echo "Usage: mkcd <directory_name>" && return 1
    mkdir -p "$1" && cd "$1"
}
# Quick directory navigation up
up() {
    local levels=${1:-1} path=""
    for ((i=0; i<levels; i++)); do path="../$path"; done
    cd "$path"
}
# Safe delete (move to trash)
trash() {
    [[ $# -eq 0 ]] && echo "Usage: trash <file1> [file2] ..." && return 1
    local trash_dir="$HOME/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    for file in "$@"; do
        if [[ -e "$file" ]]; then
            local basename=$(basename "$file")
            local timestamp=$(date +%Y%m%d_%H%M%S)
            mv "$file" "$trash_dir/${basename}_${timestamp}"
            echo "Moved to trash: $file"
        else
            echo "Not found: $file"
        fi
    done
}

# Start local HTTP server (merge serve, prioritize function)
unalias serve 2>/dev/null
serve() {
    local port="${1:-8000}" dir="${2:-.}"
    echo "Starting HTTP server: port $port, directory $dir"
    python3 -m http.server "$port" --directory "$dir"
}
# Get external IP
myip() { curl -s ifconfig.me; }
# Quick git commit
function gcm() {
    [[ $# -eq 0 ]] && echo "Usage: gcm <message>" && return 1
    git commit -m "$*"
}

# -------------------- Reserved Custom Area --------------------
# Custom aliases/functions can be added in the custom/ directory

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED aliases"
echo "INFO: Aliases module initialized"
