#!/usr/bin/env bash
# =============================================================================
# ZSH Configuration Validator
# This script validates the ZSH configuration setup
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

# Validation functions
validate_environment() {
    log_info "Validating environment..."
    
    # Check ZSH installation
    if command -v zsh >/dev/null 2>&1; then
        log_success "ZSH is installed: $(zsh --version | head -1)"
    else
        log_error "ZSH is not installed"
        return 1
    fi
    
    # Check ZSH version
    local zsh_version
    zsh_version=$(zsh --version | head -1 | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    if [[ -n "$zsh_version" ]]; then
        log_info "ZSH version: $zsh_version"
        if [[ "$zsh_version" < "5.0" ]]; then
            log_warning "ZSH version $zsh_version is older than recommended (5.0+)"
        else
            log_success "ZSH version $zsh_version is acceptable"
        fi
    else
        log_warning "Could not determine ZSH version"
    fi
    
    return 0
}

validate_directories() {
    log_info "Validating directories..."
    
    local dirs=(
        "$ZSH_CONFIG_DIR"
        "$ZSH_CONFIG_DIR/modules"
        "$ZSH_CONFIG_DIR/themes"
        "$HOME/.cache/zsh"
        "$HOME/.local/share/zsh"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_success "Directory exists: $dir"
        else
            log_warning "Directory missing: $dir"
        fi
    done
}

validate_files() {
    log_info "Validating configuration files..."
    
    local files=(
        "$ZSH_CONFIG_DIR/zshrc"
        "$ZSH_CONFIG_DIR/zshenv"
        "$HOME/.zshenv"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "File exists: $file"
            
            # Check if file is readable
            if [[ -r "$file" ]]; then
                log_success "File is readable: $file"
            else
                log_error "File is not readable: $file"
            fi
            
            # Check file size
            local size
            size=$(wc -c < "$file" 2>/dev/null || echo "0")
            if [[ $size -gt 0 ]]; then
                log_success "File has content: $file ($size bytes)"
            else
                log_warning "File is empty: $file"
            fi
        else
            log_warning "File missing: $file"
        fi
    done
}

validate_modules() {
    log_info "Validating modules..."
    
    if [[ -d "$ZSH_CONFIG_DIR/modules" ]]; then
        local module_count
        module_count=$(find "$ZSH_CONFIG_DIR/modules" -name "*.zsh" 2>/dev/null | wc -l)
        
        if [[ $module_count -gt 0 ]]; then
            log_success "Found $module_count module(s)"
            
            # List modules
            for module in "$ZSH_CONFIG_DIR/modules"/*.zsh; do
                if [[ -f "$module" ]]; then
                    log_info "  - $(basename "$module")"
                fi
            done
        else
            log_warning "No modules found"
        fi
    else
        log_warning "Modules directory not found"
    fi
}

validate_syntax() {
    log_info "Validating syntax..."
    
    local errors=0
    
    # Check main configuration files
    for file in zshrc zshenv; do
        if [[ -f "$ZSH_CONFIG_DIR/$file" ]]; then
            if zsh -n "$ZSH_CONFIG_DIR/$file" 2>/dev/null; then
                log_success "Syntax OK: $file"
            else
                log_error "Syntax error: $file"
                ((errors++))
            fi
        fi
    done
    
    # Check module files
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
        log_success "All syntax validation passed"
        return 0
    else
        log_error "$errors syntax error(s) found"
        return 1
    fi
}

validate_permissions() {
    log_info "Validating file permissions..."
    
    # Check script permissions
    local scripts=("install.sh" "status.sh" "test.sh" "run-tests.sh")
    for script in "${scripts[@]}"; do
        if [[ -f "$ZSH_CONFIG_DIR/$script" ]]; then
            if [[ -x "$ZSH_CONFIG_DIR/$script" ]]; then
                log_success "Script is executable: $script"
            else
                log_warning "Script is not executable: $script"
            fi
        fi
    done
    
    # Check configuration file permissions
    for file in zshrc zshenv; do
        if [[ -f "$ZSH_CONFIG_DIR/$file" ]]; then
            local permissions
            permissions=$(stat -c "%a" "$ZSH_CONFIG_DIR/$file" 2>/dev/null || stat -f "%Lp" "$ZSH_CONFIG_DIR/$file" 2>/dev/null)
            log_info "File permissions for $file: $permissions"
        fi
    done
}

# Main execution
main() {
    echo
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                🔍 ZSH Configuration Validator                 ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
    
    local exit_code=0
    
    # Run validations
    validate_environment || exit_code=1
    validate_directories || exit_code=1
    validate_files || exit_code=1
    validate_modules || exit_code=1
    validate_syntax || exit_code=1
    validate_permissions || exit_code=1
    
    echo
    if [[ $exit_code -eq 0 ]]; then
        log_success "Configuration validation completed successfully!"
    else
        log_error "Configuration validation found issues!"
    fi
    
    exit $exit_code
}

# Run main function
main "$@" 