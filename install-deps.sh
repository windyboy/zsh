#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# Dependency Installation Script
# =============================================================================

# Shared logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/logging.sh"

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in curl wget tar; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        return 1
    fi
}

# Verify installation
verify_installation() {
    log "Verifying installation results..."
    local tools=("zsh" "git" "fzf" "zoxide" "eza" "oh-my-posh")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            success "$tool ✓"
        else
            warning "$tool ✗"
        fi
    done
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos";;
        Linux*)     echo "linux";;
        CYGWIN*)    echo "windows";;
        MINGW*)     echo "windows";;
        *)          echo "unknown";;
    esac
}

# Detect package manager
detect_package_manager() {
    if command -v brew >/dev/null 2>&1; then
        echo "brew"
    elif command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    else
        echo "unknown"
    fi
}

# Install eza binary
install_eza() {
    log "Installing eza..."
    
    # Detect OS and architecture
    local os=""
    local arch=""
    
    case "$(uname -s)" in
        Darwin*)    os="apple-darwin";;
        Linux*)     os="unknown-linux-gnu";;
        *)          warning "Unsupported operating system: $(uname -s), skipping eza installation"; return 1;;
    esac
    
    case "$(uname -m)" in
        x86_64)         arch="x86_64";;
        arm64|aarch64)  arch="aarch64";;
        armv7l)         arch="armv7";;
        *)              warning "Unsupported architecture: $(uname -m), skipping eza installation"; return 1;;
    esac
    
    # Correct download URL format
    local eza_url="https://github.com/eza-community/eza/releases/latest/download/eza_${arch}-${os}.tar.gz"
    local temp_dir
    temp_dir=$(mktemp -d)
    
    log "Downloading eza: $eza_url"
    if curl -L -o "$temp_dir/eza.tar.gz" "$eza_url" 2>/dev/null; then
        cd "$temp_dir" || return 1
        if tar -xzf eza.tar.gz 2>/dev/null && [[ -f "eza" ]]; then
            # Try multiple installation paths
            if sudo mv eza /usr/local/bin/ 2>/dev/null; then
                success "eza installed to /usr/local/bin/"
            elif mkdir -p ~/.local/bin && mv eza ~/.local/bin/ 2>/dev/null; then
                # Ensure ~/.local/bin is in PATH
                for rc_file in ~/.bashrc ~/.zshrc; do
                    if [[ -f "$rc_file" ]] && ! grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$rc_file"; then
                        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$rc_file"
                    fi
                done
                success "eza installed to ~/.local/bin/"
                warning "Please restart terminal or run 'source ~/.bashrc' to update PATH"
            else
                error "eza installation failed: cannot move to target directory"
                return 1
            fi
        else
            error "eza extraction failed or binary file not found"
            return 1
        fi
    else
        error "Failed to download eza: $eza_url"
        return 1
    fi
    
    rm -rf "$temp_dir"
}

