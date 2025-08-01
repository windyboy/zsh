#!/usr/bin/env bash
# =============================================================================
# ZSH Configuration Update Script
# Version: 1.0 - Automatic Update System
# =============================================================================

# Enhanced logging with timestamps
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️  $1"; }
success() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1"; }
warning() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1"; }
error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1"; }

# Version information
VERSION="1.0.0"
BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Configuration
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
ZINIT_DIR="$HOME/.local/share/zsh/zinit/zinit.git"
BACKUP_DIR="$HOME/.config/zsh/backup/$(date +%Y%m%d_%H%M%S)"



# Create backup directory
create_backup() {
    log "Creating backup..."
    if ! mkdir -p "$BACKUP_DIR"; then
        error "Failed to create backup directory"
        return 1
    fi
    
    # Backup current configuration
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$BACKUP_DIR/"
    fi
    
    if [[ -f "$HOME/.zshenv" ]]; then
        cp "$HOME/.zshenv" "$BACKUP_DIR/"
    fi
    
    if [[ -d "$ZSH_CONFIG_DIR" ]]; then
        cp -r "$ZSH_CONFIG_DIR" "$BACKUP_DIR/"
    fi
    
    success "Backup created at: $BACKUP_DIR"
}

# Update zinit
update_zinit() {
    log "Updating zinit..."
    
    if [[ ! -d "$ZINIT_DIR" ]]; then
        error "Zinit not found. Please run install.sh first."
        return 1
    fi
    
    cd "$ZINIT_DIR" || {
        error "Cannot access zinit directory"
        return 1
    }
    
    # Fetch latest changes
    if ! git fetch origin; then
        error "Failed to fetch zinit updates"
        return 1
    fi
    
    # Get current and latest versions
    local current_commit=$(git rev-parse HEAD)
    local latest_commit=$(git rev-parse origin/master)
    
    if [[ "$current_commit" == "$latest_commit" ]]; then
        success "Zinit is already up to date"
        return 0
    fi
    
    # Update to latest version
    if ! git reset --hard origin/master; then
        error "Failed to update zinit"
        return 1
    fi
    
    success "Zinit updated successfully"
    log "Previous version: ${current_commit:0:8}"
    log "New version: ${latest_commit:0:8}"
}

# Update oh-my-posh
update_oh_my_posh() {
    log "Checking oh-my-posh updates..."
    
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        warning "oh-my-posh not installed, skipping"
        return 0
    fi
    
    local current_version=$(oh-my-posh version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    log "Current oh-my-posh version: $current_version"
    
    # Detect OS and architecture
    local os=""
    local arch=""
    
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
    
    # Download latest version
    local download_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-${os}-${arch}"
    local temp_file="/tmp/oh-my-posh-latest"
    
    log "Downloading latest oh-my-posh..."
    if ! curl -L -o "$temp_file" "$download_url"; then
        error "Failed to download oh-my-posh"
        return 1
    fi
    
    # Install new version
    if ! chmod +x "$temp_file"; then
        error "Failed to make oh-my-posh executable"
        return 1
    fi
    
    local install_path=""
    if [[ "$os" == "darwin" ]]; then
        install_path="/usr/local/bin/oh-my-posh"
    else
        install_path="/usr/local/bin/oh-my-posh"
    fi
    
    if ! sudo mv "$temp_file" "$install_path"; then
        error "Failed to install oh-my-posh"
        return 1
    fi
    
    local new_version=$(oh-my-posh version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    success "oh-my-posh updated: $current_version → $new_version"
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

# Update themes
update_themes() {
    log "Updating themes..."
    
    if [[ -f "./install-themes.sh" ]]; then
        if ! bash ./install-themes.sh --update; then
            warning "Theme update failed"
        else
            success "Themes updated"
        fi
    else
        warning "install-themes.sh not found"
    fi
}

# Clean up old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."
    
    local backup_root="$HOME/.config/zsh/backup"
    if [[ ! -d "$backup_root" ]]; then
        return 0
    fi
    
    # Keep only last 5 backups
    local old_backups=$(find "$backup_root" -maxdepth 1 -type d -name "*_*" | sort -r | tail -n +6)
    
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
    echo "    • themes collection"
    echo
    echo "  💡 Next steps:"
    echo "    • Restart your terminal"
    echo "    • Run './status.sh' to verify updates"
    echo "    • Run './test.sh' to test configuration"
}

# Parse command line arguments
INTERACTIVE_MODE=0
SKIP_BACKUP=0
FORCE_UPDATE=0

for arg in "$@"; do
    case "$arg" in
        --interactive|-i)
            INTERACTIVE_MODE=1
            ;;
        --skip-backup|-s)
            SKIP_BACKUP=1
            ;;
        --force|-f)
            FORCE_UPDATE=1
            ;;
        --help|-h)
            echo "ZSH Configuration Update Script v${VERSION}"
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  -i, --interactive    Interactive mode with prompts"
            echo "  -s, --skip-backup    Skip creating backup"
            echo "  -f, --force          Force update even if already up to date"
            echo "  -h, --help           Show this help message"
            echo "  -v, --version        Show version information"
            echo
            echo "Examples:"
            echo "  $0                   # Normal update"
            echo "  $0 --interactive     # Interactive update"
            echo "  $0 --skip-backup     # Update without backup"
            exit 0
            ;;
        --version|-v)
            echo "ZSH Configuration Update Script v${VERSION}"
            echo "Build Date: ${BUILD_DATE}"
            exit 0
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
    
    if ! update_zinit; then
        ((update_failures++))
    fi
    
    if ! update_oh_my_posh; then
        ((update_failures++))
    fi
    
    update_optional_tools
    
    if ! update_themes; then
        ((update_failures++))
    fi
    
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