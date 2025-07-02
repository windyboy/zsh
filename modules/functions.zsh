#!/usr/bin/env zsh
# =============================================================================
# ZSH Functions Module - 实用函数集合
# =============================================================================

# =============================================================================
# CONFIGURATION MANAGEMENT
# =============================================================================

# Safe ZSH reload function
zsh_reload() {
    echo "🔄 Reloading ZSH configuration..."
    
    # Temporarily disable error handling
    local old_error_trap=$(trap -p ERR 2>/dev/null || echo "")
    trap - ERR
    
    # Clear any existing error state
    unset ZSH_ERROR_TRAP_SET
    
    # Reload configuration
    if source ~/.zshrc 2>/dev/null; then
        echo "✅ Configuration reloaded successfully"
    else
        echo "❌ Configuration reload failed"
        # Restore error trap if it existed
        if [[ -n "$old_error_trap" ]]; then
            eval "$old_error_trap"
        fi
        return 1
    fi
    
    # Restore error trap if it existed
    if [[ -n "$old_error_trap" ]]; then
        eval "$old_error_trap"
    fi
    
    return 0
}

# =============================================================================
# DIRECTORY OPERATIONS - 目录操作
# =============================================================================

# 创建目录并进入
function mkcd() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    
    mkdir -p "$1" && cd "$1"
}

# 返回上级目录的快捷方式
function up() {
    local levels=${1:-1}
    local path=""
    
    for ((i=0; i<levels; i++)); do
        path="../$path"
    done
    
    cd "$path"
}

# 显示目录大小
function dirsize() {
    local target="${1:-.}"
    if [[ -d "$target" ]]; then
        du -sh "$target"/* 2>/dev/null | sort -hr
    else
        echo "Error: '$target' is not a directory"
        return 1
    fi
}

# 查找大文件
function findlarge() {
    local size="${1:-100M}"
    local path="${2:-.}"
    
    echo "Finding files larger than $size in $path..."
    find "$path" -type f -size "+$size" -exec ls -lh {} \; 2>/dev/null | \
    awk '{print $5 "\t" $9}' | sort -hr
}

# =============================================================================
# FILE OPERATIONS - 文件操作
# =============================================================================

# 安全删除（移动到回收站）
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

# 创建备份文件
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

# 提取各种压缩文件
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
# NETWORK OPERATIONS - 网络操作
# =============================================================================

# 启动简单HTTP服务器
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

# 获取外部IP地址
function myip() {
    echo "Getting external IP address..."
    local ip
    
    # 尝试多个服务
    for service in "ifconfig.me" "ipinfo.io/ip" "icanhazip.com"; do
        if ip=$(curl -s --connect-timeout 5 "$service" 2>/dev/null); then
            if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "External IP: $ip"
                return 0
            fi
        fi
    done
    
    echo "Failed to get external IP address"
    return 1
}

# 端口扫描
function portscan() {
    local host="${1:-localhost}"
    local start_port="${2:-1}"
    local end_port="${3:-1000}"
    
    echo "Scanning ports $start_port-$end_port on $host..."
    
    for ((port=start_port; port<=end_port; port++)); do
        if timeout 1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
            echo "Port $port: Open"
        fi
    done
}

# =============================================================================
# SYSTEM INFORMATION - 系统信息
# =============================================================================

# 系统信息概览
function sysinfo() {
    echo "🖥️  System Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "OS: $(uname -s -r)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Shell: $SHELL ($ZSH_VERSION)"
    echo "Terminal: $TERM"
    echo "Date: $(date)"
    
    if command -v uptime >/dev/null; then
        echo "Uptime: $(uptime | sed 's/.*up //' | sed 's/, load.*//')"
    fi
    
    if [[ -f /proc/meminfo ]]; then
        local total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local free_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        local used_mem=$((total_mem - free_mem))
        echo "Memory: $((used_mem/1024))MB used / $((total_mem/1024))MB total"
    fi
    
    echo "Current directory: $(pwd)"
    echo "Disk usage: $(df -h . | tail -1 | awk '{print $3 " used / " $2 " total (" $5 " used)"}')"
}

# 进程监控
function psgrep() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: psgrep <pattern>"
        return 1
    fi
    
    ps aux | grep -i "$1" | grep -v grep
}

# 查找占用端口的进程
function whoisport() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: whoisport <port>"
        return 1
    fi
    
    local port="$1"
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a number"
        return 1
    fi
    
    if command -v lsof >/dev/null; then
        lsof -i ":$port"
    elif command -v netstat >/dev/null; then
        netstat -tulpn | grep ":$port "
    else
        echo "Neither lsof nor netstat available"
        return 1
    fi
}

