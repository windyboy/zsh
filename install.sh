#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# Unified ZSH Installer
# Version: 5.3.1
# =============================================================================

VERSION="5.3.1"
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_warn()    { echo -e "${YELLOW}⚠️  $*${NC}"; }
log_error()   { echo -e "${RED}❌ $*${NC}"; exit 1; }

# 1. Prerequisite Checks
check_requirements() {
    log_info "Checking prerequisites..."
    command -v zsh >/dev/null 2>&1 || log_error "ZSH is not installed."
    command -v git >/dev/null 2>&1 || log_error "Git is not installed."
}

# 2. Dependency Installation
install_dependencies() {
    log_info "Installing dependencies..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew >/dev/null 2>&1; then
            brew install fzf bat eza zoxide fd ripgrep 2>/dev/null || true
        fi
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y fzf bat eza zoxide fd-find ripgrep || true
    fi
}

# 3. Setup Configuration
setup_config() {
    log_info "Setting up configuration at $ZSH_CONFIG_DIR"
    mkdir -p "$ZSH_CONFIG_DIR"
    
    # Symlink or Copy files
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    if [[ "$script_dir" != "$ZSH_CONFIG_DIR" ]]; then
        cp -rv "$script_dir"/* "$ZSH_CONFIG_DIR/"
    fi

    # Create .zshenv link in $HOME if not exists
    if [[ ! -L "$HOME/.zshenv" && ! -f "$HOME/.zshenv" ]]; then
        ln -s "$ZSH_CONFIG_DIR/zshenv" "$HOME/.zshenv"
        log_success "Created ~/.zshenv symlink"
    fi
}

# 4. Finalize
finalize() {
    log_success "Installation complete! Please restart your terminal or run: source ~/.zshenv && source \$ZDOTDIR/zshrc"
}

# Main Execution
echo -e "${BLUE}ZSH Configuration Installer v${VERSION}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_requirements
install_dependencies
setup_config
finalize
