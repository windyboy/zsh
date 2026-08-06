#!/usr/bin/env bash
# =============================================================================
# ZSH Configuration Update Script
# Version: loaded from VERSION
# =============================================================================
set -euo pipefail
# shellcheck disable=SC2015,SC2162

# Shared logging with timestamp wrappers
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/logging.sh"

with_timestamp() {
    printf '[%s] ' "$(date '+%Y-%m-%d %H:%M:%S')"
    "$@"
}

eval "$(declare -f log     | sed '1s/^log/_log_plain/')"
eval "$(declare -f success | sed '1s/^success/_success_plain/')"
eval "$(declare -f warning | sed '1s/^warning/_warning_plain/')"
eval "$(declare -f error   | sed '1s/^error/_error_plain/')"

log()     { with_timestamp _log_plain "$@"; }
success() { with_timestamp _success_plain "$@"; }
warning() { with_timestamp _warning_plain "$@"; }
error()   { with_timestamp _error_plain "$@"; }

# Version information
VERSION_FILE="$SCRIPT_DIR/VERSION"
[[ -r "$VERSION_FILE" ]] || { error "VERSION file is missing or unreadable: $VERSION_FILE"; exit 1; }
VERSION="$(<"$VERSION_FILE")"
BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Configuration
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
ZINIT_DIR="${ZINIT_HOME:-$HOME/.local/share/zinit}/zinit.git"
BACKUP_DIR="$ZSH_CONFIG_DIR/backup/$(date +%Y%m%d_%H%M%S)"



# Create backup directory
create_backup() {
    log "Creating backup..."
    if ! mkdir -p "$BACKUP_DIR"; then
        error "Failed to create backup directory"
        return 1
    fi
    
    # Backup the dotfiles this config manages or redirects around.
    # ~/.zshenv is the symlink install.sh creates. ~/.zshrc, ~/.zprofile and
    # ~/.zlogin are backed up defensively: after ZDOTDIR redirection they are
    # ignored by the shell, but a user may have pre-existing versions worth
    # preserving. The ~/.zshrc backup is legacy/defensive since install.sh
    # never creates it.
    local dotfile
    for dotfile in .zshenv .zshrc .zprofile .zlogin; do
        if [[ -f "$HOME/$dotfile" ]]; then
            cp "$HOME/$dotfile" "$BACKUP_DIR/"
        fi
    done
    
    if [[ -d "$ZSH_CONFIG_DIR" ]]; then
        cp -r "$ZSH_CONFIG_DIR" "$BACKUP_DIR/"
    fi
    
    success "Backup created at: $BACKUP_DIR"
}

# Update zinit
update_zinit() {
    log "Updating zinit..."

    if [[ ! -d "$ZINIT_DIR/.git" ]]; then
        error "Zinit not found. It is cloned automatically on the first interactive shell when ZSH_ENABLE_PLUGINS=1;"
        error "start a new shell or run 'zsh -ic exit' to install it, then re-run this update."
        return 1
    fi

    if ! git -C "$ZINIT_DIR" pull --ff-only --quiet; then
        error "Failed to update zinit"
        return 1
    fi

    success "Zinit is up to date"
}

