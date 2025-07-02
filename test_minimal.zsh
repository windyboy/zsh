#!/usr/bin/env zsh
# Minimal test configuration

echo "=== Before loading any modules ==="
echo "module_path: $module_path"
echo "ZSH_MODULE_PATH: $ZSH_MODULE_PATH"

# Set basic paths
export ZSH_CONFIG_DIR="${HOME}/.config/zsh"
export ZSH_CACHE_DIR="${HOME}/.cache/zsh"
export ZSH_DATA_DIR="${HOME}/.local/share/zsh"

# Create necessary directories
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"
[[ ! -d "$ZSH_DATA_DIR" ]] && mkdir -p "$ZSH_DATA_DIR"

echo "=== After setting paths ==="
echo "module_path: $module_path"

# Load only core module
if [[ -f "${ZSH_CONFIG_DIR}/modules/core.zsh" ]]; then
    echo "=== Loading core module ==="
    source "${ZSH_CONFIG_DIR}/modules/core.zsh"
    echo "module_path after core: $module_path"
fi

# Load zinit module
if [[ -f "${ZSH_CONFIG_DIR}/modules/zinit.zsh" ]]; then
    echo "=== Loading zinit module ==="
    source "${ZSH_CONFIG_DIR}/modules/zinit.zsh"
    echo "module_path after zinit: $module_path"
fi

# Load completion module
if [[ -f "${ZSH_CONFIG_DIR}/modules/completion.zsh" ]]; then
    echo "=== Loading completion module ==="
    source "${ZSH_CONFIG_DIR}/modules/completion.zsh"
    echo "module_path after completion: $module_path"
fi

echo "=== Final state ==="
echo "module_path: $module_path"
echo "ZSH_MODULE_PATH: $ZSH_MODULE_PATH" 