#!/usr/bin/env zsh
# =============================================================================
# Test Script for File & Directory Completion
# =============================================================================

echo "🧪 Testing File & Directory Completion..."
echo "========================================"

# Test 1: Check if enhanced completion is loaded
echo "1. Testing enhanced completion system..."
if (( ${+functions[_enhanced_file_completion]} )); then
    echo "   ✅ Enhanced file completion function loaded"
else
    echo "   ❌ Enhanced file completion function not found"
fi

# Test 2: Check if smart directory completion is loaded
echo "2. Testing smart directory completion..."
if (( ${+functions[_smart_dir_completion]} )); then
    echo "   ✅ Smart directory completion function loaded"
else
    echo "   ❌ Smart directory completion function not found"
fi

# Test 3: Check if safe file suggestions are loaded
echo "3. Testing safe file suggestions..."
if (( ${+functions[_safe_file_suggest]} )); then
    echo "   ✅ Safe file suggestions function loaded"
else
    echo "   ❌ Safe file suggestions function not found"
fi

# Test 4: Test new utility functions
echo "4. Testing new utility functions..."
if (( ${+functions[lls]} )); then
    echo "   ✅ Enhanced ls function (lls) available"
else
    echo "   ❌ Enhanced ls function not found"
fi

if (( ${+functions[qcd]} )); then
    echo "   ✅ Quick cd function (qcd) available"
else
    echo "   ❌ Quick cd function not found"
fi

if (( ${+functions[findf]} )); then
    echo "   ✅ Smart file finder (findf) available"
else
    echo "   ❌ Smart file finder not found"
fi

# Test 5: Test FZF tab completion
echo "5. Testing FZF tab completion..."
if command -v fzf >/dev/null 2>&1; then
    echo "   ✅ FZF is available"
    if [[ -n "$ZINIT" ]]; then
        echo "   ✅ Zinit is loaded"
        echo "   💡 Try: ls <TAB> to test FZF tab completion"
    else
        echo "   ⚠️  Zinit not loaded, FZF tab may not work"
    fi
else
    echo "   ❌ FZF not installed"
    echo "   💡 Install with: brew install fzf (macOS)"
fi

# Test 6: Test completion styles
echo "6. Testing completion styles..."
zstyle -L ':completion:*' menu 2>/dev/null && echo "   ✅ Menu completion enabled" || echo "   ❌ Menu completion not enabled"
zstyle -L ':completion:*' file-patterns 2>/dev/null && echo "   ✅ File patterns configured" || echo "   ❌ File patterns not configured"

# Test 7: Test directory listing
echo "7. Testing directory listing..."
echo "   Current directory contents:"
if (( ${+functions[lls]} )); then
    lls | head -5
else
    ls -la | head -5
fi

echo ""
echo "🎉 File & Directory Completion Test Completed!"
echo ""
echo "💡 Try these commands to test the new functionality:"
echo "   • ls <TAB> - Enhanced file completion with FZF"
echo "   • cd <TAB> - Smart directory completion"
echo "   • lls - Enhanced directory listing"
echo "   • qcd - Quick directory navigation with preview"
echo "   • findf <pattern> - Smart file finder"
echo "   • treef - Directory tree view"
echo ""
echo "🔧 If completion doesn't work as expected:"
echo "   • Run: source ~/.zshrc"
echo "   • Check if FZF is installed: command -v fzf"
echo "   • Verify Zinit is loaded: echo \$ZINIT" 