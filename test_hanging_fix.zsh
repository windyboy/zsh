#!/usr/bin/env zsh
# =============================================================================
# Test Script for Hanging Issue Fix
# =============================================================================

echo "🧪 Testing ZSH hanging issue fix..."
echo "=================================="

# Test 1: Check if completion system loads without hanging
echo "1. Testing completion system initialization..."
start_time=$SECONDS
source ~/.config/zsh/modules/completion.zsh
completion_time=$((SECONDS - start_time))
echo "   ✅ Completion system loaded in ${completion_time}s"

# Test 2: Check if plugins load without hanging
echo "2. Testing plugin system initialization..."
start_time=$SECONDS
source ~/.config/zsh/modules/plugins.zsh
plugin_time=$((SECONDS - start_time))
echo "   ✅ Plugin system loaded in ${plugin_time}s"

# Test 3: Test empty return behavior
echo "3. Testing empty return behavior..."
echo "   Press Enter twice to test if shell hangs:"
read -r
echo "   First Enter pressed"
read -r
echo "   Second Enter pressed - if you see this, no hanging occurred!"

# Test 4: Check for background processes
echo "4. Checking for background processes..."
background_jobs=$(jobs 2>/dev/null | wc -l)
if [[ $background_jobs -eq 0 ]]; then
    echo "   ✅ No background jobs running"
else
    echo "   ⚠️  $background_jobs background job(s) running"
    jobs
fi

# Test 5: Check completion cache
echo "5. Checking completion cache..."
if [[ -f ~/.cache/zsh/zcompdump ]]; then
    cache_size=$(ls -lh ~/.cache/zsh/zcompdump | awk '{print $5}')
    echo "   ✅ Completion cache exists (${cache_size})"
else
    echo "   ⚠️  Completion cache not found"
fi

echo ""
echo "🎉 Test completed successfully!"
echo "If you didn't experience any hanging, the fix is working."
echo ""
echo "💡 If you still experience hanging, try:"
echo "   - Restart your terminal completely"
echo "   - Run: source ~/.zshrc"
echo "   - Check if any external tools (docker, bun, deno) are slow to respond" 