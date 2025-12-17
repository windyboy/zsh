#!/usr/bin/env zsh
# shellcheck shell=bash
# =============================================================================
# ZSH Configuration Status Check Script
# Version: 5.3.1 - Enhanced Beautiful Output
# =============================================================================

# Load shared color functions
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
if [[ -f "$ZSH_CONFIG_DIR/modules/colors.zsh" ]]; then
    # shellcheck disable=SC1091
    source "$ZSH_CONFIG_DIR/modules/colors.zsh"
else
    color_red()    { echo -e "\033[31m$1\033[0m"; }
    color_green()  { echo -e "\033[32m$1\033[0m"; }
    color_yellow() { echo -e "\033[33m$1\033[0m"; }
    color_blue()   { echo -e "\033[34m$1\033[0m"; }
    color_magenta(){ echo -e "\033[35m$1\033[0m"; }
    color_cyan()   { echo -e "\033[36m$1\033[0m"; }
    color_bold()   { echo -e "\033[1m$1\033[0m"; }
fi

# Local wrappers for status script
status_color_red()    { color_red "$@"; }
status_color_green()  { color_green "$@"; }
status_color_yellow() { color_yellow "$@"; }
status_color_blue()   { color_blue "$@"; }
status_color_purple() { color_magenta "$@"; }
status_color_cyan()   { color_cyan "$@"; }
status_color_bold()   { color_bold "$@"; }
status_color_dim()    { echo -e "\033[2m$1\033[0m"; }

# Progress indicator function
show_progress() {
    local current=$1
    local total=$2
    local width=30
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%%" $((current * 100 / total))
}

