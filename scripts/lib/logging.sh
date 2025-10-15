#!/usr/bin/env bash
# =============================================================================
# Shared Logging Utilities
# Provides consistent, minimal logging helpers for project scripts.
# =============================================================================

# Prevent re-definition when sourced multiple times.
if [[ -n "${__ZSH_CONFIG_LOGGING_LOADED:-}" ]]; then
    return 0
fi
__ZSH_CONFIG_LOGGING_LOADED=1

# Determine whether to emit ANSI colours.
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    LOG_COLOR_RED='\033[0;31m'
    LOG_COLOR_GREEN='\033[0;32m'
    LOG_COLOR_YELLOW='\033[1;33m'
    LOG_COLOR_BLUE='\033[0;34m'
    LOG_COLOR_CYAN='\033[0;36m'
    LOG_COLOR_RESET='\033[0m'
else
    LOG_COLOR_RED=''
    LOG_COLOR_GREEN=''
    LOG_COLOR_YELLOW=''
    LOG_COLOR_BLUE=''
    LOG_COLOR_CYAN=''
    LOG_COLOR_RESET=''
fi

_log_print() {
    local prefix="$1"
    local colour="$2"
    local message="$3"
    printf '%b%s %s%b\n' "$colour" "$prefix" "$message" "$LOG_COLOR_RESET"
}

log()     { _log_print "ℹ️ "  "$LOG_COLOR_BLUE"   "${1:-}"; }
info()    { _log_print "📋"    "$LOG_COLOR_CYAN"   "${1:-}"; }
success() { _log_print "✅"    "$LOG_COLOR_GREEN"  "${1:-}"; }
warning() { _log_print "⚠️ "  "$LOG_COLOR_YELLOW" "${1:-}"; }
error()   { _log_print "❌"    "$LOG_COLOR_RED"    "${1:-}"; }

unset -f _log_print
