#!/usr/bin/env zsh
# =============================================================================
# Utils Module - 常用实用函数（极简高频）
# 说明：仅保留高频、刚需、易记的工具函数，命名统一小写，注释清晰。
# =============================================================================

# 彩色输出工具
color_red()   { echo -e "\033[31m$1\033[0m"; }
color_green() { echo -e "\033[32m$1\033[0m"; }

# -------------------- 文件/目录操作 --------------------
# 备份文件
backup() {
    [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]] && echo "用法: backup <文件>" && return 1
    local file="$1"
    [[ ! -f "$file" ]] && color_red "未找到: $file" && return 1
    cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
    color_green "已备份: ${file}.backup.$(date +%Y%m%d_%H%M%S)"
}
# 查找文件/目录
ff() { [[ $# -eq 0 ]] && echo "用法: ff <模式>" && return 1; find . -name "*$1*" -type f 2>/dev/null; }
fd() { [[ $# -eq 0 ]] && echo "用法: fd <模式>" && return 1; find . -name "*$1*" -type d 2>/dev/null; }
# 上下文查找
grepc() { [[ $# -eq 0 ]] && echo "用法: grepc <模式> [上下文行数]" && return 1; grep -r -n -C "${2:-3}" "$1" . 2>/dev/null; }

# -------------------- 系统信息 --------------------
sysinfo() {
    echo "🖥️  系统信息: $(uname -s) $(uname -r) | 架构: $(uname -m) | 主机: $(hostname) | 用户: $USER | Shell: $SHELL | 终端: $TERM"
    [[ -n "$SSH_CLIENT" ]] && echo "SSH: $SSH_CLIENT"
}
diskusage() { df -h | grep -E '^/dev/' | awk '{print $1, $2, $3, $4, $5, $6}'; }
memusage() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat | perl -ne '/page size of (\\d+)/ and $size=$1; /Pages free: (\\d+)/ and printf "Free: %.1f MB\\n", $1 * $size / 1048576'
        top -l 1 -s 0 | grep PhysMem
    else
        free -h
    fi
}
network() {
    ping -c 1 8.8.8.8 >/dev/null 2>&1 && color_green "Internet: 已连接" || color_red "Internet: 未连接"
    [[ -n "$SSH_CLIENT" ]] && color_green "SSH: $SSH_CLIENT" || color_red "SSH: 未连接"
}

# -------------------- Git/开发 --------------------
gstatus() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { color_red "非git仓库"; return 1; }
    git status --short; echo; git log --oneline -5
}
newproject() {
    [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]] && echo "用法: newproject <名称> [类型]" && return 1
    local name="$1" type="${2:-basic}"
    mkdir -p "$name" && cd "$name"
    case "$type" in
        node|npm) npm init -y; echo "Node.js项目: $name" ;;
        python) echo "# $name" > README.md; echo "Python项目: $name" ;;
        git) git init; echo "# $name" > README.md; echo "Git仓库: $name" ;;
        *) echo "# $name" > README.md; echo "项目: $name" ;;
    esac
}

# -------------------- 文本处理 --------------------
lcount() { [[ $# -eq 0 ]] && echo "用法: lcount <文件...>" && return 1; for f in "$@"; do [[ -f "$f" ]] && echo "$f: $(wc -l < "$f") 行" || color_red "$f: 未找到"; done; }
rmempty() { [[ $# -eq 0 ]] && echo "用法: rmempty <文件>" && return 1; sed -i '/^[[:space:]]*$/d' "$1" && color_green "已移除空行: $1"; }
tolower() { [[ $# -eq 0 ]] && echo "用法: tolower <文件>" && return 1; tr '[:upper:]' '[:lower:]' < "$1" > "${1}.tmp" && mv "${1}.tmp" "$1" && color_green "已转小写: $1"; }

# -------------------- 进程/网络 --------------------
psfind() { [[ $# -eq 0 ]] && echo "用法: psfind <进程名>" && return 1; ps aux | grep -i "$1" | grep -v grep; }
pkill() { [[ $# -eq 0 ]] && echo "用法: pkill <进程名>" && return 1; ps aux | grep -i "$1" | grep -v grep | awk '{print $2}' | xargs kill -9; }
monitor() { top -l 1 -s 0 | grep "CPU usage" 2>/dev/null || top -b -n1 | head -20; }
myip() { curl -s ifconfig.me 2>/dev/null || color_red "无法获取外网IP"; }
portcheck() { [[ $# -eq 0 ]] && echo "用法: portcheck <端口>" && return 1; nc -z localhost "$1" && color_green "端口$1: 开放" || color_red "端口$1: 关闭"; }
download() { [[ $# -eq 0 ]] && echo "用法: download <url>" && return 1; command -v wget >/dev/null 2>&1 && wget --progress=bar "$1" || curl -O "$1"; }

# -------------------- 时间/归档 --------------------
timestamp() { date +"%Y-%m-%d %H:%M:%S"; }
countdown() { [[ $# -eq 0 ]] && echo "用法: countdown <秒数>" && return 1; local s=$1; while ((s>0)); do printf "\r倒计时: %02d:%02d" $((s/60)) $((s%60)); sleep 1; ((s--)); done; echo -e "\n时间到!"; }
archive() { [[ $# -lt 2 ]] && echo "用法: archive <名称> <文件...>" && return 1; local name="$1"; shift; tar -czf "${name}.tar.gz" "$@" && color_green "已归档: ${name}.tar.gz"; }


# -------------------- 预留自定义区 --------------------
# 可在 custom/ 目录下添加自定义函数

# 标记模块已加载
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED utils"
echo "INFO: Utils module initialized" 