main() {
# Load configuration with progress
echo
status_color_bold "╔══════════════════════════════════════════════════════════════╗"
status_color_bold "║                🚀 ZSH Configuration Status Check             ║"
status_color_bold "╚══════════════════════════════════════════════════════════════╝"
echo

status_color_cyan "🔄 Loading configuration..."
# Suppress module loading messages for cleaner output
if [[ -f "$ZSH_CONFIG_DIR/zshrc" ]]; then
    # shellcheck disable=SC1091
    source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1
    status_color_green "✅ Configuration loaded successfully!"
else
    status_color_red "❌ ZSH configuration file not found: $ZSH_CONFIG_DIR/zshrc"
    exit 1
fi
echo

# System information section
status_color_cyan "🖥️  System Information"
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  %s %-20s %s\n" "🏷️" "Shell:" "$(status_color_bold "$SHELL")"
printf "  %s %-20s %s\n" "📁" "Config Dir:" "$(status_color_bold "$ZSH_CONFIG_DIR")"
printf "  %s %-20s %s\n" "👤" "User:" "$(status_color_bold "$USER@$(hostname)")"
printf "  %s %-20s %s\n" "🕐" "Time:" "$(status_color_bold "$(date '+%Y-%m-%d %H:%M:%S')")"
echo

# Version information with beautiful formatting
status_color_cyan "📦 Version Information"
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  %s %s %s\n" "🏷️" "Version:" "$(status_color_bold "5.3.1 (Enhanced)")"
printf "  %s %s %s\n" "🎯" "Architecture:" "$(status_color_cyan "Modular & Minimal")"
printf "  %s %s %s\n" "⚡" "Performance:" "$(status_color_green "Optimized")"
printf "  %s %s %s\n" "🎨" "Experience:" "$(status_color_purple "Personalized")"
printf "  %s %s %s\n" "📦" "Modules:" "$(status_color_yellow "colors/core/navigation/path/plugins/completion/aliases/keybindings/utils")"
echo

# Module status with enhanced formatting and progress
status_color_cyan "📁 Module Status"
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
local total_lines=0
local loaded_modules=0
local module_count=9
local current_module=0

for module in colors core navigation path plugins completion aliases keybindings utils; do
    current_module=$((current_module + 1))
    local file="$ZSH_CONFIG_DIR/modules/${module}.zsh"
    if [[ -f "$file" ]]; then
        local lines
        lines=$(wc -l < "$file" 2>/dev/null)
        total_lines=$((total_lines + lines))
        loaded_modules=$((loaded_modules + 1))
        printf "  %s %-15s %s %s %s\n" "✅" "$module.zsh" "($(printf '%6d' "$lines") lines)" "$(status_color_green "✓")" "$(show_progress "$current_module" "$module_count")"
    else
        printf "  %s %-15s %s %s %s\n" "❌" "$module.zsh" "$(status_color_red "missing")" "$(status_color_red "✗")" "$(show_progress "$current_module" "$module_count")"
    fi
done
echo
printf "  %s %s %s %s\n" "📊" "Total:" "$(printf '%6d' "$total_lines") lines" "($loaded_modules/$module_count modules loaded)"
printf "  %s %s %s\n" "📈" "Load Rate:" "$(status_color_green "$((loaded_modules * 100 / module_count))%")"
echo

# Performance status with beautiful formatting
status_color_cyan "⚡ Performance Status"
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Get performance metrics
local func_count
func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
local alias_count
alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
local memory_kb
memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
local history_lines
history_lines=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
local memory_mb
memory_mb=$(echo "scale=1; ${memory_kb:-0} / 1024" | bc 2>/dev/null || echo "Unknown")

printf "  %s %-20s %s\n" "🔧" "Functions:" "$(status_color_cyan "$(printf '%6d' "${func_count:-0}")")"
printf "  %s %-20s %s\n" "⚡" "Aliases:" "$(status_color_cyan "$(printf '%6d' "${alias_count:-0}")")"
printf "  %s %-20s %s\n" "💾" "Memory Usage:" "$(status_color_blue "$memory_mb MB")"
printf "  %s %-20s %s\n" "📚" "History:" "$(status_color_purple "$(printf '%6d' "$history_lines") lines")"

# Performance rating
local performance_rating=""
if (( func_count < 100 )); then
    performance_rating="$(status_color_green "EXCELLENT")"
elif (( func_count < 200 )); then
    performance_rating="$(status_color_yellow "GOOD")"
else
    performance_rating="$(status_color_red "NEEDS OPTIMIZATION")"
fi
printf "  %s %-20s %s\n" "🎯" "Performance Rating:" "$performance_rating"
echo

# Configuration validation with beautiful formatting
status_color_cyan "🔧 Configuration Validation"
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if typeset -f validation_run >/dev/null 2>&1; then
    local -a status_validation_messages=()
    validation_run status_validation_messages false

    for entry in "${status_validation_messages[@]}"; do
        local level="${entry%%|*}"
        local message="${entry#*|}"
        case "$level" in
            success) printf "    %s %s\n" "✅" "$(status_color_green "$message")" ;;
            warning) printf "    %s %s\n" "⚠️" "$(status_color_yellow "$message")" ;;
            error)   printf "    %s %s\n" "❌" "$(status_color_red "$message")" ;;
            info)    printf "    %s %s\n" "ℹ️" "$(status_color_blue "$message")" ;;
        esac
    done

    printf "    %s %s\n" "❌" "$(status_color_bold "Errors: $VALIDATION_ERRORS")"
    printf "    %s %s\n" "⚠️" "$(status_color_bold "Warnings: $VALIDATION_WARNINGS")"

    if [[ $VALIDATION_ERRORS -eq 0 && $VALIDATION_WARNINGS -eq 0 ]]; then
        printf "    %s %s\n" "✅" "$(status_color_green "Configuration validation passed")"
    elif [[ $VALIDATION_ERRORS -eq 0 ]]; then
        printf "    %s %s\n" "⚠️" "$(status_color_yellow "Warnings present but no errors")"
    else
        printf "    %s %s\n" "❌" "$(status_color_red "Validation reported errors")"
    fi
else
    status_color_red "Validation library not available"
fi

}

main "$@"
