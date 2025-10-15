#!/usr/bin/env zsh
# =============================================================================
# Aliases and Functions Module - Optimized for High-Frequency Use
# =============================================================================

# -------------------- Directory/File Operations --------------------
alias ..='cd ..'
alias ...='cd ../..'

# -------------------- ls/eza Related --------------------
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -la --color=always --group-directories-first --icons'
    alias la='eza -a --color=always --group-directories-first --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'
    alias la='ls -A --color=auto'
fi

# -------------------- Git Related --------------------
alias g='git'
alias ga='git add'
alias gc='git commit -v'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'
alias gst='git status'
alias glog='git log --oneline --decorate --graph'
unalias gcm 2>/dev/null
gcm() {
    [[ $# -eq 0 ]] && echo "Usage: gcm <message>" && return 1
    git commit -m "$*"
}

# -------------------- Development Tools --------------------
if command -v npm >/dev/null 2>&1; then
    alias ni='npm install'
fi
if command -v python3 >/dev/null 2>&1; then
    alias py='python3'
fi

# -------------------- Configuration/Navigation --------------------
alias zshrc='${EDITOR:-code} ~/.config/zsh/zshrc'

# -------------------- Time/Date --------------------
alias now='date +"%T"'

# -------------------- Other High-Frequency --------------------
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
unalias serve 2>/dev/null
serve() {
    local port="${1:-8000}" dir="${2:-.}"
    echo "Starting HTTP server: port $port, directory $dir"
    python3 -m http.server "$port" --directory "$dir"
}

# -------------------- Reserved Custom Area --------------------
# Custom aliases/functions can be added in the custom/ directory

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED aliases"
