#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration Verification Script
# =============================================================================

echo "🔍 ZSH Configuration Verification"
echo "================================"

# Check system compatibility
echo ""
echo "📋 System Compatibility Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ macOS detected"
    OS_COMPATIBLE=true
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "✅ Linux detected"
    OS_COMPATIBLE=true
else
    echo "⚠️  Unknown OS: $OSTYPE"
    OS_COMPATIBLE=false
fi

# Check zsh version
ZSH_VERSION_NUM=$(zsh --version | grep -o '[0-9]\+\.[0-9]\+' | head -1)
if [[ -n "$ZSH_VERSION_NUM" ]]; then
    echo "✅ ZSH version: $ZSH_VERSION_NUM"
    if (( $(echo "$ZSH_VERSION_NUM >= 5.0" | bc -l 2>/dev/null || echo "0") )); then
        echo "✅ ZSH version is recent enough"
        ZSH_COMPATIBLE=true
    else
        echo "⚠️  ZSH version might be too old"
        ZSH_COMPATIBLE=false
    fi
else
    echo "❌ Could not determine ZSH version"
    ZSH_COMPATIBLE=false
fi

# Check required commands
echo ""
echo "🔧 Required Commands Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REQUIRED_COMMANDS=("git" "curl" "find" "grep" "sed" "awk")
MISSING_COMMANDS=()

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ $cmd is available"
    else
        echo "❌ $cmd is missing"
        MISSING_COMMANDS+=("$cmd")
    fi
done

# Check optional commands
echo ""
echo "🔧 Optional Commands Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

OPTIONAL_COMMANDS=("timeout" "bc" "bat" "fzf" "zoxide" "eza" "oh-my-posh")
AVAILABLE_OPTIONAL=()

for cmd in "${OPTIONAL_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ $cmd is available"
        AVAILABLE_OPTIONAL+=("$cmd")
    else
        echo "⚠️  $cmd is not available (optional)"
    fi
done

# Check configuration files
echo ""
echo "📁 Configuration Files Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CONFIG_FILES=(
    "$ZSH_CONFIG_DIR/zshrc"
    "$ZSH_CONFIG_DIR/zshenv"
    "$ZSH_CONFIG_DIR/modules/core.zsh"
    "$ZSH_CONFIG_DIR/modules/error_handling.zsh"
    "$ZSH_CONFIG_DIR/modules/security.zsh"
    "$ZSH_CONFIG_DIR/modules/performance.zsh"
    "$ZSH_CONFIG_DIR/modules/plugins.zsh"
    "$ZSH_CONFIG_DIR/modules/completion.zsh"
    "$ZSH_CONFIG_DIR/modules/functions.zsh"
    "$ZSH_CONFIG_DIR/modules/aliases.zsh"
    "$ZSH_CONFIG_DIR/modules/keybindings.zsh"
    "$ZSH_CONFIG_DIR/themes/prompt.zsh"
)

MISSING_FILES=()

for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $(basename "$file") exists"
    else
        echo "❌ $(basename "$file") missing"
        MISSING_FILES+=("$file")
    fi
done

# Check directories
echo ""
echo "📁 Directory Structure Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REQUIRED_DIRS=(
    "$ZSH_CONFIG_DIR"
    "$ZSH_CACHE_DIR"
    "$ZSH_DATA_DIR"
    "$ZSH_CONFIG_DIR/modules"
    "$ZSH_CONFIG_DIR/themes"
    "$ZSH_CONFIG_DIR/completions"
)

MISSING_DIRS=()

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "✅ $(basename "$dir") directory exists"
    else
        echo "❌ $(basename "$dir") directory missing"
        MISSING_DIRS+=("$dir")
    fi
done

# Performance check
echo ""
echo "⚡ Performance Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if performance functions are available
if (( ${+functions[zsh_perf_analyze]} )); then
    echo "✅ Performance analysis function available"
    PERFORMANCE_READY=true
