# ZSH 性能优化模块 - 修复版

# 禁用启动检查的环境变量
if [[ -n "$ZSH_DISABLE_STARTUP_CHECK" ]]; then
    return 0
fi

# ============================================================================
# 修复后的启动时间检测
# ============================================================================

check_startup_time() {
    # 如果禁用了检查，直接返回
    [[ -n "$ZSH_DISABLE_STARTUP_CHECK" ]] && return 0
    
    # 使用临时文件存储启动时间
    local time_file="${TMPDIR:-/tmp}/zsh_startup_time_$$"
    
    # 如果是新shell启动，记录开始时间
    if [[ ! -f "$time_file" ]]; then
        echo "$EPOCHREALTIME" > "$time_file" 2>/dev/null
        return 0
    fi
    
    # 读取开始时间并计算持续时间
    local start_time
    if [[ -f "$time_file" ]]; then
        start_time=$(cat "$time_file" 2>/dev/null)
        if [[ -n "$start_time" ]]; then
            local current_time=$EPOCHREALTIME
            # Fix: Use bc for proper floating-point arithmetic with error handling
            local duration
            if command -v bc >/dev/null 2>&1; then
                duration=$(printf "%.3f" $(echo "$current_time - $start_time" | bc -l 2>/dev/null || echo "0"))
            else
                # Fallback to integer arithmetic if bc is not available
                duration=$(printf "%.3f" $((current_time - start_time)))
            fi
            
            # 删除临时文件
            rm -f "$time_file" 2>/dev/null
            
            # 检查时间差是否合理 (只显示小于60秒的结果)
            if (( $(echo "$duration >= 0 && $duration < 60" | bc -l 2>/dev/null) )); then
                if (( $(echo "$duration > 2" | bc -l 2>/dev/null) )); then
                    echo "⚠️  Zsh startup time: ${duration}s (consider optimization)"
                elif (( $(echo "$duration > 1" | bc -l 2>/dev/null) )); then
                    echo "🟡 Zsh startup time: ${duration}s (moderate)"
                else
                    echo "🟢 Zsh startup time: ${duration}s (fast)"
                fi
            fi
        fi
    fi
}

# ============================================================================
# 安全的临时文件创建
# ============================================================================

create_temp_file() {
    local temp_file=""
    local attempts=0
    local max_attempts=5
    
    while (( attempts < max_attempts )); do
        if [[ "$OSTYPE" == darwin* ]]; then
            temp_file=$(mktemp -t "zsh_perf_$(date +%s)_$$" 2>/dev/null)
        else
            temp_file=$(mktemp 2>/dev/null)
        fi
        
        if [[ -n "$temp_file" && -w "$temp_file" ]]; then
            echo "$temp_file"
            return 0
        fi
        
        # 备用方法
        temp_file="/tmp/zsh_perf_$$_$(date +%s)_$attempts"
        if touch "$temp_file" 2>/dev/null && [[ -w "$temp_file" ]]; then
            echo "$temp_file"
            return 0
        fi
        
        ((attempts++))
        sleep 0.1
    done
    
    return 1
}

# ============================================================================
# 简化的性能测试函数
# ============================================================================

quick_test() {
    echo "⚡ Quick startup test..."
    
    local start_time end_time duration
    
    # 使用简单的秒级计时
    start_time=$(date +%s)
    timeout 10s zsh -i -c exit >/dev/null 2>&1
    local exit_code=$?
    end_time=$(date +%s)
    
    if (( exit_code == 124 )); then
        echo "❌ Test timed out (> 10 seconds)"
        return 1
    elif (( exit_code != 0 )); then
        echo "❌ Test failed with exit code: $exit_code"
        return 1
    fi
    
    duration=$((end_time - start_time))
    
    if (( duration < 0 || duration > 60 )); then
        echo "⚠️  Invalid timing result"
        return 1
    fi
    
    printf "Startup time: %d seconds " "$duration"
    
    if (( duration == 0 )); then
        echo "🟢 (Very fast)"
    elif (( duration <= 1 )); then
        echo "🟢 (Fast)"
    elif (( duration <= 3 )); then
        echo "🟡 (Moderate)"
    else
        echo "🔴 (Slow - needs optimization)"
    fi
}

