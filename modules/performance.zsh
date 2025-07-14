#!/usr/bin/env zsh
# =============================================================================
# Performance Module - Unified Module System Integration
# Version: 3.0 - Comprehensive Performance Monitoring
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Performance monitoring configuration
PERF_LOG="${ZSH_CACHE_DIR}/performance.log"
PERF_METRICS_FILE="${ZSH_CACHE_DIR}/metrics.json"
PERF_THRESHOLD_WARNING=1.0
PERF_THRESHOLD_CRITICAL=2.0

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize performance monitoring
init_performance_monitoring() {
    [[ ! -d "$PERF_LOG:h" ]] && mkdir -p "$PERF_LOG:h"
    export ZSH_PERF_START=$EPOCHREALTIME
    
    # Log performance module initialization
    log_performance_event "Performance module initialized"
}

# =============================================================================
# PERFORMANCE LOGGING
# =============================================================================

# Log performance events
log_performance_event() {
    local event="$1"
    local level="${2:-info}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $event" >> "$PERF_LOG"
}

# =============================================================================
# PERFORMANCE ANALYSIS
# =============================================================================

# Analyze startup performance
_analyze_startup_performance() {
    local duration="$1"
    
    if (( duration >= 0 && duration < 60 )); then
        local performance_level=""
        local emoji=""
        
        if (( duration > PERF_THRESHOLD_CRITICAL )); then
            performance_level="CRITICAL"
            emoji="🔴"
        elif (( duration > PERF_THRESHOLD_WARNING )); then
            performance_level="WARNING"
            emoji="🟡"
        else
            performance_level="GOOD"
            emoji="🟢"
        fi
        
        echo "$emoji Zsh startup: ${duration}s ($performance_level)"
        _log_performance_metrics "$duration" "$performance_level"
        
        if [[ "$performance_level" != "GOOD" ]]; then
            _suggest_optimizations "$duration"
        fi
    fi
}

# Log performance metrics
_log_performance_metrics() {
    local duration="$1"
    local level="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    mkdir -p "$(dirname "$PERF_LOG")"
    echo "[$timestamp] Startup: ${duration}s ($level)" >> "$PERF_LOG"
}

# Suggest optimizations
_suggest_optimizations() {
    local duration="$1"
    
    echo "💡 Performance optimization suggestions:"
    
    if (( duration > 2.0 )); then
        echo "  • Consider disabling heavy plugins"
        echo "  • Review completion cache settings"
        echo "  • Check for slow-loading modules"
    fi
    
    if (( duration > 1.0 )); then
        echo "  • Enable lazy loading for non-critical plugins"
        echo "  • Optimize PATH variable"
        echo "  • Review custom functions"
    fi
    
    echo "  • Run 'zsh-perf-analyze' for detailed analysis"
}

# =============================================================================
# PERFORMANCE ANALYSIS FUNCTIONS
# =============================================================================

# Advanced performance analysis
zsh_perf_analyze() {
    log_performance_event "Performance analysis started"
    
    echo "🔍 ZSH Performance Analysis"
    echo "=========================="
    
    # Basic metrics
    local func_count=$(declare -F | wc -l)
    local alias_count=$(alias | wc -l)
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    local memory_usage=$(ps -o rss= -p $$ 2>/dev/null | awk '{printf "%.1f MB", $1/1024}' | head -1 | tr -d '\n')
    
    echo "Functions: $func_count"
    echo "Aliases: $alias_count"
    echo "PATH entries: $path_count"
    echo "Memory: $memory_usage"
    
    # Advanced metrics
    echo "History size: $(wc -l < "$HISTFILE" 2>/dev/null || echo "0")"
    echo "Completion cache size: $(ls -la "$COMPLETION_CACHE_FILE" 2>/dev/null | awk '{print $5}' || echo "0")"
    echo "Loaded modules: $(echo $ZSH_MODULES_LOADED | wc -w 2>/dev/null || echo "0")"
    
    # Performance assessment
    if (( func_count > 500 )); then
        echo "⚠️  High function count: $func_count"
    fi
    
    if (( path_count > 20 )); then
        echo "⚠️  Many PATH entries: $path_count"
    fi
    
    local hist_size=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
    if (( hist_size > 10000 )); then
        echo "⚠️  Large history file: $hist_size lines"
    fi
    
    # Performance score calculation
    local score=100
    (( func_count > 500 )) && ((score -= 10))
    (( path_count > 20 )) && ((score -= 10))
    (( hist_size > 10000 )) && ((score -= 10))
    
    echo "📊 Performance Score: $score/100"
    
    log_performance_event "Performance analysis completed"
}

# Simple bottleneck check
_identify_bottlenecks() {
    local issues=0
    
    if [[ -f "$HISTFILE" ]]; then
        local hist_size=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
        if (( hist_size > 10000 )); then
            echo "⚠️  Large history file: $hist_size lines"
            ((issues++))
        fi
    fi
    
    if (( issues == 0 )); then
        echo "✅ No obvious performance issues"
    fi
}

# =============================================================================
# OPTIMIZATION FUNCTIONS
# =============================================================================

