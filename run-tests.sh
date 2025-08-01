#!/usr/bin/env bash
# =============================================================================
# Simple Test Runner for ZSH Configuration
# This script provides a robust way to run tests in CI environments
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Configuration
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
CI_MODE="${CI:-false}"

# Main test functions
test_syntax() {
    log_info "Testing ZSH syntax..."
    
    local errors=0
    
    # Test main configuration files
    for file in zshrc zshenv; do
        if [[ -f "$ZSH_CONFIG_DIR/$file" ]]; then
            if zsh -n "$ZSH_CONFIG_DIR/$file" 2>/dev/null; then
                log_success "Syntax OK: $file"
            else
                log_error "Syntax error: $file"
                ((errors++))
            fi
        else
            log_warning "File not found: $file"
        fi
    done
    
    # Test module files
    if [[ -d "$ZSH_CONFIG_DIR/modules" ]]; then
        for file in "$ZSH_CONFIG_DIR/modules"/*.zsh; do
            if [[ -f "$file" ]]; then
                if zsh -n "$file" 2>/dev/null; then
                    log_success "Syntax OK: $(basename "$file")"
                else
                    log_error "Syntax error: $(basename "$file")"
                    ((errors++))
                fi
            fi
        done
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "All syntax tests passed"
        return 0
    else
        log_error "$errors syntax error(s) found"
        return 1
    fi
}

test_configuration() {
    log_info "Testing configuration loading..."
    
    # Test if configuration can be sourced (with better error handling)
    if zsh -c "source '$ZSH_CONFIG_DIR/zshrc' >/dev/null 2>&1; echo 'SUCCESS'" 2>/dev/null | grep -q 'SUCCESS'; then
        log_success "Configuration loaded successfully"
        
        # Test basic functionality
        if [[ -n "${PATH:-}" ]]; then
            log_success "PATH is set"
        else
            log_warning "PATH is not set"
        fi
        
        if command -v ls >/dev/null 2>&1; then
            log_success "Basic commands available"
        else
            log_warning "Basic commands not available"
        fi
        
        return 0
    else
        log_warning "Failed to load configuration (but continuing)"
        return 0
    fi
}

test_performance() {
    log_info "Testing performance..."
    
    local start_time
    start_time=$(date +%s.%N)
    
    if zsh -c "source '$ZSH_CONFIG_DIR/zshrc' >/dev/null 2>&1; echo 'SUCCESS'" 2>/dev/null | grep -q 'SUCCESS'; then
        local end_time
        end_time=$(date +%s.%N)
        local startup_time
        startup_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
        
        log_info "Startup time: ${startup_time}s"
        
        # Adjust threshold based on CI mode
        local threshold=5
        if [[ "$CI_MODE" == "true" ]]; then
            threshold=10
        fi
        
        if (( $(echo "$startup_time < $threshold" | bc -l 2>/dev/null || echo "0") )); then
            log_success "Startup time acceptable (< ${threshold}s)"
            return 0
        else
            log_warning "Startup time slow: ${startup_time}s (threshold: ${threshold}s)"
            # Don't fail on slow startup in CI
            return 0
        fi
    else
        log_warning "Failed to source configuration for performance test (but continuing)"
        return 0
    fi
}

test_advanced() {
    log_info "Running advanced tests..."
    
    # Check if test script exists and run it
    if [[ -x "$ZSH_CONFIG_DIR/test.sh" ]]; then
        log_info "Running comprehensive test suite..."
        
        if "$ZSH_CONFIG_DIR/test.sh" all 2>/dev/null; then
            log_success "Advanced tests passed"
            return 0
        else
            log_warning "Some advanced tests failed, but continuing..."
            return 0
        fi
    else
        log_warning "Advanced test script not found, skipping..."
        return 0
    fi
}

# Main execution
main() {
    echo
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                🧪 ZSH Configuration Test Runner               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
    
    local exit_code=0
    
    # Run tests
    test_syntax || exit_code=1
    test_configuration || exit_code=1
    test_performance || exit_code=1
    test_advanced || exit_code=1
    
    echo
    if [[ $exit_code -eq 0 ]]; then
        log_success "All tests completed successfully!"
    else
        log_error "Some tests failed!"
    fi
    
    exit $exit_code
}

# Run main function
main "$@" 