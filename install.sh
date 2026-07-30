#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# Unified ZSH Installer
# Version: loaded from VERSION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(<"$SCRIPT_DIR/VERSION")"
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
log_error()   { echo -e "${RED}❌ $*${NC}" >&2; exit 1; }

# 1. Prerequisite Checks
check_requirements() {
    log_info "Checking prerequisites..."
    command -v zsh >/dev/null 2>&1 || log_error "ZSH is not installed."
    command -v git >/dev/null 2>&1 || log_error "Git is not installed."
}

# 2. Setup Configuration
setup_config() {
    log_info "Setting up configuration at $ZSH_CONFIG_DIR"
    [[ "$SCRIPT_DIR" == "$ZSH_CONFIG_DIR" ]] || log_error "Clone the repository to $ZSH_CONFIG_DIR before running install.sh."
    [[ -f "$ZSH_CONFIG_DIR/zshenv" && -f "$ZSH_CONFIG_DIR/zshrc" ]] || log_error "Configuration files are missing from $ZSH_CONFIG_DIR."

    # Create .zshenv link in $HOME if not exists
    if [[ ! -e "$HOME/.zshenv" ]]; then
        ln -s "$ZSH_CONFIG_DIR/zshenv" "$HOME/.zshenv"
        log_success "Created ~/.zshenv symlink"
    elif [[ -L "$HOME/.zshenv" && "$(readlink "$HOME/.zshenv")" == "$ZSH_CONFIG_DIR/zshenv" ]]; then
        log_success "~/.zshenv already points to this configuration"
    else
        log_error "~/.zshenv already exists; review it before replacing it."
    fi
}

# 3. Finalize
finalize() {
    log_success "Installation complete! Please restart your terminal or run: source ~/.zshenv && source \$ZDOTDIR/zshrc"
}

# Main Execution
echo -e "${BLUE}ZSH Configuration Installer v${VERSION}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[[ $# -eq 0 ]] || log_error "Usage: $0"
check_requirements
setup_config
finalize
