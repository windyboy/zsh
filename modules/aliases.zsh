#!/usr/bin/env zsh
# =============================================================================
# ZSH Aliases - Enhanced (基于您现有的配置)
# =============================================================================

# ===== Configuration Management Aliases =====
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

# ===== Security Aliases =====
alias security-audit='security_audit'
alias check-suspicious='check_suspicious_files'
alias secure-delete='secure_rm'
alias validate-security='validate_security_config'

# ===== 历史管理别名 (新增) =====
alias h='history'
alias hg='history | grep'
alias hist-stats='history_stats'
alias hist-clean='echo "⚠️  This will clear all history. Type: history -c && > \$HISTFILE"'

# ===== 您现有的别名配置 =====
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

# 强制操作别名 (新增)
alias rmf='rm -f'
alias cpf='cp -f'
alias mvf='mv -f'

# =============================================================================
# SYSTEM INFORMATION
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
# DEVELOPMENT TOOLS (保留您的所有配置)
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
# UTILITY FUNCTIONS AS ALIASES
# =============================================================================

# Extract archives
alias extract='_extract'
alias fe='find_and_edit'  # 查找并编辑文件

# Find files
alias ff='find . -type f -name'
alias fd='find . -type d -name'

# Grep with color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# =============================================================================
# CONDITIONAL ALIASES
# =============================================================================

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias o='open'
    alias pbcopy='pbcopy'
    alias pbpaste='pbpaste'
    alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
fi

# Linux specific
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias o='xdg-open'
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
    alias update='sudo apt update && sudo apt upgrade'
fi

# =============================================================================
# GLOBAL ALIASES (保留您的配置)
# =============================================================================

# Global aliases for common patterns
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g CA="2>&1 | cat -A"
alias -g C='| wc -l'
alias -g D="DISPLAY=:0.0"
alias -g DN=/dev/null
alias -g ED="export DISPLAY=:0.0"
alias -g EG='|& egrep'
alias -g EH='|& head'
alias -g EL='|& less'
alias -g ELS='|& less -S'
alias -g ETL='|& tail -20'
alias -g ET='|& tail'
alias -g F=' | fmt -'
alias -g G='| grep'
alias -g H='| head'
alias -g HL='|& head -20'
alias -g Sk="*~(*.bz2|*.gz|*.tgz|*.zip|*.z)"
alias -g LL="2>&1 | less"
alias -g L="| less"
alias -g LS='| less -S'
alias -g MM='| most'
alias -g M='| more'
alias -g NE="2> /dev/null"
alias -g NS='| sort -n'
alias -g NUL="> /dev/null 2>&1"
alias -g PIPE='|'
alias -g R=' > /c/aaa/tee.txt '
alias -g RNS='| sort -nr'
alias -g S='| sort'
alias -g TL='| tail -20'
alias -g T='| tail'
alias -g US='| sort -u'
alias -g VM=/var/log/messages
alias -g X0G='| xargs -0 egrep'
alias -g X0='| xargs -0'
alias -g XG='| xargs egrep'
alias -g X='| xargs'

# =============================================================================
# SUFFIX ALIASES (保留您的配置)
# =============================================================================

# Auto-open files by extension
alias -s txt='${EDITOR:-code}'
alias -s md='${EDITOR:-code}'
alias -s js='${EDITOR:-code}'
alias -s ts='${EDITOR:-code}'
alias -s py='${EDITOR:-code}'
alias -s html='${BROWSER:-firefox}'
alias -s pdf='${PDF_READER:-evince}'
alias -s png='${IMAGE_VIEWER:-eog}'
alias -s jpg='${IMAGE_VIEWER:-eog}'
alias -s jpeg='${IMAGE_VIEWER:-eog}'
alias -s gif='${IMAGE_VIEWER:-eog}'
