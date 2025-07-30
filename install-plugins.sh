#!/usr/bin/env bash
# Plugin Installation Automation Script

set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

log() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"

# Plugin definitions
declare -A PLUGINS=(
    ["fast-syntax-highlighting"]="zdharma-continuum/fast-syntax-highlighting"
    ["zsh-autosuggestions"]="zsh-users/zsh-autosuggestions"
    ["zsh-completions"]="zsh-users/zsh-completions"
    ["zsh-history-substring-search"]="zsh-users/zsh-history-substring-search"
    ["zsh-extract"]="le0me55i/zsh-extract"
    ["z"]="rupa/z"
    ["fzf-tab"]="Aloxaf/fzf-tab"
)

install_zinit() {
    log "Installing zinit plugin manager..."
    if [[ -d "$ZINIT_HOME/zinit.git" ]]; then
        success "zinit already installed"
        return 0
    fi
    if git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME/zinit.git" 2>/dev/null; then
        success "zinit installed successfully"
        return 0
    else
        error "Failed to install zinit"
        return 1
    fi
}

install_plugin() {
    local plugin_name="$1"
    local plugin_repo="$2"
    
    if [[ -d "$ZINIT_HOME/plugins/$plugin_name" ]]; then
        success "Plugin already installed: $plugin_name"
        return 0
    fi
    
    log "Installing plugin: $plugin_name"
    local plugin_dir="$ZINIT_HOME/plugins/$plugin_name"
    mkdir -p "$plugin_dir"
    
    if git clone "https://github.com/$plugin_repo.git" "$plugin_dir" 2>/dev/null; then
        success "Plugin installed: $plugin_name"
        return 0
    else
        error "Failed to install plugin: $plugin_name"
        return 1
    fi
}

install_all_plugins() {
    log "Installing all plugins..."
    local installed_count=0
    local total_count=${#PLUGINS[@]}
    
    for plugin_name in "${!PLUGINS[@]}"; do
        if install_plugin "$plugin_name" "${PLUGINS[$plugin_name]}"; then
            ((installed_count++))
        fi
    done
    
    echo
    success "Installed $installed_count/$total_count plugins"
}

health_check() {
    log "Running health check..."
    local errors=0
    
    for plugin_name in "${!PLUGINS[@]}"; do
        local plugin_path="$ZINIT_HOME/plugins/$plugin_name"
        if [[ ! -d "$plugin_path" ]]; then
            error "Plugin not installed: $plugin_name"
            ((errors++))
        else
            success "Plugin healthy: $plugin_name"
        fi
    done
    
    echo
    if [[ $errors -eq 0 ]]; then
        success "All plugins are healthy!"
        return 0
    else
        error "Health check failed: $errors errors"
        return 1
    fi
}

main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                🔌 Plugin Installation Manager               ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    case "${1:-}" in
        "install")
            install_zinit
            install_all_plugins
            ;;
        "health")
            health_check
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo "Commands: install, health, help"
            ;;
        *)
            error "Unknown command: ${1:-}"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
}

main "$@" 