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
            if ! cp "$HOME/$dotfile" "$BACKUP_DIR/"; then
                error "Failed to back up $HOME/$dotfile"
                return 1
            fi
        fi
    done

    if [[ -d "$ZSH_CONFIG_DIR" ]]; then
        # BACKUP_DIR is a child of ZSH_CONFIG_DIR, so copying the root into it
        # would recurse into itself. Copy each top-level entry except backup/
        # into a named snapshot instead. .git is excluded: it doubles the
        # snapshot size and copies the user's full repository history.
        local snapshot_dir entry
        local -a config_entries=()
        snapshot_dir="$BACKUP_DIR/config"
        if ! mkdir -p "$snapshot_dir"; then
            error "Failed to create configuration snapshot directory"
            return 1
        fi
        while IFS= read -r -d '' entry; do
            config_entries+=("$entry")
        done < <(find "$ZSH_CONFIG_DIR" -mindepth 1 -maxdepth 1 ! -name backup ! -name .git -print0)
        if ((${#config_entries[@]})) && ! cp -a "${config_entries[@]}" "$snapshot_dir/"; then
            error "Failed to back up configuration files"
            return 1
        fi
    fi
    
    success "Backup created at: $BACKUP_DIR"
}

# Update zinit
update_zinit() {
    log "Updating zinit..."

    if [[ ! -d "$ZINIT_DIR/.git" ]]; then
        # Plugins are optional (off by default): a default install never
        # clones zinit, so its absence is a skip, not a failure. Failing here
        # made every plain `./update.sh` exit 1 on a healthy machine.
        log "Zinit not installed (plugins disabled); skipping. It is cloned on the first"
        log "interactive shell when ZSH_ENABLE_PLUGINS=1."
        return 0
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
            rm -f "$temp_file"
            return 1
        fi
    else
        log "Installing to $install_path requires sudo"
        if ! sudo mv "$temp_file" "$install_path"; then
            error "Failed to install oh-my-posh to $install_path"
            rm -f "$temp_file"
            return 1
        fi
    fi
    
    local new_version
    new_version=$(oh-my-posh version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    success "oh-my-posh updated: $current_version → $new_version"
}

# Portable SHA256 of a file (Linux sha256sum / macOS shasum)
_hash_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

# Update the framework repo itself
update_framework() {
    if [[ "$SKIP_SELF" -eq 1 ]]; then
        log "Skipping framework self-update (--skip-self)"
        return 0
    fi

    log "Updating framework repo..."
    local self_hash_before
    self_hash_before="$(_hash_file "$SCRIPT_DIR/update.sh")"
    if ! git -C "$SCRIPT_DIR" pull --ff-only --quiet; then
        warning "Framework self-update failed (repo dirty or network issue)"
        log "Run manually: git -C \"$SCRIPT_DIR\" pull --ff-only"
        return 1
    fi
    success "Framework repo is up to date"

    # This script is tracked by the repo it pulls: bash reads it by byte
    # offset, so continuing after the file changed risks executing garbled
    # commands. Restart the new copy, skipping what already ran (backup is
    # made, framework pulled).
    if [[ "$self_hash_before" != "$(_hash_file "$SCRIPT_DIR/update.sh")" ]]; then
        log "update.sh changed upstream; restarting updated version"
        exec env ZSH_UPDATE_SELF_SKIP=1 bash "$SCRIPT_DIR/update.sh" \
            ${SCRIPT_ARGS[@]+"${SCRIPT_ARGS[@]}"} --skip-backup
    fi
}

# Update optional tools
update_optional_tools() {
    log "Checking optional tools updates..."
    
    # Update fzf
    if command -v fzf >/dev/null 2>&1; then
        log "Updating fzf..."
        if command -v brew >/dev/null 2>&1; then
            if brew upgrade fzf 2>/dev/null; then
                success "fzf updated"
            else
                warning "fzf update failed"
            fi
        elif command -v apt >/dev/null 2>&1; then
            if sudo apt update && sudo apt install -y fzf 2>/dev/null; then
                success "fzf updated"
            else
                warning "fzf update failed"
            fi
        fi
    fi
    
    # Update zoxide
    if command -v zoxide >/dev/null 2>&1; then
        log "Updating zoxide..."
        if command -v brew >/dev/null 2>&1; then
            if brew upgrade zoxide 2>/dev/null; then
                success "zoxide updated"
            else
                warning "zoxide update failed"
            fi
        elif command -v apt >/dev/null 2>&1; then
            if sudo apt update && sudo apt install -y zoxide 2>/dev/null; then
                success "zoxide updated"
            else
                warning "zoxide update failed"
            fi
        fi
    fi
    
    # Update eza
    if command -v eza >/dev/null 2>&1; then
        log "Updating eza..."
        if command -v brew >/dev/null 2>&1; then
            if brew upgrade eza 2>/dev/null; then
                success "eza updated"
            else
                warning "eza update failed"
            fi
        elif command -v apt >/dev/null 2>&1; then
            if sudo apt update && sudo apt install -y eza 2>/dev/null; then
                success "eza updated"
            else
                warning "eza update failed"
            fi
        fi
    fi
}

# Clean up old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."

    local backup_root="$ZSH_CONFIG_DIR/backup"
    [[ -d "$backup_root" ]] || return 0

    # Keep only the last 5 backups. Glob iteration (not find|sort|tail) keeps
    # paths with spaces intact; timestamp names sort lexicographically.
    local -a backups=()
    local backup
    for backup in "$backup_root"/*_*; do
        [[ -d "$backup" ]] && backups+=("$backup")
    done
    if ((${#backups[@]} == 0)); then
        log "No old backups to clean"
        return 0
    fi

    local -a sorted=()
    IFS=$'\n' read -r -d '' -a sorted < <(printf '%s\n' "${backups[@]}" | sort -r)
    ((${#sorted[@]} > 5)) || { log "No old backups to clean"; return 0; }

    for backup in "${sorted[@]:5}"; do
        log "Removing old backup: $backup"
        rm -rf "$backup"
    done
    success "Old backups cleaned up"
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

INTERACTIVE_MODE=0
SKIP_BACKUP=0
SKIP_SELF="${ZSH_UPDATE_SELF_SKIP:-0}"

parse_args() {
    local arg
    for arg in "$@"; do
        case "$arg" in
            --interactive|-i) INTERACTIVE_MODE=1 ;;
            --skip-backup|-s) SKIP_BACKUP=1 ;;
            --skip-self|-S) SKIP_SELF=1 ;;
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
                return 2
                ;;
            --version|-v)
                echo "ZSH Configuration Update Script v${VERSION}"
                echo "Build Date: ${BUILD_DATE}"
                return 2
                ;;
            *)
                error "Unknown option: $arg (run '$0 --help' for usage)"
                return 1
                ;;
        esac
    done
}

confirm_update() {
    [[ $INTERACTIVE_MODE -eq 1 ]] || return 0

    echo "🔄 ZSH Configuration Update"
    echo "This will update your zsh configuration components."
    echo
    if [[ $SKIP_BACKUP -eq 0 ]]; then
        read -r -p "Create backup before updating? [Y/n]: " backup_confirm
        [[ "$backup_confirm" =~ ^[Nn]$ ]] && SKIP_BACKUP=1
    fi

    read -r -p "Continue with update? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Update cancelled."
        return 2
    fi
}

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

# Only execute when invoked directly; tests can source the helper functions.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    SCRIPT_ARGS=("$@")
    parse_rc=0
    parse_args "$@" || parse_rc=$?
    [[ $parse_rc -eq 2 ]] && exit 0
    [[ $parse_rc -eq 0 ]] || exit "$parse_rc"
    confirm_rc=0
    confirm_update || confirm_rc=$?
    [[ $confirm_rc -eq 2 ]] && exit 0
    [[ $confirm_rc -eq 0 ]] || exit "$confirm_rc"
    main
fi
