#!/usr/bin/env zsh
# =============================================================================
# Simple Plugin Conflict Test
# =============================================================================

# Load unified logging system
if [[ -f "$HOME/.config/zsh/modules/logging.zsh" ]]; then
    source "$HOME/.config/zsh/modules/logging.zsh"
else
    # Fallback logging functions
    log() { echo "ℹ️  $1"; }
    success() { echo "✅ $1"; }
    error() { echo "❌ $1"; }
    warning() { echo "⚠️  $1"; }
fi

echo "🔍 Testing Plugin Conflicts..."
echo "============================="

# Source the plugins module
if [[ -f "$HOME/.config/zsh/modules/plugins.zsh" ]]; then
    source "$HOME/.config/zsh/modules/plugins.zsh"
    success "Plugins module loaded"
else
    error "Plugins module not found"
    exit 1
fi

echo ""
echo "📋 Running conflict checks..."

# Test 1: Check for REAL key binding conflicts
echo ""
echo "1️⃣  Checking for REAL key binding conflicts..."
echo "💡 This checks if the same key is bound to different functions (actual conflicts)"
echo "💡 Multiple keys bound to the same function is NORMAL zsh behavior"

# Use the improved conflict detection
if command -v check_plugin_conflicts >/dev/null 2>&1; then
    check_plugin_conflicts
else
    error "check_plugin_conflicts function not found"
fi

# Test 2: Check for duplicate aliases
echo ""
echo "2️⃣  Checking aliases..."
duplicate_aliases=$(alias | cut -d= -f1 | sed 's/^alias //g' | sort | uniq -d)
if [[ -n "$duplicate_aliases" ]]; then
    error "Duplicate aliases found:"
    echo "$duplicate_aliases" | sed 's/^/  • /'
else
    success "No duplicate aliases"
fi

# Test 3: Check for duplicate zstyle configurations
echo ""
echo "3️⃣  Checking zstyle configurations..."
duplicate_zstyles=$(zstyle -L | grep -E '^[[:space:]]*:' | awk '{print $1}' | sort | uniq -d)
if [[ -n "$duplicate_zstyles" ]]; then
    error "Duplicate zstyle configurations found:"
    echo "$duplicate_zstyles" | sed 's/^/  • /'
else
    success "No duplicate zstyle configurations"
fi

# Test 4: Check specific plugin conflicts
echo ""
echo "4️⃣  Checking specific plugin conflicts..."

# Check if ls alias conflicts exist
if alias ls >/dev/null 2>&1; then
    local ls_alias=$(alias ls)
    log "ls alias: $ls_alias"
else
    error "No ls alias found"
fi

# Check if Ctrl+T is bound multiple times
ctrl_t_bindings=$(bindkey | grep '^\^T' | wc -l)
if [[ $ctrl_t_bindings -gt 1 ]]; then
    error "Ctrl+T bound multiple times:"
    bindkey | grep '^\^T' | sed 's/^/  • /'
else
    success "Ctrl+T binding is unique"
fi

# Check if Ctrl+R is bound multiple times
ctrl_r_bindings=$(bindkey | grep '^\^R' | wc -l)
if [[ $ctrl_r_bindings -gt 1 ]]; then
    error "Ctrl+R bound multiple times:"
    bindkey | grep '^\^R' | sed 's/^/  • /'
else
    success "Ctrl+R binding is unique"
fi

# Test 5: Check plugin functionality
echo ""
echo "5️⃣  Testing plugin functionality..."

# Test if check_plugin_conflicts function exists
if command -v check_plugin_conflicts >/dev/null 2>&1; then
    success "check_plugin_conflicts function available"
else
    error "check_plugin_conflicts function not found"
fi

# Test if resolve_plugin_conflicts function exists
if command -v resolve_plugin_conflicts >/dev/null 2>&1; then
    success "resolve_plugin_conflicts function available"
else
    error "resolve_plugin_conflicts function not found"
fi

# Test if check_plugins function exists
if command -v check_plugins >/dev/null 2>&1; then
    success "check_plugins function available"
else
    error "check_plugins function not found"
fi

echo ""
echo "🎯 Test completed!"
echo ""
echo "💡 Explanation of Results:"
echo "   • ✅ = No conflicts detected"
echo "   • ❌ = Actual conflicts found"
echo "   • Multiple keys bound to same function = NORMAL (not a conflict)"
echo "   • Same key bound to different functions = REAL CONFLICT"
