#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# Dependency Installation Script
# =============================================================================

# Simple logging
log() { echo "ℹ️  $1"; }
success() { echo "✅ $1"; }
warning() { echo "⚠️  $1"; }
error() { echo "❌ $1"; }

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in curl wget tar; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "缺少必要依赖: ${missing_deps[*]}"
        return 1
    fi
}

# Verify installation
verify_installation() {
    log "验证安装结果..."
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
    log "安装eza..."
    
    # Detect OS and architecture
    local os=""
    local arch=""
    
    case "$(uname -s)" in
        Darwin*)    os="apple-darwin";;
        Linux*)     os="unknown-linux-gnu";;
        *)          warning "不支持的操作系统: $(uname -s)，跳过eza安装"; return 1;;
    esac
    
    case "$(uname -m)" in
        x86_64)         arch="x86_64";;
        arm64|aarch64)  arch="aarch64";;
        armv7l)         arch="armv7";;
        *)              warning "不支持的架构: $(uname -m)，跳过eza安装"; return 1;;
    esac
    
    # 正确的下载URL格式
    local eza_url="https://github.com/eza-community/eza/releases/latest/download/eza_${arch}-${os}.tar.gz"
    local temp_dir=$(mktemp -d)
    
    log "下载eza: $eza_url"
    if curl -L -o "$temp_dir/eza.tar.gz" "$eza_url" 2>/dev/null; then
        cd "$temp_dir" || return 1
        if tar -xzf eza.tar.gz 2>/dev/null && [[ -f "eza" ]]; then
            # 尝试多种安装路径
            if sudo mv eza /usr/local/bin/ 2>/dev/null; then
                success "eza安装到 /usr/local/bin/"
            elif mkdir -p ~/.local/bin && mv eza ~/.local/bin/ 2>/dev/null; then
                # 确保 ~/.local/bin 在 PATH 中
                for rc_file in ~/.bashrc ~/.zshrc; do
                    if [[ -f "$rc_file" ]] && ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$rc_file"; then
                        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc_file"
                    fi
                done
                success "eza安装到 ~/.local/bin/"
                warning "请重启终端或运行 'source ~/.bashrc' 来更新PATH"
            else
                error "eza安装失败：无法移动到目标目录"
                return 1
            fi
        else
            error "eza解压失败或二进制文件未找到"
            return 1
        fi
    else
        error "下载eza失败: $eza_url"
        return 1
    fi
    
    rm -rf "$temp_dir"
}

