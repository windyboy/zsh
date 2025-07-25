#!/usr/bin/env zsh
# =============================================================================
# Local Configuration - Machine Specific Settings
# =============================================================================

# =============================================================================
# Local Reload Functions (Enhanced)
# =============================================================================

# Source reload function (for debugging)
reload_source() {
    echo "🔄 Sourcing ZSH configuration..."
    local start_time=$EPOCHREALTIME

    # Source zshenv first (if it exists)
    if [[ -f ~/.zshenv ]]; then
        echo "📁 Sourcing ~/.zshenv..."
        source ~/.zshenv
    fi

    # Then source the main zshrc
    source ~/.config/zsh/zshrc

    local end_time=$EPOCHREALTIME
    local duration=$(printf "%.3f" $((end_time - start_time)))
    echo "✅ Configuration reloaded in ${duration}s"
}

# Source only zshenv function
reload_zshenv() {
    echo "🔄 Sourcing ~/.zshenv..."
    if [[ -f ~/.zshenv ]]; then
        local start_time=$EPOCHREALTIME
        source ~/.zshenv
        local end_time=$EPOCHREALTIME
        local duration=$(printf "%.3f" $((end_time - start_time)))
        echo "✅ ~/.zshenv reloaded in ${duration}s"
    else
        echo "❌ ~/.zshenv not found"
    fi
}

# Aliases for reload functions
alias r='reload_source'
alias rs='reload_source'
alias rz='reload_source'
alias rsenv='reload_zshenv'
alias sz='source ~/.zshenv'

# =============================================================================
# Local Customizations
# =============================================================================

# Add your personal aliases here
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='htop'  # If you have htop installed

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Add your personal functions here
# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
function extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick directory size
dirsize() {
    du -sh "${1:-.}"
}

# Find process by name
psgrep() {
    ps aux | grep -i "$1" | grep -v grep
}

# Add your personal environment variables here
export EDITOR='nvim'  # or your preferred editor
export VISUAL='nvim'
export PAGER='less'
export LESS='-R --use-color -Dd+r$Du+b'

# Machine-specific configurations
case "$(/usr/bin/uname)" in
    Darwin)
        # macOS specific settings
        export BROWSER="open"
        ;;
    Linux)
        # Linux specific settings
        export BROWSER="xdg-open"
        ;;
esac

# Add any other local configurations here

