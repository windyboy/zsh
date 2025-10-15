#!/usr/bin/env bash
# =============================================================================
# Quick ZSH Installation Script
# One-command installation for ZSH configuration
# =============================================================================
# shellcheck disable=SC1091

set -euo pipefail

# Shared logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/logging.sh"

# Configuration
REPO_URL="${ZSH_REPO_URL:-https://github.com/yourusername/zsh-config.git}"
INSTALL_DIR="${ZSH_INSTALL_DIR:-$HOME/.config/zsh}"

# Load configuration if available
if [[ -f "$HOME/.zsh-install.conf" ]]; then
    # shellcheck disable=SC1091
    source "$HOME/.zsh-install.conf"
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root"
    exit 1
fi

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

# Install ZSH on different platforms
install_zsh() {
    local os
    os=$(detect_os)
    
    case "$os" in
        "macos")
            if ! command -v zsh >/dev/null 2>&1; then
                log "Installing ZSH on macOS..."
                if command -v brew >/dev/null 2>&1; then
                    brew install zsh
                else
                    error "Homebrew not found. Please install Homebrew first:"
                    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                    exit 1
                fi
            fi
            ;;
        "linux")
            if ! command -v zsh >/dev/null 2>&1; then
                log "Installing ZSH on Linux..."
                if command -v apt >/dev/null 2>&1; then
                    sudo apt update && sudo apt install -y zsh
                elif command -v yum >/dev/null 2>&1; then
                    sudo yum install -y zsh
                elif command -v dnf >/dev/null 2>&1; then
                    sudo dnf install -y zsh
                else
                    error "Unsupported package manager. Please install ZSH manually."
                    exit 1
                fi
            fi
            ;;
        "windows")
            warning "Windows detected. Please use WSL or Git Bash."
            log "Installing ZSH via Chocolatey..."
            if command -v choco >/dev/null 2>&1; then
                choco install zsh
            else
                error "Chocolatey not found. Please install ZSH manually."
                exit 1
            fi
            ;;
        *)
            error "Unsupported operating system"
            exit 1
            ;;
    esac
    
    success "ZSH installed: $(zsh --version | head -1)"
}

# Clone or update repository
setup_repository() {
    if [[ -d "$INSTALL_DIR" ]]; then
        log "Updating existing installation..."
        cd "$INSTALL_DIR"
        if git pull origin main >/dev/null 2>&1; then
            success "Repository updated"
        else
            warning "Failed to update repository, continuing with existing version"
        fi
    else
        log "Cloning repository..."
        if git clone "$REPO_URL" "$INSTALL_DIR" >/dev/null 2>&1; then
            success "Repository cloned"
        else
            error "Failed to clone repository: $REPO_URL"
            echo "💡 Check your internet connection and repository URL"
            echo "💡 You can set a custom URL with: export ZSH_REPO_URL='your-repo-url'"
            exit 1
        fi
    fi
}

# Run installation
run_installation() {
    log "Running installation script..."
    cd "$INSTALL_DIR"
    
    if [[ -f "install.sh" ]]; then
        if bash install.sh --interactive; then
            success "Installation completed successfully!"
        else
            error "Installation failed"
            exit 1
        fi
    else
        error "install.sh not found in repository"
        exit 1
    fi
}

# Set default shell
set_default_shell() {
    local zsh_path
    zsh_path=$(which zsh)
    
    if [[ "$SHELL" != "$zsh_path" ]]; then
        log "Setting ZSH as default shell..."
        if chsh -s "$zsh_path"; then
            success "Default shell changed to ZSH"
            warning "Please restart your terminal or run 'exec zsh'"
        else
            warning "Failed to change default shell. You can do it manually:"
            echo "  chsh -s $(which zsh)"
        fi
    else
        success "ZSH is already the default shell"
    fi
}

# Show next steps
show_next_steps() {
    echo
    success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    success "🎉 Installation Complete!"
    success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "  📋 Next steps:"
    echo "    1. Restart your terminal or run: exec zsh"
    echo "    2. Check status: $INSTALL_DIR/status.sh"
    echo "    3. Run tests: $INSTALL_DIR/test.sh"
    echo "    4. Update later: $INSTALL_DIR/update.sh"
    echo
    echo "  📚 Documentation:"
    echo "    • README.md - Complete documentation"
    echo "    • REFERENCE.md - Configuration reference"
    echo "    • CHANGELOG.md - Version history"
    echo
    echo "  🔧 Configuration:"
    echo "    • Main config: $INSTALL_DIR/zshrc"
    echo "    • Environment: $INSTALL_DIR/zshenv"
    echo "    • Custom: $INSTALL_DIR/custom/"
    echo
    echo "  💡 Tips:"
    echo "    • Use 'reload' to reload configuration"
    echo "    • Use 'status' to check system status"
    echo "    • Use 'version' to see version info"
    echo
}

# Main function
main() {
    printf '%b╔══════════════════════════════════════════════════════════════╗%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    printf '%b║                🚀 Quick ZSH Installation                    ║%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    printf '%b╚══════════════════════════════════════════════════════════════╝%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    echo
    
    # Check prerequisites
    if ! command -v git >/dev/null 2>&1; then
        error "Git is required but not installed"
        exit 1
    fi
    
    # Install ZSH if needed
    install_zsh
    
    # Setup repository
    setup_repository
    
    # Run installation
    run_installation
    
    # Set default shell
    set_default_shell
    
    # Show next steps
    show_next_steps
}

# Parse command line arguments
case "${1:-}" in
    "-h"|"--help")
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Quick installation script for ZSH configuration"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  $0            # Run quick installation"
        echo "  curl -fsSL https://raw.githubusercontent.com/yourusername/zsh-config/main/quick-install.sh | bash"
        exit 0
        ;;
esac

# Run main function
main "$@"
