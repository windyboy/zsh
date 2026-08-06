#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# Unified ZSH Installer
# Version: loaded from VERSION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"
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

[[ -r "$VERSION_FILE" ]] || log_error "VERSION file is missing or unreadable: $VERSION_FILE"
VERSION="$(<"$VERSION_FILE")"

# 1. Prerequisite Checks
check_requirements() {
    log_info "Checking prerequisites..."
    command -v zsh >/dev/null 2>&1 || log_error "ZSH is not installed."
    command -v git >/dev/null 2>&1 || log_error "Git is not installed."
    # README requires Zsh 5.8+; enforce it at install time rather than
    # letting an older shell fail later at runtime.
    zsh -fc 'autoload -Uz is-at-least && is-at-least 5.8 "$ZSH_VERSION"' \
        || log_error "ZSH 5.8 or newer is required (found: $(zsh -fc 'print -r -- "$ZSH_VERSION"' 2>/dev/null || echo unknown))."
}

# Warn about orphaned dotfiles that ZDOTDIR redirection will ignore.
# Non-destructive: never modifies these files.
warn_orphaned_dotfiles() {
    local orphaned=()
    local f
    for f in .zshrc .zprofile .zlogin; do
        [[ -e "$HOME/$f" ]] && orphaned+=("$f")
    done
    [[ ${#orphaned[@]} -eq 0 ]] && return 0

    log_warn "ZDOTDIR redirection will ignore these existing files in $HOME:"
    local name
    for name in "${orphaned[@]}"; do
        log_warn "  ~/$name"
    done
    log_warn "Back them up if you want to keep them, e.g.:"
    log_warn "  mv ~/.zshrc ~/.zshrc.pre-zsh-config"
}

# Link ~/.zshenv to this configuration, honoring HOME/ZSH_CONFIG_DIR overrides.
# Returns:
#   0 - symlink created or already correct
#   1 - existing ~/.zshenv does not match this config (requires consent)
link_zshenv() {
    local dest="$HOME/.zshenv"
    local target="$ZSH_CONFIG_DIR/zshenv"

    if [[ ! -e "$dest" ]]; then
        ln -s "$target" "$dest"
        log_success "Created $dest symlink"
        return 0
    fi

    if [[ -L "$dest" && "$(readlink "$dest")" == "$target" ]]; then
        log_success "$dest already points to this configuration"
        return 0
    fi

    log_warn "$dest already exists and does not point to this configuration."
    return 1
}

# Back up an existing ~/.zshenv to ~/.zshenv.bak.<timestamp>, then link.
backup_and_link_zshenv() {
    local dest="$HOME/.zshenv"
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    log_info "Backed up existing $dest to $backup"
    ln -s "$ZSH_CONFIG_DIR/zshenv" "$dest"
    log_success "Created $dest symlink"
}

# 2. Setup Configuration
setup_config() {
    log_info "Setting up configuration at $ZSH_CONFIG_DIR"
    [[ "$SCRIPT_DIR" == "$ZSH_CONFIG_DIR" ]] || log_error "Clone the repository to $ZSH_CONFIG_DIR before running install.sh."
    [[ -f "$ZSH_CONFIG_DIR/zshenv" && -f "$ZSH_CONFIG_DIR/zshrc" ]] || log_error "Configuration files are missing from $ZSH_CONFIG_DIR."

    warn_orphaned_dotfiles

    if link_zshenv; then
        return 0
    fi

    if [[ "$FORCE" -eq 1 ]]; then
        backup_and_link_zshenv
        return 0
    fi

    log_error "$HOME/.zshenv already exists and does not point to this configuration. Re-run with --force to back it up and link."
}

# 3. Finalize
finalize() {
    log_success "Installation complete."
    log_success "Created: $HOME/.zshenv -> $ZSH_CONFIG_DIR/zshenv"
    log_info "Start a new shell to load the configuration: exec zsh"
    log_info "Plugins are off by default; set ZSH_ENABLE_PLUGINS=1 in env/local/environment.env to enable zinit."
}

# Argument parsing
FORCE=0
usage() {
    echo "Usage: $0 [--force]"
    echo
    echo "Options:"
    echo "  -f, --force   Back up an existing ~/.zshenv and link anyway"
    echo "  -h, --help    Show this help message"
}

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --force|-f) FORCE=1 ;;
            --help|-h) usage; exit 0 ;;
            *) usage >&2; log_error "Unknown argument: $arg" ;;
        esac
    done
}

main() {
    echo -e "${BLUE}ZSH Configuration Installer v${VERSION}${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    check_requirements
    setup_config
    finalize
}

# Only run when executed directly, so functions can be sourced for tests.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    parse_args "$@"
    main
fi
