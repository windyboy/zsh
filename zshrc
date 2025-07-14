#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration - Modular Architecture
# Version: 2.2 - Performance Enhanced
# =============================================================================

# Add deno completions to search path
if [[ ":$FPATH:" != *":${HOME}/.config/zsh/completions:"* ]]; then 
    export FPATH="${HOME}/.config/zsh/completions:$FPATH"
fi

# Initialize startup time tracking (for new shell starts only)
if [[ -z "$ZSH_STARTUP_TIME_BEGIN" ]]; then
    export ZSH_STARTUP_TIME_BEGIN=$EPOCHREALTIME
fi

# ===== Performance Monitoring Start =====
zmodload zsh/zprof
export ZSHRC_LOAD_START=$EPOCHREALTIME

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
    local module_file="${ZSH_CONFIG_DIR}/modules/${module}.zsh"
    
    if [[ -f "$module_file" ]]; then
        source "$module_file"
        export ZSH_LOADED_MODULES="$ZSH_LOADED_MODULES $module"
        return 0
    else
        echo "⚠️  Module not found: $module_file" >&2
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

# 5. Plugins (Zinit-based plugin management)
load_module "plugins"

# 6. Completion system (with tab completion fix)
load_module "completion"

# 6.1 Ensure default tab completion works (fix for fzf-tab override)
bindkey '^I' complete-word

# 8. Functions
load_module "functions"

# 9. Aliases
load_module "aliases"

# 10. Key bindings
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

# ===== Performance Monitoring End =====
export ZSHRC_LOAD_END=$EPOCHREALTIME

# Calculate timing (only show for new shell starts, not reloads)
if [[ -n "$ZSH_STARTUP_TIME_BEGIN" ]] && [[ -o interactive ]]; then
    # This is a new shell start, calculate full startup time
    export ZSH_STARTUP_TIME_END=$EPOCHREALTIME
    local startup_duration=$((ZSH_STARTUP_TIME_END - ZSH_STARTUP_TIME_BEGIN))
    FULL_STARTUP_TIME=$(printf "%.3f" $startup_duration)
    
    # Performance monitoring output (enhanced)
    if [[ -n "$ZSH_PROF" ]]; then
        echo "📊 Detailed performance report:"
        zprof
    fi
    
    # Use performance module's analysis function
    if (( ${+functions[_analyze_startup_performance]} )); then
        _analyze_startup_performance "$FULL_STARTUP_TIME"
    else
        # Fallback to simple timing display
        if (( startup_duration > 500000 )); then
            echo "⚠️  Zsh startup time: ${FULL_STARTUP_TIME}s (consider optimization)"
        elif [[ -z "$ZSH_QUIET" ]]; then
            echo "⚡ Zsh loaded in ${FULL_STARTUP_TIME}s"
        fi
    fi
    
    # Clear the startup time to prevent showing it again
    unset ZSH_STARTUP_TIME_BEGIN
else
    # This is a reload, only show config load time
    local load_duration=$((ZSHRC_LOAD_END - ZSHRC_LOAD_START))
    LOAD_TIME=$(printf "%.3f" $load_duration)
    
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
[ -s "${HOME}/.bun/_bun" ] && source "${HOME}/.bun/_bun"
# Disable automatic zinit updates for faster startup
export ZINIT_AUTO_UPDATE=0

# =============================================================================
# FINAL TAB COMPLETION ENFORCEMENT
# =============================================================================

# Ensure tab completion works after all modules and plugins are loaded
if [[ -o interactive ]]; then
    # Force tab binding to complete-word
    bindkey '^I' complete-word 2>/dev/null || true
    
    # Ensure menu completion is enabled
    zstyle ':completion:*' menu select 2>/dev/null || true
    
    # Verify tab completion is working
    if ! bindkey | grep -q '\^I.*complete-word'; then
        echo "⚠️  Tab completion binding failed, attempting to fix..."
        bindkey '^I' complete-word
    fi
fi
