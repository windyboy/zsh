# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/windy/.config/zsh/completions:"* ]]; then export FPATH="/Users/windy/.config/zsh/completions:$FPATH"; fi
#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration - Modular Architecture
# Version: 2.2 - Performance Enhanced
# =============================================================================

# Initialize startup time tracking (for new shell starts only)
if [[ -z "$ZSH_STARTUP_TIME_BEGIN" ]]; then
    export ZSH_STARTUP_TIME_BEGIN=$EPOCHREALTIME
fi

# ===== 性能监控开始 =====
zmodload zsh/zprof
ZSHRC_LOAD_START=$EPOCHREALTIME

# Performance monitoring (enhanced)
[[ -n "$ZSH_PROF" ]] && echo "🔍 ZSH Performance profiling enabled"

# =============================================================================
# Configuration Paths
# =============================================================================

export ZSH_CONFIG_DIR="${HOME}/.config/zsh"
export ZSH_CACHE_DIR="${HOME}/.cache/zsh"
export ZSH_DATA_DIR="${HOME}/.local/share/zsh"

# Create necessary directories
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"
[[ ! -d "$ZSH_DATA_DIR" ]] && mkdir -p "$ZSH_DATA_DIR"

# History configuration (enhanced)
export HISTFILE="${ZSH_DATA_DIR}/history"
export HISTSIZE=50000
export SAVEHIST=50000

# =============================================================================
# Load Modules (Order is important!)
# =============================================================================

# 1. Core settings (must be first)
[[ -f "${ZSH_CONFIG_DIR}/modules/core.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/core.zsh"

# 2. Error handling (early for safety)
[[ -f "${ZSH_CONFIG_DIR}/modules/error_handling.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/error_handling.zsh"

# 3. Performance optimizations
[[ -f "${ZSH_CONFIG_DIR}/modules/performance.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/performance.zsh"

# 4. Plugin management
[[ -f "${ZSH_CONFIG_DIR}/modules/plugins.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/plugins.zsh"

# 5. Completion system
[[ -f "${ZSH_CONFIG_DIR}/modules/completion.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/completion.zsh"

# 6. Functions
[[ -f "${ZSH_CONFIG_DIR}/modules/functions.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/functions.zsh"

# 7. Aliases
[[ -f "${ZSH_CONFIG_DIR}/modules/aliases.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/aliases.zsh"

# 8. Key bindings
[[ -f "${ZSH_CONFIG_DIR}/modules/keybindings.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/keybindings.zsh"

# 9. Theme/Prompt
[[ -f "${ZSH_CONFIG_DIR}/themes/prompt.zsh" ]] && source "${ZSH_CONFIG_DIR}/themes/prompt.zsh"

# 10. Local configuration (must be last to override defaults)
[[ -f "${ZSH_CONFIG_DIR}/local.zsh" ]] && source "${ZSH_CONFIG_DIR}/local.zsh"

# 11. Testing framework (development only)
if [[ -n "$ZSH_DEBUG" ]] && [[ -f "${ZSH_CONFIG_DIR}/tests/test_framework.zsh" ]]; then
    source "${ZSH_CONFIG_DIR}/tests/test_framework.zsh"
fi

# =============================================================================
# Final Setup & Performance Monitoring
# =============================================================================

# ===== 性能监控结束 =====
ZSHRC_LOAD_END=$EPOCHREALTIME

# Calculate timing (only show for new shell starts, not reloads)
if [[ -n "$ZSH_STARTUP_TIME_BEGIN" && "$ZSH_STARTUP_TIME_BEGIN" != "$ZSHRC_LOAD_START" ]]; then
    # This is a new shell start, calculate full startup time
    ZSH_STARTUP_TIME_END=$EPOCHREALTIME
    if command -v bc >/dev/null 2>&1; then
        FULL_STARTUP_TIME=$(printf "%.3f" $(echo "$ZSH_STARTUP_TIME_END - $ZSH_STARTUP_TIME_BEGIN" | bc -l 2>/dev/null || echo "0"))
    else
        FULL_STARTUP_TIME=$(printf "%.3f" $((ZSH_STARTUP_TIME_END - ZSH_STARTUP_TIME_BEGIN)))
    fi
    
    # Performance monitoring output (enhanced)
    if [[ -n "$ZSH_PROF" ]]; then
        echo "📊 Detailed performance report:"
        zprof
    fi
    
    # Startup time warning (with proper floating-point comparison)
    if (( $(echo "$FULL_STARTUP_TIME > 0.5" | bc -l) )); then
        echo "⚠️  Zsh startup time: ${FULL_STARTUP_TIME}s (consider optimization)"
    elif [[ -z "$ZSH_QUIET" ]]; then
        echo "⚡ Zsh loaded in ${FULL_STARTUP_TIME}s"
    fi
    
    # Clear the startup time to prevent showing it again
    unset ZSH_STARTUP_TIME_BEGIN
else
    # This is a reload, only show config load time
    if command -v bc >/dev/null 2>&1; then
        LOAD_TIME=$(printf "%.3f" $(echo "$ZSHRC_LOAD_END - $ZSHRC_LOAD_START" | bc -l 2>/dev/null || echo "0"))
    else
        LOAD_TIME=$(printf "%.3f" $((ZSHRC_LOAD_END - ZSHRC_LOAD_START)))
    fi
    
    if [[ -n "$ZSH_PROF" ]]; then
        echo "📊 Detailed performance report:"
        zprof
    fi
fi

# Success message (only in interactive shells)
if [[ -o interactive ]] && [[ -z "$ZSH_QUIET" ]]; then
    echo "✅ ZSH configuration loaded successfully"
fi

# bun completions
[ -s "/Users/windy/.bun/_bun" ] && source "/Users/windy/.bun/_bun"
