#!/usr/bin/env zsh
# =============================================================================
# Unified Performance Metrics System
# =============================================================================

# Load logging system
if [[ -f "$ZSH_CONFIG_DIR/modules/logging.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/logging.zsh"
fi

# Performance metrics cache
typeset -A _PERF_CACHE=()

# Calculate and cache performance metrics
calculate_performance_metrics() {
    # Ensure cache is initialized
    if [[ -z "$_PERF_CACHE" ]]; then
        typeset -A _PERF_CACHE=()
    fi
    
    # Function count
    local func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
    _PERF_CACHE[func_count]="${func_count:-0}"
    
    # Alias count
    local alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
    _PERF_CACHE[alias_count]="${alias_count:-0}"
    
    # PATH entries
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l 2>/dev/null)
    _PERF_CACHE[path_count]="${path_count:-0}"
    
    # Memory usage
    local memory_kb=$(ps -o rss= -p $$ 2>/dev/null | tr -d ' ')
    if [[ -n "$memory_kb" && "$memory_kb" =~ ^[0-9]+$ ]]; then
        local memory_mb=$(echo "scale=1; $memory_kb / 1024" | bc 2>/dev/null)
        _PERF_CACHE[memory_mb]="${memory_mb:-0}"
    else
        _PERF_CACHE[memory_mb]="0"
    fi
    
    # History size
    if [[ -f "$HISTFILE" ]]; then
        local hist_size=$(wc -l < "$HISTFILE" 2>/dev/null)
        _PERF_CACHE[hist_size]="${hist_size:-0}"
    else
        _PERF_CACHE[hist_size]="0"
    fi
    
    # Startup time (if available)
    if [[ -n "$ZSH_STARTUP_TIME" ]]; then
        _PERF_CACHE[startup_time]="$ZSH_STARTUP_TIME"
    fi
}

# Get cached metric or calculate if not cached
get_performance_metric() {
    local metric="$1"
    
    if [[ -z "${_PERF_CACHE[$metric]}" ]]; then
        calculate_performance_metrics
    fi
    
    echo "${_PERF_CACHE[$metric]}"
}

# Display performance dashboard
show_performance_dashboard() {
    calculate_performance_metrics
    
    echo "Performance Dashboard"
    echo "===================="
    
    perf_log "Functions" "${_PERF_CACHE[func_count]}" ""
    perf_log "Aliases" "${_PERF_CACHE[alias_count]}" ""
    perf_log "PATH entries" "${_PERF_CACHE[path_count]}" ""
    perf_log "Memory usage" "${_PERF_CACHE[memory_mb]}" " MB"
    perf_log "History size" "${_PERF_CACHE[hist_size]}" " lines"
    
    if [[ -n "${_PERF_CACHE[startup_time]}" ]]; then
        perf_log "Startup time" "${_PERF_CACHE[startup_time]}" " ms"
    fi
    
    # Performance assessment
    echo ""
    echo "Performance Assessment:"
    
    # Function count assessment
    if [[ ${_PERF_CACHE[func_count]} -lt 100 ]]; then
        success "Function count is optimal"
    elif [[ ${_PERF_CACHE[func_count]} -lt 200 ]]; then
        warning "Function count is moderate"
    else
        error "Function count is high - consider optimization"
    fi
    
    # Memory usage assessment
    if [[ ${_PERF_CACHE[memory_mb]} -lt 50 ]]; then
        success "Memory usage is excellent"
    elif [[ ${_PERF_CACHE[memory_mb]} -lt 100 ]]; then
        warning "Memory usage is acceptable"
    else
        error "Memory usage is high - consider optimization"
    fi
    
    # PATH assessment
    if [[ ${_PERF_CACHE[path_count]} -lt 20 ]]; then
        success "PATH is clean"
    elif [[ ${_PERF_CACHE[path_count]} -lt 50 ]]; then
        warning "PATH has many entries"
    else
        error "PATH is bloated - consider cleanup"
    fi
}

# Quick performance check
quick_perf_check() {
    calculate_performance_metrics
    
    echo "Quick Performance Check:"
    echo "  Functions: ${_PERF_CACHE[func_count]}"
    echo "  Memory: ${_PERF_CACHE[memory_mb]} MB"
    echo "  PATH entries: ${_PERF_CACHE[path_count]}"
}

# Performance optimization suggestions
get_optimization_suggestions() {
    calculate_performance_metrics
    
    local suggestions=()
    
    if [[ ${_PERF_CACHE[func_count]} -gt 150 ]]; then
        suggestions+=("Consider removing unused functions")
    fi
    
    if [[ ${_PERF_CACHE[memory_mb]} -gt 80 ]]; then
        suggestions+=("Consider lazy loading plugins")
    fi
    
    if [[ ${_PERF_CACHE[path_count]} -gt 30 ]]; then
        suggestions+=("Clean up PATH entries")
    fi
    
    if [[ ${#suggestions[@]} -eq 0 ]]; then
        success "No optimization needed"
    else
        warning "Optimization suggestions:"
        for suggestion in "${suggestions[@]}"; do
            echo "  • $suggestion"
        done
    fi
} 