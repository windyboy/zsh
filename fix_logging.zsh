#!/usr/bin/env zsh
# =============================================================================
# Logging Directory Fix Script
# =============================================================================

echo "🔧 Fixing logging directory issues..."

# Set up directories
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}"
export ZSH_DATA_DIR="${ZSH_DATA_DIR:-$HOME/.local/share/zsh}"

# Create all necessary directories
echo "📁 Creating cache directories..."
mkdir -p "$ZSH_CACHE_DIR"

# Create log directories for each module
echo "📝 Creating log directories..."
mkdir -p "$ZSH_CACHE_DIR"

# Test logging functionality
echo "🧪 Testing logging functionality..."

# Test module manager logging
MODULE_MANAGER_LOG="${ZSH_CACHE_DIR}/module_manager.log"
[[ ! -d "$MODULE_MANAGER_LOG:h" ]] && mkdir -p "$MODULE_MANAGER_LOG:h"
echo "$(date '+%Y-%m-%d %H:%M:%S') [info] Test log entry" >> "$MODULE_MANAGER_LOG"

# Test error logging
ERROR_LOG="${ZSH_CACHE_DIR}/error.log"
[[ ! -d "$ERROR_LOG:h" ]] && mkdir -p "$ERROR_LOG:h"
echo "$(date '+%Y-%m-%d %H:%M:%S') [info] Test error log entry" >> "$ERROR_LOG"

# Test security logging
SECURITY_LOG="${ZSH_CACHE_DIR}/security.log"
[[ ! -d "$SECURITY_LOG:h" ]] && mkdir -p "$SECURITY_LOG:h"
echo "$(date '+%Y-%m-%d %H:%M:%S') [info] Test security log entry" >> "$SECURITY_LOG"

# Test performance logging
PERF_LOG="${ZSH_CACHE_DIR}/performance.log"
[[ ! -d "$PERF_LOG:h" ]] && mkdir -p "$PERF_LOG:h"
echo "$(date '+%Y-%m-%d %H:%M:%S') [info] Test performance log entry" >> "$PERF_LOG"

# Test alias logging
ALIAS_LOG="${ZSH_CACHE_DIR}/aliases.log"
[[ ! -d "$ALIAS_LOG:h" ]] && mkdir -p "$ALIAS_LOG:h"
echo "$(date '+%Y-%m-%d %H:%M:%S') [info] Test alias log entry" >> "$ALIAS_LOG"

# Test function logging
FUNCTION_LOG="${ZSH_CACHE_DIR}/functions.log"
[[ ! -d "$FUNCTION_LOG:h" ]] && mkdir -p "$FUNCTION_LOG:h"
echo "$(date '+%Y-%m-%d %H:%M:%S') [info] Test function log entry" >> "$FUNCTION_LOG"

# Test keybinding logging
KEYBINDING_LOG="${ZSH_CACHE_DIR}/keybindings.log"
[[ ! -d "$KEYBINDING_LOG:h" ]] && mkdir -p "$KEYBINDING_LOG:h"
echo "$(date '+%Y-%m-%d %H:%M:%S') [info] Test keybinding log entry" >> "$KEYBINDING_LOG"

# Test status logging
STATUS_LOG="${ZSH_CACHE_DIR}/system_status.log"
[[ ! -d "$STATUS_LOG:h" ]] && mkdir -p "$STATUS_LOG:h"
echo "$(date '+%Y-%m-%d %H:%M:%S') [info] Test status log entry" >> "$STATUS_LOG"

echo "✅ Logging directories created and tested successfully!"
echo "📁 Cache directory: $ZSH_CACHE_DIR"
echo "📝 Log files created in: $ZSH_CACHE_DIR"

# Show created log files
echo "📋 Created log files:"
ls -la "$ZSH_CACHE_DIR"/*.log 2>/dev/null || echo "No log files found"

echo "🔄 You can now reload your ZSH configuration:"
echo "   source ~/.zshrc" 