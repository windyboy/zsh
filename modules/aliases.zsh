#!/usr/bin/env zsh
# =============================================================================
# Aliases and Functions Module - Simplified Productivity Tools
# Version: 4.0 - Streamlined Alias and Function Management
# =============================================================================

# =============================================================================
# SYSTEM ALIASES
# =============================================================================

# Load tools detection module
if [[ -f "$ZSH_CONFIG_DIR/modules/tools.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/tools.zsh"
fi

# Enhanced ls with eza (if available)
if has_tool eza; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -la --color=always --group-directories-first --icons'
    alias la='eza -a --color=always --group-directories-first --icons'
    alias lt='eza -T --color=always --group-directories-first --icons'
else
    # Fallback to standard ls
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
    alias l.='ls -d .* --color=auto'
fi

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Directory operations
alias md='mkdir -p'
alias rd='rmdir'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ln='ln -i'

# Force operation aliases
alias rmf='rm -f'
alias cpf='cp -f'
alias mvf='mv -f'

# =============================================================================
# SYSTEM INFORMATION ALIASES
# =============================================================================

# Process management
alias ps='ps aux'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias top='htop'

# System information
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias mount='mount | column -t'

# Network
alias ping='ping -c 5'
alias ports='netstat -tulanp'
alias wget='wget -c'

# =============================================================================
# DEVELOPMENT TOOLS ALIASES
# =============================================================================

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcb='git checkout -b'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gl='git pull'
alias glog='git log --oneline --decorate --graph'
alias gp='git push'
alias gst='git status'
alias gsta='git stash save'
alias gstp='git stash pop'

# Docker aliases
if has_tool docker; then
    alias d='docker'
    alias dc='docker-compose'
    alias dcu='docker-compose up'
    alias dcd='docker-compose down'
    alias dcb='docker-compose build'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias drmi='docker rmi'
    alias drmf='docker system prune -f'
fi

# Node.js/NPM aliases
if has_tool npm; then
    alias ni='npm install'
    alias nid='npm install --save-dev'
    alias nig='npm install --global'
    alias nr='npm run'
    alias ns='npm start'
    alias nt='npm test'
    alias nu='npm update'
    alias nci='npm ci'
fi

# Yarn aliases
if has_tool yarn; then
    alias y='yarn'
    alias ya='yarn add'
    alias yad='yarn add --dev'
    alias yr='yarn run'
    alias ys='yarn start'
    alias yt='yarn test'
    alias yu='yarn upgrade'
fi

# Bun aliases
if has_tool bun; then
    alias b='bun'
    alias bi='bun install'
    alias ba='bun add'
    alias bad='bun add --dev'
    alias br='bun run'
    alias bt='bun test'
    alias bu='bun update'
fi

# Python aliases
if has_tool python3; then
    alias py='python3'
    alias pip='pip3'
    alias venv='python3 -m venv'
    alias serve='python3 -m http.server'
fi

# =============================================================================
# PRODUCTIVITY ALIASES
# =============================================================================

# Quick edit
alias zshrc='${EDITOR:-code} ~/.config/zsh/zshrc'
alias zshenv='${EDITOR:-code} ~/.config/zsh/zshenv'

# Quick navigation
alias projects='cd ~/Projects'
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'

# System shortcuts
alias c='clear'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime='date +"%d-%m-%Y %T"'
alias nowdate='date +"%d-%m-%Y"'

# =============================================================================
# UTILITY ALIASES
# =============================================================================

# Extract archives
alias extract='tar -xzf'

# =============================================================================
# DIRECTORY OPERATIONS FUNCTIONS
# =============================================================================

# Create directory and enter it
function mkcd() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    
    mkdir -p "$1" && cd "$1"
}

# Quick way to go up directories
function up() {
    local levels=${1:-1}
    local path=""
    
    for ((i=0; i<levels; i++)); do
        path="../$path"
    done
    
    cd "$path"
}

# Show directory size
function dirsize() {
    local target="${1:-.}"
    if [[ -d "$target" ]]; then
        du -sh "$target"/* 2>/dev/null | sort -hr
    else
        echo "Error: '$target' is not a directory"
        return 1
    fi
}

# Find large files
function findlarge() {
    local size="${1:-100M}"
    local path="${2:-.}"
    
    echo "Finding files larger than $size in $path..."
    find "$path" -type f -size "+$size" -exec ls -lh {} \; 2>/dev/null | \
    awk '{print $5 "\t" $9}' | sort -hr
}

# =============================================================================
# FILE OPERATIONS FUNCTIONS
# =============================================================================

# Safe delete (move to trash)
function trash() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: trash <file1> [file2] ..."
        return 1
    fi
    
    local trash_dir="$HOME/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    
    for file in "$@"; do
        if [[ -e "$file" ]]; then
            local basename=$(basename "$file")
            local timestamp=$(date +%Y%m%d_%H%M%S)
            mv "$file" "$trash_dir/${basename}_${timestamp}"
            echo "Moved '$file' to trash"
        else
            echo "Warning: '$file' does not exist"
        fi
    done
}

# Create backup file
function backup() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: backup <file>"
        return 1
    fi
    
    for file in "$@"; do
        if [[ -e "$file" ]]; then
            local backup_name="${file}.backup.$(date +%Y%m%d_%H%M%S)"
            cp -r "$file" "$backup_name"
            echo "Created backup: $backup_name"
        else
            echo "Warning: '$file' does not exist"
        fi
    done
}

# Extract various compressed files
function extract() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: extract <file>"
        return 1
    fi
    
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            case "$file" in
                *.tar.bz2)   tar xjf "$file"     ;;
                *.tar.gz)    tar xzf "$file"     ;;
                *.bz2)       bunzip2 "$file"     ;;
                *.rar)       unrar x "$file"     ;;
                *.gz)        gunzip "$file"      ;;
                *.tar)       tar xf "$file"      ;;
                *.tbz2)      tar xjf "$file"     ;;
                *.tgz)       tar xzf "$file"     ;;
                *.zip)       unzip "$file"       ;;
                *.Z)         uncompress "$file"  ;;
                *.7z)        7z x "$file"        ;;
                *)           echo "'$file' cannot be extracted via extract()" ;;
            esac
        else
            echo "'$file' is not a valid file"
        fi
    done
}

# =============================================================================
# NETWORK OPERATIONS FUNCTIONS
# =============================================================================

# Start simple HTTP server
function serve() {
    local port="${1:-8000}"
    local directory="${2:-.}"
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || (( port < 1024 || port > 65535 )); then
        echo "Error: Port must be between 1024 and 65535"
        return 1
    fi
    
    if [[ ! -d "$directory" ]]; then
        echo "Error: Directory '$directory' does not exist"
        return 1
    fi
    
    echo "Starting HTTP server on port $port, serving directory: $directory"
    echo "Access at: http://localhost:$port"
    echo "Press Ctrl+C to stop"
    
    cd "$directory" || return 1
    
    if command -v python3 >/dev/null; then
        python3 -m http.server "$port"
    elif command -v python >/dev/null; then
        python -m SimpleHTTPServer "$port"
    else
        echo "Error: Python not found"
        return 1
    fi
}

# Get external IP address
function myip() {
    echo "Getting external IP address..."
    local ip
    
    # Try multiple services
    local services=(
        "https://ipinfo.io/ip"
        "https://icanhazip.com"
        "https://ifconfig.me"
        "https://ipecho.net/plain"
    )
    
    for service in "${services[@]}"; do
        ip=$(curl -s --connect-timeout 5 "$service" 2>/dev/null)
        if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "External IP: $ip"
            return 0
        fi
    done
    
    echo "Error: Could not determine external IP"
    return 1
}

# =============================================================================
# DEVELOPMENT TOOLS FUNCTIONS
# =============================================================================

# Create a new project with git
function newproject() {
    local project_name="$1"
    local project_type="${2:-basic}"
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: newproject <name> [type]"
        echo "Types: basic, node, python, react, vue"
        return 1
    fi
    
    if [[ -d "$project_name" ]]; then
        echo "Error: Directory '$project_name' already exists"
        return 1
    fi
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    case "$project_type" in
        "node")
            npm init -y
            echo "Node.js project created"
            ;;
        "python")
            python3 -m venv venv
            echo "Python project created with virtual environment"
            ;;
        "react")
            npx create-react-app . --yes
            echo "React project created"
            ;;
        "vue")
            npm create vue@latest . --yes
            echo "Vue project created"
            ;;
        *)
            echo "Basic project created"
            ;;
    esac
    
    git init
    echo "Git repository initialized"
}

# Quick git commit with message
function gcm() {
    local message="$1"
    
    if [[ -z "$message" ]]; then
        echo "Usage: gcm <message>"
        return 1
    fi
    
    git add .
    git commit -m "$message"
}

# =============================================================================
# SYSTEM UTILITY FUNCTIONS
# =============================================================================

# Show system information
function sysinfo() {
    echo "🖥️  System Information"
    echo "====================="
    echo "OS: $(uname -s) $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Shell: $SHELL"
    echo "Home: $HOME"
    
    if command -v neofetch >/dev/null 2>&1; then
        echo ""
        neofetch --stdout
    fi
}

# Show disk usage
function diskusage() {
    echo "💾 Disk Usage"
    echo "============="
    df -h | grep -E '^/dev/'
}

# Show memory usage
function memusage() {
    echo "🧠 Memory Usage"
    echo "==============="
    if command -v free >/dev/null 2>&1; then
        free -h
    else
        vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages free: (\d+)/ and printf("Free: %.1f MB\n", $1 * $size / 1048576); /Pages active: (\d+)/ and printf("Active: %.1f MB\n", $1 * $size / 1048576);'
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Mark aliases module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED aliases"

log "Aliases and functions module initialized" "success" "aliases" 