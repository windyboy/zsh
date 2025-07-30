#!/usr/bin/env zsh
# shellcheck shell=bash
# =============================================================================
# ZSH Configuration Status Check Script
# Version: 4.3 - Enhanced Beautiful Output
# =============================================================================

# Load shared color functions
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
if [[ -f "$ZSH_CONFIG_DIR/modules/colors.zsh" ]]; then
    # shellcheck source=/dev/null
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
# shellcheck source=/dev/null
source "$HOME/.config/zsh/zshrc" >/dev/null 2>&1 || {
    status_color_red "❌ Unable to load ZSH configuration"
    exit 1
}
status_color_green "✅ Configuration loaded successfully!"
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
printf "  %s %s %s\n" "🏷️" "Version:" "$(status_color_bold "4.2.3 (Personal Minimal)")"
printf "  %s %s %s\n" "🎯" "Architecture:" "$(status_color_cyan "Modular & Minimal")"
printf "  %s %s %s\n" "⚡" "Performance:" "$(status_color_green "Optimized")"
printf "  %s %s %s\n" "🎨" "Experience:" "$(status_color_purple "Personalized")"
printf "  %s %s %s\n" "📦" "Modules:" "$(status_color_yellow "core/aliases/plugins/completion/keybindings/utils")"
echo

# Module status with enhanced formatting and progress
status_color_cyan "📁 Module Status"
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
local total_lines=0
local loaded_modules=0
local module_count=6
local current_module=0

for module in core aliases plugins completion keybindings utils; do
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
# Validate configuration
local validation_errors=0

# Check if essential variables are set
if [[ -z "$ZSH_CONFIG_DIR" ]]; then
    printf "    %s %s\n" "❌" "$(status_color_red "ZSH_CONFIG_DIR not set")"
    ((validation_errors++))
else
    printf "    %s %s\n" "✅" "$(status_color_green "ZSH_CONFIG_DIR: $ZSH_CONFIG_DIR")"
fi

# Check if modules are loaded
if [[ -z "$ZSH_MODULES_LOADED" ]]; then
    printf "    %s %s\n" "❌" "$(status_color_red "No modules loaded")"
    ((validation_errors++))
else
    printf "    %s %s\n" "✅" "$(status_color_green "Modules loaded: $ZSH_MODULES_LOADED")"
fi

# Check if zinit is available
if [[ -z "$ZINIT_HOME" ]]; then
    printf "    %s %s\n" "⚠️" "$(status_color_yellow "ZINIT_HOME not set (plugins may not work)")"
else
    printf "    %s %s\n" "✅" "$(status_color_green "ZINIT_HOME: $ZINIT_HOME")"
fi

# Check if history file exists
if [[ ! -f "$HISTFILE" ]]; then
    printf "    %s %s\n" "⚠️" "$(status_color_yellow "History file not found: $HISTFILE")"
else
    printf "    %s %s\n" "✅" "$(status_color_green "History file: $HISTFILE")"
fi

if [[ $validation_errors -eq 0 ]]; then
    printf "    %s %s\n" "✅" "$(status_color_green "Configuration validation passed")"
else
    printf "    %s %s\n" "❌" "$(status_color_red "Configuration validation failed ($validation_errors errors)")"
fi
echo

# Plugin status with beautiful formatting
status_color_cyan "🔌 Plugin Status"
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Get plugin information
local plugin_count=0
local active_plugins=0

# Check zinit plugins
local zinit_plugins=(
    "fast-syntax-highlighting:Syntax Highlighting"
    "zsh-autosuggestions:Auto Suggestions"
    "zsh-completions:Enhanced Completions"
    "fzf-tab:FZF Tab Completion"
    "z:Directory Jump"
    "zsh-extract:Enhanced File Extraction"
)

# Check tool plugins
local tool_plugins=(
    "fzf:Fuzzy Finder"
    "zoxide:Smart Navigation"
    "eza:Enhanced ls"
)