# Install oh-my-posh themes
install_oh_my_posh_themes() {
    log "Downloading all Oh My Posh themes from GitHub..."
    local themes_dir="$HOME/.poshthemes"
    mkdir -p "$themes_dir"
    
    # Create temporary directory for cloning
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the oh-my-posh repository to get all themes
    if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
        log "GitHub repository cloned successfully"
        
        # Copy all theme files
        if [[ -d "oh-my-posh/themes" ]]; then
            local theme_count=0
            for theme_file in oh-my-posh/themes/*.omp.json; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name
                    theme_name=$(basename "$theme_file")
                    cp "$theme_file" "$themes_dir/"
                    ((theme_count++))
                    log "Theme ${theme_name} copied successfully"
                fi
            done
            
            # Also copy YAML themes if they exist
            for theme_file in oh-my-posh/themes/*.omp.yaml; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name
                    theme_name=$(basename "$theme_file")
                    cp "$theme_file" "$themes_dir/"
                    ((theme_count++))
                    log "Theme ${theme_name} copied successfully"
                fi
            done
            
            success "Theme installation completed, installed ${theme_count} themes"
            echo "💡 Theme location: $themes_dir"
            echo "💡 Use theme: oh-my-posh init zsh --config $themes_dir/agnoster.omp.json"
            echo "💡 Preview theme: oh-my-posh print primary --config $themes_dir/agnoster.omp.json"
        else
            warning "Theme directory not found"
        fi
    else
        warning "GitHub repository clone failed, trying to download popular themes..."
        # Fallback to downloading popular themes
        local themes=("agnoster" "powerlevel10k_modern" "paradox" "atomic" "agnosterplus" "jandedobbeleer")
        for theme in "${themes[@]}"; do
            if curl -s "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$themes_dir/${theme}.omp.json"; then
                log "Theme ${theme} downloaded successfully"
            else
                warning "Theme ${theme} download failed"
            fi
        done
    fi
    
    # Clean up
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Install oh-my-posh and themes
install_oh_my_posh() {
    log "Installing oh-my-posh..."
    local os=""
    local arch=""
    
    case "$(uname -s)" in
        Darwin*)    os="darwin";;
        Linux*)     os="linux";;
        *)          warning "Unsupported operating system: $(uname -s), skipping oh-my-posh installation"; return 1;;
    esac
    
    case "$(uname -m)" in
        x86_64)         arch="amd64";;
        arm64|aarch64)  arch="arm64";;
        armv7l)         arch="arm";;
        *)              warning "Unsupported architecture: $(uname -m), skipping oh-my-posh installation"; return 1;;
    esac
    
    local binary_name="posh-${os}-${arch}"
    local download_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/${binary_name}"
    
    if curl -L -o /tmp/oh-my-posh "$download_url" && sudo mv /tmp/oh-my-posh /usr/local/bin/oh-my-posh && sudo chmod +x /usr/local/bin/oh-my-posh; then
        success "oh-my-posh installed successfully"
        
        # Install themes
        install_oh_my_posh_themes
    else
        warning "oh-my-posh installation failed"
    fi
}

# Install on macOS
install_macos() {
    log "Detected macOS system, using Homebrew for installation..."
    
    if ! command -v brew >/dev/null 2>&1; then
        error "Homebrew not installed, please install Homebrew first"
        echo "Installation command: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    
    # Required tools
    log "Installing required tools..."
    brew install zsh git
    
    # Recommended tools
    log "Installing recommended tools..."
    brew install fzf zoxide eza curl
    
    # Install oh-my-posh
    log "Installing oh-my-posh..."
    if brew install oh-my-posh; then
        success "oh-my-posh installed successfully"
        
        # Install themes
        install_oh_my_posh_themes
    else
        warning "oh-my-posh installation failed"
    fi
    
    success "macOS dependencies installation completed"
}

# Install on Ubuntu/Debian
install_ubuntu() {
    log "Detected Ubuntu/Debian system, using apt for installation..."
    
    # Update package list
    log "Updating package list..."
    if ! sudo apt update; then
        error "Failed to update package list"
        return 1
    fi
    
    # Required tools
    log "Installing required tools..."
    sudo apt install -y zsh git curl wget unzip
    
    # Recommended tools
    log "Installing recommended tools..."
    sudo apt install -y fzf
    
    # Install zoxide
    log "Installing zoxide..."
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | zsh; then
        success "zoxide installed successfully"
    else
        warning "zoxide installation failed"
    fi
    
    # Install eza
    install_eza
    
    # Install oh-my-posh and themes
    install_oh_my_posh
    
    success "Ubuntu/Debian dependencies installation completed"
}

# Install on CentOS/RHEL/Fedora
install_centos() {
    local pkg_manager
    pkg_manager=$(detect_package_manager)
    
    if [[ "$pkg_manager" == "dnf" ]]; then
        log "Detected Fedora system, using dnf for installation..."
        sudo dnf install -y zsh git fzf curl wget unzip
    elif [[ "$pkg_manager" == "yum" ]]; then
        log "Detected CentOS/RHEL system, using yum for installation..."
        sudo yum install -y zsh git fzf curl wget unzip
    else
        error "Unable to detect package manager"
        return 1
    fi
    
    # Install zoxide
    log "Installing zoxide..."
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | zsh; then
        success "zoxide installed successfully"
    else
        warning "zoxide installation failed"
    fi
    
    # Install eza
    install_eza
    
    # Install oh-my-posh and themes
    install_oh_my_posh
    
    success "CentOS/RHEL/Fedora dependencies installation completed"
}

# Install on Windows
install_windows() {
    log "Detected Windows system..."
    warning "Windows users are recommended to use WSL (Windows Subsystem for Linux)"
    echo "Follow Ubuntu/Debian steps in WSL"
    echo "Or manually install each tool"
    return 1
}

# Main installation
main() {
    log "Starting ZSH configuration dependencies installation..."
    
    # Check basic dependencies
    if ! check_dependencies; then
        error "Missing required dependencies, please install basic tools first"
        return 1
    fi
    
    local os
    os=$(detect_os)
    
    case "$os" in
        "macos")
            install_macos
            ;;
        "linux")
            local pkg_manager
            pkg_manager=$(detect_package_manager)
            if [[ "$pkg_manager" == "apt" ]]; then
                install_ubuntu
            elif [[ "$pkg_manager" == "dnf" || "$pkg_manager" == "yum" ]]; then
                install_centos
            else
                error "Unsupported Linux distribution"
                echo "Please manually install dependency tools"
                return 1
            fi
            ;;
        "windows")
            install_windows
            ;;
        *)
            error "Unsupported operating system: $os"
            return 1
            ;;
    esac
    
    # Verify installation results
    verify_installation
    
    echo
    success "Dependencies installation completed!"
    log "Next step: Run ./install.sh to install ZSH configuration"
}

main "$@" 
