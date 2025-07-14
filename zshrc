#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration - Unified Module System
# Version: 3.0 - Comprehensive and Optimized
# =============================================================================

# =============================================================================
# STARTUP TIMING
# =============================================================================

# Record startup time for performance monitoring
export ZSH_STARTUP_START=$EPOCHREALTIME

# =============================================================================
# ENVIRONMENT SETUP
# =============================================================================

# Set ZSH configuration directory
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}"
export ZSH_DATA_DIR="${ZSH_DATA_DIR:-$HOME/.local/share/zsh}"

# Create necessary directories
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"
[[ ! -d "$ZSH_DATA_DIR" ]] && mkdir -p "$ZSH_DATA_DIR"

# Create subdirectories for logs
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"

# =============================================================================
# CORE CONFIGURATION
# =============================================================================

# Load core module first (foundation)
if [[ -f "$ZSH_CONFIG_DIR/modules/core.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/core.zsh"
else
    echo "❌ Core module not found. Please check your installation."
    return 1
fi

# =============================================================================
# MODULE MANAGER
# =============================================================================

# Load module manager
if [[ -f "$ZSH_CONFIG_DIR/modules/module_manager.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/module_manager.zsh"
else
    echo "❌ Module manager not found. Loading modules individually..."
    
    # Fallback: load modules individually
    local modules=("error_handling" "security" "performance" "plugins" "completion" "aliases" "functions" "keybindings")
    for module in "${modules[@]}"; do
        local module_file="$ZSH_CONFIG_DIR/modules/${module}.zsh"
        if [[ -f "$module_file" ]]; then
            source "$module_file"
        else
            echo "⚠️  Module not found: $module"
        fi
    done
fi

# =============================================================================
# UNIFIED MODULE LOADING
# =============================================================================

# Load all modules using the module manager
if command -v load_all_modules >/dev/null 2>&1; then
    load_all_modules
else
    echo "⚠️  Module manager not available. Using fallback loading..."
    
    # Fallback loading
    local fallback_modules=("error_handling" "security" "performance" "plugins" "completion" "aliases" "functions" "keybindings")
    for module in "${fallback_modules[@]}"; do
        if safe_load_module "$module" 2>/dev/null; then
            echo "✅ Loaded: $module"
        else
            echo "❌ Failed to load: $module"
        fi
    done
fi

# =============================================================================
# THEME AND PROMPT
# =============================================================================

# Load theme
if [[ -f "$ZSH_CONFIG_DIR/themes/prompt.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/themes/prompt.zsh"
else
    # Fallback prompt
    PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f %# '
fi

# =============================================================================
# FINAL VALIDATION
# =============================================================================

# Validate configuration
if command -v validate_configuration >/dev/null 2>&1; then
    validate_configuration
fi

# Validate module system
if command -v validate_module_system >/dev/null 2>&1; then
    validate_module_system
fi

# =============================================================================
# STARTUP COMPLETION
# =============================================================================

# Record startup completion time
export ZSH_STARTUP_END=$EPOCHREALTIME

# Calculate startup time
if [[ -n "$ZSH_STARTUP_START" ]] && [[ -n "$ZSH_STARTUP_END" ]]; then
    local startup_time=$((ZSH_STARTUP_END - ZSH_STARTUP_START))
    local startup_formatted=$(printf "%.3f" $startup_time)
    
    # Log startup time
    if [[ -f "$ZSH_CACHE_DIR/startup.log" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Startup time: ${startup_formatted}s" >> "$ZSH_CACHE_DIR/startup.log"
    fi
    
    # Show startup time if verbose mode is enabled
    if [[ -n "$ZSH_VERBOSE" ]]; then
        echo "🚀 ZSH startup completed in ${startup_formatted}s"
    fi
    
    # Warn if startup is slow
    if (( startup_time > 1000 )); then
        echo "⚠️  Slow startup detected: ${startup_formatted}s"
        echo "💡 Consider running: zsh-perf-opt"
    fi
fi

# =============================================================================
# WELCOME MESSAGE
# =============================================================================

# Show welcome message for new sessions
if [[ -n "$ZSH_WELCOME" ]] || [[ -z "$ZSH_WELCOME_SHOWN" ]]; then
    echo "🎉 Welcome to ZSH Configuration v3.0"
    echo "📦 Loaded modules: $(echo $ZSH_MODULES_LOADED | wc -w)"
    echo "💡 Available commands: zsh-check, zsh-perf, security-audit"
    export ZSH_WELCOME_SHOWN=1
fi

# =============================================================================
# CLEANUP
# =============================================================================

# Unset temporary variables
unset ZSH_STARTUP_START ZSH_STARTUP_END
