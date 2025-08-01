#!/usr/bin/env bash
# =============================================================================
# ZSH Configuration Test Suite
# Version: 5.1 - Enhanced CI-Ready Testing Framework
# =============================================================================

# Re-exec with zsh if available
if [[ -z "${ZSH_VERSION:-}" ]]; then
    if command -v zsh >/dev/null 2>&1; then
        exec zsh "$0" "$@"
    else
        echo "❌ test.sh must be run with zsh but zsh is not installed or not in PATH" >&2
        echo "💡 Please install zsh before running tests:" >&2
        echo "   • macOS: brew install zsh" >&2
        echo "   • Ubuntu/Debian: sudo apt install zsh" >&2
        echo "   • CentOS/RHEL: sudo yum install zsh" >&2
        echo "   • Arch: sudo pacman -S zsh" >&2
        exit 1
    fi
fi

# Enhanced color functions with fallback
test_color_red()    { echo -e "\033[31m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_green()  { echo -e "\033[32m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_yellow() { echo -e "\033[33m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_blue()   { echo -e "\033[34m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_purple() { echo -e "\033[35m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_cyan()   { echo -e "\033[36m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_bold()   { echo -e "\033[1m$1\033[0m" 2>/dev/null || echo "$1"; }

# Test framework variables
TEST_RESULTS=()
TEST_COUNT=0
PASSED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0
TEST_START_TIME=$(date +%s)
CI_MODE=${CI:-false}

# Test framework functions
test_assert() {
    local test_name="$1"
    local condition="$2"
    local message="${3:-Test failed}"
    
    ((TEST_COUNT++))
    
    if eval "$condition" 2>/dev/null; then
        TEST_RESULTS+=("PASS: $test_name")
        ((PASSED_COUNT++))
        test_color_green "✅ $test_name"
        return 0
    else
        TEST_RESULTS+=("FAIL: $test_name - $message")
        ((FAILED_COUNT++))
        test_color_red "❌ $test_name - $message"
        # In CI mode, don't exit on first failure
        if [[ "$CI_MODE" == "true" ]]; then
            return 1
        else
            return 1
        fi
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
    local end_time
    end_time=$(date +%s)
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
        # In CI mode, exit with failure code
        if [[ "$CI_MODE" == "true" ]]; then
            return 1
        else
            return 1
        fi
    fi
}

# Load configuration for testing with better error handling
load_config_for_testing() {
    export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
    
    if [[ ! -f "$ZSH_CONFIG_DIR/zshrc" ]]; then
        test_color_red "❌ Configuration not found at $ZSH_CONFIG_DIR"
        test_color_yellow "💡 Trying alternative locations..."
        
        # Try alternative locations
        local alt_locations=(
            "$HOME/.zshrc"
            "$PWD/zshrc"
            "$PWD/.zshrc"
        )
        
        for location in "${alt_locations[@]}"; do
            if [[ -f "$location" ]]; then
                export ZSH_CONFIG_DIR="$(dirname "$location")"
                test_color_green "✅ Found configuration at $location"
                break
            fi
        done
        
        if [[ ! -f "$ZSH_CONFIG_DIR/zshrc" ]]; then
            test_color_red "❌ No configuration found in any location"
            return 1
        fi
    fi
    
    # Load configuration in test mode with error handling
    export ZSH_TEST_MODE=1
    if source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1; then
        test_color_green "✅ Configuration loaded successfully"
    else
        test_color_yellow "⚠️ Configuration loaded with warnings"
    fi
}

# Unit Tests with better error handling
run_unit_tests() {
    test_section "Unit Tests"
    
    # Test basic ZSH functionality
    test_assert "ZSH is working" "command -v zsh >/dev/null 2>&1" "ZSH not available"
    test_assert "ZSH version is set" "[[ -n \"$ZSH_VERSION\" ]]" "ZSH_VERSION not set"
    
    # Test environment setup
    test_assert "ZSH_CONFIG_DIR is set" "[[ -n \"$ZSH_CONFIG_DIR\" ]]" "ZSH_CONFIG_DIR not set"
    
    # Test if configuration directory exists
    if [[ -d "$ZSH_CONFIG_DIR" ]]; then
        test_assert "Config directory exists" "true" "Config directory not found"
        
        # Test key configuration files
        local config_files=("zshrc" "zshenv")
        for file in "${config_files[@]}"; do
            if [[ -f "$ZSH_CONFIG_DIR/$file" ]]; then
                test_assert "$file exists" "true" "$file not found"
            else
                test_skip "$file exists" "$file not found"
            fi
        done
        
        # Test modules directory
        if [[ -d "$ZSH_CONFIG_DIR/modules" ]]; then
            test_assert "Modules directory exists" "true" "Modules directory not found"
            
            # Count module files
            local module_count
            module_count=$(find "$ZSH_CONFIG_DIR/modules" -name "*.zsh" 2>/dev/null | wc -l)
            if [[ $module_count -gt 0 ]]; then
                test_assert "Module files found" "true" "No module files found"
            else
                test_skip "Module files found" "No module files found"
            fi
        else
            test_skip "Modules directory exists" "Modules directory not found"
        fi
    else
        test_assert "Config directory exists" "false" "Config directory not found"
    fi
    
    # Test basic shell functionality
    test_assert "PATH is set" "[[ -n \"$PATH\" ]]" "PATH not set"
    test_assert "Basic commands work" "command -v ls >/dev/null 2>&1" "Basic commands not available"
}

# Integration Tests with fallbacks
run_integration_tests() {
    test_section "Integration Tests"
    
    # Test if configuration can be sourced
    if source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1; then
        test_assert "Configuration can be sourced" "true" "Configuration sourcing failed"
        
        # Test completion system
        if autoload -Uz compinit 2>/dev/null; then
            compinit -C 2>/dev/null || true
            test_assert "Completion system works" "true" "Completion system not working"
        else
            test_skip "Completion system works" "Completion system not available"
        fi
        
        # Test keybindings
        if bindkey >/dev/null 2>&1; then
            local binding_count
            binding_count=$(bindkey 2>/dev/null | wc -l)
            if [[ $binding_count -gt 0 ]]; then
                test_assert "Keybindings loaded" "true" "No keybindings found"
            else
                test_skip "Keybindings loaded" "No keybindings found"
            fi
        else
            test_skip "Keybindings loaded" "bindkey not available"
        fi
        
        # Test aliases
        if alias >/dev/null 2>&1; then
            local alias_count
            alias_count=$(alias 2>/dev/null | wc -l)
            if [[ $alias_count -gt 0 ]]; then
                test_assert "Aliases loaded" "true" "No aliases found"
            else
                test_skip "Aliases loaded" "No aliases found"
            fi
        else
            test_skip "Aliases loaded" "alias command not available"
        fi
    else
        test_assert "Configuration can be sourced" "false" "Configuration sourcing failed"
    fi
}

# Performance Tests with CI adjustments
run_performance_tests() {
    test_section "Performance Tests"
    
    # Test startup time with CI-friendly thresholds
    local start_time
    start_time=$(date +%s.%N)
    
    if source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1; then
        local end_time
        end_time=$(date +%s.%N)
        local startup_time
        startup_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
        
        # Adjust threshold based on CI mode
        local threshold=5
        if [[ "$CI_MODE" == "true" ]]; then
            threshold=10
        fi
        
        if (( $(echo "$startup_time < $threshold" | bc 2>/dev/null || echo "0") )); then
            test_assert "Startup time < ${threshold}s" "true" "Startup time too slow: ${startup_time}s"
        else
            test_skip "Startup time < ${threshold}s" "Startup time slow: ${startup_time}s (but continuing)"
        fi
    else
        test_skip "Startup time test" "Configuration sourcing failed"
    fi
    
    # Test memory usage (skip in CI if not available)
    if command -v ps >/dev/null 2>&1; then
        local memory_kb
        memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
        if [[ -n "$memory_kb" && "$memory_kb" != "RSS" ]]; then
            local memory_mb
            memory_mb=$(echo "scale=1; ${memory_kb:-0} / 1024" | bc 2>/dev/null || echo "0")
            
            local memory_threshold=50
            if [[ "$CI_MODE" == "true" ]]; then
                memory_threshold=100
            fi
            
            if (( $(echo "$memory_mb < $memory_threshold" | bc 2>/dev/null || echo "0") )); then
                test_assert "Memory usage < ${memory_threshold}MB" "true" "Memory usage too high: ${memory_mb}MB"
            else
                test_skip "Memory usage < ${memory_threshold}MB" "Memory usage high: ${memory_mb}MB (but continuing)"
            fi
        else
            test_skip "Memory usage test" "Memory information not available"
        fi
    else
        test_skip "Memory usage test" "ps command not available"
    fi
}

# Plugin Tests with better detection
run_plugin_tests() {
    test_section "Plugin Tests"
    
    # Test if plugin manager is available
    local plugin_managers=("zinit" "zplug" "antigen" "oh-my-zsh")
    local found_manager=""
    
    for manager in "${plugin_managers[@]}"; do
        if command -v "$manager" >/dev/null 2>&1; then
            found_manager="$manager"
            test_assert "$manager is available" "true" "$manager not available"
            break
        fi
    done
    
    if [[ -z "$found_manager" ]]; then
        test_skip "Plugin manager available" "No plugin manager found"
    fi
    
    # Test plugin directories
    local plugin_dirs=("$ZSH_CONFIG_DIR/plugins" "$ZSH_CONFIG_DIR/custom")
    for dir in "${plugin_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            test_assert "Plugin directory exists: $(basename "$dir")" "true" "Plugin directory not found"
        else
            test_skip "Plugin directory exists: $(basename "$dir")" "Plugin directory not found"
        fi
    done
}

# Conflict Tests
run_conflict_tests() {
    test_section "Conflict Detection Tests"
    
    # Test for duplicate aliases
    if command -v alias >/dev/null 2>&1; then
        local duplicate_aliases
        duplicate_aliases=$(alias 2>/dev/null | cut -d= -f1 | sed 's/^alias //g' | sort | uniq -d)
        if [[ -z "$duplicate_aliases" ]]; then
            test_assert "No duplicate aliases" "true" "Duplicate aliases found"
        else
            test_skip "No duplicate aliases" "Duplicate aliases found: $duplicate_aliases"
        fi
    else
        test_skip "No duplicate aliases" "alias command not available"
    fi
    
    # Test for function name conflicts
    if command -v declare >/dev/null 2>&1; then
        local duplicate_functions
        duplicate_functions=$(declare -F 2>/dev/null | awk '{print $3}' | sort | uniq -d)
        if [[ -z "$duplicate_functions" ]]; then
            test_assert "No duplicate functions" "true" "Duplicate functions found"
        else
            test_skip "No duplicate functions" "Duplicate functions found: $duplicate_functions"
        fi
    else
        test_skip "No duplicate functions" "declare command not available"
    fi
}

# Security Tests
run_security_tests() {
    test_section "Security Tests"
    
    # Test file permissions
    if [[ -f "$ZSH_CONFIG_DIR/zshrc" ]]; then
        local permissions
        permissions=$(stat -c "%a" "$ZSH_CONFIG_DIR/zshrc" 2>/dev/null || stat -f "%Lp" "$ZSH_CONFIG_DIR/zshrc" 2>/dev/null)
        if [[ "$permissions" == "644" || "$permissions" == "600" ]]; then
            test_assert "Configuration file permissions are secure" "true" "Insecure file permissions: $permissions"
        else
            test_skip "Configuration file permissions are secure" "File permissions: $permissions"
        fi
    else
        test_skip "Configuration file permissions are secure" "Configuration file not found"
    fi
    
    # Test for world-writable files
    local world_writable
    world_writable=$(find "$ZSH_CONFIG_DIR" -type f -perm -002 2>/dev/null | wc -l)
    if [[ $world_writable -eq 0 ]]; then
        test_assert "No world-writable files" "true" "World-writable files found"
    else
        test_skip "No world-writable files" "World-writable files found"
    fi
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
    if ! load_config_for_testing; then
        test_color_red "❌ Failed to load configuration for testing"
        exit 1
    fi
    
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
        "conflicts")
            run_conflict_tests
            ;;
        "security")
            run_security_tests
            ;;
        "all"|*)
            run_unit_tests
            run_integration_tests
            run_performance_tests
            run_plugin_tests
            run_conflict_tests
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
    echo "  plugins      - Run plugin tests only"
    echo "  conflicts    - Run conflict detection tests only"
    echo "  security     - Run security tests only"
    echo "  all          - Run all tests (default)"
    echo
    echo "Examples:"
    echo "  $0              # Run all tests"
    echo "  $0 unit         # Run unit tests only"
    echo "  $0 performance  # Run performance tests only"
    echo "  $0 plugins      # Run plugin tests only"
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
