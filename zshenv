#!/usr/bin/env zsh
# =============================================================================
# ZSH Core Environment Variables
# 说明: 系统核心环境变量，不进行模板化管理
# =============================================================================

# =============================================================================
# XDG Base Directory Specification
# 说明: 遵循XDG标准，定义用户配置、缓存、数据的标准位置
# =============================================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# =============================================================================
# ZSH Specific Paths
# 说明: 定义ZSH配置系统的核心路径
# =============================================================================
export ZSH_CONFIG_DIR="${XDG_CONFIG_HOME}/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
export ZSH_DATA_DIR="${XDG_DATA_HOME}/zsh"
export ZDOTDIR="${ZSH_CONFIG_DIR}"

# =============================================================================
# History Configuration
# 说明: 配置ZSH命令历史记录的行为和存储
# =============================================================================
export HISTFILE="${ZSH_DATA_DIR}/history"
export HISTSIZE=50000
export SAVEHIST=50000

# =============================================================================
# Terminal Settings
# 说明: 配置终端显示和颜色支持
# =============================================================================
export TERM=xterm-256color
export COLORTERM=truecolor

# =============================================================================
# Development Tools
# 说明: 配置常用开发工具的默认编辑器
# =============================================================================
export EDITOR="${EDITOR:-code}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"

# =============================================================================
# 用户环境配置加载
# 说明: 加载用户特定的环境变量配置
# =============================================================================
if [[ -f "$ZSH_CONFIG_DIR/env/local/environment.env" ]]; then
    source "$ZSH_CONFIG_DIR/env/local/environment.env"
elif [[ -f "$ZSH_CONFIG_DIR/env/templates/environment.env.template" ]]; then
    echo "⚠️  提示: 未找到用户环境配置文件"
    echo "💡 如需自定义开发工具配置，请运行: $ZSH_CONFIG_DIR/env/init-env.sh"
fi

# =============================================================================
# 向后兼容性支持
# 说明: 保持与旧配置文件的兼容性
# =============================================================================
if [[ -f "$ZSH_CONFIG_DIR/env/development.zsh" ]]; then
    echo "⚠️  注意: 检测到旧的开发环境配置文件"
    echo "💡 建议迁移到新的配置系统: $ZSH_CONFIG_DIR/env/migrate-env.sh"
    source "$ZSH_CONFIG_DIR/env/development.zsh"
fi

if [[ -f "$ZSH_CONFIG_DIR/env/local.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/env/local.zsh"
fi

# =============================================================================
# 配置验证
# 说明: 验证关键环境变量是否正确设置
# =============================================================================
# 简化验证：只检查关键变量是否存在
[[ -z "$ZSH_CONFIG_DIR" ]] && echo "⚠️  警告: ZSH_CONFIG_DIR 未设置"
[[ -z "$ZSH_CACHE_DIR" ]] && echo "⚠️  警告: ZSH_CACHE_DIR 未设置"
[[ -z "$ZSH_DATA_DIR" ]] && echo "⚠️  警告: ZSH_DATA_DIR 未设置"

# =============================================================================
# 文件结束标记
# 说明: 此文件负责设置核心环境变量
# ============================================================================= 