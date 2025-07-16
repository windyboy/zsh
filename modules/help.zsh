#!/usr/bin/env zsh
# =============================================================================
# Unified Help System
# =============================================================================

# Load logging system
if [[ -f "$ZSH_CONFIG_DIR/modules/logging.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/logging.zsh"
fi

# Help categories
typeset -A HELP_CATEGORIES
HELP_CATEGORIES=(
    "system" "System management commands"
    "performance" "Performance and optimization"
    "development" "Development tools and shortcuts"
    "files" "File and directory operations"
    "network" "Network and connectivity"
    "debug" "Debugging and troubleshooting"
    "config" "Configuration management"
)

# System commands
typeset -A SYSTEM_COMMANDS
SYSTEM_COMMANDS=(
    "status" "Check system status"
    "reload" "Reload configuration"
    "validate" "Validate configuration"
    "errors" "Show recent errors"
    "health_check" "System health check"
)

# Performance commands
typeset -A PERFORMANCE_COMMANDS
PERFORMANCE_COMMANDS=(
    "perf" "Performance analysis"
    "optimize" "Performance optimization"
    "quick_perf_check" "Quick performance check"
    "show_performance_dashboard" "Detailed performance dashboard"
    "get_optimization_suggestions" "Get optimization suggestions"
)

# Development commands
typeset -A DEVELOPMENT_COMMANDS
DEVELOPMENT_COMMANDS=(
    "g" "Git shortcuts"
    "d" "Docker shortcuts"
    "n" "Node.js shortcuts"
    "y" "Yarn shortcuts"
    "b" "Bun shortcuts"
    "py" "Python shortcuts"
)

# File commands
typeset -A FILE_COMMANDS
FILE_COMMANDS=(
    "mkcd" "Create directory and enter it"
    "up" "Go up directories"
    "dirsize" "Show directory size"
    "findlarge" "Find large files"
    "trash" "Safe file deletion"
    "backup" "Create file backup"
    "extract" "Extract archives"
)

# Network commands
typeset -A NETWORK_COMMANDS
NETWORK_COMMANDS=(
    "serve" "Start HTTP server"
    "myip" "Show external IP"
    "ping" "Enhanced ping"
    "ports" "Show open ports"
)

# Debug commands
typeset -A DEBUG_COMMANDS
DEBUG_COMMANDS=(
    "debug" "Show debug information"
    "debug_config" "Debug configuration"
    "debug_functions" "Debug functions"
    "check_recent_errors" "Check recent errors"
    "error_stats" "Error statistics"
    "enter_recovery_mode" "Enter recovery mode"
    "exit_recovery_mode" "Exit recovery mode"
)

# Config commands
typeset -A CONFIG_COMMANDS
CONFIG_COMMANDS=(
    "config" "Edit configuration files"
    "list_configs" "List all configuration files"
    "validate_configs" "Validate configuration files"
    "backup_config" "Backup configuration"
    "restore_config" "Restore configuration"
    "config_status" "Configuration status"
)

# Show help for a specific category
show_category_help() {
    local category="$1"
    local commands_var="${category:u}_COMMANDS"
    
    if [[ -z "$category" ]]; then
        echo "Usage: help <category>"
        echo "Available categories:"
        for cat in "${(@k)HELP_CATEGORIES}"; do
            echo "  $cat - ${HELP_CATEGORIES[$cat]}"
        done
        return 1
    fi
    
    if [[ -z "${(P)commands_var}" ]]; then
        error "Unknown category: $category"
        return 1
    fi
    
    echo "📚 $category Commands"
    echo "====================="
    echo "${HELP_CATEGORIES[$category]}"
    echo ""
    
    local commands="${(P)commands_var}"
    for cmd in "${(@k)commands}"; do
        echo "  $cmd - ${commands[$cmd]}"
    done
}

# Show help for a specific command
show_command_help() {
    local command="$1"
    
    if [[ -z "$command" ]]; then
        echo "Usage: help <command>"
        return 1
    fi
    
    # Check all command categories
    local found=0
    for category in system performance development files network debug config; do
        local commands_var="${category:u}_COMMANDS"
        local commands="${(P)commands_var}"
        
        if [[ -n "${commands[$command]}" ]]; then
            echo "📖 $command"
            echo "=========="
            echo "${commands[$command]}"
            echo ""
            echo "Category: $category"
            found=1
            break
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        error "Command not found: $command"
        return 1
    fi
}

# Main help function
help() {
    local topic="$1"
    
    if [[ -z "$topic" ]]; then
        echo "🔧 ZSH Configuration Help"
        echo "========================"
        echo ""
        echo "Quick commands:"
        echo "  status          - Check system status"
        echo "  perf            - Performance analysis"
        echo "  config          - Edit configuration"
        echo "  debug           - Debug information"
        echo ""
        echo "Use 'help <category>' for detailed help:"
        for cat in "${(@k)HELP_CATEGORIES}"; do
            echo "  $cat - ${HELP_CATEGORIES[$cat]}"
        done
        echo ""
        echo "Use 'help <command>' for specific command help"
        return 0
    fi
    
    # Check if it's a category
    if [[ -n "${HELP_CATEGORIES[$topic]}" ]]; then
        show_category_help "$topic"
        return 0
    fi
    
    # Check if it's a command
    show_command_help "$topic"
}

# Quick help aliases
alias h='help'
alias hc='help config'
alias hp='help performance'
alias hs='help system'
alias hd='help debug'
alias hf='help files'
alias hn='help network'
alias hdev='help development' 