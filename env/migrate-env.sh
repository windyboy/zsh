#!/usr/bin/env zsh
# =============================================================================
# 环境变量迁移脚本 - Environment Variables Migration Script
# 说明: 帮助用户从旧的环境变量配置迁移到新的配置系统
# 使用方法: ./migrate-env.sh
# =============================================================================

# 颜色输出函数
color_red()   { echo -e "\033[31m$1\033[0m"; }
color_green() { echo -e "\033[32m$1\033[0m"; }
color_yellow() { echo -e "\033[33m$1\033[0m"; }
color_blue()  { echo -e "\033[34m$1\033[0m"; }
color_cyan()  { echo -e "\033[36m$1\033[0m"; }

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSH_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

echo "$(color_cyan "=============================================================================")"
echo "$(color_cyan "环境变量配置迁移工具")"
echo "$(color_cyan "Environment Variables Configuration Migration Tool")"
echo "$(color_cyan "=============================================================================")"
echo

# 检查是否需要迁移
echo "$(color_yellow "检查现有配置...")"
echo

# 检查旧配置文件
old_files=()
if [[ -f "$ZSH_CONFIG_DIR/env/development.zsh" ]]; then
    old_files+=("development.zsh")
fi

if [[ -f "$ZSH_CONFIG_DIR/env/local.zsh" ]]; then
    old_files+=("local.zsh")
fi

if [[ ${#old_files[@]} -eq 0 ]]; then
    color_green "✅ 没有发现需要迁移的旧配置文件"
    echo
    echo "建议运行初始化脚本创建新的配置:"
    echo "  $SCRIPT_DIR/init-env.sh"
    exit 0
fi

echo "$(color_yellow "发现以下旧配置文件:")"
for file in "${old_files[@]}"; do
    echo "  • $file"
done
echo

# 确认迁移
echo "$(color_blue "迁移说明:")"
echo "• 旧配置文件将被备份到 backup/ 目录"
echo "• 新的环境配置文件将被创建"
echo "• 你可以手动将旧配置中的自定义设置复制到新配置中"
echo

read -k 1 "REPLY?是否继续迁移? (y/N): "
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "$(color_yellow "迁移已取消")"
    exit 0
fi

echo
echo "$(color_yellow "开始迁移...")"
echo

# 创建备份目录
backup_dir="$SCRIPT_DIR/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
color_green "创建备份目录: $backup_dir"

# 迁移 development.zsh
if [[ -f "$ZSH_CONFIG_DIR/env/development.zsh" ]]; then
    echo
    echo "$(color_blue "迁移 development.zsh...")"
    
    # 备份旧文件
    cp "$ZSH_CONFIG_DIR/env/development.zsh" "$backup_dir/"
    color_green "  备份: $ZSH_CONFIG_DIR/env/development.zsh -> $backup_dir/development.zsh"
    
    # 创建新的本地配置文件
    if [[ ! -f "$SCRIPT_DIR/local/environment.env" ]]; then
        cp "$SCRIPT_DIR/templates/environment.env.template" "$SCRIPT_DIR/local/environment.env"
        color_green "  创建: $SCRIPT_DIR/local/environment.env"
        
        # 提取环境变量并添加到新配置
        echo
        echo "$(color_yellow "  提取环境变量...")"
        
        # 读取旧文件中的export语句
        while IFS= read -r line; do
            if [[ $line =~ ^export[[:space:]]+([^=]+)= ]]; then
                var_name="${BASH_REMATCH[1]}"
                echo "  发现变量: $var_name"
                
                # 在新配置文件中查找并取消注释对应的变量
                case $var_name in
                    BUN_INSTALL|DENO_INSTALL|PNPM_HOME)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    GOPATH|GOROOT|GOPROXY|GO111MODULE)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    RUSTUP_DIST_SERVER|RUSTUP_UPDATE_ROOT)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    PUB_HOSTED_URL|FLUTTER_STORAGE_BASE_URL)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    ANDROID_HOME|ANDROID_SDK_ROOT)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    SDKMAN_DIR)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    HOMEBREW_BREW_GIT_REMOTE)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                esac
            fi
        done < "$ZSH_CONFIG_DIR/env/development.zsh"
        
        # 清理备份文件
        rm -f "$SCRIPT_DIR/local/environment.env.bak"
        
        color_green "  环境变量提取完成"
    else
        color_yellow "  跳过: 本地配置文件已存在"
    fi
fi

# 迁移 local.zsh
if [[ -f "$ZSH_CONFIG_DIR/env/local.zsh" ]]; then
    echo
    echo "$(color_blue "迁移 local.zsh...")"
    
    # 备份旧文件
    cp "$ZSH_CONFIG_DIR/env/local.zsh" "$backup_dir/"
    color_green "  备份: $ZSH_CONFIG_DIR/env/local.zsh -> $backup_dir/local.zsh"
    
    # 创建自定义配置区域
    echo
    echo "$(color_yellow "  创建自定义配置区域...")"
    
    # 在environment.env中添加自定义配置
    if [[ -f "$SCRIPT_DIR/local/environment.env" ]]; then
        echo "" >> "$SCRIPT_DIR/local/environment.env"
        echo "# =============================================================================" >> "$SCRIPT_DIR/local/environment.env"
        echo "# 从 local.zsh 迁移的自定义配置" >> "$SCRIPT_DIR/local/environment.env"
        echo "# =============================================================================" >> "$SCRIPT_DIR/local/environment.env"
        echo "" >> "$SCRIPT_DIR/local/environment.env"
        
        # 提取export语句并添加到environment.env
        while IFS= read -r line; do
            if [[ $line =~ ^export[[:space:]]+([^=]+)= ]]; then
                echo "$line" >> "$SCRIPT_DIR/local/environment.env"
                var_name="${BASH_REMATCH[1]}"
                echo "  添加变量: $var_name"
            fi
        done < "$ZSH_CONFIG_DIR/env/local.zsh"
        
        color_green "  自定义配置已添加到 environment.env"
    else
        color_yellow "  跳过: environment.env 不存在，请先运行 init-env.sh"
    fi
fi

# 迁移完成
echo
echo "$(color_cyan "=============================================================================")"
echo "$(color_cyan "迁移完成")"
echo "$(color_cyan "=============================================================================")"
echo

echo "迁移统计:"
echo "  备份文件: $backup_dir/"
echo "  迁移文件: ${#old_files[@]} 个"
echo

echo "$(color_green "下一步操作:")"
echo "1. 检查新创建的配置文件:"
echo "   ${EDITOR:-code} $SCRIPT_DIR/local/environment.env"

echo
echo "2. 根据你的实际环境调整配置值"

echo
echo "3. 重新加载ZSH配置:"
echo "   source ~/.config/zsh/zshrc"

echo
echo "4. 验证配置是否正确:"
echo "   env | grep -E '(GOPATH|ANDROID_HOME|BUN_INSTALL)'"

echo
echo "$(color_blue "注意事项:")"
echo "• 旧配置文件已备份到: $backup_dir/"
echo "• 建议检查新配置文件中的路径和设置"
echo "• 如有问题，可以恢复备份文件"

echo
echo "$(color_green "迁移完成！")"