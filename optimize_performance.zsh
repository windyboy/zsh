#!/usr/bin/env zsh
# =============================================================================
# ZSH Configuration Optimizer
# Version: 3.0 - Comprehensive Optimization Suite
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Configuration paths
ZSH_CONFIG_DIR="${HOME}/.config/zsh"
ZSH_CACHE_DIR="${HOME}/.cache/zsh"
ZSH_DATA_DIR="${HOME}/.local/share/zsh"

# Performance thresholds
PERF_THRESHOLD_WARNING=1.0
PERF_THRESHOLD_CRITICAL=2.0

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Print colored output
print_status() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        "info") echo "ℹ️  $message" ;;
        "success") echo "✅ $message" ;;
        "warning") echo "⚠️  $message" ;;
        "error") echo "❌ $message" ;;
        "header") echo "🔧 $message" ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# =============================================================================
# PERFORMANCE ANALYSIS
# =============================================================================

# Analyze current performance
analyze_performance() {
    print_status "header" "Performance Analysis"
    echo "================================"
    
    # Basic metrics
    local func_count=$(declare -F | wc -l)
    local alias_count=$(alias | wc -l)
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    local memory_usage=$(ps -o rss= -p $$ 2>/dev/null | awk '{printf "%.1f MB", $1/1024}' | head -1 | tr -d '\n')
    
    echo "Functions: $func_count"
    echo "Aliases: $alias_count"
    echo "PATH entries: $path_count"
    echo "Memory usage: $memory_usage"
    
    # History analysis
    if [[ -f "$HISTFILE" ]]; then
        local hist_size=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
        echo "History size: $hist_size lines"
        
        if (( hist_size > 10000 )); then
            print_status "warning" "Large history file detected"
        fi
    fi
    
    # Performance score
    local score=100
    (( func_count > 500 )) && ((score -= 10))
    (( path_count > 20 )) && ((score -= 10))
    (( hist_size > 10000 )) && ((score -= 10))
    
    echo "Performance score: $score/100"
    
    if (( score < 80 )); then
        print_status "warning" "Performance optimization recommended"
    else
        print_status "success" "Performance is good"
    fi
}

# =============================================================================
# OPTIMIZATION FUNCTIONS
# =============================================================================

# Optimize completion cache
optimize_completion_cache() {
    print_status "header" "Optimizing Completion Cache"
    
    local comp_cache="$ZSH_CACHE_DIR/zcompdump"
    
    if [[ -f "$comp_cache" ]]; then
        autoload -Uz compinit
        compinit -d "$comp_cache"
        
        if [[ -f "$comp_cache" ]] && [[ ! -f "${comp_cache}.zwc" ]]; then
            zcompile "$comp_cache"
            print_status "success" "Completion cache compiled"
        fi
    else
        print_status "warning" "Completion cache not found"
    fi
}

# Optimize history
optimize_history() {
    print_status "header" "Optimizing History"
    
    if [[ -f "$HISTFILE" ]]; then
        # Remove duplicates
        local temp_hist=$(mktemp)
        tac "$HISTFILE" | awk '!seen[$0]++' | tac > "$temp_hist"
        mv "$temp_hist" "$HISTFILE"
        
        # Limit size
        local max_lines=5000
        if [[ $(wc -l < "$HISTFILE") -gt $max_lines ]]; then
            tail -n $max_lines "$HISTFILE" > "${HISTFILE}.tmp" && \
            mv "${HISTFILE}.tmp" "$HISTFILE"
        fi
        
        print_status "success" "History optimized"
    else
        print_status "warning" "History file not found"
    fi
}

# Optimize PATH
optimize_path() {
    print_status "header" "Optimizing PATH"
    
    # Remove duplicates
    typeset -U path
    
    # Remove non-existent directories
    local new_path=""
    for dir in $(echo "$PATH" | tr ':' ' '); do
        if [[ -d "$dir" ]]; then
            new_path="${new_path:+$new_path:}$dir"
        fi
    done
    export PATH="$new_path"
    
    print_status "success" "PATH optimized"
}

# Compile zsh files
compile_zsh_files() {
    print_status "header" "Compiling ZSH Files"
    
    local files_to_compile=(
        "$ZSH_CONFIG_DIR/zshrc"
        "$ZSH_CONFIG_DIR/zshenv"
        "$ZSH_CONFIG_DIR/modules/core.zsh"
        "$ZSH_CONFIG_DIR/modules/plugins.zsh"
        "$ZSH_CONFIG_DIR/modules/completion.zsh"
        "$ZSH_CONFIG_DIR/modules/functions.zsh"
        "$ZSH_CONFIG_DIR/modules/aliases.zsh"
        "$ZSH_CONFIG_DIR/modules/keybindings.zsh"
        "$ZSH_CONFIG_DIR/themes/prompt.zsh"
    )
    
    local compiled_count=0
    for file in "${files_to_compile[@]}"; do
        if [[ -f "$file" ]] && [[ ! -f "${file}.zwc" ]]; then
            zcompile "$file" 2>/dev/null && ((compiled_count++))
        fi
    done
    
    print_status "success" "Compiled $compiled_count files"
}

