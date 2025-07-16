#!/usr/bin/env zsh
# =============================================================================
# Utils Module - Debug and Performance Tools
# Version: 4.0 - Streamlined Utility Functions
# =============================================================================

# =============================================================================
# DEBUG TOOLS
# =============================================================================

# Debug mode
debug() {
    echo "🐛 Debug Mode"
    echo "============="
    echo "ZSH_VERSION: $ZSH_VERSION"
    echo "SHELL: $SHELL"
    echo "PWD: $PWD"
    echo "USER: $USER"
    echo "HOME: $HOME"
    echo "PATH: $PATH"
    echo "FPATH: $FPATH"
    echo "HISTFILE: $HISTFILE"
    echo "HISTSIZE: $HISTSIZE"
    echo "SAVEHIST: $SAVEHIST"
    echo "ZSH_CONFIG_DIR: $ZSH_CONFIG_DIR"
    echo "ZSH_CACHE_DIR: $ZSH_CACHE_DIR"
    echo "ZSH_DATA_DIR: $ZSH_DATA_DIR"
    echo "ZSH_MODULES_LOADED: $ZSH_MODULES_LOADED"
    echo "ZSH_VERBOSE: $ZSH_VERBOSE"
    echo "ZSH_QUIET: $ZSH_QUIET"
}

# Debug configuration
debug_config() {
    echo "🔧 Configuration Debug"
    echo "====================="
    
    # Check core files
    local core_files=(
        "$ZSH_CONFIG_DIR/zshrc"
        "$ZSH_CONFIG_DIR/zshenv"
        "$ZSH_CONFIG_DIR/core.zsh"
        "$ZSH_CONFIG_DIR/plugins.zsh"
        "$ZSH_CONFIG_DIR/completion.zsh"
        "$ZSH_CONFIG_DIR/aliases.zsh"
        "$ZSH_CONFIG_DIR/keybindings.zsh"
        "$ZSH_CONFIG_DIR/utils.zsh"
    )
    
    for file in "${core_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "✅ $file"
        else
            echo "❌ $file"
        fi
    done
    
    # Check directories
    local dirs=(
        "$ZSH_CONFIG_DIR"
        "$ZSH_CACHE_DIR"
        "$ZSH_DATA_DIR"
        "$ZSH_CONFIG_DIR/custom"
        "$ZSH_CONFIG_DIR/completions"
    )
    
    echo ""
    echo "Directories:"
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "✅ $dir"
        else
            echo "❌ $dir"
        fi
    done
}

# Debug functions
debug_functions() {
    echo "🔍 Function Debug"
    echo "================="
    
    local functions=(
        "log"
        "safe_source"
        "load_module"
        "reload"
        "validate"
        "status"
        "errors"
        "perf"
        "debug"
        "debug_config"
        "debug_functions"
        "plugins"
        "check_conflicts"
        "completion_status"
        "rebuild_completion"
        "keybindings"
        "check_keybindings"
        "sysinfo"
        "diskusage"
        "memusage"
    )
    
    for func in "${functions[@]}"; do
        if command -v "$func" >/dev/null 2>&1; then
            echo "✅ $func"
        else
            echo "❌ $func"
        fi
    done
}

# =============================================================================
# PERFORMANCE TOOLS
# =============================================================================

