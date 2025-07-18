#!/usr/bin/env zsh
# =============================================================================
# Completion Module - 补全系统配置
# 说明：只保留高频、刚需、极简的补全配置，注释清晰，命名统一。
# =============================================================================

# 彩色输出工具
comp_color_red()   { echo -e "\033[31m$1\033[0m"; }
comp_color_green() { echo -e "\033[32m$1\033[0m"; }

# -------------------- 补全缓存 --------------------
COMPLETION_CACHE_FILE="$ZSH_CACHE_DIR/zcompdump"
autoload -Uz compinit
if [[ ! -f "$COMPLETION_CACHE_FILE" ]] || [[ $(find "$COMPLETION_CACHE_FILE" -mtime +1 2>/dev/null) ]]; then
    compinit -d "$COMPLETION_CACHE_FILE" 2>/dev/null || compinit -C -d "$COMPLETION_CACHE_FILE"
    [[ -f "$COMPLETION_CACHE_FILE" ]] && zcompile "$COMPLETION_CACHE_FILE" 2>/dev/null
else
    compinit -C -d "$COMPLETION_CACHE_FILE"
fi
autoload -Uz _files _cd _ls _cp _mv _rm

# -------------------- 基础补全样式 --------------------
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/completion"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# -------------------- 文件/目录补全 --------------------
zstyle ':completion:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:ls:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:cp:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:mv:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:rm:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'

# -------------------- 进程/SSH补全 --------------------
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost

# -------------------- man 补全 --------------------
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-tab true

# -------------------- 自定义/工具补全 --------------------
if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
    for completion in "$ZSH_CONFIG_DIR/completions"/_*(N); do
        [[ -f "$completion" ]] && source "$completion"
    done
fi
if command -v bun >/dev/null 2>&1; then
    [[ ! -f "$ZSH_CACHE_DIR/_bun" ]] && bun completions > "$ZSH_CACHE_DIR/_bun" 2>/dev/null
    [[ -f "$ZSH_CACHE_DIR/_bun" ]] && source "$ZSH_CACHE_DIR/_bun"
fi
if command -v deno >/dev/null 2>&1; then
    [[ ! -f "$ZSH_CACHE_DIR/_deno" ]] && deno completions zsh > "$ZSH_CACHE_DIR/_deno" 2>/dev/null
    [[ -f "$ZSH_CACHE_DIR/_deno" ]] && source "$ZSH_CACHE_DIR/_deno"
fi
if command -v docker >/dev/null 2>&1; then
    [[ ! -f "$ZSH_CACHE_DIR/_docker" ]] && docker completion zsh > "$ZSH_CACHE_DIR/_docker" 2>/dev/null
    [[ -f "$ZSH_CACHE_DIR/_docker" ]] && source "$ZSH_CACHE_DIR/_docker"
fi

# -------------------- Tab增强 --------------------
bindkey '^I' complete-word 2>/dev/null || true
bindkey '^[[Z' reverse-menu-complete 2>/dev/null || true
zstyle ':completion:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' force-list always
zstyle ':completion:*' insert-tab pending
if (( ${+_comps[fzf-tab]} )); then
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' continuous-trigger 'space'
    zstyle ':fzf-tab:*' accept-line 'ctrl-space'
fi

# -------------------- 常用函数 --------------------
completion_status() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "用法: completion_status" && return 0
    local errors=0
    (( ${+_comps} )) && comp_color_green "✅ 补全系统已初始化" || { comp_color_red "❌ 补全系统未初始化"; ((errors++)); }
    [[ -f "$COMPLETION_CACHE_FILE" ]] && comp_color_green "✅ 补全缓存存在" || { comp_color_red "❌ 补全缓存缺失"; ((errors++)); }
    local completion_functions=("_files" "_cd" "_ls" "_cp" "_mv" "_rm")
    for func in "${completion_functions[@]}"; do
        (( ${+_comps[$func]} )) && comp_color_green "✅ $func 补全可用" || { comp_color_red "❌ $func 补全缺失"; ((errors++)); }
    done
    (( errors == 0 )) && comp_color_green "补全系统正常" || comp_color_red "补全系统有 $errors 处问题"
    return $errors
}
rebuild_completion() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "用法: rebuild_completion" && return 0
    [[ -f "$COMPLETION_CACHE_FILE" ]] && rm "$COMPLETION_CACHE_FILE"
    [[ -f "${COMPLETION_CACHE_FILE}.zwc" ]] && rm "${COMPLETION_CACHE_FILE}.zwc"
    autoload -Uz compinit
    compinit -d "$COMPLETION_CACHE_FILE"
    [[ -f "$COMPLETION_CACHE_FILE" ]] && zcompile "$COMPLETION_CACHE_FILE"
    comp_color_green "✅ 补全缓存已重建"
}

# -------------------- 预留自定义区 --------------------
# 可在 custom/ 目录下添加自定义补全

# 标记模块已加载
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED completion"
echo "INFO: Completion module initialized" 