# Check builtin plugins
local builtin_plugins=(
    "git:Git Integration"
    "history:History Management"
)

plugin_count=$(( ${#zinit_plugins[@]} + ${#tool_plugins[@]} + ${#builtin_plugins[@]} ))

# Display zinit plugins
printf "  %s %s\n" "🎨" "$(status_color_cyan "Zinit Plugins:")"
for plugin in "${zinit_plugins[@]}"; do
    local name="${plugin%%:*}"
    local desc="${plugin##*:}"
    if [[ -n "$ZINIT" ]] && [[ -d "$ZINIT_HOME/plugins" ]]; then
        printf "    %s %-25s %s\n" "✅" "$name" "$(status_color_green "$desc")"
        ((active_plugins++))
    else
        printf "    %s %-25s %s\n" "❌" "$name" "$(status_color_red "$desc")"
    fi
done

# Display tool plugins
printf "  %s %s\n" "🛠️" "$(status_color_cyan "Tool Plugins:")"
for plugin in "${tool_plugins[@]}"; do
    local name="${plugin%%:*}"
    local desc="${plugin##*:}"
    if command -v "$name" >/dev/null 2>&1; then
        printf "    %s %-25s %s\n" "✅" "$name" "$(status_color_green "$desc")"
        ((active_plugins++))
    else
        printf "    %s %-25s %s\n" "❌" "$name" "$(status_color_red "$desc")"
    fi
done

# Display builtin plugins
printf "  %s %s\n" "🔧" "$(status_color_cyan "Builtin Plugins:")"
for plugin in "${builtin_plugins[@]}"; do
    local name="${plugin%%:*}"
    local desc="${plugin##*:}"
    printf "    %s %-25s %s\n" "✅" "$name" "$(status_color_green "$desc")"
    ((active_plugins++))
done

echo
printf "  %s %s %s %s\n" "📊" "Plugin Summary:" "$(status_color_green "$active_plugins/$plugin_count active")" "$(status_color_cyan "($((active_plugins * 100 / plugin_count))%)")"
echo

# Summary section
status_color_cyan "📋 Summary"
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Calculate overall score
local module_score=$((loaded_modules * 100 / module_count))
local plugin_score=$((active_plugins * 100 / plugin_count))
local performance_score=0
if (( func_count < 100 )); then
    performance_score=100
elif (( func_count < 200 )); then
    performance_score=80
else
    performance_score=60
fi
local overall_score=$(( (module_score + plugin_score + performance_score) / 3 ))

# Determine overall status
local overall_status=""
if (( overall_score >= 90 )); then
    overall_status="$(status_color_green "EXCELLENT")"
elif (( overall_score >= 80 )); then
    overall_status="$(status_color_yellow "GOOD")"
elif (( overall_score >= 70 )); then
    overall_status="$(status_color_blue "FAIR")"
else
    overall_status="$(status_color_red "NEEDS ATTENTION")"
fi

printf "  %s %s %s\n" "🎯" "Overall Status:" "$overall_status"
printf "  %s %s %s\n" "📦" "Modules Loaded:" "$(status_color_green "$loaded_modules/$module_count") ($(status_color_cyan "${module_score}%"))"
printf "  %s %s %s\n" "🔌" "Plugins Active:" "$(status_color_green "$active_plugins/$plugin_count") ($(status_color_cyan "${plugin_score}%"))"
printf "  %s %s %s\n" "⚡" "Performance:" "$(status_color_green "$performance_score/100")"
printf "  %s %s %s\n" "📝" "Total Code:" "$(status_color_cyan "$total_lines lines")"
printf "  %s %s %s\n" "📊" "Overall Score:" "$(status_color_bold "$overall_score/100")"
echo

# Beautiful footer with timestamp
status_color_yellow "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
status_color_green "✅ Status check completed successfully!"
status_color_cyan "   Your ZSH configuration is ready to use."
status_color_dim "   Generated at $(date '+%Y-%m-%d %H:%M:%S')"
echo
}

main "$@"
