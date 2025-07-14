#!/usr/bin/env bash
# =============================================================================
# Test ZSH Configuration Reload
# =============================================================================

echo "🧪 Testing ZSH Configuration Reload"
echo "==================================="

# Test 1: Check if zshrc exists and is readable
echo "1. Checking zshrc file..."
if [[ -f ~/.zshrc ]] && [[ -r ~/.zshrc ]]; then
    echo "✅ ~/.zshrc exists and is readable"
else
    echo "❌ ~/.zshrc missing or not readable"
    exit 1
fi

# Test 2: Check if it's a symlink to the correct location
echo "2. Checking zshrc symlink..."
if [[ -L ~/.zshrc ]]; then
    target=$(readlink ~/.zshrc)
    echo "✅ ~/.zshrc is a symlink to: $target"
else
    echo "⚠️  ~/.zshrc is not a symlink"
fi

# Test 3: Check essential directories
echo "3. Checking essential directories..."
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

for dir in "$config_dir" "$cache_dir" "$data_dir"; do
    if [[ -d "$dir" ]]; then
        echo "✅ Directory exists: $dir"
    else
        echo "❌ Directory missing: $dir"
    fi
done

# Test 4: Check essential modules
echo "4. Checking essential modules..."
modules=(
    "core.zsh"
    "error_handling.zsh"
    "security.zsh"
    "performance.zsh"
    "plugins.zsh"
    "completion.zsh"
    "functions.zsh"
    "aliases.zsh"
    "keybindings.zsh"
)

for module in "${modules[@]}"; do
    if [[ -f "$config_dir/modules/$module" ]]; then
        echo "✅ Module exists: $module"
    else
        echo "❌ Module missing: $module"
    fi
done

# Test 5: Test syntax check
echo "5. Testing syntax..."
if zsh -n ~/.zshrc 2>/dev/null; then
    echo "✅ Syntax check passed"
else
    echo "❌ Syntax errors found"
    echo "Running zsh -n ~/.zshrc to see errors:"
    zsh -n ~/.zshrc
    exit 1
fi

# Test 6: Test safe reload
echo "6. Testing safe reload..."
if zsh -c "source ~/.zshrc" 2>/dev/null; then
    echo "✅ Safe reload test passed"
else
    echo "❌ Safe reload test failed"
    echo "Running zsh -c 'source ~/.zshrc' to see errors:"
    zsh -c "source ~/.zshrc"
    exit 1
fi

echo ""
echo "🎉 All tests passed! Your zsh configuration should work correctly."
echo ""
echo "To reload your configuration, use:"
echo "  reload"
echo "  zsh-reload"
echo "  source ~/.zshrc" 