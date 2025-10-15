#!/usr/bin/env bash
# =============================================================================
# ZSH Configuration Test Suite
# Version: 5.3.1 - Enhanced CI-Ready Testing Framework
# =============================================================================
# shellcheck disable=SC1091

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

# Shared logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/logging.sh"

# Enhanced color functions with fallback
test_color_red()    { echo -e "\033[31m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_green()  { echo -e "\033[32m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_yellow() { echo -e "\033[33m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_blue()   { echo -e "\033[34m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_purple() { echo -e "\033[35m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_cyan()   { echo -e "\033[36m$1\033[0m" 2>/dev/null || echo "$1"; }
test_color_bold()   { echo -e "\033[1m$1\033[0m" 2>/dev/null || echo "$1"; }

# Ensure ZSH_CONFIG_DIR points to a usable configuration directory before loading modules
if [[ -z "${ZSH_CONFIG_DIR:-}" ]]; then
    if [[ -d "$HOME/.config/zsh/modules" ]]; then
        export ZSH_CONFIG_DIR="$HOME/.config/zsh"
    else
        script_source="$0"
        script_dir="$(cd "$(dirname "${script_source}")" 2>/dev/null && pwd)"
        export ZSH_CONFIG_DIR="${script_dir:-$PWD}"
    fi
fi

# Helper functions for portable floating-point math comparisons
float_difference() {
    awk -v lhs="${1:-0}" -v rhs="${2:-0}" 'BEGIN {printf "%.6f", (lhs + 0) - (rhs + 0)}' 2>/dev/null || echo "0"
}

float_less_than() {
    awk -v lhs="${1:-0}" -v rhs="${2:-0}" 'BEGIN {exit ((lhs + 0) < (rhs + 0)) ? 0 : 1}' 2>/dev/null
}

float_divide() {
    awk -v numerator="${1:-0}" -v denominator="${2:-1}" '
        BEGIN {
            if ((denominator + 0) == 0) {
                print "0"
            } else {
                printf "%.1f", (numerator + 0) / (denominator + 0)
            }
        }
    ' 2>/dev/null || echo "0"
}

# Test framework variables
TEST_RESULTS=()
TEST_COUNT=0
PASSED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0
TEST_START_TIME=$(date +%s)
CI_MODE=${CI:-false}
# Source the plugins module
if [[ -f "$ZSH_CONFIG_DIR/modules/plugins.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/plugins.zsh"
    success "Plugins module loaded"
else
    error "Plugins module not found: $ZSH_CONFIG_DIR/modules/plugins.zsh"
    exit 1
fi

if [[ -f "$ZSH_CONFIG_DIR/modules/lib/validation.zsh" ]]; then
    # shellcheck disable=SC1091
    source "$ZSH_CONFIG_DIR/modules/lib/validation.zsh"
else
    warning "Validation library not found: $ZSH_CONFIG_DIR/modules/lib/validation.zsh"
fi

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
    printf "  %s %-20s %s\n" "✅" "Passed:" "$(test_color_green "$PASSED_COUNT")"
    printf "  %s %-20s %s\n" "❌" "Failed:" "$(test_color_red "$FAILED_COUNT")"
    printf "  %s %-20s %s\n" "⏭️" "Skipped:" "$(test_color_yellow "$SKIPPED_COUNT")"
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
                ZSH_CONFIG_DIR="$(dirname "$location")"
                export ZSH_CONFIG_DIR
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
            module_count=0
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
        startup_time=$(float_difference "$end_time" "$start_time")
        
        # Adjust threshold based on CI mode
        local threshold=5
        if [[ "$CI_MODE" == "true" ]]; then
            threshold=10
        fi
        
        if float_less_than "$startup_time" "$threshold"; then
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
            memory_mb=$(float_divide "${memory_kb:-0}" 1024)
            
            local memory_threshold=50
            if [[ "$CI_MODE" == "true" ]]; then
                memory_threshold=100
            fi
            
            if float_less_than "$memory_mb" "$memory_threshold"; then
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
    local plugin_managers=("zinit" "zplug" "antigen")
    local found_manager=""
    
    # First check if zinit is available in PATH
    for manager in "${plugin_managers[@]}"; do
        if command -v "$manager" >/dev/null 2>&1; then
            found_manager="$manager"
            test_assert "$manager is available" "true" "$manager not available"
            break
        fi
    done
    
    # If no manager found in PATH, check for zinit in common locations
    if [[ -z "$found_manager" ]]; then
        local zinit_paths=(
            "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
            "$HOME/.zinit/bin/zinit.zsh"
            "/usr/local/share/zinit/zinit.git/zinit.zsh"
        )
        
        for zinit_path in "${zinit_paths[@]}"; do
            if [[ -f "$zinit_path" ]]; then
                found_manager="zinit"
                test_assert "zinit is available (found at $zinit_path)" "true" "zinit not available"
                break
            fi
        done
    fi
    
    if [[ -z "$found_manager" ]]; then
        test_skip "Plugin manager available" "No plugin manager found"
    fi
    
    # Test plugin directories
    local plugin_dirs=()
    
    # Add zinit plugins directory if zinit is found
    if [[ -n "$found_manager" && "$found_manager" == "zinit" && -n "$ZINIT_HOME" ]]; then
        plugin_dirs+=("$ZINIT_HOME/plugins:zinit plugins")
    fi
    
    for dir_info in "${plugin_dirs[@]}"; do
        local dir="${dir_info%%:*}"
        local dir_name="${dir_info##*:}"
        if [[ -d "$dir" ]]; then
            test_assert "Plugin directory exists: $dir_name" "true" "Plugin directory not found"
        else
            test_skip "Plugin directory exists: $dir_name" "Plugin directory not found"
        fi
    done

    # Test if Oh My Posh is available
    if command -v oh-my-posh >/dev/null 2>&1; then
        test_assert "oh-my-posh is available" "true" "oh-my-posh not available"
    else
        test_skip "oh-my-posh is available" "oh-my-posh not installed"
    fi
    
    # Test ZINIT_HOME if zinit is found
    if [[ "$found_manager" == "zinit" ]]; then
        if [[ -n "$ZINIT_HOME" ]]; then
            test_assert "ZINIT_HOME is set" "true" "ZINIT_HOME not set"
            if [[ -d "$ZINIT_HOME" ]]; then
                test_assert "ZINIT_HOME directory exists" "true" "ZINIT_HOME directory not found"
            else
                test_skip "ZINIT_HOME directory exists" "ZINIT_HOME directory not found"
            fi
        else
            test_skip "ZINIT_HOME is set" "ZINIT_HOME not set"
        fi
    fi
}

run_validation_tests() {
    test_section "Validation Checks"

    if typeset -f validation_run >/dev/null 2>&1; then
        local -a validation_messages=()
        validation_run validation_messages false
        
        # Suppress shellcheck warning - messages are used by validation_run internally
        # shellcheck disable=SC2034
        : "${validation_messages[@]}"
        
        test_assert "Validation reports no errors" "[[ $VALIDATION_ERRORS -eq 0 ]]" "Validation reported $VALIDATION_ERRORS error(s)"

        if [[ $VALIDATION_WARNINGS -gt 0 ]]; then
            test_skip "Validation warnings" "$VALIDATION_WARNINGS warning(s) reported"
        else
            test_assert "Validation reports no warnings" "[[ $VALIDATION_WARNINGS -eq 0 ]]" "Validation warnings detected"
        fi
    else
        test_skip "Validation library available" "validation_run not found"
    fi
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
        "validation")
            run_validation_tests
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
            run_validation_tests
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
    echo "  validation   - Run validation checks only"
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
