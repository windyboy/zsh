#!/usr/bin/env zsh
# =============================================================================
# Keybindings Module - 快捷键绑定
# 说明：只保留高频、刚需、极简的按键绑定，注释清晰，命名统一。
# =============================================================================

# 彩色输出工具
kb_color_red()   { echo -e "\033[31m$1\033[0m"; }
kb_color_green() { echo -e "\033[32m$1\033[0m"; }

# -------------------- 基础编辑/导航 --------------------
bindkey -e
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^B' backward-char
bindkey '^F' forward-char
bindkey '^D' delete-char
bindkey '^H' backward-delete-char
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^Y' yank
bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[d' kill-word
bindkey '^[^?' backward-kill-word
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^I' complete-word
bindkey '^[[Z' reverse-menu-complete
bindkey '^T' transpose-chars
bindkey '^Z' undo
bindkey '^[z' redo

# -------------------- 自定义函数绑定 --------------------
# 智能cd
_smart_cd() {
    if [[ $# -eq 0 ]]; then cd ~
    elif [[ -d "$1" ]]; then cd "$1"
    else local dir=$(find . -type d -name "*$1*" 2>/dev/null | head -1)
        [[ -n "$dir" ]] && cd "$dir" || kb_color_red "未找到: $1"
    fi
}
# 快速编辑
_quick_edit() {
    local file="$1"
    [[ -z "$file" ]] && kb_color_red "用法: _quick_edit <文件>" && return 1
    [[ -f "$file" ]] && ${EDITOR:-code} "$file" || kb_color_red "未找到: $file"
}
bindkey -s '^[e' '_quick_edit\n'
bindkey -s '^[d' '_smart_cd\n'

# -------------------- 插件相关绑定 --------------------
# FZF widgets - 使用安全的方式绑定以避免zsh-syntax-highlighting警告
if command -v fzf >/dev/null 2>&1; then
    # 确保FZF widget被正确注册，避免zsh-syntax-highlighting警告
    autoload -Uz fzf-file-widget fzf-history-widget fzf-cd-widget 2>/dev/null || true
    zle -N fzf-file-widget 2>/dev/null || true
    zle -N fzf-history-widget 2>/dev/null || true
    zle -N fzf-cd-widget 2>/dev/null || true
    
    # 绑定FZF widget
    bindkey '^[f' fzf-file-widget 2>/dev/null || true
    bindkey '^[r' fzf-history-widget 2>/dev/null || true
    bindkey '^[d' fzf-cd-widget 2>/dev/null || true
fi
if (( ${+_comps[zsh-autosuggestions]} )); then
    bindkey '^[;' autosuggest-accept 2>/dev/null || true
    bindkey '^[,' autosuggest-execute 2>/dev/null || true
    bindkey '^[/' autosuggest-toggle 2>/dev/null || true
fi
if (( ${+_comps[zsh-history-substring-search]} )); then
    bindkey '^[[A' history-substring-search-up 2>/dev/null || true
    bindkey '^[[B' history-substring-search-down 2>/dev/null || true
    bindkey '^P' history-substring-search-up 2>/dev/null || true
    bindkey '^N' history-substring-search-down 2>/dev/null || true
fi

# -------------------- 系统平台适配 --------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    bindkey '^[^[[D' backward-word 2>/dev/null || true
    bindkey '^[^[[C' forward-word 2>/dev/null || true
    bindkey '^[^?' backward-kill-word 2>/dev/null || true
fi
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    bindkey '^[[H' beginning-of-line 2>/dev/null || true
    bindkey '^[[F' end-of-line 2>/dev/null || true
    bindkey '^[[3~' delete-char 2>/dev/null || true
fi

# -------------------- 常用函数 --------------------
list_bindings() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "用法: list_bindings" && return 0
    echo "⌨️  常用快捷键："
    echo "Ctrl+A/E: 行首/行尾  Ctrl+B/F: 左/右移  Ctrl+D/H: 删除/后退删"
    echo "Ctrl+K/U: 删除到行尾/行首  Ctrl+W: 删除词  Ctrl+Y: 粘贴"
    echo "Alt+B/F/D: 词左/右/删  Ctrl+R/S: 历史搜索  Ctrl+P/N: 上/下历史"
    echo "Tab/Shift+Tab: 补全/反向补全  Ctrl+T: 交换字符  Ctrl+Z: 撤销"
}
test_bindings() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "用法: test_bindings" && return 0
    local errors=0
    local test_bindings=("beginning-of-line:^A" "end-of-line:^E" "backward-char:^B" "forward-char:^F")
    for binding in "${test_bindings[@]}"; do
        local func="${binding%%:*}"
        local key="${binding##*:}"
        if bindkey | grep -q "$key.*$func"; then
            kb_color_green "✅ $func ($key)"
        else
            kb_color_red "❌ $func ($key)"
            ((errors++))
        fi
    done
    (( errors == 0 )) && kb_color_green "全部绑定正常" || kb_color_red "$errors 项绑定异常"
    return $errors
}

# -------------------- 预留自定义区 --------------------
# 可在 custom/ 目录下添加自定义按键绑定

# 标记模块已加载
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED keybindings"
echo "INFO: Keybindings module initialized" 