# =============================================================================
# DEVELOPMENT TOOLS - 开发工具
# =============================================================================

# Git相关快捷函数
function gitlog() {
    git log --oneline --graph --decorate --all -n "${1:-10}"
}

function gitstatus() {
    git status --short --branch
}

function gitclean() {
    echo "Cleaning Git repository..."
    git clean -fd
    git gc --prune=now
}

# 代码行数统计
function countlines() {
    local dir="${1:-.}"
    local pattern="${2:-*}"
    
    echo "Counting lines in $dir (pattern: $pattern)"
    find "$dir" -name "$pattern" -type f -exec wc -l {} + | sort -n
}

# 查找代码中的TODO/FIXME
function todos() {
    local dir="${1:-.}"
    echo "Searching for TODOs and FIXMEs in $dir..."
    grep -r -n -i -E "(TODO|FIXME|XXX|HACK)" "$dir" --include="*.py" --include="*.js" --include="*.sh" --include="*.zsh" 2>/dev/null
}

# =============================================================================
# TEXT PROCESSING - 文本处理
# =============================================================================

# 文本搜索和替换
function findreplace() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: findreplace <search> <replace> [directory]"
        return 1
    fi
    
    local search="$1"
    local replace="$2"
    local dir="${3:-.}"
    
    echo "Searching for '$search' in $dir..."
    grep -r -l "$search" "$dir" 2>/dev/null | while read -r file; do
        echo "Processing: $file"
        sed -i.bak "s/$search/$replace/g" "$file"
    done
}

# 重复行检测
function finddupes() {
    local file="${1:-/dev/stdin}"
    sort "$file" | uniq -d
}

