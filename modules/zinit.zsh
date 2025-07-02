#!/usr/bin/env zsh
# =============================================================================
# Zinit Configuration - Fixed Module Loading
# =============================================================================

# Only load zinit if it's not already loaded
if [[ -z "$ZINIT" ]]; then
    # Set up zinit installation directory
    export ZINIT_HOME="${HOME}/.local/share/zinit"
    
    # Install zinit if not present
    if [[ ! -f "$ZINIT_HOME/zinit.git/zinit.zsh" ]]; then
        echo "📦 Installing zinit..."
        mkdir -p "$ZINIT_HOME"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME/zinit.git"
    fi
    
    # Load zinit
source "$ZINIT_HOME/zinit.git/zinit.zsh"

# Fix module loading path - ensure zsh modules are loaded from system path
# This prevents zinit from looking in the wrong directory
if [[ -z "$ZSH_MODULE_PATH" ]]; then
    # Set the correct module path for zsh modules on Linux
    export ZSH_MODULE_PATH="/usr/lib64/zsh/5.9"
    # Alternative paths for different systems
    [[ ! -d "$ZSH_MODULE_PATH" ]] && export ZSH_MODULE_PATH="/usr/lib/zsh/5.9"
    [[ ! -d "$ZSH_MODULE_PATH" ]] && export ZSH_MODULE_PATH="/usr/lib/zsh"
    [[ ! -d "$ZSH_MODULE_PATH" ]] && export ZSH_MODULE_PATH="/usr/local/lib/zsh"
    [[ ! -d "$ZSH_MODULE_PATH" ]] && export ZSH_MODULE_PATH="/opt/homebrew/lib/zsh"
fi

# Set the module path for zsh to find modules correctly
export ZMODULE_PATH="$ZSH_MODULE_PATH/zsh"
# Ensure the system module path is included so plugins like
# fast-syntax-highlighting can load modules such as zsh/termcap
# without specifying the directory explicitly.
if [[ -d "$ZMODULE_PATH" ]]; then
    [[ "${module_path:-}" != *"$ZMODULE_PATH"* ]] && module_path=("$ZMODULE_PATH" $module_path)
fi
fi

# =============================================================================
# Essential Plugins
# =============================================================================

# Ensure zsh modules are loaded from the correct system path
# This is critical to prevent the "Not a directory" errors
if [[ -n "$ZSH_MODULE_PATH" ]]; then
    # Pre-load essential zsh modules from system path
    # Use the full path to the module directory
    zmodload -d "$ZMODULE_PATH" zsh/termcap 2>/dev/null || true
    zmodload -d "$ZMODULE_PATH" zsh/terminfo 2>/dev/null || true
    zmodload -d "$ZMODULE_PATH" zsh/mapfile 2>/dev/null || true
    zmodload -d "$ZMODULE_PATH" zsh/stat 2>/dev/null || true
    zmodload -d "$ZMODULE_PATH" zsh/complete 2>/dev/null || true
    zmodload -d "$ZMODULE_PATH" zsh/computil 2>/dev/null || true
fi

# Syntax highlighting (must be loaded last)
zinit light zdharma-continuum/fast-syntax-highlighting

# Auto suggestions
zinit light zsh-users/zsh-autosuggestions

# FZF tab completion
zinit light Aloxaf/fzf-tab

# =============================================================================
# Plugin Configuration
# =============================================================================

# FZF tab configuration
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath'

# Auto suggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"

# =============================================================================
# Utility Functions
# =============================================================================

# Function to check zinit plugin status
check_zinit_plugins() {
    echo "🔌 Zinit Plugin Status:"
    echo "======================="
    
    local plugins=(
        "fast-syntax-highlighting:Syntax Highlighting"
        "zsh-autosuggestions:Auto Suggestions"
        "fzf-tab:FZF Tab Completion"
    )
    
    for plugin in "${plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        
        if [[ -d "$ZINIT_HOME/plugins" ]] && ls "$ZINIT_HOME/plugins" | grep -q "$name"; then
            echo "✅ $desc"
        else
            echo "❌ $desc (not installed)"
        fi
    done
}

# Function to debug zsh module loading
debug_zsh_modules() {
    echo "🔍 ZSH Module Debug Info:"
    echo "========================="
    echo "ZSH_MODULE_PATH: $ZSH_MODULE_PATH"
    echo "ZMODULE_PATH: $ZMODULE_PATH"
    echo "Available modules in $ZMODULE_PATH:"
    if [[ -d "$ZMODULE_PATH" ]]; then
        ls -la "$ZMODULE_PATH" | grep "\.so$" | head -10
    else
        echo "❌ Module directory not found: $ZMODULE_PATH"
    fi
    
    echo "Loaded modules:"
    zmodload | grep -E "(termcap|terminfo|mapfile|stat|complete|computil)" || echo "No relevant modules loaded"
}

# Export functions
export -f check_zinit_plugins debug_zsh_modules 2>/dev/null || true 