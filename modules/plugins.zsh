#!/usr/bin/env zsh
# =============================================================================
# Plugins Module - 插件管理与增强
# 说明：只保留高频、刚需插件，注释清晰，命名统一。
# =============================================================================

# 彩色输出工具
plugins_color_red()   { echo -e "\033[31m$1\033[0m"; }
plugins_color_green() { echo -e "\033[32m$1\033[0m"; }

# -------------------- zinit 安装与加载 --------------------
if [[ -z "$ZINIT" ]]; then
    local ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"
    local ZINIT_BIN="${ZINIT_HOME}/zinit.git"
    [[ ! -f "$ZINIT_BIN/zinit.zsh" ]] && echo "📦 安装zinit..." && mkdir -p "$ZINIT_HOME" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_BIN"
    source "$ZINIT_BIN/zinit.zsh" 2>/dev/null
    ZINIT[MUTE_WARNINGS]=1 2>/dev/null || true
    ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1 2>/dev/null || true
    ZINIT[COMPINIT_OPTS]="-C" 2>/dev/null || true
    ZINIT[NO_ALIASES]=1 2>/dev/null || true
fi

# -------------------- 必备插件（高频） --------------------
if [[ -o interactive ]]; then
    zinit ice wait"0" lucid
    zinit light zdharma-continuum/fast-syntax-highlighting 2>/dev/null || true
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-autosuggestions 2>/dev/null || true
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-completions 2>/dev/null || true
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/history/history.plugin.zsh
fi

# -------------------- 可选增强插件 --------------------
if command -v fzf >/dev/null 2>&1; then
    zinit ice wait"0" lucid
    zinit light Aloxaf/fzf-tab 2>/dev/null || true
fi
if ! bindkey | grep -q '\^\[\[A.*history-substring-search-up'; then
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-history-substring-search 2>/dev/null || true
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
if command -v eza >/dev/null 2>&1; then
    alias lt='eza -T --icons --group-directories-first'
fi

# -------------------- 插件配置 --------------------
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
if (( ${+_comps[fzf-tab]} )); then
    zstyle ':fzf-tab:complete:*' fzf-flags --preview-window=right:60%:wrap --timeout=3
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' continuous-trigger 'space'
    zstyle ':fzf-tab:*' accept-line 'ctrl-space'
fi

# -------------------- 常用函数 --------------------
plugins() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "用法: plugins" && return 0
    echo "🔌 插件状态："
    
    # 检测zinit插件
    local zinit_plugins=(
        "fast-syntax-highlighting:Syntax Highlighting"
        "zsh-autosuggestions:Auto Suggestions"
        "zsh-completions:Enhanced Completions"
        "fzf-tab:FZF Tab Completion"
    )
    
    # 检测工具插件
    local tool_plugins=(
        "fzf:Fuzzy Finder"
        "zoxide:Smart Navigation"
        "eza:Enhanced ls"
    )
    
    # 检测内置插件
    local builtin_plugins=(
        "git:Git Integration"
        "history:History Management"
    )
    
    # 检查zinit插件
    for plugin in "${zinit_plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        if [[ -n "$ZINIT" ]] && [[ -d "$ZINIT_HOME/plugins" ]]; then
            plugins_color_green "✅ $name - $desc"
        else
            plugins_color_red "❌ $name - $desc"
        fi
    done
    
    # 检查工具插件
    for plugin in "${tool_plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        if command -v "$name" >/dev/null 2>&1; then
            plugins_color_green "✅ $name - $desc"
        else
            plugins_color_red "❌ $name - $desc"
        fi
    done
    
    # 检查内置插件
    for plugin in "${builtin_plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        plugins_color_green "✅ $name - $desc"
    done
}

# -------------------- 预留自定义区 --------------------
# 可在 custom/ 目录下添加自定义插件配置

# 标记模块已加载
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED plugins"
echo "INFO: Plugins module initialized" 