# Load performance module
if [[ -f "$ZSH_CONFIG_DIR/modules/performance.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/performance.zsh"
fi

# Performance dashboard (legacy function for compatibility)
perf_dashboard() {
    show_performance_dashboard
}

# Performance optimization
optimize() {
    echo "🔧 Performance Optimization"
    echo "=========================="
    
    # Optimize completion cache
    echo "• Optimizing completion cache..."
    rebuild_completion
    
    # Optimize history
    echo "• Optimizing history..."
    if [[ -f "$HISTFILE" ]]; then
        # Remove duplicate entries
        local temp_hist=$(mktemp)
        tac "$HISTFILE" | awk '!seen[$0]++' | tac > "$temp_hist"
        mv "$temp_hist" "$HISTFILE"
        
        # Limit history size
        local max_lines=5000
        if [[ $(wc -l < "$HISTFILE") -gt $max_lines ]]; then
            tail -n $max_lines "$HISTFILE" > "${HISTFILE}.tmp" && \
            mv "${HISTFILE}.tmp" "$HISTFILE"
        fi
    fi
    
    # Optimize PATH
    echo "• Optimizing PATH..."
    typeset -U path
    
    local new_path=""
    for dir in $(echo "$PATH" | tr ':' ' '); do
        if [[ -d "$dir" ]]; then
            new_path="${new_path:+$new_path:}$dir"
        fi
    done
    export PATH="$new_path"
    
    # Compile zsh files
    echo "• Compiling zsh files..."
    local files_to_compile=(
        "$ZSH_CONFIG_DIR/zshrc"
        "$ZSH_CONFIG_DIR/core.zsh"
        "$ZSH_CONFIG_DIR/plugins.zsh"
        "$ZSH_CONFIG_DIR/completion.zsh"
        "$ZSH_CONFIG_DIR/aliases.zsh"
        "$ZSH_CONFIG_DIR/keybindings.zsh"
        "$ZSH_CONFIG_DIR/utils.zsh"
    )
    
    for file in "${files_to_compile[@]}"; do
        if [[ -f "$file" ]] && [[ ! -f "${file}.zwc" ]]; then
            zcompile "$file" 2>/dev/null && echo "  Compiled: $file"
        fi
    done
    
    echo "✅ Performance optimization completed"
}

# =============================================================================
# CONFIGURATION TOOLS
# =============================================================================

# Load configuration management module
if [[ -f "$ZSH_CONFIG_DIR/modules/config.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/config.zsh"
fi

# =============================================================================
# SYSTEM TOOLS
# =============================================================================

# System health check
health_check() {
    echo "🏥 System Health Check"
    echo "====================="
    
    local issues=0
    
    # Check core functionality
    echo "Core functionality:"
    if command -v log >/dev/null 2>&1; then
        echo "  ✅ Logging system"
    else
        echo "  ❌ Logging system"
        ((issues++))
    fi
    
    if command -v safe_source >/dev/null 2>&1; then
        echo "  ✅ Safe source"
    else
        echo "  ❌ Safe source"
        ((issues++))
    fi
    
    if command -v load_module >/dev/null 2>&1; then
        echo "  ✅ Module loading"
    else
        echo "  ❌ Module loading"
        ((issues++))
    fi
    
    # Check modules
    echo ""
    echo "Modules:"
    local modules=("core" "plugins" "completion" "aliases" "keybindings" "utils")
    for module in "${modules[@]}"; do
        if [[ " $ZSH_MODULES_LOADED " == *" $module "* ]]; then
            echo "  ✅ $module"
        else
            echo "  ❌ $module"
            ((issues++))
        fi
    done
    
    # Check directories
    echo ""
    echo "Directories:"
    local dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "  ✅ $dir"
        else
            echo "  ❌ $dir"
            ((issues++))
        fi
    done
    
    # Check files
    echo ""
    echo "Files:"
    local files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/core.zsh")
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "  ✅ $file"
        else
            echo "  ❌ $file"
            ((issues++))
        fi
    done
    
    # Summary
    echo ""
    if (( issues == 0 )); then
        echo "✅ System is healthy"
        return 0
    else
        echo "❌ System has $issues issues"
        return 1
    fi
}

# Clean cache
clean_cache() {
    echo "🧹 Cleaning cache..."
    
    # Clean completion cache
    local comp_cache="$ZSH_CACHE_DIR/zcompdump"
    if [[ -f "$comp_cache" ]]; then
        rm "$comp_cache" "${comp_cache}.zwc" 2>/dev/null
        echo "  Cleaned completion cache"
    fi
    
    # Clean log files
    local log_files=(
        "$ZSH_CACHE_DIR/system.log"
        "$ZSH_CACHE_DIR/error.log"
        "$ZSH_CACHE_DIR/performance.log"
        "$ZSH_CACHE_DIR/security.log"
    )
    
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            rm "$log_file"
            echo "  Cleaned: $(basename "$log_file")"
        fi
    done
    
    # Clean compiled files
    local compiled_files=(
        "$ZSH_CONFIG_DIR/core.zsh.zwc"
        "$ZSH_CONFIG_DIR/plugins.zsh.zwc"
        "$ZSH_CONFIG_DIR/completion.zsh.zwc"
        "$ZSH_CONFIG_DIR/aliases.zsh.zwc"
        "$ZSH_CONFIG_DIR/keybindings.zsh.zwc"
        "$ZSH_CONFIG_DIR/utils.zsh.zwc"
    )
    
    for compiled_file in "${compiled_files[@]}"; do
        if [[ -f "$compiled_file" ]]; then
            rm "$compiled_file"
            echo "  Cleaned: $(basename "$compiled_file")"
        fi
    done
    
    echo "✅ Cache cleaned"
}

# =============================================================================
# HELP SYSTEM
# =============================================================================

# Show help
help() {
    echo "📚 ZSH Configuration Help"
    echo "========================"
    echo ""
    echo "Core Commands:"
    echo "  reload     - Reload configuration"
    echo "  validate   - Validate configuration"
    echo "  status     - Show system status"
    echo "  errors     - Show recent errors"
    echo "  perf       - Performance analysis"
    echo ""
    echo "Debug Commands:"
    echo "  debug      - Debug information"
    echo "  debug_config - Debug configuration"
    echo "  debug_functions - Debug functions"
    echo ""
    echo "Performance Commands:"
    echo "  perf_dashboard - Performance dashboard"
    echo "  optimize   - Optimize performance"
    echo ""
    echo "Configuration Commands:"
    echo "  config <file> - Edit configuration"
    echo "  backup_config - Backup configuration"
    echo "  restore_config <dir> - Restore configuration"
    echo ""
    echo "System Commands:"
    echo "  health_check - System health check"
    echo "  clean_cache - Clean cache"
    echo "  sysinfo    - System information"
    echo "  diskusage  - Disk usage"
    echo "  memusage   - Memory usage"
    echo ""
    echo "Module Commands:"
    echo "  plugins    - Plugin status"
    echo "  check_conflicts - Check plugin conflicts"
    echo "  completion_status - Completion status"
    echo "  rebuild_completion - Rebuild completion cache"
    echo "  keybindings - Show key bindings"
    echo "  check_keybindings - Check key binding conflicts"
    echo ""
    echo "For more information, see the documentation."
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Mark utils module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED utils"

log "Utils module initialized" "success" "utils" 