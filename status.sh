#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration Status Check Script
# Version: 4.2
# =============================================================================

# Load configuration
source "$HOME/.config/zsh/zshrc" 2>/dev/null || {
    echo "❌ Unable to load ZSH configuration"
    exit 1
}

echo "🔍 ZSH Configuration Status Check"
echo "================================="

# Basic information
echo "📦 Version Information:"
version
echo

# Module status
echo "📁 Module Status:"
local total_lines=0
for module in core aliases plugins completion keybindings utils; do
    local file="$ZSH_CONFIG_DIR/modules/${module}.zsh"
    if [[ -f "$file" ]]; then
        local lines=$(wc -l < "$file" 2>/dev/null)
        total_lines=$((total_lines + lines))
        echo "  ✅ $module.zsh ($lines lines)"
    else
        echo "  ❌ $module.zsh (missing)"
    fi
done
echo "  Total: $total_lines lines"
echo

# Performance status
echo "⚡ Performance Status:"
perf
echo

# Configuration validation
echo "🔧 Configuration Validation:"
validate
echo

# Plugin status
echo "🔌 Plugin Status:"
plugins
echo

echo "✅ Status check completed" 