# Update oh-my-posh
update_oh_my_posh() {
    log "Checking oh-my-posh updates..."
    
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        warning "oh-my-posh not installed, skipping"
        return 0
    fi
    
    local current_version
    current_version=$(oh-my-posh version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    log "Current oh-my-posh version: $current_version"

    # Prefer the package manager when it owns the installation.
    if command -v brew >/dev/null 2>&1 && brew list --versions oh-my-posh >/dev/null 2>&1; then
        log "oh-my-posh is brew-managed; upgrading via brew"
        if brew upgrade oh-my-posh >/dev/null 2>&1; then
            success "oh-my-posh updated via brew"
        else
            warning "brew upgrade oh-my-posh failed"
        fi
        return 0
    fi
    
    # Detect OS and architecture
    local os
    local arch
    os=""
    arch=""
    
    case "$(uname -s)" in
        Darwin*) os="darwin" ;;
        Linux*)  os="linux" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *)       os="unknown" ;;
    esac
    
    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        arm64|aarch64) arch="arm64" ;;
        *)       arch="unknown" ;;
    esac
    
    if [[ "$os" == "unknown" || "$arch" == "unknown" ]]; then
        warning "Cannot determine OS/architecture for oh-my-posh update"
        return 0
    fi
    
    # Download the latest binary together with the release checksums.
    local download_url sums_url temp_file sums_file
    download_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-${os}-${arch}"
    sums_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/checksums.txt"
    temp_file="$(mktemp)"
    sums_file="$(mktemp)"

    log "Downloading latest oh-my-posh..."
    if ! curl -fsSL -o "$temp_file" "$download_url" || ! curl -fsSL -o "$sums_file" "$sums_url"; then
        error "Failed to download oh-my-posh or its checksums"
        rm -f "$temp_file" "$sums_file"
        return 1
    fi

    # Verify the checksum before installing anything: a sudo-installed binary
    # without verification is a supply-chain hole.
    local expected_sum actual_sum
    expected_sum="$(awk -v f="posh-${os}-${arch}" '$2 == f {print $1}' "$sums_file")"
    rm -f "$sums_file"
    if [[ -z "$expected_sum" ]]; then
        error "No checksum found for posh-${os}-${arch} in the release checksums"
        rm -f "$temp_file"
        return 1
    fi
    if command -v sha256sum >/dev/null 2>&1; then
        actual_sum="$(sha256sum "$temp_file" | awk '{print $1}')"
    elif command -v shasum >/dev/null 2>&1; then
        actual_sum="$(shasum -a 256 "$temp_file" | awk '{print $1}')"
    else
        error "No SHA256 tool available; refusing to install an unverified binary"
        rm -f "$temp_file"
        return 1
    fi
    if [[ "$actual_sum" != "$expected_sum" ]]; then
        error "Checksum mismatch for oh-my-posh (expected $expected_sum, got $actual_sum)"
        rm -f "$temp_file"
        return 1
    fi
    log "Checksum verified (sha256: ${actual_sum:0:12}...)"

    if ! chmod +x "$temp_file"; then
        error "Failed to make oh-my-posh executable"
        rm -f "$temp_file"
        return 1
    fi

    # Update the existing binary in place (resolving symlinks) instead of
    # hardcoding /usr/local/bin; sudo is only needed when the target
    # directory is not user-writable.
    local install_path target_dir
    install_path="$(readlink -f "$(command -v oh-my-posh)" 2>/dev/null || command -v oh-my-posh)"
    target_dir="$(dirname "$install_path")"

    if [[ -w "$target_dir" ]]; then
        if ! mv "$temp_file" "$install_path"; then
            error "Failed to install oh-my-posh to $install_path"
            return 1
        fi
    else
        log "Installing to $install_path requires sudo"
        if ! sudo mv "$temp_file" "$install_path"; then
            error "Failed to install oh-my-posh to $install_path"
            return 1
        fi
    fi
    
    local new_version
    new_version=$(oh-my-posh version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    success "oh-my-posh updated: $current_version → $new_version"
}

# Update the framework repo itself
update_framework() {
    if [[ "$SKIP_SELF" -eq 1 ]]; then
        log "Skipping framework self-update (--skip-self)"
        return 0
    fi

    log "Updating framework repo..."
    if ! git -C "$SCRIPT_DIR" pull --ff-only --quiet; then
        warning "Framework self-update failed (repo dirty or network issue)"
        log "Run manually: git -C \"$SCRIPT_DIR\" pull --ff-only"
        return 1
    fi
    success "Framework repo is up to date"
}

# Update optional tools
update_optional_tools() {
    log "Checking optional tools updates..."
    
    # Update fzf
    if command -v fzf >/dev/null 2>&1; then
        log "Updating fzf..."
        if command -v brew >/dev/null 2>&1; then
            brew upgrade fzf 2>/dev/null && success "fzf updated" || warning "fzf update failed"
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y fzf 2>/dev/null && success "fzf updated" || warning "fzf update failed"
        fi
    fi
    
    # Update zoxide
    if command -v zoxide >/dev/null 2>&1; then
        log "Updating zoxide..."
        if command -v brew >/dev/null 2>&1; then
            brew upgrade zoxide 2>/dev/null && success "zoxide updated" || warning "zoxide update failed"
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y zoxide 2>/dev/null && success "zoxide updated" || warning "zoxide update failed"
        fi
    fi
    
    # Update eza
    if command -v eza >/dev/null 2>&1; then
        log "Updating eza..."
        if command -v brew >/dev/null 2>&1; then
            brew upgrade eza 2>/dev/null && success "eza updated" || warning "eza update failed"
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y eza 2>/dev/null && success "eza updated" || warning "eza update failed"
        fi
    fi
}

