# ZSH Performance Optimization Module - Enhanced Version

# Performance monitoring configuration
PERF_LOG="${ZSH_CACHE_DIR}/performance.log"
PERF_METRICS_FILE="${ZSH_CACHE_DIR}/metrics.json"
PERF_THRESHOLD_WARNING=1.0
PERF_THRESHOLD_CRITICAL=2.0

# Initialize performance monitoring
init_performance_monitoring() {
    # Create performance log directory
    [[ ! -d "$PERF_LOG:h" ]] && mkdir -p "$PERF_LOG:h"
    
    # Start performance profiling if enabled
    [[ -n "$ZSH_PROF" ]] && zmodload zsh/zprof
    
    # Record start time
    export ZSH_PERF_START=$EPOCHREALTIME
    
    # Set up performance tracking
    _setup_performance_tracking
}

# Simple performance tracking
_setup_performance_tracking() {
    # Basic performance monitoring setup
    # ZSH_PERF_START is already set in init_performance_monitoring
}

# Analyze startup performance (called from main zshrc)
_analyze_startup_performance() {
    local duration="$1"
    
    # Only show results for reasonable timeframes
    if (( $(echo "$duration >= 0 && $duration < 60" | bc -l 2>/dev/null) )); then
        local performance_level=""
        local emoji=""
        
        if (( $(echo "$duration > $PERF_THRESHOLD_CRITICAL" | bc -l 2>/dev/null) )); then
            performance_level="CRITICAL"
            emoji="🔴"
        elif (( $(echo "$duration > $PERF_THRESHOLD_WARNING" | bc -l 2>/dev/null) )); then
            performance_level="WARNING"
            emoji="🟡"
        else
            performance_level="GOOD"
            emoji="🟢"
        fi
        
        echo "$emoji Zsh startup: ${duration}s ($performance_level)"
        
        # Log performance data
        _log_performance_metrics "$duration" "$performance_level"
        
        # Provide optimization suggestions
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
    # Ensure the directory exists
    mkdir -p "$(dirname "$PERF_LOG")"
    echo "[$timestamp] Startup: ${duration}s ($level)" >> "$PERF_LOG"
}

# Suggest optimizations
_suggest_optimizations() {
    local duration="$1"
    
    echo "💡 Performance optimization suggestions:"
    
    if (( $(echo "$duration > 2.0" | bc -l 2>/dev/null) )); then
        echo "  • Consider disabling heavy plugins"
        echo "  • Review completion cache settings"
        echo "  • Check for slow-loading modules"
    fi
    
    if (( $(echo "$duration > 1.0" | bc -l 2>/dev/null) )); then
        echo "  • Enable lazy loading for non-critical plugins"
        echo "  • Optimize PATH variable"
        echo "  • Review custom functions"
    fi
    
    echo "  • Run 'zsh-perf-analyze' for detailed analysis"
}

# Advanced performance analysis
zsh_perf_analyze() {
    echo "🔍 ZSH Performance Analysis"
    echo "=========================="
    
    # Basic metrics
    echo "Functions: $(declare -F | wc -l)"
    echo "Aliases: $(alias | wc -l)"
    echo "PATH entries: $(echo "$PATH" | tr ':' '\n' | wc -l)"
    echo "Memory: $(ps -o rss= -p $$ 2>/dev/null | awk '{printf "%.1f MB", $1/1024}' | head -1 | tr -d '\n')"
    
    # Advanced metrics
    echo "History size: $(wc -l < "$HISTFILE" 2>/dev/null || echo "0")"
    echo "Completion cache size: $(ls -la "$COMPLETION_CACHE_FILE" 2>/dev/null | awk '{print $5}' || echo "0")"
    echo "Loaded modules: $(echo $ZSH_LOADED_MODULES | wc -w 2>/dev/null || echo "0")"
    
    # Performance assessment
    local func_count=$(declare -F | wc -l)
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    local hist_size=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
    
    if (( func_count > 500 )); then
        echo "⚠️  High function count: $func_count"
    fi
    
    if (( path_count > 20 )); then
        echo "⚠️  Many PATH entries: $path_count"
    fi
    
    if (( hist_size > 10000 )); then
        echo "⚠️  Large history file: $hist_size lines"
    fi
    
    # Performance score calculation
    local score=100
    (( func_count > 500 )) && ((score -= 10))
    (( path_count > 20 )) && ((score -= 10))
    (( hist_size > 10000 )) && ((score -= 10))
    
    echo "📊 Performance Score: $score/100"
}

# Simple bottleneck check
_identify_bottlenecks() {
    local issues=0
    
    # Check for large history file
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

# Performance optimization functions
optimize_zsh_performance() {
    echo "⚡ Optimizing ZSH Performance..."
    
    # Optimize completion cache
    _optimize_completion_cache
    
    # Clean up history
    _optimize_history
    
    # Optimize PATH
    _optimize_path
    
    # Compile zsh files
    _compile_zsh_files
    
    echo "✅ Performance optimization completed"
}

# Optimize completion cache
_optimize_completion_cache() {
    echo "  • Optimizing completion cache..."
    
    local comp_cache="$ZSH_CACHE_DIR/zcompdump"
    if [[ -f "$comp_cache" ]]; then
        # Rebuild completion cache
        autoload -Uz compinit
        compinit -d "$comp_cache"
        
        # Compile for faster loading
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
    
    # Remove duplicate entries
    typeset -U path
    
    # Remove non-existent directories
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
    
    # Compile main configuration files
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
    
    for file in "${files_to_compile[@]}"; do
        if [[ -f "$file" ]] && [[ ! -f "${file}.zwc" ]]; then
            zcompile "$file" 2>/dev/null || true
        fi
    done
}

# Simple performance dashboard
zsh_perf_dashboard() {
    echo "📊 ZSH Performance Dashboard"
    echo "==========================="
    
    # Current metrics
    echo "Memory: $(ps -o rss= -p $$ 2>/dev/null | awk '{printf "%.1f MB", $1/1024}' | head -1 | tr -d '\n')"
    echo "Functions: $(declare -F | wc -l)"
    echo "Aliases: $(alias | wc -l)"
    echo "PATH entries: $(echo "$PATH" | tr ':' '\n' | wc -l)"
    
    # Recent startup times
    if [[ -f "$PERF_LOG" ]]; then
        echo ""
        echo "Recent startup times:"
        tail -5 "$PERF_LOG" | sed 's/^/  /'
    fi
}

# Quick performance check
quick_perf_check() {
    echo "⚡ Quick Performance Check"
    echo "========================="
    
    local start_time=$EPOCHREALTIME
    
    # Test basic operations
    local func_count=$(declare -F | wc -l)
    local alias_count=$(alias | wc -l)
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    
    local end_time=$EPOCHREALTIME
    local duration=$(printf "%.3f" $(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0"))
    
    echo "Metrics collected in ${duration}s:"
    echo "  • Functions: $func_count"
    echo "  • Aliases: $alias_count"
    echo "  • PATH entries: $path_count"
    
    # Performance assessment
    if (( $(echo "$duration > 0.1" | bc -l 2>/dev/null) )); then
        echo "⚠️  Slow metric collection detected"
    else
        echo "✅ Performance check passed"
    fi
}

# Initialize performance monitoring
init_performance_monitoring

# Export performance functions
export -f zsh_perf_analyze optimize_zsh_performance zsh_perf_dashboard quick_perf_check 2>/dev/null || true
