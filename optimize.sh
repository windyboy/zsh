#!/usr/bin/env zsh
# shellcheck shell=bash
# =============================================================================
# Simple Performance Optimizer
# =============================================================================

# Load unified logging system
if [[ -f "$HOME/.config/zsh/modules/logging.zsh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.config/zsh/modules/logging.zsh"
else
    # Fallback logging functions
    log() { echo "ℹ️  $1"; }
    success() { echo "✅ $1"; }
    error() { echo "❌ $1"; }
fi

# Optimize completion cache
optimize_completion() {
    log "Optimizing completion cache..."
    
    local comp_cache="$HOME/.cache/zsh/zcompdump"
    if [[ -f "$comp_cache" ]]; then
        autoload -Uz compinit
        compinit -d "$comp_cache"
        
        if [[ -f "$comp_cache" ]] && [[ ! -f "${comp_cache}.zwc" ]]; then
            zcompile "$comp_cache"
            success "Completion cache compiled"
        fi
    fi
}

# Optimize history
optimize_history() {
    log "Optimizing history..."
    
    if [[ -f "$HISTFILE" ]]; then
        # Remove duplicates
        local temp_hist
        temp_hist=$(mktemp)
        tac "$HISTFILE" | awk '!seen[$0]++' | tac > "$temp_hist"
        mv "$temp_hist" "$HISTFILE"
        
        # Limit size
        local max_lines=5000
        if [[ $(wc -l < "$HISTFILE") -gt $max_lines ]]; then
            tail -n $max_lines "$HISTFILE" > "${HISTFILE}.tmp" && \
            mv "${HISTFILE}.tmp" "$HISTFILE"
        fi
        
        success "History optimized"
    fi
}

# Optimize PATH
optimize_path() {
    log "Optimizing PATH..."

    local -a path_array
    local -A seen
    IFS=':' read -r -a path_array <<< "$PATH"

    local new_path=""
    for dir in "${path_array[@]}"; do
        if [[ -d "$dir" && -z ${seen["$dir"]+1} ]]; then
            seen["$dir"]=1
            new_path="${new_path:+$new_path:}$dir"
        fi
    done

    export PATH="$new_path"

    success "PATH optimized"
}

# Compile zsh files
compile_files() {
    log "Compiling zsh files..."
    
    local files=(
        "$HOME/.config/zsh/zshrc"
        "$HOME/.config/zsh/zshenv"
        "$HOME/.config/zsh/modules/core.zsh"
        "$HOME/.config/zsh/modules/plugins.zsh"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]] && [[ ! -f "${file}.zwc" ]]; then
            zcompile "$file"
            log "Compiled: $file"
        fi
    done
    
    success "Files compiled"
}

# Check performance
check_performance() {
    log "Checking performance..."
    
    # Function count
    local func_count
    func_count=$(declare -F | wc -l)
    log "Functions: $func_count"
    
    # Memory usage
    local memory
    memory=$(ps -o rss= -p $$ | awk '{printf "%.1f MB", $1/1024}')
    log "Memory: $memory"
    
    success "Performance check completed"
}

# Main optimization
main() {
    log "Starting performance optimization..."
    
    optimize_completion
    optimize_history
    optimize_path
    compile_files
    check_performance
    
    success "Optimization completed!"
}

main "$@" 
