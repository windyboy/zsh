#!/usr/bin/env zsh
# =============================================================================
# Core ZSH Configuration - 环境核心设置
# 说明：只保留高频、刚需、极简的核心环境配置，注释清晰，命名统一。
# =============================================================================

# 彩色输出工具
core_color_red()   { echo -e "\033[31m$1\033[0m"; }
core_color_green() { echo -e "\033[32m$1\033[0m"; }

# -------------------- 目录/环境变量 --------------------
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$HOME/.cache/zsh}"
export ZSH_DATA_DIR="${ZSH_DATA_DIR:-$HOME/.local/share/zsh}"
export ZSH_MODULES_LOADED=""

# -------------------- 目录初始化 --------------------
core_init_dirs() {
    local dirs=("$ZSH_CACHE_DIR" "$ZSH_DATA_DIR" "$ZSH_CONFIG_DIR/custom" "$ZSH_CONFIG_DIR/completions")
    for dir in "${dirs[@]}"; do
        [[ ! -d "$dir" ]] && mkdir -p "$dir" 2>/dev/null && core_color_green "已创建: $dir"
    done
}
core_init_dirs

# -------------------- 安全/历史/导航 --------------------
setopt NO_CLOBBER RM_STAR_WAIT PIPE_FAIL
setopt HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS
alias rm='rm -i' cp='cp -i' mv='mv -i'
umask 022
setopt APPEND_HISTORY SHARE_HISTORY HIST_SAVE_NO_DUPS HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_VERIFY
export HISTSIZE=50000 SAVEHIST=50000
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT CDABLE_VARS
setopt EXTENDED_GLOB NO_CASE_GLOB NUMERIC_GLOB_SORT
setopt CORRECT CORRECT_ALL
setopt NO_HUP NO_CHECK_JOBS
setopt AUTO_PARAM_KEYS AUTO_PARAM_SLASH COMPLETE_IN_WORD HASH_LIST_ALL
setopt INTERACTIVE_COMMENTS MULTIOS NOTIFY
unsetopt BEEP CASE_GLOB FLOW_CONTROL

# -------------------- 全局别名 --------------------
alias -g ...='../..' ....='../../..' .....='../../../..' ......='../../../../..'
alias -g G='| grep' L='| less' H='| head' T='| tail' S='| sort' U='| uniq' C='| wc -l'

# -------------------- 常用函数 --------------------
# 重新加载配置
reload() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "用法: reload" && return 0
    echo "🔄 正在重新加载ZSH配置..."
    source ~/.zshrc && core_color_green "✅ 配置已重载"
}
# 配置校验
validate() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "用法: validate" && return 0
    local errors=0
    local required_dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    local core_files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/modules/core.zsh")
    for dir in "${required_dirs[@]}"; do [[ ! -d "$dir" ]] && core_color_red "❌ 缺少目录: $dir" && ((errors++)); done
    for file in "${core_files[@]}"; do [[ ! -f "$file" ]] && core_color_red "❌ 缺少文件: $file" && ((errors++)); done
    (( errors == 0 )) && core_color_green "配置校验通过" || core_color_red "配置校验失败: $errors 处错误"
    return $errors
}
# 系统状态
status() {
    echo "📊 状态"
    echo "ZSH版本: $(zsh --version | head -1)"
    echo "配置目录: $ZSH_CONFIG_DIR"
    echo "缓存目录: $ZSH_CACHE_DIR"
    echo "数据目录: $ZSH_DATA_DIR"
    echo "已加载模块: $ZSH_MODULES_LOADED"
}
# 性能检查
perf() {
    local func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
    local alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
    local memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
    echo "函数数: ${func_count:-0}"
    echo "别名数: ${alias_count:-0}"
    [[ -n "$memory_kb" && "$memory_kb" =~ ^[0-9]+$ ]] && echo "内存: $(echo "scale=1; $memory_kb / 1024" | bc 2>/dev/null) MB" || echo "内存: 未知"
    [[ -f "$HISTFILE" ]] && echo "历史: $(wc -l < "$HISTFILE" 2>/dev/null) 行"
    (( func_count < 100 )) && core_color_green "性能: 优秀" || (( func_count < 200 )) && echo "性能: 良好" || core_color_red "性能: 建议优化"
}
# 版本信息
version() {
    echo "📦 ZSH 配置版本 4.2.0 (个人极简)"
    echo "主要特性：极简架构、核心功能、性能优化、个人体验"
    echo "模块：core/aliases/plugins/completion/keybindings/utils"
}

# -------------------- 预留自定义区 --------------------
# 可在 custom/ 目录下添加自定义函数/变量

# 标记模块已加载
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED core" 