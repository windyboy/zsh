# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/windy/.config/zsh/completions:"* ]]; then export FPATH="/Users/windy/.config/zsh/completions:$FPATH"; fi
#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration - Modular Architecture
# Version: 2.2 - Performance Enhanced
# =============================================================================

# Initialize startup time tracking
export ZSH_STARTUP_TIME=$EPOCHREALTIME

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

# 2. Performance optimizations
[[ -f "${ZSH_CONFIG_DIR}/modules/performance.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/performance.zsh"

# 3. Plugin management
[[ -f "${ZSH_CONFIG_DIR}/modules/plugins.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/plugins.zsh"

# 4. Completion system
[[ -f "${ZSH_CONFIG_DIR}/modules/completion.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/completion.zsh"

# 5. Functions
[[ -f "${ZSH_CONFIG_DIR}/modules/functions.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/functions.zsh"

# 6. Aliases
[[ -f "${ZSH_CONFIG_DIR}/modules/aliases.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/aliases.zsh"

# 7. Key bindings
[[ -f "${ZSH_CONFIG_DIR}/modules/keybindings.zsh" ]] && source "${ZSH_CONFIG_DIR}/modules/keybindings.zsh"

# 8. Theme/Prompt
[[ -f "${ZSH_CONFIG_DIR}/themes/prompt.zsh" ]] && source "${ZSH_CONFIG_DIR}/themes/prompt.zsh"

# 9. Local configuration (must be last to override defaults)
[[ -f "${ZSH_CONFIG_DIR}/local.zsh" ]] && source "${ZSH_CONFIG_DIR}/local.zsh"

# =============================================================================
# Final Setup & Performance Monitoring
# =============================================================================

# ===== 性能监控结束 =====
ZSHRC_LOAD_END=$EPOCHREALTIME
# Fix: Use bc for proper floating-point arithmetic with error handling
if command -v bc >/dev/null 2>&1; then
    LOAD_TIME=$(printf "%.3f" $(echo "$ZSHRC_LOAD_END - $ZSHRC_LOAD_START" | bc -l 2>/dev/null || echo "0"))
else
    # Fallback to integer arithmetic if bc is not available
    LOAD_TIME=$(printf "%.3f" $((ZSHRC_LOAD_END - ZSHRC_LOAD_START)))
fi

# Performance monitoring output (enhanced)
if [[ -n "$ZSH_PROF" ]]; then
    echo "📊 Detailed performance report:"
    zprof
fi

# Startup time warning (with proper floating-point comparison)
if (( $(echo "$LOAD_TIME > 0.5" | bc -l) )); then
    echo "⚠️  Zsh startup time: ${LOAD_TIME}s (consider optimization)"
elif [[ -z "$ZSH_QUIET" ]]; then
    echo "⚡ Zsh loaded in ${LOAD_TIME}s"
fi

# Success message (only in interactive shells)
if [[ -o interactive ]] && [[ -z "$ZSH_QUIET" ]]; then
    echo "✅ ZSH configuration loaded successfully"
fi

# bun completions
[ -s "/Users/windy/.bun/_bun" ] && source "/Users/windy/.bun/_bun"
