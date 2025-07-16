#!/usr/bin/env zsh
# =============================================================================
# Unified Logging System
# =============================================================================

# Standard logging functions
log() {
    echo "INFO: $1"
}
success() {
    echo "SUCCESS: $1"
}
error() {
    echo "ERROR: $1"
}
warning() {
    echo "WARNING: $1"
}

# Enhanced logging with module context
log_with_module() {
    local message="$1"
    local module="${2:-unknown}"
    echo "INFO: [$module] $message"
}

# Performance logging
perf_log() {
    local metric="$1"
    local value="$2"
    local unit="${3:-}"
    echo "PERF: $metric: $value$unit"
}

# Debug logging (only when DEBUG is set)
debug_log() {
    if [[ -n "$DEBUG" ]]; then
        echo "DEBUG: $1"
    fi
}

# Error logging with stack trace
error_with_trace() {
    local message="$1"
    echo "ERROR: $message"
    if [[ -n "$DEBUG" ]]; then
        echo "   Stack trace:"
        local frame=1
        while caller $frame; do
            ((frame++))
        done
    fi
} 