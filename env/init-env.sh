#!/usr/bin/env zsh
# =============================================================================
# 环境变量初始化脚本 - Environment Variables Initialization Script
# 说明: 帮助用户创建环境变量配置文件
# 使用方法: ./init-env.sh
# =============================================================================

# 颜色输出函数
color_red()   { echo -e "\033[31m$1\033[0m"; }
color_green() { echo -e "\033[32m$1\033[0m"; }
color_yellow() { echo -e "\033[33m$1\033[0m"; }
color_blue()  { echo -e "\033[34m$1\033[0m"; }
color_cyan()  { echo -e "\033[36m$1\033[0m"; }

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "$(color_cyan "=============================================================================")"
echo "$(color_cyan "环境变量配置初始化工具")"
echo "$(color_cyan "Environment Variables Configuration Initialization Tool")"
echo "$(color_cyan "=============================================================================")"
echo

# 检查模板目录是否存在
if [[ ! -d "$SCRIPT_DIR/templates" ]]; then
    color_red "错误: 模板目录不存在: $SCRIPT_DIR/templates"
    exit 1
fi

# 创建本地配置目录
if [[ ! -d "$SCRIPT_DIR/local" ]]; then
    mkdir -p "$SCRIPT_DIR/local"
    color_green "创建本地配置目录: $SCRIPT_DIR/local"
fi

# 定义模板文件
template_file="environment.env.template"
local_file="environment.env"
template_path="$SCRIPT_DIR/templates/$template_file"
local_path="$SCRIPT_DIR/local/$local_file"

echo "$(color_yellow "开始初始化环境变量配置...")"
echo

echo "$(color_blue "处理: $template_file")"
echo "  描述: 用户环境变量配置"

# 检查模板文件是否存在
if [[ ! -f "$template_path" ]]; then
    color_red "  错误: 模板文件不存在: $template_path"
    exit 1
fi

# 检查本地文件是否已存在
if [[ -f "$local_path" ]]; then
    echo "  状态: $(color_yellow "跳过 (已存在)")"
    echo "  文件: $local_path"
else
    # 复制模板文件到本地配置
    if cp "$template_path" "$local_path"; then
        echo "  状态: $(color_green "创建成功")"
        echo "  文件: $local_path"
    else
        color_red "  错误: 创建文件失败: $local_path"
        exit 1
    fi
fi

echo
echo "$(color_cyan "=============================================================================")"
echo "$(color_cyan "初始化完成")"
echo "$(color_cyan "=============================================================================")"
echo

# 显示下一步操作指南
if [[ ! -f "$local_path" ]]; then
    echo "$(color_green "下一步操作:")"
    echo "1. 编辑新创建的配置文件:"
    echo "   ${EDITOR:-code} $local_path"
    echo
    echo "2. 根据你的实际环境修改配置值"
    echo "3. 重新加载ZSH配置: source ~/.config/zsh/zshrc"
    echo
fi

# 显示使用说明
echo "$(color_blue "使用说明:")"
echo "• 模板文件位于: $SCRIPT_DIR/templates/"
echo "• 本地配置文件位于: $SCRIPT_DIR/local/"
echo "• 不要直接修改模板文件，它们用于版本控制"
echo "• 可以自由修改本地配置文件"
echo "• 查看详细说明: cat $SCRIPT_DIR/README.md"
echo

# 检查是否有配置文件需要编辑
if [[ ! -f "$local_path" ]]; then
    echo "$(color_yellow "提示: 建议立即编辑新创建的配置文件以适配你的环境")"
    echo
    read -k 1 "REPLY?是否现在打开编辑器编辑配置文件? (y/N): "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "打开: $local_path"
        ${EDITOR:-code} "$local_path"
    fi
fi

echo
echo "$(color_green "环境变量配置初始化完成！")" 