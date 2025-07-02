#!/usr/bin/env zsh
# ZSH Performance Optimization Verification Script

echo "🔍 ZSH Performance Optimization Verification"
echo "============================================"

# =============================================================================
# 1. Check if optimizations are in place
# =============================================================================
echo "1. Checking optimization status..."

# Check ZINIT_AUTO_UPDATE setting
if grep -q "ZINIT_AUTO_UPDATE=0" ~/.zshrc; then
    echo "  ✅ ZINIT_AUTO_UPDATE=0 is set"
else
    echo "  ❌ ZINIT_AUTO_UPDATE=0 is not set"
fi

# Check for compiled zsh files
compiled_files=$(find ~/.config/zsh -name "*.zwc" 2>/dev/null | wc -l)
echo "  📦 Found $compiled_files compiled zsh files"

# Check completion cache
if [[ -f ~/.cache/zsh/zcompdump.zwc ]]; then
    echo "  ✅ Completion cache is compiled"
else
    echo "  ⚠️  Completion cache is not compiled"
fi

# =============================================================================
# 2. Performance testing
# =============================================================================
echo ""
echo "2. Performance testing..."

# Test basic startup time
echo "  Testing basic startup time..."
basic_time=$(time zsh -c "exit" 2>&1 | grep real | awk '{print $2}')
echo "    Basic startup: $basic_time"

# Test configuration load time
echo "  Testing configuration load time..."
config_time=$(time zsh -c "source ~/.zshrc; exit" 2>&1 | grep real | awk '{print $2}')
echo "    Configuration load: $config_time"

# Test interactive shell startup
echo "  Testing interactive shell startup..."
interactive_time=$(time zsh -i -c "exit" 2>&1 | grep real | awk '{print $2}')
echo "    Interactive startup: $interactive_time"

# =============================================================================
# 3. Performance analysis
# =============================================================================
echo ""
echo "3. Performance analysis..."

# Run performance analysis
zsh -c "source ~/.zshrc; zsh_perf_analyze" 2>/dev/null | head -10

# =============================================================================
# 4. Optimization verification
# =============================================================================
echo ""
echo "4. Optimization verification..."

# Check if startup time is acceptable
if [[ "$config_time" < "1.0" ]]; then
    echo "  ✅ Configuration load time is good: $config_time"
else
    echo "  ⚠️  Configuration load time is slow: $config_time"
fi

if [[ "$interactive_time" < "2.0" ]]; then
    echo "  ✅ Interactive startup time is good: $interactive_time"
else
    echo "  ⚠️  Interactive startup time is slow: $interactive_time"
fi

# =============================================================================
# 5. Summary
# =============================================================================
echo ""
echo "📊 Performance Summary"
echo "====================="
echo "Basic startup:      $basic_time"
echo "Config load:        $config_time"
echo "Interactive:        $interactive_time"
echo "Compiled files:     $compiled_files"
echo ""

# Performance assessment
if [[ "$config_time" < "0.5" ]] && [[ "$interactive_time" < "2.0" ]]; then
    echo "🎉 Performance is EXCELLENT!"
    echo "✅ All optimizations are working correctly"
elif [[ "$config_time" < "1.0" ]] && [[ "$interactive_time" < "3.0" ]]; then
    echo "👍 Performance is GOOD"
    echo "✅ Optimizations are working well"
else
    echo "⚠️  Performance needs attention"
    echo "🔧 Consider running ./optimize_performance.zsh"
fi

echo ""
echo "🔧 Maintenance commands:"
echo "  ./test_performance.zsh    - Quick performance test"
echo "  ./optimize_performance.zsh - Full optimization"
echo "  zsh_perf_analyze          - Detailed analysis" 