# 文件编码转换
function convert_encoding() {
    if [[ $# -lt 3 ]]; then
        echo "Usage: convert_encoding <file> <from_encoding> <to_encoding>"
        return 1
    fi
    
    local file="$1"
    local from="$2"
    local to="$3"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist"
        return 1
    fi
    
    if command -v iconv >/dev/null; then
        iconv -f "$from" -t "$to" "$file" > "${file}.converted"
        echo "Converted '$file' from $from to $to -> ${file}.converted"
    else
        echo "Error: iconv not available"
        return 1
    fi
}

# =============================================================================
# UTILITIES - 实用工具
# =============================================================================

# 生成随机密码
function genpass() {
    local length="${1:-16}"
    local include_symbols="${2:-yes}"
    
    if ! [[ "$length" =~ ^[0-9]+$ ]] || (( length < 4 || length > 128 )); then
        echo "Error: Length must be between 4 and 128"
        return 1
    fi
    
    local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    if [[ "$include_symbols" == "yes" ]]; then
        chars="${chars}!@#$%^&*()_+-=[]{}|;:,.<>?"
    fi
    
    if command -v openssl >/dev/null; then
        openssl rand -base64 32 | tr -d "=+/" | cut -c1-"$length"
    else
        # Fallback method
        for ((i=0; i<length; i++)); do
            echo -n "${chars:RANDOM%${#chars}:1}"
        done
        echo
    fi
}

# 计算器
function calc() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: calc <expression>"
        echo "Example: calc '2 + 2'"
        return 1
    fi
    
    if command -v bc >/dev/null; then
        echo "$*" | bc -l
    else
        echo $((${*//.*/}))  # Basic integer calculation
    fi
}

# 颜色测试
function colortest() {
    echo "Color test:"
    for i in {0..255}; do
        printf "\e[38;5;${i}m%3d\e[0m " "$i"
        if (( (i+1) % 16 == 0 )); then
            echo
        fi
    done
    echo
}

# 天气查询
function weather() {
    local city="${1:-}"
    if [[ -n "$city" ]]; then
        curl -s "wttr.in/$city?format=3"
    else
        curl -s "wttr.in/?format=3"
    fi
}

# QR码生成
function qr() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: qr <text>"
        return 1
    fi
    
    local text="$*"
    if command -v qrencode >/dev/null; then
        qrencode -t ansiutf8 "$text"
    else
        # 使用在线服务
        curl -s "qrenco.de/$text"
    fi
}

# Base64 编码/解码
function b64encode() {
    if [[ $# -eq 0 ]]; then
        base64
    else
        echo -n "$*" | base64
    fi
}

function b64decode() {
    if [[ $# -eq 0 ]]; then
        base64 -d
    else
        echo -n "$*" | base64 -d
    fi
}

# URL 编码/解码
function urlencode() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: urlencode <text>"
        return 1
    fi
    
    local string="$*"
    local strlen=${#string}
    local encoded=""
    local pos c o
    
    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * ) printf -v o '%%%02x' "'$c" ;;
        esac
        encoded+="${o}"
    done
    
    echo "$encoded"
}

# 文件监控
function watchfile() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: watchfile <file> [command]"
        return 1
    fi
    
    local file="$1"
    local cmd="${2:-echo File changed: $file}"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist"
        return 1
    fi
    
    echo "Watching $file for changes... (Press Ctrl+C to stop)"
    
    if command -v fswatch >/dev/null; then
        fswatch -o "$file" | while read -r; do
            eval "$cmd"
        done
    else
        # Fallback using stat
        local last_mod=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
        while true; do
            sleep 1
            local current_mod=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
            if [[ "$current_mod" != "$last_mod" ]]; then
                eval "$cmd"
                last_mod="$current_mod"
            fi
        done
    fi
}

# =============================================================================
# CLEANUP AND MAINTENANCE - 清理和维护
# =============================================================================

# 清理临时文件
function cleanup() {
    echo "Cleaning up temporary files..."
    
    # 清理常见的临时文件
    local temp_patterns=(
        "*.tmp"
        "*.temp"
        "*~"
        ".DS_Store"
        "Thumbs.db"
        "*.log"
        "*.bak"
        "*.swp"
        "*.swo"
        ".*.swp"
        ".*.swo"
    )
    
    local cleaned=0
    for pattern in "${temp_patterns[@]}"; do
        local files=(${~pattern})
        if [[ ${#files[@]} -gt 0 && -e "${files[1]}" ]]; then
            for file in "${files[@]}"; do
                if [[ -f "$file" ]]; then
                    rm -f "$file"
                    echo "Removed: $file"
                    ((cleaned++))
                fi
            done
        fi
    done
    
    echo "Cleaned $cleaned temporary files"
}

# 磁盘使用分析
function diskusage() {
    local dir="${1:-.}"
    echo "Disk usage analysis for: $dir"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if command -v ncdu >/dev/null; then
        ncdu "$dir"
    else
        du -h "$dir" | sort -hr | head -20
    fi
}

# 重复文件查找
function findduplicates() {
    local dir="${1:-.}"
    echo "Finding duplicate files in: $dir"
    
    if command -v fdupes >/dev/null; then
        fdupes -r "$dir"
    else
        # 简单的重复文件检测
        find "$dir" -type f -exec md5sum {} \; 2>/dev/null | \
        sort | uniq -w32 -dD
    fi
}

# =============================================================================
# ZSH CONFIGURATION MANAGEMENT - ZSH配置管理
# =============================================================================

# Reload zsh configuration
function zsh_reload() {
    echo "🔄 Reloading ZSH configuration..."
    
    # Start timing
    local start_time=$EPOCHREALTIME
    
    # Source the main configuration
    if [[ -f "$HOME/.config/zsh/zshrc" ]]; then
        source "$HOME/.config/zsh/zshrc"
        local end_time=$EPOCHREALTIME
        local reload_time
        if command -v bc >/dev/null 2>&1; then
            reload_time=$(printf "%.3f" $(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0"))
        else
            reload_time=$(printf "%.3f" $((end_time - start_time)))
        fi
        echo "✅ ZSH configuration reloaded in ${reload_time}s"
    else
        echo "❌ ZSH configuration file not found: $HOME/.config/zsh/zshrc"
        return 1
    fi
}

# Validate zsh configuration
function validate_zsh_config() {
    echo "🔍 Validating ZSH configuration..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local errors=0
    local warnings=0
    
    # Check main configuration files
    local config_files=(
        "$HOME/.config/zsh/zshrc"
        "$HOME/.config/zsh/zshenv"
        "$HOME/.config/zsh/modules/core.zsh"
        "$HOME/.config/zsh/modules/performance.zsh"
        "$HOME/.config/zsh/modules/plugins.zsh"
        "$HOME/.config/zsh/modules/completion.zsh"
        "$HOME/.config/zsh/modules/functions.zsh"
        "$HOME/.config/zsh/modules/aliases.zsh"
        "$HOME/.config/zsh/modules/keybindings.zsh"
        "$HOME/.config/zsh/themes/prompt.zsh"
    )
    
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "✅ $file"
        else
            echo "❌ $file (missing)"
            ((errors++))
        fi
    done
    
    # Check directories
    local dirs=(
        "$HOME/.config/zsh"
        "$HOME/.cache/zsh"
        "$HOME/.local/share/zsh"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "✅ $dir"
        else
            echo "⚠️  $dir (missing)"
            ((warnings++))
        fi
    done
    
    # Check required commands
    local commands=("zsh" "git" "bc")
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "✅ $cmd available"
        else
            echo "⚠️  $cmd not found"
            ((warnings++))
        fi
    done
    
    # Check zsh options
    local required_options=("EXTENDED_HISTORY" "SHARE_HISTORY" "AUTO_CD" "EXTENDED_GLOB")
    for opt in "${required_options[@]}"; do
        if [[ -o "$opt" ]]; then
            echo "✅ Option $opt is set"
        else
            echo "❌ Option $opt is not set"
            ((errors++))
        fi
    done
    
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if (( errors == 0 && warnings == 0 )); then
        echo "✅ Configuration validation passed"
        return 0
    elif (( errors == 0 )); then
        echo "⚠️  Configuration validation passed with $warnings warnings"
        return 0
    else
        echo "❌ Configuration validation failed with $errors errors and $warnings warnings"
        return 1
    fi
}

# Performance analysis
function zsh_performance() {
    echo "🚀 ZSH Performance Analysis"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if performance functions are available
    if (( ${+functions[diagnose_performance]} )); then
        diagnose_performance
    else
        echo "⚠️  Performance diagnosis functions not available"
    fi
    
    # Check if quick test is available
    if (( ${+functions[quick_test]} )); then
        echo
        quick_test
    else
        echo "⚠️  Quick test function not available"
    fi
    
    # Manual performance check
    echo
    echo "📊 Manual Performance Check:"
    echo "PATH entries: $(echo "$PATH" | tr ':' '\n' | wc -l | tr -d ' ')"
    echo "Functions: $(declare -F | wc -l | tr -d ' ')"
    echo "Aliases: $(alias | wc -l | tr -d ' ')"
    echo "History size: $HISTSIZE"
    echo "History file: $HISTFILE"
}

# Backup zsh configuration
function zsh_backup() {
    echo "💾 Creating ZSH configuration backup..."
    
    local backup_dir="$HOME/.config/zsh/backup"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$backup_dir/${timestamp}"
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Backup main configuration files
    local files_to_backup=(
        "$HOME/.config/zsh/zshrc"
        "$HOME/.config/zsh/zshenv"
        "$HOME/.config/zsh/modules"
        "$HOME/.config/zsh/themes"
        "$HOME/.config/zsh/completions"
    )
    
    local backed_up=0
    for item in "${files_to_backup[@]}"; do
        if [[ -e "$item" ]]; then
            if [[ -d "$item" ]]; then
                cp -r "$item" "$backup_path/"
            else
                cp "$item" "$backup_path/"
            fi
            echo "✅ Backed up: $(basename "$item")"
            ((backed_up++))
        else
            echo "⚠️  Skipped: $(basename "$item") (not found)"
        fi
    done
    
    # Create backup info file
    cat > "$backup_path/backup_info.txt" << EOF
ZSH Configuration Backup
Created: $(date)
ZSH Version: $ZSH_VERSION
User: $(whoami)
Host: $(hostname)
Files backed up: $backed_up
EOF
    
    echo
    echo "✅ Backup completed: $backup_path"
    echo "📁 Backup contains $backed_up items"
    echo "📄 Backup info: $backup_path/backup_info.txt"
}

# History statistics
function history_stats() {
    echo "📊 History Statistics"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ -f "$HISTFILE" ]]; then
        local total_commands=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
        local unique_commands=$(sort "$HISTFILE" | uniq | wc -l 2>/dev/null || echo "0")
        local file_size=$(du -h "$HISTFILE" 2>/dev/null | cut -f1 || echo "unknown")
        
        echo "Total commands: $total_commands"
        echo "Unique commands: $unique_commands"
        echo "History file size: $file_size"
        echo "History file: $HISTFILE"
        
        echo
        echo "🔝 Most used commands:"
        cut -d';' -f2- "$HISTFILE" 2>/dev/null | \
        sed 's/^[[:space:]]*//' | \
        cut -d' ' -f1 | \
        sort | uniq -c | sort -nr | head -10
    else
        echo "❌ History file not found: $HISTFILE"
    fi
}
