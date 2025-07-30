#!/usr/bin/env bash
# =============================================================================
# Project Status Check Script
# Comprehensive project validation and health check
# =============================================================================

set -euo pipefail

# Colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Logging functions
log() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${CYAN}📋 $1${NC}"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Test framework
run_test() {
    local test_name="$1"
    local test_command="$2"
    local description="${3:-}"
    local critical="${4:-false}"
    
    ((TOTAL_TESTS++))
    
    if eval "$test_command" >/dev/null 2>&1; then
        ((PASSED_TESTS++))
        success "$test_name"
        if [[ -n "$description" ]]; then
            echo "    $description"
        fi
        return 0
    else
        if [[ "$critical" == "true" ]]; then
            ((FAILED_TESTS++))
            error "$test_name"
            if [[ -n "$description" ]]; then
                echo "    $description"
            fi
            return 1
        else
            ((WARNINGS++))
            warning "$test_name"
            if [[ -n "$description" ]]; then
                echo "    $description"
            fi
            echo "    ⚠️  Continuing despite failure..."
            return 0
        fi
    fi
}

run_warning_test() {
    local test_name="$1"
    local test_command="$2"
    local description="${3:-}"
    
    ((TOTAL_TESTS++))
    
    if eval "$test_command" >/dev/null 2>&1; then
        ((PASSED_TESTS++))
        success "$test_name"
        if [[ -n "$description" ]]; then
            echo "    $description"
        fi
        return 0
    else
        ((WARNINGS++))
        warning "$test_name"
        if [[ -n "$description" ]]; then
            echo "    $description"
        fi
        return 1
    fi
}

# File structure tests
check_file_structure() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "📁 File Structure Check"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Essential files
    run_test "Main installation script exists" "[[ -f "$PROJECT_ROOT/install.sh" ]]" "Core installation script"
    run_test "Status script exists" "[[ -f "$PROJECT_ROOT/status.sh" ]]" "System status checker"
    run_test "Test script exists" "[[ -f "$PROJECT_ROOT/test.sh" ]]" "Test suite"
    run_test "Update script exists" "[[ -f "$PROJECT_ROOT/update.sh" ]]" "Update mechanism"
    run_test "Quick install script exists" "[[ -f "$PROJECT_ROOT/quick-install.sh" ]]" "One-command installer"
    
    # Configuration files
    run_test "Main zshrc exists" "[[ -f "$PROJECT_ROOT/zshrc" ]]" "Main configuration file"
    run_test "Environment file exists" "[[ -f "$PROJECT_ROOT/zshenv" ]]" "Environment configuration"
    run_test "Template file exists" "[[ -f "$PROJECT_ROOT/.zshrc.template" ]]" "Configuration template"
    
    # Documentation
    run_test "README exists" "[[ -f "$PROJECT_ROOT/README.md" ]]" "Project documentation"
    run_test "CHANGELOG exists" "[[ -f "$PROJECT_ROOT/CHANGELOG.md" ]]" "Version history"
    run_test "REFERENCE exists" "[[ -f "$PROJECT_ROOT/REFERENCE.md" ]]" "Configuration reference"
    run_test "LICENSE exists" "[[ -f "$PROJECT_ROOT/LICENSE" ]]" "License information"
    
    # Directories
    run_test "Modules directory exists" "[[ -d "$PROJECT_ROOT/modules" ]]" "Configuration modules"
    run_test "Themes directory exists" "[[ -d "$PROJECT_ROOT/themes" ]]" "Theme collection"
    run_test "Custom directory exists" "[[ -d "$PROJECT_ROOT/custom" ]]" "Custom configurations"
    run_test "Completions directory exists" "[[ -d "$PROJECT_ROOT/completions" ]]" "Completion scripts"
    run_test "Environment directory exists" "[[ -d "$PROJECT_ROOT/env" ]]" "Environment management"
    
    # CI/CD
    run_test "GitHub Actions exists" "[[ -d "$PROJECT_ROOT/.github/workflows" ]]" "CI/CD pipeline"
    run_test "Test workflow exists" "[[ -f "$PROJECT_ROOT/.github/workflows/test.yml" ]]" "Automated testing"
}

# Script permissions tests
check_script_permissions() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "🔐 Script Permissions Check"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local scripts=(
        "install.sh"
        "status.sh"
        "test.sh"
        "update.sh"
        "quick-install.sh"
        "install-deps.sh"
        "install-themes.sh"
        "optimize.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$PROJECT_ROOT/$script" ]]; then
            run_test "$script is executable" "[[ -x "$PROJECT_ROOT/$script" ]]" "Script permissions"
        fi
    done
}

# Syntax validation tests
check_syntax() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "🔍 Syntax Validation Check"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if shellcheck is available
    if command -v shellcheck >/dev/null 2>&1; then
        local scripts=(
            "install.sh"
            "status.sh"
            "test.sh"
            "update.sh"
            "quick-install.sh"
            "install-deps.sh"
            "install-themes.sh"
            "optimize.sh"
        )
        
        for script in "${scripts[@]}"; do
            if [[ -f "$PROJECT_ROOT/$script" ]]; then
                run_warning_test "$script syntax check" "shellcheck "$PROJECT_ROOT/$script"" "Shell script validation"
            fi
        done
    else
        warning "shellcheck not available - skipping syntax validation"
        echo "    Install shellcheck for better validation:"
        echo "    • macOS: brew install shellcheck"
        echo "    • Ubuntu: sudo apt install shellcheck"
    fi
}

