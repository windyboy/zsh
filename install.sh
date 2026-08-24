#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# Unified ZSH Installer
# Version: loaded from VERSION
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == */* ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi
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
    local missing=()
    local cmd
    for cmd in zsh git ln readlink mv date; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
    fi

    # Oh My Posh is optional; the prompt module uses a built-in fallback when
    # it is unavailable, but surface that choice during installation.
    command -v oh-my-posh >/dev/null 2>&1 \
        || log_warn "oh-my-posh is not installed; the fallback prompt will be used."

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
    echo
    echo "Next steps:"
    echo "  1. Machine-specific environment (optional, recommended):"
    echo "       cd $ZSH_CONFIG_DIR/env && ./init-env.sh"
    echo "       \${EDITOR:-vi} $ZSH_CONFIG_DIR/env/local/environment.env"
    echo "     Put per-machine exports here (GOPATH, mirrors, custom PATH)."
    echo "     This file is gitignored - it never touches the repository."
    echo "  2. Per-host overrides (optional, for multi-machine setups):"
    echo "       mkdir -p $ZSH_CONFIG_DIR/env/local/hosts"
    echo "       echo 'export MY_VAR=...' > $ZSH_CONFIG_DIR/env/local/hosts/\$(hostname).env"
    echo "     Loaded after modules, so it overrides framework defaults on this host."
    echo "  3. Local aliases/functions (optional):"
    echo "       cp $ZSH_CONFIG_DIR/env/templates/local.zsh.template $ZSH_CONFIG_DIR/local.zsh"
    echo "  4. Plugins are off by default; to enable zinit:"
    echo "       echo 'export ZSH_ENABLE_PLUGINS=1' >> $ZSH_CONFIG_DIR/env/local/environment.env"
    echo
    echo "Keep machine-specific settings out of tracked files so every machine"
    echo "can git-pull the same repository. After editing, verify with:"
    echo "  zsh -n $ZSH_CONFIG_DIR/env/local/environment.env && reload"
    echo
    log_info "Start a new shell to load the configuration: exec zsh"
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
