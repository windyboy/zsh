#!/usr/bin/env zsh
# =============================================================================
# ZSH配置状态检查脚本
# 版本: 4.2
# =============================================================================

# 加载配置
source "$HOME/.config/zsh/zshrc" 2>/dev/null || {
    echo "❌ 无法加载ZSH配置"
    exit 1
}

echo "🔍 ZSH配置状态检查"
echo "=================="

# 基本信息
echo "📦 版本信息:"
version
echo

# 模块状态
echo "📁 模块状态:"
local total_lines=0
for module in core aliases plugins completion keybindings utils; do
    local file="$ZSH_CONFIG_DIR/modules/${module}.zsh"
    if [[ -f "$file" ]]; then
        local lines=$(wc -l < "$file" 2>/dev/null)
        total_lines=$((total_lines + lines))
        echo "  ✅ $module.zsh ($lines 行)"
    else
        echo "  ❌ $module.zsh (缺失)"
    fi
done
echo "  总计: $total_lines 行"
echo

# 性能状态
echo "⚡ 性能状态:"
perf
echo

# 配置验证
echo "🔧 配置验证:"
validate
echo

# 插件状态
echo "🔌 插件状态:"
plugins
echo

echo "✅ 状态检查完成" 