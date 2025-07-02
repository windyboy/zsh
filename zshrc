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

# Initialize module tracking
export ZSH_LOADED_MODULES=""

# Module loading helper
load_module() {
    local module="$1"
    local module_path="${ZSH_CONFIG_DIR}/modules/${module}.zsh"
    
    if [[ -f "$module_path" ]]; then
        source "$module_path"
        export ZSH_LOADED_MODULES="$ZSH_LOADED_MODULES $module"
        return 0
    else
        echo "⚠️  Module not found: $module_path" >&2
        return 1
    fi
}

# 1. Core settings (must be first)
load_module "core"

# 2. Error handling (early for safety)
load_module "error_handling"

# 3. Security (early for protection)
load_module "security"

# 4. Performance optimizations
load_module "performance"

# 5. Plugin management (zinit-based)
load_module "zinit"

# 6. Completion system
load_module "completion"

# 7. Functions
load_module "functions"

# 8. Aliases
load_module "aliases"

# 9. Key bindings
load_module "keybindings"

# 10. Theme/Prompt
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
    echo "📊 Loaded modules: $ZSH_LOADED_MODULES"
    echo "🔒 Security: $(validate_security_config >/dev/null 2>&1 && echo "Enabled" || echo "Issues")"
    echo "⚡ Performance: $(zsh_perf_analyze >/dev/null 2>&1 && echo "Optimized" || echo "Needs attention")"
fi

# bun completions
[ -s "/Users/windy/.bun/_bun" ] && source "/Users/windy/.bun/_bun"
