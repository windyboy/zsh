#!/usr/bin/env bash
# =============================================================================
# ZSH Modular Configuration Installer
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create directory if it doesn't exist
ensure_directory() {
    if [[ ! -d "$1" ]]; then
        mkdir -p "$1"
        log_success "Created directory: $1"
    fi
}

# Backup existing file
backup_file() {
    if [[ -f "$1" ]]; then
        local backup_name="${1}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$1" "$backup_name"
        log_warning "Backed up existing file: $1 -> $backup_name"
    fi
}

# Install prerequisites
install_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for zsh
    if ! command_exists zsh; then
        log_error "ZSH is not installed. Please install zsh first."
        exit 1
    fi
    
    # Check for git
    if ! command_exists git; then
        log_error "Git is not installed. Please install git first."
        exit 1
    fi
    
    # Check for curl
    if ! command_exists curl; then
        log_warning "curl is not installed. Some features may not work."
    fi
    
    # Check for fzf
    if ! command_exists fzf; then
        log_warning "fzf is not installed. Install it for enhanced functionality."
    fi
    
    # Check for oh-my-posh
    if ! command_exists oh-my-posh; then
        log_warning "oh-my-posh is not installed. Using fallback prompt."
    fi
    
    log_success "Prerequisites check completed"
}

# Setup directory structure
setup_directories() {
    log_info "Setting up directory structure..."
    
    ensure_directory "$ZSH_CONFIG_DIR"
    ensure_directory "$ZSH_CONFIG_DIR/modules"
    ensure_directory "$ZSH_CONFIG_DIR/themes"
    ensure_directory "$ZSH_CONFIG_DIR/completions"
    ensure_directory "$ZSH_CACHE_DIR"
    ensure_directory "$ZSH_DATA_DIR"
    
    log_success "Directory structure created"
}

# Install zinit
install_zinit() {
    local zinit_dir="$ZSH_DATA_DIR/zinit/zinit.git"
    
    if [[ ! -d "$zinit_dir" ]]; then
        log_info "Installing Zinit..."
        git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir"
        log_success "Zinit installed"
    else
        log_info "Zinit already installed"
    fi
}

# Create configuration files
create_config_files() {
    log_info "Creating configuration files..."
    
    # Backup existing zshrc if it exists
    backup_file "$HOME/.zshrc"
    
    # Create symlink to new zshrc
    ln -sf "$ZSH_CONFIG_DIR/zshrc" "$HOME/.zshrc"
    log_success "Created ~/.zshrc symlink"
    
    # Create zshenv if it doesn't exist
    if [[ ! -f "$HOME/.zshenv" ]]; then
        ln -sf "$ZSH_CONFIG_DIR/zshenv" "$HOME/.zshenv"
        log_success "Created ~/.zshenv symlink"
    else
        log_warning "~/.zshenv already exists, skipping"
    fi
    
    # Create local config template
    if [[ ! -f "$ZSH_CONFIG_DIR/local.zsh" ]]; then
        if [[ -f "$ZSH_CONFIG_DIR/local.zsh.example" ]]; then
            cp "$ZSH_CONFIG_DIR/local.zsh.example" "$ZSH_CONFIG_DIR/local.zsh"
            log_success "Created local.zsh from template"
        fi
    fi
}

