#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration Test Framework
# =============================================================================

# Simple test framework
TEST_LOG="${ZSH_CACHE_DIR}/test.log"

# Test colors
TEST_PASS="✅"
TEST_FAIL="❌"

# Simple test functions
assert_file_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo "$TEST_PASS File exists: $file"
        return 0
    else
        echo "$TEST_FAIL File missing: $file"
        return 1
    fi
}

assert_command_exists() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "$TEST_PASS Command exists: $cmd"
        return 0
    else
        echo "$TEST_FAIL Command missing: $cmd"
        return 1
    fi
}

assert_function_exists() {
    local func="$1"
    if typeset -f "$func" >/dev/null 2>&1; then
        echo "$TEST_PASS Function exists: $func"
        return 0
    else
        echo "$TEST_FAIL Function missing: $func"
        return 1
    fi
}

# Test core configuration
test_core_configuration() {
    echo "=== Testing Core Configuration ==="
    local errors=0
    
    # Test essential files
    assert_file_exists "$ZSH_CONFIG_DIR/zshrc" || ((errors++))
    assert_file_exists "$ZSH_CONFIG_DIR/zshenv" || ((errors++))
    assert_file_exists "$ZSH_CONFIG_DIR/modules/core.zsh" || ((errors++))
    
    # Test environment variables
    if [[ -n "$ZSH_CONFIG_DIR" ]]; then
        echo "$TEST_PASS ZSH_CONFIG_DIR is set"
    else
        echo "$TEST_FAIL ZSH_CONFIG_DIR is not set"
        ((errors++))
    fi
    
    # Test security configuration
    if [[ -o NO_CLOBBER ]]; then
        echo "$TEST_PASS NO_CLOBBER is set"
    else
        echo "$TEST_FAIL NO_CLOBBER is not set"
        ((errors++))
    fi
    
    if [[ -o RM_STAR_WAIT ]]; then
        echo "$TEST_PASS RM_STAR_WAIT is set"
    else
        echo "$TEST_FAIL RM_STAR_WAIT is not set"
        ((errors++))
    fi
    
    return $errors
}

# Test custom functions
test_custom_functions() {
    echo "=== Testing Custom Functions ==="
    local errors=0
    
    # Test essential functions
    local essential_functions=("mkcd" "extract" "serve")
    for func in "${essential_functions[@]}"; do
        assert_function_exists "$func" || ((errors++))
    done
    
    return $errors
}

# Test module loading
test_module_loading() {
    echo "=== Testing Module Loading ==="
    local errors=0
    
    # Test that modules are loaded
    local required_modules=("core" "error_handling" "security" "performance" "plugins" "completion" "functions" "aliases" "keybindings")
    for module in "${required_modules[@]}"; do
        if [[ "$ZSH_LOADED_MODULES" == *"$module"* ]]; then
            echo "$TEST_PASS Module loaded: $module"
        else
            echo "$TEST_FAIL Module not loaded: $module"
            ((errors++))
        fi
    done
    
    return $errors
}

# Test performance
test_performance() {
    echo "=== Testing Performance ==="
    local errors=0
    
    # Test startup time
    if [[ -n "$ZSH_STARTUP_TIME_BEGIN" ]]; then
        echo "$TEST_PASS Startup time tracking enabled"
    else
        echo "$TEST_FAIL Startup time tracking not enabled"
        ((errors++))
    fi
    
    # Test function count
    local func_count=$(declare -F | wc -l)
    if (( func_count < 1000 )); then
        echo "$TEST_PASS Function count reasonable: $func_count"
    else
        echo "$TEST_FAIL High function count: $func_count"
        ((errors++))
    fi
    
    return $errors
}



# Main test runner
run_zsh_tests() {
    echo "🧪 Running ZSH Configuration Tests..."
    echo "=================================="
    
    local total_errors=0
    
    # Test core configuration
    test_core_configuration
    total_errors=$((total_errors + $?))
    
    # Test essential functions
    test_custom_functions
    total_errors=$((total_errors + $?))
    
    # Test module loading
    test_module_loading
    total_errors=$((total_errors + $?))
    
    # Test performance
    test_performance
    total_errors=$((total_errors + $?))
    
    # Test summary
    echo ""
    if (( total_errors == 0 )); then
        echo "🎉 All tests passed!"
        echo "🏆 Configuration Score: 10/10"
        return 0
    else
        echo "⚠️  $total_errors test(s) failed"
        echo "📊 Configuration Score: $((10 - total_errors))/10"
        return 1
    fi
}

# Quick test function
quick_test() {
    echo "⚡ Quick ZSH Configuration Test"
    echo "=============================="
    
    local errors=0
    
    # Essential checks
    [[ -f "$ZSH_CONFIG_DIR/zshrc" ]] || { echo "$TEST_FAIL Main zshrc missing"; ((errors++)); }
    [[ -n "$ZSH_CONFIG_DIR" ]] || { echo "$TEST_FAIL ZSH_CONFIG_DIR not set"; ((errors++)); }
    
    if (( errors == 0 )); then
        echo "$TEST_PASS Quick test passed"
        return 0
    else
        echo "$TEST_FAIL Quick test failed ($errors errors)"
        return 1
    fi
}

# Export test functions
export -f run_zsh_tests quick_test 2>/dev/null || true 