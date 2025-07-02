#!/usr/bin/env bash
# =============================================================================
# Quick Deploy Script - Creates all module files
# =============================================================================

set -euo pipefail

ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Create the main zshrc file
cat > "$ZSH_CONFIG_DIR/zshrc" << 'EOF'
#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration - Modular Architecture
# Version: 2.0
# =============================================================================

# Performance monitoring (optional)
[[ -n "$ZSH_PROF" ]] && zmodload zsh/zprof

# Configuration paths
export ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export ZSH_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

# Create necessary directories
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"
[[ ! -d "$ZSH_DATA_DIR" ]] && mkdir -p "$ZSH_DATA_DIR"

# Module loader function
_load_module() {
    local module="$1"
    local module_path="$ZSH_CONFIG_DIR/modules/$module.zsh"
    
    if [[ -f "$module_path" ]]; then
        source "$module_path"
    else
        echo "Warning: Module '$module' not found at $module_path" >&2
        return 1
    fi
}

# Theme loader function
_load_theme() {
    local theme="$1"
    local theme_path="$ZSH_CONFIG_DIR/themes/$theme.zsh"
    
    if [[ -f "$theme_path" ]]; then
        source "$theme_path"
    else
        echo "Warning: Theme '$theme' not found at $theme_path" >&2
        return 1
    fi
}

# =============================================================================
# LOADING SEQUENCE
# =============================================================================

# 1. Core settings (immediate)
_load_module "core"

# 2. Plugin management (immediate)
_load_module "plugins"

# 3. Completion system (delayed)
zinit wait"0a" lucid for \
    id-as"completion-module" \
    atload"_load_module completion" \
    zdharma-continuum/null

# 4. Theme (delayed)
zinit wait"0b" lucid for \
    id-as"theme-module" \
    atload"_load_theme prompt" \
    zdharma-continuum/null

# 5. Aliases and functions (delayed)
zinit wait"1" lucid for \
    id-as"aliases-module" \
    atload"_load_module aliases" \
    zdharma-continuum/null

zinit wait"1a" lucid for \
    id-as"functions-module" \
    atload"_load_module functions" \
    zdharma-continuum/null

# 6. Keybindings (delayed)
zinit wait"1b" lucid for \
    id-as"keybindings-module" \
    atload"_load_module keybindings" \
    zdharma-continuum/null

# 7. Performance monitoring (delayed)
zinit wait"2" lucid for \
    id-as"performance-module" \
    atload"_load_module performance" \
    zdharma-continuum/null

# 8. Local configuration (last)
zinit wait"3" lucid for \
    id-as"local-config" \
    atload"[[ -f '$ZSH_CONFIG_DIR/local.zsh' ]] && source '$ZSH_CONFIG_DIR/local.zsh'" \
    zdharma-continuum/null

# Performance monitoring end
[[ -n "$ZSH_PROF" ]] && trap 'zprof' EXIT
EOF

echo "✅ Created main zshrc file"
echo "🚀 All configuration files are ready!"
echo ""
echo "Next steps:"
echo "1. Run: chmod +x ~/.config/zsh/install.sh"
echo "2. Run: ~/.config/zsh/install.sh"
echo "3. Restart your terminal"