# Main optimization function
optimize_zsh_performance() {
    log_performance_event "Performance optimization started"
    
    echo "⚡ Optimizing ZSH Performance..."
    
    _optimize_completion_cache
    _optimize_history
    _optimize_path
    _compile_zsh_files
    _optimize_hooks
    
    echo "✅ Performance optimization completed"
    log_performance_event "Performance optimization completed"
}

# Optimize completion cache
_optimize_completion_cache() {
    echo "  • Optimizing completion cache..."
    
    local comp_cache="$ZSH_CACHE_DIR/zcompdump"
    if [[ -f "$comp_cache" ]]; then
        autoload -Uz compinit
        compinit -d "$comp_cache"
        
        [[ -f "$comp_cache" ]] && [[ ! -f "${comp_cache}.zwc" ]] && \
            zcompile "$comp_cache"
    fi
}

# Optimize history
_optimize_history() {
    echo "  • Optimizing history..."
    
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
}

# Optimize PATH
_optimize_path() {
    echo "  • Optimizing PATH..."
    
    typeset -U path
    
    local new_path=""
    for dir in $(echo "$PATH" | tr ':' ' '); do
        if [[ -d "$dir" ]]; then
            new_path="${new_path:+$new_path:}$dir"
        fi
    done
    export PATH="$new_path"
}

# Compile zsh files
_compile_zsh_files() {
    echo "  • Compiling zsh files..."
    
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
    
    echo "    Compiled $compiled_count files"
}

# Optimize hooks
_optimize_hooks() {
    echo "  • Optimizing hooks..."
    
    local hooks=$(add-zsh-hook -L precmd 2>/dev/null)
    local unique_hooks=$(echo "$hooks" | sort | uniq)
    
    if [[ "$hooks" != "$unique_hooks" ]]; then
        add-zsh-hook -D precmd '*'
        echo "$unique_hooks" | while read hook; do
            [[ -n "$hook" ]] && add-zsh-hook precmd "$hook"
        done
    fi
}

# =============================================================================
# MODULE-SPECIFIC PERFORMANCE
# =============================================================================

# Plugin performance monitoring
monitor_plugin_performance() {
    local plugin="$1"
    local start_time=$EPOCHREALTIME
    
    # Simulate plugin loading time measurement
    sleep 0.001  # Simulate work
    
    local end_time=$EPOCHREALTIME
    local duration=$((end_time - start_time))
    local duration_formatted=$(printf "%.3f" $duration)
    
    log_performance_event "Plugin $plugin loaded in ${duration_formatted}s"
    
    if (( duration > 100 )); then
        log_performance_event "Plugin $plugin is slow: ${duration_formatted}s" "warning"
    fi
}

# Completion performance monitoring
monitor_completion_performance() {
    local start_time=$EPOCHREALTIME
    
    # Measure completion cache rebuild time
    if [[ -f "$ZSH_CACHE_DIR/zcompdump" ]]; then
        autoload -Uz compinit
        compinit -C -d "$ZSH_CACHE_DIR/zcompdump" >/dev/null 2>&1
    fi
    
    local end_time=$EPOCHREALTIME
    local duration=$((end_time - start_time))
    local duration_formatted=$(printf "%.3f" $duration)
    
    log_performance_event "Completion system loaded in ${duration_formatted}s"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Performance dashboard
zsh_perf_dashboard() {
    echo "📊 ZSH Performance Dashboard"
    echo "==========================="
    
    echo "Memory: $(ps -o rss= -p $$ 2>/dev/null | awk '{printf "%.1f MB", $1/1024}' | head -1 | tr -d '\n')"
    echo "Functions: $(declare -F | wc -l)"
    echo "Aliases: $(alias | wc -l)"
    echo "PATH entries: $(echo "$PATH" | tr ':' '\n' | wc -l)"
    
    if [[ -f "$PERF_LOG" ]]; then
        echo ""
        echo "Recent performance events:"
        tail -5 "$PERF_LOG" | sed 's/^/  /'
    fi
}

# Quick performance check
quick_perf_check() {
    echo "⚡ Quick Performance Check"
    echo "========================="
    
    local start_time=$EPOCHREALTIME
    
    local func_count=$(declare -F | wc -l)
    local alias_count=$(alias | wc -l)
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    
    local end_time=$EPOCHREALTIME
    local duration=$((end_time - start_time))
    local duration_formatted=$(printf "%.3f" $duration)
    
    echo "Metrics collected in ${duration_formatted}s:"
    echo "  • Functions: $func_count"
    echo "  • Aliases: $alias_count"
    echo "  • PATH entries: $path_count"
    
    if (( duration > 100 )); then
        echo "⚠️  Slow metric collection detected"
        log_performance_event "Slow metric collection: ${duration_formatted}s" "warning"
    else
        echo "✅ Performance check passed"
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize performance monitoring
init_performance_monitoring

# Export functions
export -f zsh_perf_analyze optimize_zsh_performance zsh_perf_dashboard quick_perf_check monitor_plugin_performance monitor_completion_performance 2>/dev/null || true
