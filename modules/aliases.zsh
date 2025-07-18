#!/usr/bin/env zsh
# =============================================================================
# Aliases and Functions Module - 常用别名与高频函数
# 说明：仅保留高频、刚需、易记的命令，所有命名统一小写，注释清晰。
# =============================================================================

# -------------------- 文件/目录操作 --------------------
# 目录跳转
alias ..='cd ..' ...='cd ../..' ....='cd ../../..' ~='cd ~' -- -='cd -'

# 文件操作（安全模式）
alias cp='cp -i' mv='mv -i' rm='rm -i'

# 清屏、磁盘、内存
alias c='clear' df='df -h' du='du -h' top='htop'

# -------------------- ls/eza 统一风格 --------------------
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -la --color=always --group-directories-first --icons'
    alias la='eza -a --color=always --group-directories-first --icons'
else
    alias ls='ls --color=auto' ll='ls -la --color=auto' la='ls -A --color=auto'
fi

# -------------------- Git 快捷 --------------------
alias g='git' ga='git add' gc='git commit -v' gd='git diff' gl='git pull' gp='git push' gst='git status' glog='git log --oneline --decorate --graph'

# -------------------- Node/Python 快捷 --------------------
if command -v npm >/dev/null 2>&1; then
    alias ni='npm install' nr='npm run' ns='npm start' nt='npm test'
fi
if command -v python3 >/dev/null 2>&1; then
    alias py='python3' pip='pip3'
fi

# -------------------- 快速编辑/导航 --------------------
# 快速编辑配置
alias zshrc='${EDITOR:-code} ~/.config/zsh/zshrc'
alias zshenv='${EDITOR:-code} ~/.config/zsh/zshenv'
# 快速跳转
alias projects='cd ~/Projects' downloads='cd ~/Downloads' documents='cd ~/Documents'

# -------------------- 时间 --------------------
alias now='date +"%T"' nowdate='date +"%d-%m-%Y"'

# -------------------- 高频函数 --------------------
# 新建目录并进入
mkcd() {
    [[ $# -eq 0 ]] && echo "用法: mkcd <目录名>" && return 1
    mkdir -p "$1" && cd "$1"
}
# 快速向上跳目录
up() {
    local levels=${1:-1} path=""
    for ((i=0; i<levels; i++)); do path="../$path"; done
    cd "$path"
}
# 安全删除（移入回收站）
trash() {
    [[ $# -eq 0 ]] && echo "用法: trash <文件1> [文件2] ..." && return 1
    local trash_dir="$HOME/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    for file in "$@"; do
        if [[ -e "$file" ]]; then
            local basename=$(basename "$file")
            local timestamp=$(date +%Y%m%d_%H%M%S)
            mv "$file" "$trash_dir/${basename}_${timestamp}"
            echo "已移入回收站: $file"
        else
            echo "未找到: $file"
        fi
    done
}

# 启动本地HTTP服务（合并 serve，优先 function）
unalias serve 2>/dev/null
serve() {
    local port="${1:-8000}" dir="${2:-.}"
    echo "启动HTTP服务: 端口 $port, 目录 $dir"
    python3 -m http.server "$port" --directory "$dir"
}
# 获取外网IP
myip() { curl -s ifconfig.me; }
# 快捷 git commit
function gcm() {
    [[ $# -eq 0 ]] && echo "用法: gcm <信息>" && return 1
    git commit -m "$*"
}

# -------------------- 预留自定义区 --------------------
# 可在 custom/ 目录下添加自定义 alias/function

# 标记模块已加载
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED aliases"
echo "INFO: Aliases module initialized" 