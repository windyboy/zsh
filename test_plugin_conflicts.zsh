#!/usr/bin/env zsh
# =============================================================================
# Plugin Conflict Test Script
# =============================================================================

echo "🔍 Testing Plugin Conflicts..."
echo "============================="

# Source the plugins module
if [[ -f "$ZSH_CONFIG_DIR/modules/plugins.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/plugins.zsh"
    echo "✅ Plugins module loaded"
else
    echo "❌ Plugins module not found"
    exit 1
fi

echo ""
echo "📋 Running conflict checks..."

# Test 1: Check for duplicate key bindings
echo ""
echo "1️⃣  Checking key bindings..."
local duplicate_bindings=$(bindkey | awk '{print $2}' | sort | uniq -d)
if [[ -n "$duplicate_bindings" ]]; then
    echo "❌ Duplicate key bindings found:"
    echo "$duplicate_bindings" | sed 's/^/  • /'
else
    echo "✅ No duplicate key bindings"
fi

# Test 2: Check for duplicate aliases
echo ""
echo "2️⃣  Checking aliases..."
local duplicate_aliases=$(alias | awk '{print $1}' | sort | uniq -d)
if [[ -n "$duplicate_aliases" ]]; then
    echo "❌ Duplicate aliases found:"
    echo "$duplicate_aliases" | sed 's/^/  • /'
else
    echo "✅ No duplicate aliases"
fi

# Test 3: Check for duplicate zstyle configurations
echo ""
echo "3️⃣  Checking zstyle configurations..."
local duplicate_zstyles=$(zstyle -L | grep -E '^[[:space:]]*:' | awk '{print $1}' | sort | uniq -d)
if [[ -n "$duplicate_zstyles" ]]; then
    echo "❌ Duplicate zstyle configurations found:"
    echo "$duplicate_zstyles" | sed 's/^/  • /'
else
    echo "✅ No duplicate zstyle configurations"
fi

# Test 4: Check specific plugin conflicts
echo ""
echo "4️⃣  Checking specific plugin conflicts..."

# Check if ls alias conflicts exist
if alias ls >/dev/null 2>&1; then
    local ls_alias=$(alias ls)
    echo "📝 ls alias: $ls_alias"
else
    echo "❌ No ls alias found"
fi

# Check if Ctrl+T is bound multiple times
local ctrl_t_bindings=$(bindkey | grep '\^T' | wc -l)
if [[ $ctrl_t_bindings -gt 1 ]]; then
    echo "❌ Ctrl+T bound multiple times:"
    bindkey | grep '\^T' | sed 's/^/  • /'
else
    echo "✅ Ctrl+T binding is unique"
fi

# Check if Ctrl+R is bound multiple times
local ctrl_r_bindings=$(bindkey | grep '\^R' | wc -l)
if [[ $ctrl_r_bindings -gt 1 ]]; then
    echo "❌ Ctrl+R bound multiple times:"
    bindkey | grep '\^R' | sed 's/^/  • /'
else
    echo "✅ Ctrl+R binding is unique"
fi

# Test 5: Check plugin functionality
echo ""
echo "5️⃣  Testing plugin functionality..."

# Test if check_plugin_conflicts function exists
if command -v check_plugin_conflicts >/dev/null 2>&1; then
    echo "✅ check_plugin_conflicts function available"
    echo "Running conflict check..."
    check_plugin_conflicts
else
    echo "❌ check_plugin_conflicts function not found"
fi

# Test if resolve_plugin_conflicts function exists
if command -v resolve_plugin_conflicts >/dev/null 2>&1; then
    echo "✅ resolve_plugin_conflicts function available"
    
    # Ask user if they want to resolve conflicts
    echo ""
    echo "🔧 Would you like to automatically resolve conflicts? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Resolving conflicts..."
        resolve_plugin_conflicts
        
        echo ""
        echo "🔄 Re-checking conflicts after resolution..."
        check_plugin_conflicts
    else
        echo "Skipping automatic conflict resolution"
    fi
else
    echo "❌ resolve_plugin_conflicts function not found"
fi

# Test if check_plugins function exists
if command -v check_plugins >/dev/null 2>&1; then
    echo "✅ check_plugins function available"
else
    echo "❌ check_plugins function not found"
fi

echo ""
echo "🎯 Test completed!"
echo "💡 If you see any ❌ marks above, there may still be conflicts to resolve." 