#!/usr/bin/env bash
# =============================================================================
# Simple ZSH Installer
# =============================================================================

# Simple logging
log() { echo "ℹ️  $1"; }
success() { echo "✅ $1"; }
warning() { echo "⚠️  $1"; }
error() { echo "❌ $1"; }

# Setup directories
setup_dirs() {
    log "Setting up directories..."
    mkdir -p "$HOME/.config/zsh" "$HOME/.cache/zsh" "$HOME/.local/share/zsh"
    success "Directories ready"
}

# Check prerequisites
check_prereq() {
    log "Checking prerequisites..."
    
    if ! command -v zsh >/dev/null 2>&1; then
        error "ZSH not found. Please install zsh first."
        exit 1
    fi
    success "ZSH found: $(which zsh)"
    
    if ! command -v git >/dev/null 2>&1; then
        error "Git not found. Please install git first."
        exit 1
    fi
    success "Git found: $(which git)"
    
    success "Prerequisites OK"
}

# Install zinit
install_zinit() {
    local zinit_dir="$HOME/.local/share/zsh/zinit/zinit.git"
    
    if [[ ! -d "$zinit_dir" ]]; then
        log "Installing zinit..."
        git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir"
        success "Zinit installed"
    else
        log "Zinit already installed"
    fi
}

# Setup configuration
setup_config() {
    log "Setting up configuration..."
    
    # Backup existing files
    if [[ -f "$HOME/.zshrc" ]]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        warning "Backed up existing .zshrc"
    fi
    
    if [[ -f "$HOME/.zshenv" ]]; then
        mv "$HOME/.zshenv" "$HOME/.zshenv.backup.$(date +%Y%m%d_%H%M%S)"
        warning "Backed up existing .zshenv"
    fi
    
    # Create symlinks
    ln -sf "$HOME/.config/zsh/zshrc" "$HOME/.zshrc"
    ln -sf "$HOME/.config/zsh/zshenv" "$HOME/.zshenv"
    
    success "Configuration ready"
}

# Set default shell
set_shell() {
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log "Setting ZSH as default shell..."
        chsh -s "$(which zsh)"
        success "Default shell changed (restart terminal)"
    else
        log "ZSH already default shell"
    fi
}

# Main installation
main() {
    log "Starting ZSH installation..."
    
    check_prereq
    setup_dirs
    install_zinit
    setup_config
    set_shell
    
    success "Installation completed!"
    log "Next: restart terminal and run './status.sh'"
}

main "$@"
