#!/bin/bash

# Oh My Posh 主题安装脚本
# 从GitHub下载所有可用的主题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    local missing_deps=()
    
    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "缺少必要依赖: ${missing_deps[*]}"
        echo "请先安装这些工具后再运行此脚本"
        return 1
    fi
    
    return 0
}

# 安装所有主题
install_all_themes() {
    log "开始安装Oh My Posh主题..."
    
    local themes_dir="$HOME/.poshthemes"
    mkdir -p "$themes_dir"
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    log "克隆Oh My Posh GitHub仓库..."
    if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
        success "GitHub仓库克隆成功"
        
        # 复制所有主题文件
        if [[ -d "oh-my-posh/themes" ]]; then
            local theme_count=0
            local json_count=0
            local yaml_count=0
            
            # 复制JSON主题
            for theme_file in oh-my-posh/themes/*.omp.json; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name=$(basename "$theme_file")
                    cp "$theme_file" "$themes_dir/"
                    ((theme_count++))
                    ((json_count++))
                    log "主题 ${theme_name} 复制成功"
                fi
            done
            
            # 复制YAML主题
            for theme_file in oh-my-posh/themes/*.omp.yaml; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name=$(basename "$theme_file")
                    cp "$theme_file" "$themes_dir/"
                    ((theme_count++))
                    ((yaml_count++))
                    log "主题 ${theme_name} 复制成功"
                fi
            done
            
            success "主题安装完成！"
            echo "📊 安装统计:"
            echo "   - 总主题数: ${theme_count}"
            echo "   - JSON主题: ${json_count}"
            echo "   - YAML主题: ${yaml_count}"
            echo "   - 主题位置: $themes_dir"
            echo ""
            echo "💡 使用示例:"
            echo "   - 预览主题: oh-my-posh print primary --config $themes_dir/agnoster.omp.json"
            echo "   - 使用主题: oh-my-posh init zsh --config $themes_dir/agnoster.omp.json"
            echo "   - 列出主题: ls $themes_dir/*.omp.*"
            
        else
            error "主题目录未找到"
            return 1
        fi
    else
        error "GitHub仓库克隆失败"
        return 1
    fi
    
    # 清理临时目录
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# 安装特定主题
install_specific_themes() {
    local themes=("$@")
    log "安装指定主题: ${themes[*]}"
    
    local themes_dir="$HOME/.poshthemes"
    mkdir -p "$themes_dir"
    
    local success_count=0
    local fail_count=0
    
    for theme in "${themes[@]}"; do
        # 尝试下载JSON格式
        if curl -s "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$themes_dir/${theme}.omp.json"; then
            log "主题 ${theme}.omp.json 下载成功"
            ((success_count++))
        # 尝试下载YAML格式
        elif curl -s "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.yaml" -o "$themes_dir/${theme}.omp.yaml"; then
            log "主题 ${theme}.omp.yaml 下载成功"
            ((success_count++))
        else
            warning "主题 ${theme} 下载失败"
            ((fail_count++))
        fi
    done
    
    echo ""
    success "主题下载完成！"
    echo "📊 下载统计:"
    echo "   - 成功: ${success_count}"
    echo "   - 失败: ${fail_count}"
    echo "   - 主题位置: $themes_dir"
}

# 列出可用主题
list_available_themes() {
    log "获取GitHub上的可用主题列表..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
        if [[ -d "oh-my-posh/themes" ]]; then
            echo "📋 可用的Oh My Posh主题:"
            echo ""
            
            # JSON主题
            echo "JSON格式主题:"
            for theme_file in oh-my-posh/themes/*.omp.json; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name=$(basename "$theme_file" .omp.json)
                    echo "  - $theme_name"
                fi
            done
            
            echo ""
            echo "YAML格式主题:"
            for theme_file in oh-my-posh/themes/*.omp.yaml; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name=$(basename "$theme_file" .omp.yaml)
                    echo "  - $theme_name"
                fi
            done
        else
            error "主题目录未找到"
        fi
    else
        error "无法获取主题列表"
    fi
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# 显示帮助信息
show_help() {
    echo "Oh My Posh 主题安装脚本"
    echo ""
    echo "用法: $0 [选项] [主题名...]"
    echo ""
    echo "选项:"
    echo "  -a, --all          安装所有可用主题"
    echo "  -l, --list         列出所有可用主题"
    echo "  -h, --help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --all                    # 安装所有主题"
    echo "  $0 agnoster powerlevel10k   # 安装指定主题"
    echo "  $0 --list                   # 列出可用主题"
    echo ""
    echo "主题位置: ~/.poshthemes/"
}

# 主函数
main() {
    # 检查参数
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # 检查依赖
    if ! check_dependencies; then
        exit 1
    fi
    
    case "$1" in
        -a|--all)
            install_all_themes
            ;;
        -l|--list)
            list_available_themes
            ;;
        -h|--help)
            show_help
            ;;
        -*)
            error "未知选项: $1"
            show_help
            exit 1
            ;;
        *)
            # 安装指定主题
            install_specific_themes "$@"
            ;;
    esac
}

main "$@" 