# Install oh-my-posh and themes
install_oh_my_posh() {
    log "安装oh-my-posh..."
    local arch="amd64"
    [[ "$(uname -m)" == "aarch64" ]] && arch="arm64"
    
    if sudo wget "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${arch}" -O /usr/local/bin/oh-my-posh && sudo chmod +x /usr/local/bin/oh-my-posh; then
        success "oh-my-posh安装成功"
        
        # Install all themes from GitHub
        log "从GitHub下载所有Oh My Posh主题..."
        local themes_dir="$HOME/.poshthemes"
        mkdir -p "$themes_dir"
        
        # Create temporary directory for cloning
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        # Clone the oh-my-posh repository to get all themes
        if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
            log "GitHub仓库克隆成功"
            
            # Copy all theme files
            if [[ -d "oh-my-posh/themes" ]]; then
                local theme_count=0
                for theme_file in oh-my-posh/themes/*.omp.json; do
                    if [[ -f "$theme_file" ]]; then
                        local theme_name=$(basename "$theme_file")
                        cp "$theme_file" "$themes_dir/"
                        ((theme_count++))
                        log "主题 ${theme_name} 复制成功"
                    fi
                done
                
                # Also copy YAML themes if they exist
                for theme_file in oh-my-posh/themes/*.omp.yaml; do
                    if [[ -f "$theme_file" ]]; then
                        local theme_name=$(basename "$theme_file")
                        cp "$theme_file" "$themes_dir/"
                        ((theme_count++))
                        log "主题 ${theme_name} 复制成功"
                    fi
                done
                
                success "主题安装完成，共安装 ${theme_count} 个主题"
                echo "💡 主题位置: $themes_dir"
                echo "💡 使用主题: oh-my-posh init zsh --config $themes_dir/agnoster.omp.json"
                echo "💡 预览主题: oh-my-posh print primary --config $themes_dir/agnoster.omp.json"
            else
                warning "主题目录未找到"
            fi
        else
            warning "GitHub仓库克隆失败，尝试下载常用主题..."
            # Fallback to downloading popular themes
            local themes=("agnoster" "powerlevel10k_modern" "paradox" "atomic" "agnosterplus" "jandedobbeleer")
            for theme in "${themes[@]}"; do
                if wget -q "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -O "$themes_dir/${theme}.omp.json"; then
                    log "主题 ${theme} 下载成功"
                else
                    warning "主题 ${theme} 下载失败"
                fi
            done
        fi
        
        # Clean up
        cd - > /dev/null
        rm -rf "$temp_dir"
    else
        warning "oh-my-posh安装失败"
    fi
}

# Install on macOS
install_macos() {
    log "检测到macOS系统，使用Homebrew安装..."
    
    if ! command -v brew >/dev/null 2>&1; then
        error "Homebrew未安装，请先安装Homebrew"
        echo "安装命令: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    
    # 必需工具
    log "安装必需工具..."
    brew install zsh git
    
    # 推荐工具
    log "安装推荐工具..."
    brew install fzf zoxide eza curl
    
    # 安装oh-my-posh
    log "安装oh-my-posh..."
    if brew install oh-my-posh; then
        success "oh-my-posh安装成功"
        
        # Install all themes from GitHub
        log "从GitHub下载所有Oh My Posh主题..."
        local themes_dir="$HOME/.poshthemes"
        mkdir -p "$themes_dir"
        
        # Create temporary directory for cloning
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        # Clone the oh-my-posh repository to get all themes
        if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
            log "GitHub仓库克隆成功"
            
            # Copy all theme files
            if [[ -d "oh-my-posh/themes" ]]; then
                local theme_count=0
                for theme_file in oh-my-posh/themes/*.omp.json; do
                    if [[ -f "$theme_file" ]]; then
                        local theme_name=$(basename "$theme_file")
                        cp "$theme_file" "$themes_dir/"
                        ((theme_count++))
                        log "主题 ${theme_name} 复制成功"
                    fi
                done
                
                # Also copy YAML themes if they exist
                for theme_file in oh-my-posh/themes/*.omp.yaml; do
                    if [[ -f "$theme_file" ]]; then
                        local theme_name=$(basename "$theme_file")
                        cp "$theme_file" "$themes_dir/"
                        ((theme_count++))
                        log "主题 ${theme_name} 复制成功"
                    fi
                done
                
                success "主题安装完成，共安装 ${theme_count} 个主题"
                echo "💡 主题位置: $themes_dir"
                echo "💡 使用主题: oh-my-posh init zsh --config $themes_dir/agnoster.omp.json"
                echo "💡 预览主题: oh-my-posh print primary --config $themes_dir/agnoster.omp.json"
            else
                warning "主题目录未找到"
            fi
        else
            warning "GitHub仓库克隆失败，尝试下载常用主题..."
            # Fallback to downloading popular themes
            local themes=("agnoster" "powerlevel10k_modern" "paradox" "atomic" "agnosterplus" "jandedobbeleer")
            for theme in "${themes[@]}"; do
                if curl -s "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$themes_dir/${theme}.omp.json"; then
                    log "主题 ${theme} 下载成功"
                else
                    warning "主题 ${theme} 下载失败"
                fi
            done
        fi
        
        # Clean up
        cd - > /dev/null
        rm -rf "$temp_dir"
    else
        warning "oh-my-posh安装失败"
    fi
    
    success "macOS依赖安装完成"
}

# Install on Ubuntu/Debian
install_ubuntu() {
    log "检测到Ubuntu/Debian系统，使用apt安装..."
    
    # 更新包列表
    log "更新包列表..."
    if ! sudo apt update; then
        error "更新包列表失败"
        return 1
    fi
    
    # 必需工具
    log "安装必需工具..."
    sudo apt install -y zsh git curl wget unzip
    
    # 推荐工具
    log "安装推荐工具..."
    sudo apt install -y fzf
    
    # 安装zoxide
    log "安装zoxide..."
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
        success "zoxide安装成功"
    else
        warning "zoxide安装失败"
    fi
    
    # 安装eza
    install_eza
    
    # 安装oh-my-posh和主题
    install_oh_my_posh
    
    success "Ubuntu/Debian依赖安装完成"
}

# Install on CentOS/RHEL/Fedora
install_centos() {
    local pkg_manager=$(detect_package_manager)
    
    if [[ "$pkg_manager" == "dnf" ]]; then
        log "检测到Fedora系统，使用dnf安装..."
        sudo dnf install -y zsh git fzf curl wget unzip
    elif [[ "$pkg_manager" == "yum" ]]; then
        log "检测到CentOS/RHEL系统，使用yum安装..."
        sudo yum install -y zsh git fzf curl wget unzip
    else
        error "无法检测包管理器"
        return 1
    fi
    
    # 安装zoxide
    log "安装zoxide..."
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
        success "zoxide安装成功"
    else
        warning "zoxide安装失败"
    fi
    
    # 安装eza
    install_eza
    
    # 安装oh-my-posh和主题
    install_oh_my_posh
    
    success "CentOS/RHEL/Fedora依赖安装完成"
}

# Install on Windows
install_windows() {
    log "检测到Windows系统..."
    warning "Windows用户建议使用WSL (Windows Subsystem for Linux)"
    echo "在WSL中按照Ubuntu/Debian的步骤安装"
    echo "或者手动安装各个工具"
    return 1
}

# Main installation
main() {
    log "开始安装ZSH配置依赖..."
    
    # 检查基础依赖
    if ! check_dependencies; then
        error "缺少必要依赖，请先安装基础工具"
        return 1
    fi
    
    local os=$(detect_os)
    
    case "$os" in
        "macos")
            install_macos
            ;;
        "linux")
            local pkg_manager=$(detect_package_manager)
            if [[ "$pkg_manager" == "apt" ]]; then
                install_ubuntu
            elif [[ "$pkg_manager" == "dnf" || "$pkg_manager" == "yum" ]]; then
                install_centos
            else
                error "不支持的Linux发行版"
                echo "请手动安装依赖工具"
                return 1
            fi
            ;;
        "windows")
            install_windows
            ;;
        *)
            error "不支持的操作系统: $os"
            return 1
            ;;
    esac
    
    # 验证安装结果
    verify_installation
    
    echo
    success "依赖安装完成！"
    log "下一步：运行 ./install.sh 安装ZSH配置"
}

main "$@" 
