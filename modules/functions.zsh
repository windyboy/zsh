#!/usr/bin/env zsh
# =============================================================================
# Functions Module - Unified Module System Integration
# Version: 3.0 - Comprehensive Function Management
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Function configuration
FUNCTION_LOG="${ZSH_CACHE_DIR}/functions.log"

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize functions module
init_functions() {
    [[ ! -d "$FUNCTION_LOG:h" ]] && mkdir -p "$FUNCTION_LOG:h"
    
    # Log functions module initialization
    log_function_event "Functions module initialized"
}

# =============================================================================
# FUNCTION LOGGING
# =============================================================================

# Log function events
log_function_event() {
    local event="$1"
    local level="${2:-info}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $event" >> "$FUNCTION_LOG"
}

# =============================================================================
# CONFIGURATION MANAGEMENT FUNCTIONS
# =============================================================================

# Safe ZSH reload function
zsh_reload() {
    log_function_event "ZSH reload requested"
    
    echo "🔄 Reloading ZSH configuration..."
    
    # Temporarily disable error handling
    local old_error_trap=$(trap -p ERR 2>/dev/null || echo "")
    trap - ERR
    
    # Clear any existing error state
    unset ZSH_ERROR_TRAP_SET
    
    # Reload configuration
    if source ~/.zshrc 2>/dev/null; then
        echo "✅ Configuration reloaded successfully"
        log_function_event "ZSH reload successful"
    else
        echo "❌ Configuration reload failed"
        log_function_event "ZSH reload failed" "error"
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
# DIRECTORY OPERATIONS
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
# FILE OPERATIONS
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
# NETWORK OPERATIONS
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
# DEVELOPMENT TOOLS
# =============================================================================

# Git utilities
function git_branch_name() {
    git branch 2>/dev/null | grep '^\*' | sed 's/^\* //'
}

function git_status_short() {
    git status --porcelain 2>/dev/null | wc -l
}

# Docker utilities
function docker_cleanup() {
    echo "Cleaning up Docker resources..."
    docker system prune -f
    docker volume prune -f
    docker network prune -f
    echo "Docker cleanup completed"
}

# Node.js utilities
function npm_clean() {
    echo "Cleaning npm cache..."
    npm cache clean --force
    echo "npm cache cleaned"
}

# Python utilities
function venv_activate() {
    local venv_dir="${1:-venv}"
    if [[ -d "$venv_dir" ]]; then
        source "$venv_dir/bin/activate"
        echo "Activated virtual environment: $venv_dir"
    else
        echo "Virtual environment not found: $venv_dir"
        return 1
    fi
}

# =============================================================================
# SYSTEM UTILITIES
# =============================================================================

# System information
function sysinfo() {
    echo "System Information"
    echo "================="
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime)"
    echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $4}') available"
}

# Process management
function pskill() {
    local pattern="$1"
    if [[ -z "$pattern" ]]; then
        echo "Usage: pskill <pattern>"
        return 1
    fi
    
    local pids=$(ps aux | grep "$pattern" | grep -v grep | awk '{print $2}')
    if [[ -n "$pids" ]]; then
        echo "Killing processes matching '$pattern':"
        echo "$pids" | xargs kill -9
        echo "Processes killed"
    else
        echo "No processes found matching '$pattern'"
    fi
}

# =============================================================================
# FUNCTION MANAGEMENT
# =============================================================================

# List all functions
list_functions() {
    echo "📋 Available functions:"
    declare -f | grep '^[a-zA-Z_][a-zA-Z0-9_]* ()' | sed 's/ ()//' | sort | sed 's/^/  /'
}

# Search functions
search_functions() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: search_functions <query>"
        return 1
    fi
    
    echo "🔍 Searching functions for: $query"
    declare -f | grep -A 1 -B 1 "$query" | grep '^[a-zA-Z_][a-zA-Z0-9_]* ()' | sed 's/ ()//' | sort | uniq | sed 's/^/  /'
}

# Function statistics
function_stats() {
    local total_functions=$(declare -f | grep '^[a-zA-Z_][a-zA-Z0-9_]* ()' | wc -l)
    local git_functions=$(declare -f | grep -c "git" || echo "0")
    local docker_functions=$(declare -f | grep -c "docker" || echo "0")
    local system_functions=$(declare -f | grep -c -E "(sys|proc|mem)" || echo "0")
    
    echo "📊 Function Statistics:"
    echo "  • Total functions: $total_functions"
    echo "  • Git functions: $git_functions"
    echo "  • Docker functions: $docker_functions"
    echo "  • System functions: $system_functions"
}

# Validate functions
validate_functions() {
    local errors=0
    local warnings=0
    
    echo "🔍 Validating functions..."
    
    # Check for syntax errors in functions
    local functions=$(declare -f | grep '^[a-zA-Z_][a-zA-Z0-9_]* ()' | sed 's/ ()//')
    
    for func in $functions; do
        # Try to parse function syntax
        if ! zsh -n -c "$(declare -f "$func")" 2>/dev/null; then
            echo "❌ Syntax error in function: $func"
            ((errors++))
        fi
        
        # Check for common issues
        local func_body=$(declare -f "$func")
        if [[ "$func_body" == *"echo *"* ]] && [[ "$func_body" != *"echo \""* ]]; then
            echo "⚠️  Potential unquoted echo in function: $func"
            ((warnings++))
        fi
    done
    
    if (( errors == 0 && warnings == 0 )); then
        echo "✅ All functions validated"
        log_function_event "Function validation passed"
        return 0
    else
        echo "❌ Function validation failed ($errors errors, $warnings warnings)"
        log_function_event "Function validation failed: $errors errors, $warnings warnings" "warning"
        return 1
    fi
}

# =============================================================================
# MODULE-SPECIFIC FUNCTIONS
# =============================================================================

# Performance monitoring functions
monitor_function_performance() {
    local function_name="$1"
    local start_time=$EPOCHREALTIME
    
    # Execute function and measure time
    "$function_name" >/dev/null 2>&1
    
    local end_time=$EPOCHREALTIME
    local duration=$((end_time - start_time))
    local duration_formatted=$(printf "%.3f" $duration)
    
    log_function_event "Function $function_name executed in ${duration_formatted}s"
    
    if (( duration > 100 )); then
        log_function_event "Function $function_name is slow: ${duration_formatted}s" "warning"
    fi
}

# Security validation functions
validate_function_security() {
    local function_name="$1"
    local func_body=$(declare -f "$function_name")
    
    # Check for potentially dangerous patterns
    local dangerous_patterns=(
        "rm -rf"
        "sudo"
        "chmod 777"
        "chown root"
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$func_body" == *"$pattern"* ]]; then
            log_function_event "Function $function_name contains potentially dangerous pattern: $pattern" "warning"
            return 1
        fi
    done
    
    return 0
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize functions module
init_functions

# Export functions
export -f list_functions search_functions function_stats validate_functions monitor_function_performance validate_function_security 2>/dev/null || true
