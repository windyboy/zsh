#!/usr/bin/env zsh
# =============================================================================
# Aliases Module - Unified Module System Integration
# Version: 3.0 - Comprehensive Alias Management
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Alias configuration
ALIAS_LOG="${ZSH_CACHE_DIR}/aliases.log"

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize aliases module
init_aliases() {
    [[ ! -d "$ALIAS_LOG:h" ]] && mkdir -p "$ALIAS_LOG:h"
    
    # Log aliases module initialization
    log_alias_event "Aliases module initialized"
}

# =============================================================================
# ALIAS LOGGING
# =============================================================================

# Log alias events
log_alias_event() {
    local event="$1"
    local level="${2:-info}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $event" >> "$ALIAS_LOG"
}

# =============================================================================
# CONFIGURATION MANAGEMENT ALIASES
# =============================================================================

# ZSH configuration aliases
alias zsh-check='validate_configuration'
alias zsh-reload='zsh_reload'
alias reload='zsh_reload'
alias zsh-perf='zsh_perf_analyze'
alias zsh-perf-dash='zsh_perf_dashboard'
alias zsh-perf-opt='optimize_zsh_performance'
alias zsh-prof='ZSH_PROF=1 exec zsh'
alias zsh-debug='ZSH_DEBUG=1 exec zsh'
alias zsh-test='run_zsh_tests'
alias zsh-test-quick='quick_test'
alias zsh-errors='report_errors'
alias zsh-errors-clear='clear_error_log'
alias zsh-recovery='enter_recovery_mode'
alias zsh-comp-test='_verify_completion_system'

# =============================================================================
# SECURITY ALIASES
# =============================================================================

# Security management aliases
alias security-audit='security_audit'
alias check-suspicious='check_suspicious_files'
alias secure-delete='secure_rm'
alias validate-security='validate_security_config'
alias security-monitor='monitor_security'

# =============================================================================
# HISTORY MANAGEMENT ALIASES
# =============================================================================

# History aliases
alias h='history'
alias hg='history | grep'
alias hist-stats='history_stats'
alias hist-clean='echo "⚠️  This will clear all history. Type: history -c && > \$HISTFILE"'
alias hist-search='history | grep'
alias hist-last='history | tail -10'

# =============================================================================
# FILE SYSTEM ALIASES
# =============================================================================

# Enhanced ls with eza (if available)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -la --color=always --group-directories-first --icons'
    alias la='eza -a --color=always --group-directories-first --icons'
    alias lt='eza -T --color=always --group-directories-first --icons'
    alias l.='eza -a | grep -E "^\."'
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
if command -v docker >/dev/null 2>&1; then
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
if command -v npm >/dev/null 2>&1; then
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
if command -v yarn >/dev/null 2>&1; then
    alias y='yarn'
    alias ya='yarn add'
    alias yad='yarn add --dev'
    alias yr='yarn run'
    alias ys='yarn start'
    alias yt='yarn test'
    alias yu='yarn upgrade'
fi

# Bun aliases
if command -v bun >/dev/null 2>&1; then
    alias b='bun'
    alias bi='bun install'
    alias ba='bun add'
    alias bad='bun add --dev'
    alias br='bun run'
    alias bt='bun test'
    alias bu='bun update'
fi

# Python aliases
if command -v python3 >/dev/null 2>&1; then
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
alias x='extract'

# Network utilities
alias myip='curl -s https://ipinfo.io/ip'
alias localip='ifconfig | grep "inet " | grep -v 127.0.0.1'

# Quick file operations
alias mkdir='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# =============================================================================
# ALIAS MANAGEMENT FUNCTIONS
# =============================================================================

# List all aliases
list_aliases() {
    echo "📋 Available aliases:"
    alias | sort | sed 's/^/  /'
}

# Search aliases
search_aliases() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: search_aliases <query>"
        return 1
    fi
    
    echo "🔍 Searching aliases for: $query"
    alias | grep -i "$query" | sed 's/^/  /'
}

# Alias statistics
alias_stats() {
    local total_aliases=$(alias | wc -l)
    local git_aliases=$(alias | grep -c "git" || echo "0")
    local docker_aliases=$(alias | grep -c "docker" || echo "0")
    local system_aliases=$(alias | grep -c -E "(ls|cd|cp|mv|rm)" || echo "0")
    
    echo "📊 Alias Statistics:"
    echo "  • Total aliases: $total_aliases"
    echo "  • Git aliases: $git_aliases"
    echo "  • Docker aliases: $docker_aliases"
    echo "  • System aliases: $system_aliases"
}

# Validate aliases
validate_aliases() {
    local errors=0
    local warnings=0
    
    echo "🔍 Validating aliases..."
    
    # Check for conflicting aliases
    local conflicts=$(alias | awk '{print $1}' | sed 's/=.*//' | sort | uniq -d)
    if [[ -n "$conflicts" ]]; then
        echo "❌ Conflicting aliases found:"
        echo "$conflicts" | sed 's/^/  /'
        ((errors++))
    fi
    
    # Check for missing commands
    alias | while read line; do
        local alias_name=$(echo "$line" | awk '{print $1}' | sed 's/=.*//')
        local command=$(echo "$line" | sed 's/^[^=]*=//' | sed 's/^[[:space:]]*//')
        
        # Skip if command is a function or builtin
        if [[ "$command" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            if ! command -v "$command" >/dev/null 2>&1 && ! type "$command" >/dev/null 2>&1; then
                echo "⚠️  Alias '$alias_name' references unknown command: $command"
                ((warnings++))
            fi
        fi
    done
    
    if (( errors == 0 && warnings == 0 )); then
        echo "✅ All aliases validated"
        log_alias_event "Alias validation passed"
        return 0
    else
        echo "❌ Alias validation failed ($errors errors, $warnings warnings)"
        log_alias_event "Alias validation failed: $errors errors, $warnings warnings" "warning"
        return 1
    fi
}

# =============================================================================
# MODULE-SPECIFIC ALIASES
# =============================================================================

# Performance aliases
alias perf-check='quick_perf_check'
alias perf-analyze='zsh_perf_analyze'
alias perf-optimize='optimize_zsh_performance'

# Security aliases
alias sec-audit='security_audit'
alias sec-check='check_suspicious_files'
alias sec-monitor='monitor_security'

# Module management aliases
alias modules-list='list_modules'
alias modules-check='check_module_dependencies'
alias modules-validate='validate_module_system'

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize aliases module
init_aliases

# Export functions
export -f list_aliases search_aliases alias_stats validate_aliases 2>/dev/null || true
