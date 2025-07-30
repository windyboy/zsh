#!/usr/bin/env zsh
# =============================================================================
# Navigation Module - Directory Navigation and Globbing
# Description: Directory navigation settings, globbing options, and navigation functions
# =============================================================================

# Color output tools
source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# Module specific wrappers
nav_color_red()   { color_red "$@"; }
nav_color_green() { color_green "$@"; }

# -------------------- Navigation Settings --------------------
# Directory navigation
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT CDABLE_VARS

# Globbing options
setopt EXTENDED_GLOB NO_CASE_GLOB NUMERIC_GLOB_SORT

# -------------------- Global Aliases --------------------
# Directory navigation aliases
alias -g ...='../..' ....='../../..' .....='../../../..' ......='../../../../..'

# Pipeline aliases
alias -g G='| grep' L='| less' H='| head' T='| tail' S='| sort' U='| uniq' C='| wc -l'

# -------------------- Navigation Functions --------------------
# Create directory and change to it
mkcd() {
    if [[ -n "$1" ]]; then
        mkdir -p "$1" && cd "$1"
        nav_color_green "✅ Created and entered directory: $1"
    else
        nav_color_red "❌ Usage: mkcd <directory>"
        return 1
    fi
}

# Go up directories
up() {
    local levels="${1:-1}"
    local path=""
    
    for ((i=1; i<=levels; i++)); do
        path="../$path"
    done
    
    cd "$path" 2>/dev/null && nav_color_green "✅ Moved up $levels level(s)" || {
        nav_color_red "❌ Cannot move up $levels level(s)"
        return 1
    }
}

# Smart directory navigation
smart_cd() {
    if [[ -d "$1" ]]; then
        cd "$1"
    elif [[ -f "$1" ]]; then
        cd "$(dirname "$1")"
    else
        nav_color_red "❌ '$1' is not a valid directory or file"
        return 1
    fi
}

# Quick directory shortcuts
quick_cd() {
    case "$1" in
        "home"|"~") cd ~ ;;
        "desktop") cd ~/Desktop ;;
        "downloads") cd ~/Downloads ;;
        "documents") cd ~/Documents ;;
        "config") cd ~/.config ;;
        "cache") cd ~/.cache ;;
        "temp") cd /tmp ;;
        *) nav_color_red "❌ Unknown shortcut: $1" ;;
    esac
}

# Directory stack management
dir_stack() {
    echo "📁 Directory Stack:"
    dirs -v
}

# Clear directory stack
clear_stack() {
    dirs -c
    nav_color_green "✅ Directory stack cleared"
}

# -------------------- Navigation Utilities --------------------
# Show current directory info
dir_info() {
    echo "📁 Current Directory Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Path: $(pwd)"
    echo "  Parent: $(dirname "$(pwd)")"
    echo "  Name: $(basename "$(pwd)")"
    echo "  Permissions: $(ls -ld . | awk '{print $1}')"
    echo "  Owner: $(ls -ld . | awk '{print $3}')"
    echo "  Group: $(ls -ld . | awk '{print $4}')"
    echo "  Size: $(du -sh . 2>/dev/null | awk '{print $1}')"
    echo "  Items: $(ls -1 | wc -l | tr -d ' ') files/directories"
}

# Find files by pattern
find_files() {
    if [[ -z "$1" ]]; then
        nav_color_red "❌ Usage: find_files <pattern>"
        return 1
    fi
    
    local pattern="$1"
    local results=()
    
    # Use find with pattern
    while IFS= read -r -d '' file; do
        results+=("$file")
    done < <(find . -name "$pattern" -print0 2>/dev/null)
    
    if [[ ${#results[@]} -eq 0 ]]; then
        nav_color_yellow "⚠️  No files found matching pattern: $pattern"
        return 1
    else
        nav_color_green "✅ Found ${#results[@]} file(s) matching '$pattern':"
        printf "  %s\n" "${results[@]}"
    fi
}

# Navigation validation
nav_validate() {
    local errors=0
    
    nav_color_green "🧭 Navigation Validation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if we're in a valid directory
    if [[ ! -d "$(pwd)" ]]; then
        nav_color_red "❌ Current directory is invalid"
        ((errors++))
    else
        nav_color_green "✅ Current directory is valid"
    fi
    
    # Check if we can read current directory
    if [[ ! -r "$(pwd)" ]]; then
        nav_color_red "❌ Cannot read current directory"
        ((errors++))
    else
        nav_color_green "✅ Current directory is readable"
    fi
    
    # Check if we can write to current directory
    if [[ ! -w "$(pwd)" ]]; then
        nav_color_yellow "⚠️  Current directory is not writable"
    else
        nav_color_green "✅ Current directory is writable"
    fi
    
    # Check directory stack
    local stack_size=$(dirs -v | wc -l)
    if [[ $stack_size -gt 1 ]]; then
        nav_color_green "✅ Directory stack has $((stack_size-1)) entries"
    else
        nav_color_yellow "⚠️  Directory stack is empty"
    fi
    
    echo
    if [[ $errors -eq 0 ]]; then
        nav_color_green "✅ Navigation validation passed"
        return 0
    else
        nav_color_red "❌ Navigation validation failed: $errors errors"
        return 1
    fi
}

# Navigation help
nav_help() {
    echo "🧭 Navigation Commands"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  mkcd <dir>        - Create directory and change to it"
    echo "  up [levels]       - Go up directory levels (default: 1)"
    echo "  smart_cd <path>   - Smart directory change"
    echo "  quick_cd <name>   - Quick navigation shortcuts"
    echo "  dir_stack         - Show directory stack"
    echo "  clear_stack       - Clear directory stack"
    echo "  dir_info          - Show current directory info"
    echo "  find_files <pat>  - Find files by pattern"
    echo "  nav_validate      - Validate navigation settings"
    echo "  nav_help          - Show this help"
    echo
    echo "Quick Navigation Shortcuts:"
    echo "  home, ~           - Home directory"
    echo "  desktop           - Desktop directory"
    echo "  downloads         - Downloads directory"
    echo "  documents         - Documents directory"
    echo "  config            - Config directory"
    echo "  cache             - Cache directory"
    echo "  temp              - Temporary directory"
}

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED navigation" 