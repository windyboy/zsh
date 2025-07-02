#!/usr/bin/env zsh
# =============================================================================
# Performance Monitoring and Optimization
# =============================================================================

# =============================================================================
# PERFORMANCE MONITORING
# =============================================================================

# Enable performance profiling if requested
if [[ -n "$ZSH_PROF" ]]; then
    zmodload zsh/zprof
    
    # Show profile on exit
    _show_profile_on_exit() {
        echo "\n=== ZSH Performance Profile ==="
        zprof | head -20
    }
    
    # Set trap for exit
    trap '_show_profile_on_exit' EXIT
fi

# Startup time measurement
if [[ -n "$ZSH_BENCHMARK" ]]; then
    # Record startup time
    _zsh_startup_time() {
        local start_time="${ZSH_START_TIME:-$EPOCHREALTIME}"
        local end_time="$EPOCHREALTIME"
        local startup_time=$(( end_time - start_time ))
        
        printf "ZSH startup time: %.3f seconds\n" "$startup_time"
    }
    
    # Add to precmd for first prompt
    _benchmark_precmd() {
        _zsh_startup_time
        unset -f _benchmark_precmd
        precmd_functions=(${precmd_functions:#_benchmark_precmd})
    }
    
    precmd_functions+=(_benchmark_precmd)
fi

# =============================================================================
# PERFORMANCE UTILITIES
# =============================================================================

# Measure command execution time
timeit() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: timeit <command>"
        return 1
    fi
    
    local start_time="$EPOCHREALTIME"
    "$@"
    local end_time="$EPOCHREALTIME"
    local duration=$(( end_time - start_time ))
    
    printf "\nExecution time: %.3f seconds\n" "$duration"
}

# Profile ZSH startup
profile_startup() {
    local iterations="${1:-5}"
    local total_time=0
    local min_time=999999
    local max_time=0
    
    echo "Profiling ZSH startup ($iterations iterations)..."
    echo "================================================"
    
    for i in {1..$iterations}; do
        local start_time="$EPOCHREALTIME"
        zsh -i -c exit
        local end_time="$EPOCHREALTIME"
        local duration=$(( end_time - start_time ))
        
        total_time=$(( total_time + duration ))
        
        if (( duration < min_time )); then
            min_time="$duration"
        fi
        
        if (( duration > max_time )); then
            max_time="$duration"
        fi
        
        printf "Run %d: %.3f seconds\n" "$i" "$duration"
    done
    
    local avg_time=$(( total_time / iterations ))
    
    echo
    echo "Results:"
    printf "  Average: %.3f seconds\n" "$avg_time"
    printf "  Minimum: %.3f seconds\n" "$min_time"
    printf "  Maximum: %.3f seconds\n" "$max_time"
}

# Analyze ZSH configuration performance
analyze_config() {
    echo "Analyzing ZSH configuration performance..."
    echo "========================================"
    
    # Check for common performance issues
    local issues=0
    
    # Check for synchronous plugin loading
    if grep -q "zinit load" "$ZSH_CONFIG_DIR/zshrc" 2>/dev/null; then
        echo "⚠️  Found synchronous plugin loading (consider using 'zinit wait')"
        ((issues++))
    fi
    
    # Check for missing compinit optimization
    if ! grep -q "zicompinit\|compinit.*-C" "$ZSH_CONFIG_DIR"/{zshrc,modules/*.zsh} 2>/dev/null; then
        echo "⚠️  Consider optimizing compinit with -C flag or zicompinit"
        ((issues++))
    fi
    
    # Check for heavy operations in main thread
    if grep -qE "(curl|wget|git clone)" "$ZSH_CONFIG_DIR"/{zshrc,modules/*.zsh} 2>/dev/null; then
        echo "⚠️  Found network operations that could slow startup"
        ((issues++))
    fi
    
    # Check module count
    local module_count=$(ls "$ZSH_CONFIG_DIR/modules"/*.zsh 2>/dev/null | wc -l)
    if (( module_count > 10 )); then
        echo "ℹ️  High module count ($module_count) - consider consolidation"
    fi
    
    # Check function count
    local function_count=$(declare -f | grep -c "^[a-zA-Z_][a-zA-Z0-9_]* ()")
    if (( function_count > 50 )); then
        echo "ℹ️  High function count ($function_count) - consider lazy loading"
    fi
    
    if (( issues == 0 )); then
        echo "✅ No major performance issues found"
    else
        echo "Found $issues potential performance issues"
    fi
    
    echo
    echo "Quick startup test:"
    time zsh -i -c exit
}

# Compile ZSH configuration files
compile_config() {
    echo "Compiling ZSH configuration files..."
    echo "===================================="
    
    local compiled=0
    
    # Compile main configuration
    for file in "$ZSH_CONFIG_DIR"/{zshrc,zshenv}; do
        if [[ -f "$file" && ( ! -f "${file}.zwc" || "$file" -nt "${file}.zwc" ) ]]; then
            zcompile "$file"
            echo "✅ Compiled $(basename "$file")"
            ((compiled++))
        fi
    done
    
    # Compile modules
    for file in "$ZSH_CONFIG_DIR/modules"/*.zsh; do
        if [[ -f "$file" && ( ! -f "${file}.zwc" || "$file" -nt "${file}.zwc" ) ]]; then
            zcompile "$file"
            echo "✅ Compiled $(basename "$file")"
            ((compiled++))
        fi
    done
    
    # Compile completion cache
    if [[ -f "$ZSH_CACHE_DIR/zcompdump" && ( ! -f "$ZSH_CACHE_DIR/zcompdump.zwc" || 
          "$ZSH_CACHE_DIR/zcompdump" -nt "$ZSH_CACHE_DIR/zcompdump.zwc" ) ]]; then
        zcompile "$ZSH_CACHE_DIR/zcompdump"
        echo "✅ Compiled completion cache"
        ((compiled++))
    fi
    
    if (( compiled == 0 )); then
        echo "ℹ️  All files are already compiled and up to date"
    else
        echo "Compiled $compiled files"
    fi
}

# Clean compiled files
clean_compiled() {
    echo "Cleaning compiled ZSH files..."
    echo "============================="
    
    local cleaned=0
    
    # Remove compiled configuration files
    for file in "$ZSH_CONFIG_DIR"/{zshrc,zshenv}.zwc "$ZSH_CONFIG_DIR/modules"/*.zsh.zwc; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
            echo "🗑️  Removed $(basename "$file")"
            ((cleaned++))
        fi
    done
    
    # Remove compiled completion cache
    if [[ -f "$ZSH_CACHE_DIR/zcompdump.zwc" ]]; then
        rm -f "$ZSH_CACHE_DIR/zcompdump.zwc"
        echo "🗑️  Removed completion cache"
        ((cleaned++))
    fi
    
    if (( cleaned == 0 )); then
        echo "ℹ️  No compiled files found"
    else
        echo "Cleaned $cleaned compiled files"
    fi
}

# Reset ZSH cache
reset_cache() {
    echo "Resetting ZSH cache..."
    echo "===================="
    
    # Remove completion cache
    if [[ -d "$ZSH_CACHE_DIR" ]]; then
        rm -rf "$ZSH_CACHE_DIR"/*
        echo "✅ Cleared cache directory"
    fi
    
    # Remove zinit cache
    if [[ -d "$ZSH_DATA_DIR/zinit" ]]; then
        rm -rf "$ZSH_DATA_DIR/zinit/.zinit"
        echo "✅ Cleared zinit cache"
    fi
    
    echo "Cache reset complete. Restart ZSH to rebuild cache."
}

# Comprehensive benchmark
benchmark_zsh() {
    echo "ZSH Performance Benchmark Suite"
    echo "==============================="
    echo
    
    # Startup time
    echo "1. Startup Time Test:"
    profile_startup 3
    echo
    
    # Configuration analysis
    echo "2. Configuration Analysis:"
    analyze_config
    echo
    
    # Plugin loading time
    echo "3. Plugin Loading Analysis:"
    if command -v zinit >/dev/null 2>&1; then
        zinit times | head -10
    else
        echo "Zinit not available for plugin timing"
    fi
    echo
    
    # Memory usage
    echo "4. Memory Usage:"
    ps -o pid,ppid,pmem,vsz,rss,comm -p $$ --no-headers
    echo
    
    # Function count
    echo "5. Function Statistics:"
    local func_count=$(declare -f | grep -c "^[a-zA-Z_][a-zA-Z0-9_]* ()")
    local alias_count=$(alias | wc -l)
    echo "Functions: $func_count"
    echo "Aliases: $alias_count"
    echo
    
    echo "Benchmark complete!"
}

# Show performance tips
show_performance_tips() {
    echo ""
    echo "ZSH Performance Optimization Tips"
    echo "================================"
    echo ""
    echo "1. Startup Optimization:"
    echo "   - Use 'zinit wait' for non-essential plugins"
    echo "   - Compile configuration files with zcompile"
    echo "   - Use compinit -C for faster completion loading"
    echo "   - Minimize synchronous operations"
    echo ""
    echo "2. Plugin Management:"
    echo "   - Load only necessary plugins"
    echo "   - Use turbo mode (zinit wait) for delayed loading"
    echo "   - Prefer lightweight alternatives"
    echo "   - Regular plugin cleanup"
    echo ""
    echo "3. Completion System:"
    echo "   - Enable completion caching"
    echo "   - Use selective completion loading"
    echo "   - Optimize completion styles"
    echo "   - Regular cache cleanup"
    echo ""
    echo "4. Functions and Aliases:"
    echo "   - Use lazy loading for heavy functions"
    echo "   - Minimize global functions"
    echo "   - Prefer aliases over functions for simple commands"
    echo "   - Group related functionality"
    echo ""
    echo "5. Monitoring:"
    echo "   - Regular performance benchmarks"
    echo "   - Monitor startup time changes"
    echo "   - Profile resource usage"
    echo "   - Analyze configuration regularly"
    echo ""
    echo "Commands:"
    echo "  profile_startup     - Measure startup time"
    echo "  analyze_config      - Check for performance issues"
    echo "  compile_config      - Compile configuration files"
    echo "  benchmark_zsh       - Full performance benchmark"
    echo "  reset_cache         - Clear all caches"
    echo ""
}

# Monitor resource usage
monitor_resources() {
    local interval="${1:-1}"
    local duration="${2:-60}"
    local count=0
    
    echo "Monitoring ZSH resource usage..."
    echo "Interval: ${interval}s, Duration: ${duration}s"
    echo "================================"
    echo "Time     | PID   | %CPU | %MEM | VSZ    | RSS   "
    echo "---------|-------|------|------|--------|-------"
    
    while (( count < duration )); do
        local zsh_pids=$(pgrep -u "$USER" zsh)
        if [[ -n "$zsh_pids" ]]; then
            ps -p "$zsh_pids" -o lstart=,pid=,pcpu=,pmem=,vsz=,rss= --no-headers | \
            while read -r line; do
                printf "%-8s | %s\n" "$(date +%H:%M:%S)" "$line"
            done
        fi
        
        sleep "$interval"
        ((count += interval))
    done
}

# Quick reload function (renamed to avoid conflict)
zsh_reload() {
    echo "Reloading ZSH configuration..."
    source "$ZSH_CONFIG_DIR/zshrc"
    echo "✅ Configuration reloaded"
}

# Alias for convenience
alias reload_zsh='zsh_reload'
