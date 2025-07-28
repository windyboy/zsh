#!/usr/bin/env bash
# =============================================================================
# ZSH Configuration Test Suite
# Version: 5.0 - Comprehensive Testing Framework
# =============================================================================

# Re-exec with zsh if available
if [[ -z "${ZSH_VERSION:-}" ]]; then
    if command -v zsh >/dev/null 2>&1; then
        exec zsh "$0" "$@"
    else
        echo "❌ zsh is required but not installed." >&2
        exit 1
    fi
fi

# Enhanced color functions
test_color_red()    { echo -e "\033[31m$1\033[0m"; }
test_color_green()  { echo -e "\033[32m$1\033[0m"; }
test_color_yellow() { echo -e "\033[33m$1\033[0m"; }
test_color_blue()   { echo -e "\033[34m$1\033[0m"; }
test_color_purple() { echo -e "\033[35m$1\033[0m"; }
test_color_cyan()   { echo -e "\033[36m$1\033[0m"; }
test_color_bold()   { echo -e "\033[1m$1\033[0m"; }

# Test framework variables
TEST_RESULTS=()
TEST_COUNT=0
PASSED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0
TEST_START_TIME=$(date +%s)

# Test framework functions
test_assert() {
    local test_name="$1"
    local condition="$2"
    local message="${3:-Test failed}"
    
    ((TEST_COUNT++))
    
    if eval "$condition"; then
        TEST_RESULTS+=("PASS: $test_name")
        ((PASSED_COUNT++))
        test_color_green "✅ $test_name"
        return 0
    else
        TEST_RESULTS+=("FAIL: $test_name - $message")
        ((FAILED_COUNT++))
        test_color_red "❌ $test_name - $message"
        return 1
    fi
}

test_skip() {
    local test_name="$1"
    local reason="${2:-Skipped}"
    
    ((TEST_COUNT++))
    ((SKIPPED_COUNT++))
    TEST_RESULTS+=("SKIP: $test_name - $reason")
    test_color_yellow "⏭️  $test_name - $reason"
}

test_section() {
    echo
    test_color_bold "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    test_color_cyan "🧪 $1"
    test_color_bold "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

test_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - TEST_START_TIME))
    
    echo
    test_color_bold "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    test_color_cyan "📊 Test Summary"
    test_color_bold "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    printf "  %s %-20s %s\n" "📈" "Total Tests:" "$TEST_COUNT"
    printf "  %s %-20s %s\n" "✅" "Passed:" "$(test_color_green $PASSED_COUNT)"
    printf "  %s %-20s %s\n" "❌" "Failed:" "$(test_color_red $FAILED_COUNT)"
    printf "  %s %-20s %s\n" "⏭️" "Skipped:" "$(test_color_yellow $SKIPPED_COUNT)"
    printf "  %s %-20s %s\n" "⏱️" "Duration:" "${duration}s"
    
    if [[ $FAILED_COUNT -eq 0 ]]; then
        test_color_green "🎉 All tests passed!"
        return 0
    else
        test_color_red "💥 $FAILED_COUNT test(s) failed!"
        return 1
    fi
}

# Load configuration for testing
load_config_for_testing() {
    export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
    
    if [[ ! -f "$ZSH_CONFIG_DIR/zshrc" ]]; then
        test_color_red "❌ Configuration not found at $ZSH_CONFIG_DIR"
        exit 1
    fi
    
    # Load configuration in test mode
    export ZSH_TEST_MODE=1
    source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1
}

# Unit Tests
run_unit_tests() {
    test_section "Unit Tests"
    
    # Test color functions
    test_assert "Color functions exist" "command -v color_red >/dev/null 2>&1" "color_red function not found"
    test_assert "Color functions exist" "command -v color_green >/dev/null 2>&1" "color_green function not found"
    
    # Test core functions
    test_assert "reload function exists" "command -v reload >/dev/null 2>&1" "reload function not found"
    test_assert "validate function exists" "command -v validate >/dev/null 2>&1" "validate function not found"
    test_assert "status function exists" "command -v status >/dev/null 2>&1" "status function not found"
    test_assert "version function exists" "command -v version >/dev/null 2>&1" "version function not found"
    
    # Test utility functions
    test_assert "mkcd function exists" "command -v mkcd >/dev/null 2>&1" "mkcd function not found"
    test_assert "extract function exists" "command -v extract >/dev/null 2>&1" "extract function not found"
    test_assert "config function exists" "command -v config >/dev/null 2>&1" "config function not found"
    
    # Test environment variables
    test_assert "ZSH_CONFIG_DIR is set" "[[ -n \"$ZSH_CONFIG_DIR\" ]]" "ZSH_CONFIG_DIR not set"
    test_assert "ZSH_CACHE_DIR is set" "[[ -n \"$ZSH_CACHE_DIR\" ]]" "ZSH_CACHE_DIR not set"
    test_assert "ZSH_DATA_DIR is set" "[[ -n \"$ZSH_DATA_DIR\" ]]" "ZSH_DATA_DIR not set"
    
    # Test directory existence
    test_assert "Config directory exists" "[[ -d \"$ZSH_CONFIG_DIR\" ]]" "Config directory not found"
    test_assert "Cache directory exists" "[[ -d \"$ZSH_CACHE_DIR\" ]]" "Cache directory not found"
    test_assert "Data directory exists" "[[ -d \"$ZSH_DATA_DIR\" ]]" "Data directory not found"
}