# Configuration validation tests
check_configuration() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "⚙️  Configuration Validation Check"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check zshrc syntax
    if command -v zsh >/dev/null 2>&1; then
        run_test "zshrc syntax validation" "zsh -n "$PROJECT_ROOT/zshrc"" "ZSH configuration syntax"
        run_test "zshenv syntax validation" "zsh -n "$PROJECT_ROOT/zshenv"" "ZSH environment syntax"
    else
        warning "zsh not available - skipping configuration validation"
        echo "    💡 Install zsh to enable configuration validation"
    fi
    
    # Check for common issues
    run_test "No hardcoded paths in zshrc" "! grep -q "/home/" "$PROJECT_ROOT/zshrc"" "Path portability"
    run_test "No hardcoded paths in zshenv" "! grep -q "/home/" "$PROJECT_ROOT/zshenv"" "Path portability"
    
    # Check for required variables
    run_test "ZDOTDIR is set in zshenv" "grep -q "ZDOTDIR" "$PROJECT_ROOT/zshenv"" "Configuration directory"
    run_test "ZSH_CONFIG_DIR is set" "grep -q "ZSH_CONFIG_DIR" "$PROJECT_ROOT/zshrc"" "Config directory variable"
}

# Module validation tests
check_modules() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "🧩 Module Validation Check"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local modules=(
        "core.zsh"
        "aliases.zsh"
        "completion.zsh"
        "keybindings.zsh"
        "path.zsh"
        "plugins.zsh"
        "utils.zsh"
        "colors.zsh"
    )
    
    for module in "${modules[@]}"; do
        if [[ -f "$PROJECT_ROOT/modules/$module" ]]; then
            run_test "Module $module exists" "true" "Module file"
            if command -v zsh >/dev/null 2>&1; then
                run_warning_test "Module $module syntax" "zsh -n "$PROJECT_ROOT/modules/$module"" "Module syntax"
            else
                warning "Module $module syntax check skipped - zsh not available"
            fi
        else
            run_warning_test "Module $module exists" "false" "Missing module"
        fi
    done
}

# Documentation tests
check_documentation() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "📚 Documentation Check"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check documentation completeness
    run_test "README has installation section" "grep -q 'Installation' \"$PROJECT_ROOT/README.md\"" "Installation docs"
    run_test "README has usage section" "grep -q 'Usage' \"$PROJECT_ROOT/README.md\"" "Usage docs"
    run_test "README has configuration section" "grep -q 'Configuration' \"$PROJECT_ROOT/README.md\"" "Config docs"
    
    # Check for common documentation issues
    run_test "No broken links in README" "! grep -q 'http.*404' \"$PROJECT_ROOT/README.md\"" "Link validation"
    run_test "README has table of contents" "grep -q 'Table of Contents' \"$PROJECT_ROOT/README.md\"" "TOC structure"
}

# Security tests
check_security() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "🔒 Security Check"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check for potential security issues
    run_test "No hardcoded secrets" "! grep -rE '(password|secret|token)' \"$PROJECT_ROOT\" --exclude-dir=.git --exclude-dir=completions --exclude-dir=.github --exclude=check-project.sh --exclude=*.md" "Secret detection"
    run_test "No dangerous eval usage" "! grep -r 'eval ' \"$PROJECT_ROOT\" --exclude-dir=.git --exclude=*.md | grep -v 'eval \"\$(oh-my-posh'" "Eval usage"
    run_test "No command injection risks" "! grep -r '\$(' \"$PROJECT_ROOT\" --exclude-dir=.git --exclude=*.md | grep -v 'command -v'" "Command injection"
    
    # Check file permissions
    run_test "Scripts have secure permissions" "find "$PROJECT_ROOT" -name "*.sh" -exec test -x {} \;" "File permissions"
}

# Performance tests
check_performance() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "⚡ Performance Check"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check file sizes
    local large_files=$(find "$PROJECT_ROOT" -type f -size +1M -not -path "./.git/*" | wc -l)
    run_test "No large files (>1MB)" "[[ $large_files -eq 0 ]]" "File size optimization"
    
    # Check for unnecessary files
    run_test "No temporary files" "! find "$PROJECT_ROOT" -name "*.tmp" -o -name "*.temp" -o -name "*~"" "Clean workspace"
    
    # Check for duplicate functionality
    run_test "No duplicate aliases in modules" "! find "$PROJECT_ROOT/modules" -name "*.zsh" -exec grep -h "^alias " {} \; | sort | uniq -d" "Alias conflicts"
}

# Show summary
show_summary() {
    echo
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "📊 Project Health Summary"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    
    echo "  📈 Total Tests: $TOTAL_TESTS"
    echo "  ✅ Passed: $PASSED_TESTS"
    echo "  ❌ Failed: $FAILED_TESTS"
    echo "  ⚠️  Warnings: $WARNINGS"
    echo "  📊 Success Rate: ${success_rate}%"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        success "🎉 All critical tests passed!"
        if [[ $WARNINGS -gt 0 ]]; then
            warning "⚠️  $WARNINGS warning(s) found - consider addressing them"
        fi
        return 0
    else
        error "💥 $FAILED_TESTS test(s) failed!"
        return 1
    fi
}

# Main function
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                🔍 Project Health Check                      ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Run all checks
    check_file_structure
    check_script_permissions
    check_syntax
    check_configuration
    check_modules
    check_documentation
    check_security
    check_performance
    
    # Show summary
    show_summary
}

# Parse command line arguments
case "${1:-}" in
    "-h"|"--help")
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Project health check script for ZSH configuration"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  $0            # Run full health check"
        echo "  $0 --help     # Show help"
        exit 0
        ;;
esac

# Run main function
main "$@" 