#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration - Modular Architecture
# Version: 2.1 - Fixed
# =============================================================================

# Performance monitoring (optional)
[[ -n "$ZSH_PROF" ]] && zmodload zsh/zprof

# =============================================================================
# Configuration Paths
# =============================================================================

export ZSH_CONFIG_DIR="${HOME}/.config/zsh"
export ZSH_CACHE_DIR="${HOME}/.cache/zsh"
export ZSH_DATA_DIR="${HOME}/.local/share/zsh"

# Create necessary directories
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"
[[ ! -d "$ZSH_DATA_DIR" ]] && mkdir -p "$ZSH_DATA_DIR"

# History configuration
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
# Final Setup
# =============================================================================

# Performance monitoring output
[[ -n "$ZSH_PROF" ]] && zprof

# Success message (only in interactive shells)
if [[ -o interactive ]] && [[ -z "$ZSH_QUIET" ]]; then
    echo "✅ ZSH configuration loaded successfully"
fi
