#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Settings - Enhanced
# =============================================================================

# Ensure directories exist
[[ ! -d "$HISTFILE:h" ]] && mkdir -p "$HISTFILE:h"

# ===== 历史记录配置 (保留您的设置并增强) =====
# History options (您现有的设置)
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# 新增：历史记录优化选项
setopt HIST_EXPIRE_DUPS_FIRST    # 删除重复项时先删除旧的
setopt HIST_VERIFY               # 历史扩展时先显示命令

# ===== 目录导航 (保留您的设置) =====
# Directory options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# 新增：目录导航增强
setopt CDABLE_VARS               # 允许cd到变量

# ===== 全局模式匹配 (保留您的设置) =====
# Globbing options
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT

# ===== 拼写纠正 (保留您的设置) =====
# Correction options
setopt CORRECT
setopt CORRECT_ALL

# ===== 作业控制 (保留您的设置) =====
# Job control options
setopt NO_HUP
setopt NO_CHECK_JOBS

# ===== 其他有用选项 (保留您的设置) =====
# Other useful options
setopt AUTO_PARAM_KEYS
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt HASH_LIST_ALL
setopt INTERACTIVE_COMMENTS

# ===== 禁用选项 (保留您的设置) =====
# Disable annoying options
unsetopt BEEP
unsetopt CASE_GLOB
unsetopt FLOW_CONTROL

# ===== 新增：错误处理和安全选项 =====
# 基础错误处理
setopt PIPE_FAIL                 # 管道中任何命令失败都返回非零状态
# setopt ERR_EXIT                # 脚本遇到错误时退出（仅用于脚本，交互式shell中不启用）
# setopt NO_UNSET                # 使用未定义变量时报错（可能影响某些插件）

# 安全选项
setopt NO_CLOBBER                # 防止重定向覆盖现有文件 (使用 >| 强制覆盖)
setopt RM_STAR_WAIT              # rm * 时等待10秒确认

# 新增：其他实用选项
setopt MULTIOS                   # 允许多重重定向
setopt NOTIFY                    # 立即报告后台作业状态变化

# ===== 新增：全局别名 =====
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

# 管道相关的全局别名
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sort'
alias -g U='| uniq'
alias -g C='| wc -l'

# ===== 新增：错误恢复函数 =====
recover_from_error() {
    echo "❌ Error occurred in zsh configuration"
    echo "🔧 Try: source ~/.zshrc to reload configuration"
    echo "🆘 Or: zsh -f to start with minimal configuration"
    echo "📋 Or: zsh-check to validate configuration"
}

# ===== 新增：核心配置验证 =====
validate_core_config() {
    local errors=0
    
    # 检查历史文件目录
    if [[ ! -d "$HISTFILE:h" ]]; then
        echo "❌ History directory missing: $HISTFILE:h"
        ((errors++))
    fi
    
    # 检查关键选项
    local required_options=(
        "EXTENDED_HISTORY"
        "SHARE_HISTORY" 
        "AUTO_CD"
        "EXTENDED_GLOB"
    )
    
    for opt in "${required_options[@]}"; do
        if [[ ! -o "$opt" ]]; then
            echo "❌ Required option not set: $opt"
            ((errors++))
        fi
    done
    
    return $errors
}