# Clean up old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."
    
    local backup_root="$ZSH_CONFIG_DIR/backup"
    if [[ ! -d "$backup_root" ]]; then
        return 0
    fi
    
    # Keep only last 5 backups
    local old_backups
    old_backups=$(find "$backup_root" -maxdepth 1 -type d -name "*_*" | sort -r | tail -n +6)
    
    if [[ -n "$old_backups" ]]; then
        echo "$old_backups" | while read -r backup; do
            log "Removing old backup: $backup"
            rm -rf "$backup"
        done
        success "Old backups cleaned up"
    else
        log "No old backups to clean"
    fi
}

# Show update summary
show_summary() {
    echo
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "📊 Update Summary"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "  📁 Backup location: $BACKUP_DIR"
    echo "  🔄 Components updated:"
    echo "    • zinit plugin manager"
    echo "    • oh-my-posh theme engine"
    echo "    • optional tools (fzf, zoxide, eza)"
    echo
    echo "  💡 Next steps:"
    echo "    • Restart your terminal"
    echo "    • Start a new shell to verify updates"
    echo "    • Run './test.sh' to test configuration"
}

# Parse command line arguments
INTERACTIVE_MODE=0
SKIP_BACKUP=0
SKIP_SELF="${ZSH_UPDATE_SELF_SKIP:-0}"

for arg in "$@"; do
    case "$arg" in
        --interactive|-i)
            INTERACTIVE_MODE=1
            ;;
        --skip-backup|-s)
            SKIP_BACKUP=1
            ;;
        --skip-self|-S)
            SKIP_SELF=1
            ;;
        --help|-h)
            echo "ZSH Configuration Update Script v${VERSION}"
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  -i, --interactive    Interactive mode with prompts"
            echo "  -s, --skip-backup    Skip creating backup"
            echo "  -S, --skip-self      Skip updating the framework repo itself"
            echo "  -h, --help           Show this help message"
            echo "  -v, --version        Show version information"
            echo
            echo "Examples:"
            echo "  $0                   # Normal update"
            echo "  $0 --interactive     # Interactive update"
            echo "  $0 --skip-backup     # Update without backup"
            echo "  $0 --skip-self       # Update tools but not the framework repo"
            exit 0
            ;;
        --version|-v)
            echo "ZSH Configuration Update Script v${VERSION}"
            echo "Build Date: ${BUILD_DATE}"
            exit 0
            ;;
        *)
            error "Unknown option: $arg (run '$0 --help' for usage)"
            exit 1
            ;;
    esac
done

# Interactive confirmation
if [[ $INTERACTIVE_MODE -eq 1 ]]; then
    echo "🔄 ZSH Configuration Update"
    echo "This will update your zsh configuration components."
    echo
    
    if [[ $SKIP_BACKUP -eq 0 ]]; then
        read -p "Create backup before updating? [Y/n]: " backup_confirm
        if [[ "$backup_confirm" =~ ^[Nn]$ ]]; then
            SKIP_BACKUP=1
        fi
    fi
    
    read -p "Continue with update? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Update cancelled."
        exit 0
    fi
fi

# Main update function
main() {
    log "Starting ZSH configuration update..."
    
    # Create backup unless skipped
    if [[ $SKIP_BACKUP -eq 0 ]]; then
        if ! create_backup; then
            error "Backup creation failed"
            exit 1
        fi
    fi
    
    # Update components
    local update_failures=0

    if ! update_framework; then
        update_failures=$((update_failures + 1))
    fi

    if ! update_zinit; then
        update_failures=$((update_failures + 1))
    fi
    
    if ! update_oh_my_posh; then
        update_failures=$((update_failures + 1))
    fi
    
    update_optional_tools
    
    # Cleanup
    cleanup_old_backups
    
    # Show summary
    show_summary
    
    if [[ $update_failures -eq 0 ]]; then
        success "Update completed successfully!"
        exit 0
    else
        warning "Update completed with $update_failures failure(s)"
        exit 1
    fi
}

# Run main function
main "$@" 
