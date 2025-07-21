#!/usr/bin/env bash
# =============================================================================
# Simple ZSH Installer
# =============================================================================

# Simple logging
log() { echo "ℹ️  $1"; }
success() { echo "✅ $1"; }
warning() { echo "⚠️  $1"; }
error() { echo "❌ $1"; }

# Check ZSH version
check_zsh_version() {
    local required_version="5.8"
    local current_version=$(zsh --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "$current_version" ]]; then
        error "无法获取ZSH版本信息"
        return 1
    fi
    
    # Simple version comparison
    IFS='.' read -r -a current <<< "$current_version"
    IFS='.' read -r -a required <<< "$required_version"
    
    if (( current[0] > required[0] )) || \
       (( current[0] == required[0] && current[1] >= required[1] )); then
        success "ZSH版本检查通过: $current_version (需要: $required_version+)"
        return 0
    else
        error "ZSH版本过低: $current_version (需要: $required_version+)"
        return 1
    fi
}

# Check optional tools
check_optional_tools() {
    log "检查可选工具..."
    
    local optional_tools=(
        "fzf:Fuzzy Finder"
        "zoxide:Smart Navigation"
        "eza:Enhanced ls"
        "oh-my-posh:Theme System"
        "curl:Network Tool"
        "wget:Network Tool"
    )
    
    local found_tools=()
    local missing_tools=()
    
    for tool_info in "${optional_tools[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info##*:}"
        
        if command -v "$tool" >/dev/null 2>&1; then
            found_tools+=("$tool")
            success "✅ $tool - $desc"
        else
            missing_tools+=("$tool")
            warning "⚠️  $tool - $desc (未安装)"
        fi
    done
    
    echo
    if [[ ${#found_tools[@]} -gt 0 ]]; then
        success "已安装工具: ${found_tools[*]}"
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        warning "未安装工具: ${missing_tools[*]}"
        echo "💡 这些工具是可选的，但建议安装以获得更好的体验"
        echo "📖 查看README.md了解安装方法"
    fi
}

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
        echo "📖 查看README.md了解安装方法"
        exit 1
    fi
    success "ZSH found: $(which zsh)"
    
    if ! check_zsh_version; then
        error "ZSH version check failed."
        echo "📖 查看README.md了解版本要求"
        exit 1
    fi
    
    if ! command -v git >/dev/null 2>&1; then
        error "Git not found. Please install git first."
        echo "📖 查看README.md了解安装方法"
        exit 1
    fi
    success "Git found: $(which git)"
    
    success "Prerequisites OK"
    
    # Check optional tools
    check_optional_tools
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
    
    # Set ZDOTDIR in shell profile if not already set
    setup_zdotdir
    
    success "Configuration ready"
}

# Setup ZDOTDIR
setup_zdotdir() {
    local profile_file=""
    local zdotdir_line="export ZDOTDIR=\"\$HOME/.config/zsh\""
    
    # Determine which profile file to use
    if [[ -f "$HOME/.bash_profile" ]]; then
        profile_file="$HOME/.bash_profile"
    elif [[ -f "$HOME/.bashrc" ]]; then
        profile_file="$HOME/.bashrc"
    elif [[ -f "$HOME/.profile" ]]; then
        profile_file="$HOME/.profile"
    else
        # Create .profile if none exists
        profile_file="$HOME/.profile"
        touch "$profile_file"
    fi
    
    # Check if ZDOTDIR is already set
    if ! grep -q "ZDOTDIR" "$profile_file" 2>/dev/null; then
        log "Setting ZDOTDIR in $profile_file..."
        echo "" >> "$profile_file"
        echo "# ZSH Configuration Directory" >> "$profile_file"
        echo "$zdotdir_line" >> "$profile_file"
        success "ZDOTDIR configured in $profile_file"
    else
        log "ZDOTDIR already configured in $profile_file"
    fi
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