# ============================================================================
# 系统检查
# ============================================================================

check_system_compatibility() {
    echo "🔍 System compatibility check..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "System: $OSTYPE"
    echo "Shell: $SHELL"
    echo "ZSH version: $ZSH_VERSION"
    echo "User: $(whoami)"
    echo "Home: $HOME"
    
    # 检查基本命令
    local commands=("date" "mktemp" "timeout")
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "✅ $cmd available"
        else
            echo "❌ $cmd not found"
        fi
    done
    
    # 检查临时目录
    local tmpdir="${TMPDIR:-/tmp}"
    if [[ -d "$tmpdir" && -w "$tmpdir" ]]; then
        echo "✅ Temp directory: $tmpdir"
    else
        echo "❌ Temp directory issue: $tmpdir"
    fi
}

# ============================================================================
# 诊断和优化
# ============================================================================

diagnose_performance() {
    echo "🔬 Performance diagnosis..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local issues=0
    
    # 检查 PATH
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l | tr -d ' ')
    echo "PATH entries: $path_count"
    if (( path_count > 30 )); then
        echo "⚠️  Too many PATH entries"
        ((issues++))
    fi
    
    # 检查函数数量
    local func_count=$(declare -F | wc -l | tr -d ' ')
    echo "Functions: $func_count"
    if (( func_count > 200 )); then
        echo "⚠️  Many functions loaded"
        ((issues++))
    fi
    
    # 检查别名
    local alias_count=$(alias | wc -l | tr -d ' ')
    echo "Aliases: $alias_count"
    if (( alias_count > 50 )); then
        echo "⚠️  Many aliases"
        ((issues++))
    fi
    
    echo
    if (( issues == 0 )); then
        echo "✅ No major issues detected"
    else
        echo "⚠️  Found $issues potential issues"
    fi
}

# ============================================================================
# 工具函数
# ============================================================================

# 禁用启动检查
disable_startup_check() {
    export ZSH_DISABLE_STARTUP_CHECK=1
    echo "✅ Startup time check disabled"
    echo "💡 To re-enable: unset ZSH_DISABLE_STARTUP_CHECK"
}

# 启用启动检查
enable_startup_check() {
    unset ZSH_DISABLE_STARTUP_CHECK
    echo "✅ Startup time check enabled"
}

# 性能帮助
performance_help() {
    echo "💡 Performance Tools"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "🚀 Commands:"
    echo "   • quick_test                 - Safe startup test"
    echo "   • check_system_compatibility - System check"
    echo "   • diagnose_performance       - Performance analysis"
    echo "   • disable_startup_check      - Disable auto-check"
    echo "   • enable_startup_check       - Enable auto-check"
    echo "   • performance_help           - Show this help"
    echo
    echo "🔧 Emergency:"
    echo "   export ZSH_DISABLE_STARTUP_CHECK=1"
    echo
    echo "💡 If terminal hangs:"
    echo "   1. Press Ctrl+C multiple times"
    echo "   2. Close terminal and reopen"
    echo "   3. Run: disable_startup_check"
}

# ============================================================================
# 安全的启动时间检查
# ============================================================================

# 只在交互式 shell 中运行，且未禁用时
if [[ $- == *i* && -z "$ZSH_DISABLE_STARTUP_CHECK" ]]; then
    # 清理可能存在的旧时间文件
    rm -f "${TMPDIR:-/tmp}/zsh_startup_time_"* 2>/dev/null
    
    # 设置启动时间
    local time_file="${TMPDIR:-/tmp}/zsh_startup_time_$$"
    echo "$EPOCHREALTIME" > "$time_file" 2>/dev/null
    
    # 使用后台进程检查启动时间
    (sleep 0.1; if [[ -f "$time_file" ]]; then check_startup_time; fi) &
fi

# 模块加载完成
if [[ -n "$ZSH_PERFORMANCE_DEBUG" ]]; then
    echo "✅ Performance module loaded (safe mode)"
fi