# Integration Tests
run_integration_tests() {
    test_section "Integration Tests"
    
    # Test module loading
    test_assert "Core module loaded" "[[ -n \"$ZSH_MODULES_LOADED\" && \"$ZSH_MODULES_LOADED\" == *core* ]]" "Core module not loaded"
    
    # Test plugin system
    if command -v zinit >/dev/null 2>&1; then
        test_assert "zinit is available" "true" "zinit not available"
    else
        test_skip "zinit integration" "zinit not installed"
    fi
    
    # Test completion system
    test_assert "Completion system works" "compdef >/dev/null 2>&1" "Completion system not working"
    
    # Test keybindings
    test_assert "Keybindings loaded" "bindkey | grep -q '^'" "No keybindings found"
    
    # Test aliases
    test_assert "Aliases loaded" "alias | grep -q '^'" "No aliases found"
}

# Performance Tests
run_performance_tests() {
    test_section "Performance Tests"
    
    # Test startup time
    local start_time=$(date +%s.%N)
    source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local startup_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    
    test_assert "Startup time < 2s" "[[ $(echo "$startup_time < 2" | bc 2>/dev/null || echo "0") -eq 1 ]]" "Startup time too slow: ${startup_time}s"
    
    # Test memory usage
    local memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
    local memory_mb=$(echo "scale=1; ${memory_kb:-0} / 1024" | bc 2>/dev/null || echo "0")
    
    test_assert "Memory usage < 10MB" "[[ $(echo "$memory_mb < 10" | bc 2>/dev/null || echo "0") -eq 1 ]]" "Memory usage too high: ${memory_mb}MB"
    
    # Test function count
    local func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
    test_assert "Function count < 200" "[[ $func_count -lt 200 ]]" "Too many functions: $func_count"
    
    # Test alias count
    local alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
    test_assert "Alias count < 100" "[[ $alias_count -lt 100 ]]" "Too many aliases: $alias_count"
}

# Plugin Conflict Tests
run_plugin_tests() {
    test_section "Plugin Conflict Tests"
    
    # Test for duplicate aliases
    local duplicate_aliases=$(alias | cut -d= -f1 | sed 's/^alias //g' | sort | uniq -d)
    test_assert "No duplicate aliases" "[[ -z \"$duplicate_aliases\" ]]" "Duplicate aliases found: $duplicate_aliases"
    
    # Test for key binding conflicts
    local ctrl_t_bindings=$(bindkey | grep '^\^T' | wc -l)
    test_assert "Ctrl+T binding unique" "[[ $ctrl_t_bindings -le 1 ]]" "Ctrl+T bound multiple times"
    
    local ctrl_r_bindings=$(bindkey | grep '^\^R' | wc -l)
    test_assert "Ctrl+R binding unique" "[[ $ctrl_r_bindings -le 1 ]]" "Ctrl+R bound multiple times"
    
    # Test for zstyle conflicts
    local duplicate_zstyles=$(zstyle -L | grep -E '^[[:space:]]*:' | awk '{print $1}' | sort | uniq -d)
    test_assert "No duplicate zstyles" "[[ -z \"$duplicate_zstyles\" ]]" "Duplicate zstyle configurations found"
}

# Security Tests
run_security_tests() {
    test_section "Security Tests"
    
    # Test file permissions
    test_assert "Config files secure" "[[ $(stat -c %a \"$ZSH_CONFIG_DIR/zshrc\" 2>/dev/null || stat -f %Lp \"$ZSH_CONFIG_DIR/zshrc\" 2>/dev/null) -le 644 ]]" "Config files have insecure permissions"
    
    # Test for dangerous aliases
    test_assert "No dangerous rm alias" "! alias | grep -q '^alias rm=' || alias rm | grep -q 'rm -i'" "Dangerous rm alias found"
    
    # Test for command injection vulnerabilities
    test_assert "No eval in functions" "! grep -r 'eval ' \"$ZSH_CONFIG_DIR/modules/\" 2>/dev/null | grep -v 'eval \"\$(oh-my-posh'" "Potential eval usage found"
}

# Main test runner
main() {
    local test_type="${1:-all}"
    
    echo
    test_color_bold "╔══════════════════════════════════════════════════════════════╗"
    test_color_bold "║                🧪 ZSH Configuration Test Suite               ║"
    test_color_bold "╚══════════════════════════════════════════════════════════════╝"
    echo
    
    # Load configuration
    load_config_for_testing
    
    case "$test_type" in
        "unit")
            run_unit_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "performance")
            run_performance_tests
            ;;
        "plugins")
            run_plugin_tests
            ;;
        "security")
            run_security_tests
            ;;
        "all"|*)
            run_unit_tests
            run_integration_tests
            run_performance_tests
            run_plugin_tests
            run_security_tests
            ;;
    esac
    
    test_summary
}

# Help function
show_help() {
    echo "Usage: $0 [test_type]"
    echo
    echo "Test Types:"
    echo "  unit         - Run unit tests only"
    echo "  integration  - Run integration tests only"
    echo "  performance  - Run performance tests only"
    echo "  plugins      - Run plugin conflict tests only"
    echo "  security     - Run security tests only"
    echo "  all          - Run all tests (default)"
    echo
    echo "Examples:"
    echo "  $0              # Run all tests"
    echo "  $0 unit         # Run unit tests only"
    echo "  $0 performance  # Run performance tests only"
}

# Parse command line arguments
case "${1:-}" in
    "-h"|"--help")
        show_help
        exit 0
        ;;
esac

# Run tests
main "$@"
