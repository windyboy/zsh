#!/usr/bin/env zsh
# =============================================================================
# Main ZSH Configuration - Simplified Modular Loader
# =============================================================================

# 设置ZSH配置根目录（兼容直接调用）
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

# 加载核心模块（顺序不可变）
for mod in core plugins completion aliases keybindings utils; do
    modfile="$ZSH_CONFIG_DIR/modules/${mod}.zsh"
    if [[ -f "$modfile" ]]; then
        source "$modfile"
    else
        echo "[zshrc] Warning: module not found: $modfile" >&2
    fi
done

# 加载辅助模块（可选）
for mod in logging performance tools config errors help; do
    modfile="$ZSH_CONFIG_DIR/modules/${mod}.zsh"
    if [[ -f "$modfile" ]]; then
        source "$modfile"
    fi
done

# 加载主题配置
if [[ -f "$ZSH_CONFIG_DIR/themes/prompt.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/themes/prompt.zsh"
fi

# 加载用户自定义扩展（可选）
if [[ -d "$ZSH_CONFIG_DIR/modules/custom" ]]; then
    for custom in "$ZSH_CONFIG_DIR/modules/custom"/*.zsh(N); do
        [[ -f "$custom" ]] && source "$custom"
    done
fi

# 加载本地个性化配置（可选）
if [[ -f "$ZSH_CONFIG_DIR/local.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/local.zsh"
fi

# 结束提示
log "zshrc loaded all modules and custom configs" "success" "zshrc"
