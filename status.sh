#!/usr/bin/env zsh
# =============================================================================
# Simple System Status Checker
# =============================================================================

# Simple logging
log() { echo "ℹ️  $1"; }
success() { echo "✅ $1"; }
error() { echo "❌ $1"; }
warning() { echo "⚠️  $1"; }

# Check core system
check_core() {
    log "Checking core system..."
    
    if command -v zsh >/dev/null 2>&1; then
        success "ZSH: $(zsh --version | head -1)"
    else
        error "ZSH not found"
    fi
    
    if [[ -f "$HOME/.zshrc" ]]; then
        success "zshrc: found"
    else
        error "zshrc: missing"
    fi
    
    if [[ -f "$HOME/.zshenv" ]]; then
        success "zshenv: found"
    else
        error "zshenv: missing"
    fi
}

# Check modules
check_modules() {
    log "Checking modules..."
    
    local modules=(
        "core.zsh"
        "plugins.zsh"
        "completion.zsh"
        "aliases.zsh"
        "functions.zsh"
        "keybindings.zsh"
        "performance.zsh"
    )
    
    local found=0
    for module in "${modules[@]}"; do
        if [[ -f "$HOME/.config/zsh/modules/$module" ]]; then
            success "Module: $module"
            ((found++))
        else
            error "Module: $module (missing)"
        fi
    done
    
    log "Modules: $found/${#modules[@]} found"
}

# Check performance
check_performance() {
    log "Checking performance..."
    
    # Function count
    local func_count=$(declare -F | wc -l)
    log "Functions: $func_count"
    
    # Alias count
    local alias_count=$(alias | wc -l)
    log "Aliases: $alias_count"
    
    # PATH entries
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    log "PATH entries: $path_count"
    
    # History size
    if [[ -f "$HISTFILE" ]]; then
        local hist_size=$(wc -l < "$HISTFILE")
        log "History: $hist_size lines"
    fi
}

# Check plugins
check_plugins() {
    log "Checking plugins..."
    
    if command -v zinit >/dev/null 2>&1; then
        success "zinit: installed"
    else
        warning "zinit: not found"
    fi
    
    if command -v fzf >/dev/null 2>&1; then
        success "fzf: installed"
    else
        warning "fzf: not found"
    fi
    
    if command -v oh-my-posh >/dev/null 2>&1; then
        success "oh-my-posh: installed"
    else
        warning "oh-my-posh: not found"
    fi
}

# Main status check
main() {
    log "System Status Check"
    echo "=================="
    
    check_core
    check_modules
    check_performance
    check_plugins
    
    success "Status check completed!"
}

main "$@" 