else
    echo "❌ Performance analysis function not available"
    PERFORMANCE_READY=false
fi

# Check if optimization functions are available
if (( ${+functions[optimize_zsh_performance]} )); then
    echo "✅ Performance optimization function available"
    OPTIMIZATION_READY=true
else
    echo "❌ Performance optimization function not available"
    OPTIMIZATION_READY=false
fi

# Security check
echo ""
echo "🔒 Security Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if security functions are available
if (( ${+functions[validate_security_config]} )); then
    echo "✅ Security validation function available"
    SECURITY_READY=true
else
    echo "❌ Security validation function not available"
    SECURITY_READY=false
fi

# Check if security options are set
if [[ -o NO_CLOBBER ]]; then
    echo "✅ NO_CLOBBER is set"
else
    echo "❌ NO_CLOBBER is not set"
fi

if [[ -o RM_STAR_WAIT ]]; then
    echo "✅ RM_STAR_WAIT is set"
else
    echo "❌ RM_STAR_WAIT is not set"
fi

# Summary
echo ""
echo "📊 Verification Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_ISSUES=0

if [[ "$OS_COMPATIBLE" == "true" ]]; then
    echo "✅ OS compatibility: PASS"
else
    echo "❌ OS compatibility: FAIL"
    ((TOTAL_ISSUES++))
fi

if [[ "$ZSH_COMPATIBLE" == "true" ]]; then
    echo "✅ ZSH compatibility: PASS"
else
    echo "❌ ZSH compatibility: FAIL"
    ((TOTAL_ISSUES++))
fi

if [[ ${#MISSING_COMMANDS[@]} -eq 0 ]]; then
    echo "✅ Required commands: PASS"
else
    echo "❌ Required commands: FAIL (${#MISSING_COMMANDS[@]} missing)"
    ((TOTAL_ISSUES++))
fi

if [[ ${#MISSING_FILES[@]} -eq 0 ]]; then
    echo "✅ Configuration files: PASS"
else
    echo "❌ Configuration files: FAIL (${#MISSING_FILES[@]} missing)"
    ((TOTAL_ISSUES++))
fi

if [[ ${#MISSING_DIRS[@]} -eq 0 ]]; then
    echo "✅ Directory structure: PASS"
else
    echo "❌ Directory structure: FAIL (${#MISSING_DIRS[@]} missing)"
    ((TOTAL_ISSUES++))
fi

if [[ "$PERFORMANCE_READY" == "true" ]]; then
    echo "✅ Performance functions: PASS"
else
    echo "❌ Performance functions: FAIL"
    ((TOTAL_ISSUES++))
fi

if [[ "$SECURITY_READY" == "true" ]]; then
    echo "✅ Security functions: PASS"
else
    echo "❌ Security functions: FAIL"
    ((TOTAL_ISSUES++))
fi

echo ""
if [[ $TOTAL_ISSUES -eq 0 ]]; then
    echo "🎉 All checks passed! Configuration is ready to use."
    echo "💡 Optional enhancements available: ${AVAILABLE_OPTIONAL[*]}"
    exit 0
else
    echo "⚠️  $TOTAL_ISSUES issue(s) found. Please address them before using the configuration."
    
    if [[ ${#MISSING_COMMANDS[@]} -gt 0 ]]; then
        echo ""
        echo "Missing required commands: ${MISSING_COMMANDS[*]}"
        echo "Please install them using your system's package manager."
    fi
    
    if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
        echo ""
        echo "Missing configuration files:"
        for file in "${MISSING_FILES[@]}"; do
            echo "  - $file"
        done
    fi
    
    if [[ ${#MISSING_DIRS[@]} -gt 0 ]]; then
        echo ""
        echo "Missing directories:"
        for dir in "${MISSING_DIRS[@]}"; do
            echo "  - $dir"
        done
    fi
    
    exit 1
fi 