# Optimize hooks
optimize_hooks() {
    print_status "header" "Optimizing Hooks"
    
    local hooks=$(add-zsh-hook -L precmd 2>/dev/null)
    local unique_hooks=$(echo "$hooks" | sort | uniq)
    
    if [[ "$hooks" != "$unique_hooks" ]]; then
        add-zsh-hook -D precmd '*'
        echo "$unique_hooks" | while read hook; do
            [[ -n "$hook" ]] && add-zsh-hook precmd "$hook"
        done
        print_status "success" "Hooks optimized"
    else
        print_status "info" "Hooks already optimized"
    fi
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Validate configuration
validate_configuration() {
    print_status "header" "Validating Configuration"
    
    local errors=0
    
    # Check directories
    local required_dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_status "error" "Missing directory: $dir"
            ((errors++))
        fi
    done
    
    # Check files
    local required_files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/zshenv")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_status "error" "Missing file: $file"
            ((errors++))
        fi
    done
    
    # Check security
    local required_options=("NO_CLOBBER" "RM_STAR_WAIT" "PIPE_FAIL")
    for opt in "${required_options[@]}"; do
        if [[ ! -o "$opt" ]]; then
            print_status "error" "Security option not set: $opt"
            ((errors++))
        fi
    done
    
    if (( errors == 0 )); then
        print_status "success" "Configuration validation passed"
        return 0
    else
        print_status "error" "Configuration validation failed ($errors errors)"
        return 1
    fi
}

# =============================================================================
# MAIN OPTIMIZATION FUNCTION
# =============================================================================

# Main optimization function
optimize_zsh() {
    print_status "header" "ZSH Configuration Optimizer"
    echo "====================================="
    
    # Create directories
    mkdir -p "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR"
    
    # Analyze current state
    analyze_performance
    echo ""
    
    # Run optimizations
    optimize_completion_cache
    optimize_history
    optimize_path
    compile_zsh_files
    optimize_hooks
    echo ""
    
    # Validate configuration
    validate_configuration
    echo ""
    
    print_status "success" "Optimization completed"
    echo ""
    print_status "info" "Run 'source ~/.zshrc' to apply changes"
}

# =============================================================================
# QUICK OPTIMIZATION
# =============================================================================

# Quick optimization for common issues
quick_optimize() {
    print_status "header" "Quick Optimization"
    
    # Optimize completion cache
    optimize_completion_cache
    
    # Optimize history
    optimize_history
    
    # Compile files
    compile_zsh_files
    
    print_status "success" "Quick optimization completed"
}

# =============================================================================
# DIAGNOSTIC FUNCTIONS
# =============================================================================

# Show diagnostic information
show_diagnostics() {
    print_status "header" "ZSH Diagnostics"
    echo "=================="
    
    # System information
    echo "ZSH version: $(zsh --version | head -1)"
    echo "OS: $(uname -s) $(uname -r)"
    echo "Architecture: $(uname -m)"
    
    # Configuration paths
    echo ""
    echo "Configuration paths:"
    echo "  Config: $ZSH_CONFIG_DIR"
    echo "  Cache: $ZSH_CACHE_DIR"
    echo "  Data: $ZSH_DATA_DIR"
    
    # Module status
    echo ""
    echo "Module status:"
    echo "  Core: $([[ -f "$ZSH_CONFIG_DIR/modules/core.zsh" ]] && echo "✅" || echo "❌")"
    echo "  Plugins: $([[ -f "$ZSH_CONFIG_DIR/modules/plugins.zsh" ]] && echo "✅" || echo "❌")"
    echo "  Completion: $([[ -f "$ZSH_CONFIG_DIR/modules/completion.zsh" ]] && echo "✅" || echo "❌")"
    echo "  Functions: $([[ -f "$ZSH_CONFIG_DIR/modules/functions.zsh" ]] && echo "✅" || echo "❌")"
    echo "  Aliases: $([[ -f "$ZSH_CONFIG_DIR/modules/aliases.zsh" ]] && echo "✅" || echo "❌")"
    echo "  Keybindings: $([[ -f "$ZSH_CONFIG_DIR/modules/keybindings.zsh" ]] && echo "✅" || echo "❌")"
}

# =============================================================================
# COMMAND LINE INTERFACE
# =============================================================================

# Main function
main() {
    case "${1:-}" in
        "analyze")
            analyze_performance
            ;;
        "optimize")
            optimize_zsh
            ;;
        "quick")
            quick_optimize
            ;;
        "validate")
            validate_configuration
            ;;
        "diagnose")
            show_diagnostics
            ;;
        "help"|"-h"|"--help")
            echo "ZSH Configuration Optimizer"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  analyze    - Analyze current performance"
            echo "  optimize   - Full optimization"
            echo "  quick      - Quick optimization"
            echo "  validate   - Validate configuration"
            echo "  diagnose   - Show diagnostic information"
            echo "  help       - Show this help"
            ;;
        *)
            optimize_zsh
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 