# Set zsh as default shell
set_default_shell() {
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log_info "Setting ZSH as default shell..."
        
        # Add zsh to /etc/shells if not present
        if ! grep -q "$(which zsh)" /etc/shells 2>/dev/null; then
            echo "$(which zsh)" | sudo tee -a /etc/shells >/dev/null
        fi
        
        # Change default shell
        chsh -s "$(which zsh)"
        log_success "ZSH set as default shell (restart terminal to take effect)"
    else
        log_info "ZSH is already the default shell"
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    local errors=0
    
    # Check required files
    local required_files=(
        "$ZSH_CONFIG_DIR/zshrc"
        "$ZSH_CONFIG_DIR/zshenv"
        "$ZSH_CONFIG_DIR/modules/core.zsh"
        "$ZSH_CONFIG_DIR/modules/plugins.zsh"
        "$ZSH_CONFIG_DIR/modules/completion.zsh"
        "$ZSH_CONFIG_DIR/modules/aliases.zsh"
        "$ZSH_CONFIG_DIR/modules/functions.zsh"
        "$ZSH_CONFIG_DIR/modules/keybindings.zsh"
        "$ZSH_CONFIG_DIR/modules/performance.zsh"
        "$ZSH_CONFIG_DIR/themes/prompt.zsh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Missing file: $file"
            ((errors++))
        fi
    done
    
    # Check zinit installation
    if [[ ! -d "$ZSH_DATA_DIR/zinit/zinit.git" ]]; then
        log_error "Zinit not installed properly"
        ((errors++))
    fi
    
    if (( errors == 0 )); then
        log_success "Installation verification passed"
        return 0
    else
        log_error "Installation verification failed with $errors errors"
        return 1
    fi
}

# Show post-installation instructions
show_post_install() {
    cat << EOF

${GREEN}🎉 ZSH Modular Configuration Installation Complete!${NC}

${BLUE}Next Steps:${NC}
1. Restart your terminal or run: ${YELLOW}exec zsh${NC}
2. The first startup will install plugins (may take a moment)
3. Customize your settings in: ${YELLOW}~/.config/zsh/local.zsh${NC}

${BLUE}Useful Commands:${NC}
• ${YELLOW}reload${NC}              - Reload ZSH configuration
• ${YELLOW}benchmark_zsh${NC}       - Test performance
• ${YELLOW}compile_config${NC}      - Compile for faster loading
• ${YELLOW}show_performance_tips${NC} - Show optimization tips

${BLUE}Configuration Files:${NC}
• Main config: ${YELLOW}~/.config/zsh/zshrc${NC}
• Modules: ${YELLOW}~/.config/zsh/modules/${NC}
• Local config: ${YELLOW}~/.config/zsh/local.zsh${NC}

${BLUE}Troubleshooting:${NC}
• If you encounter issues, check: ${YELLOW}~/.config/zsh/modules/performance.zsh${NC}
• Run ${YELLOW}analyze_config${NC} to check for problems
• Use ${YELLOW}ZSH_PROF=1 zsh${NC} to profile startup

Enjoy your new ZSH configuration! 🚀

EOF
}

# Main installation function
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                ZSH Modular Configuration Installer           ║
║                                                              ║
║  This will install a modular, high-performance ZSH setup    ║
║  with lazy loading, intelligent completion, and modern       ║
║  development tools integration.                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Confirm installation
    echo -n "Do you want to proceed with the installation? (y/N): "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
    
    # Run installation steps
    install_prerequisites
    setup_directories
    install_zinit
    create_config_files
    
    # Ask about setting default shell
    echo -n "Set ZSH as your default shell? (y/N): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        set_default_shell
    fi
    
    # Verify installation
    if verify_installation; then
        show_post_install
    else
        log_error "Installation completed with errors. Please check the output above."
        exit 1
    fi
}

# Handle command line arguments
case "${1:-install}" in
    install)
        main
        ;;
    verify)
        verify_installation
        ;;
    clean)
        log_info "Cleaning installation..."
        rm -rf "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR"
        log_success "Cache and data directories cleaned"
        ;;
    update)
        log_info "Updating Zinit..."
        if [[ -d "$ZSH_DATA_DIR/zinit/zinit.git" ]]; then
            cd "$ZSH_DATA_DIR/zinit/zinit.git" && git pull
            log_success "Zinit updated"
        else
            log_error "Zinit not found"
        fi
        ;;
    *)
        echo "Usage: $0 [install|verify|clean|update]"
        echo "  install - Full installation (default)"
        echo "  verify  - Verify installation"
        echo "  clean   - Clean cache and data"
        echo "  update  - Update Zinit"
        exit 1
        ;;
esac
