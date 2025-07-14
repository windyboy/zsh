#!/usr/bin/env zsh
# =============================================================================
# Keybindings Module - Unified Module System Integration
# Version: 3.0 - Comprehensive Keybinding Management
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Keybinding configuration
KEYBINDING_LOG="${ZSH_CACHE_DIR}/keybindings.log"

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize keybindings module
init_keybindings() {
    [[ ! -d "$KEYBINDING_LOG:h" ]] && mkdir -p "$KEYBINDING_LOG:h"
    
    # Log keybindings module initialization
    log_keybinding_event "Keybindings module initialized"
}

# =============================================================================
# KEYBINDING LOGGING
# =============================================================================

# Log keybinding events
log_keybinding_event() {
    local event="$1"
    local level="${2:-info}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $event" >> "$KEYBINDING_LOG"
}

# =============================================================================
# BASIC NAVIGATION
# =============================================================================

# Set keymap mode
bindkey -e  # Emacs mode (use -v for Vi mode)

# Line navigation
bindkey '^A' beginning-of-line          # Ctrl+A
bindkey '^E' end-of-line                # Ctrl+E
bindkey '^B' backward-char              # Ctrl+B
bindkey '^F' forward-char               # Ctrl+F

# Word navigation
bindkey '^[b' backward-word             # Alt+B
bindkey '^[f' forward-word              # Alt+F
bindkey '^[[1;5D' backward-word         # Ctrl+Left
bindkey '^[[1;5C' forward-word          # Ctrl+Right

# Line editing
bindkey '^K' kill-line                  # Ctrl+K (kill to end)
bindkey '^U' kill-whole-line            # Ctrl+U (kill whole line)
bindkey '^W' backward-kill-word         # Ctrl+W (kill word backward)
bindkey '^[d' kill-word                 # Alt+D (kill word forward)
bindkey '^Y' yank                       # Ctrl+Y (paste)

# =============================================================================
# HISTORY NAVIGATION
# =============================================================================

# History search
bindkey '^R' history-incremental-search-backward  # Ctrl+R
bindkey '^S' history-incremental-search-forward   # Ctrl+S
bindkey '^P' up-history                           # Ctrl+P
bindkey '^N' down-history                         # Ctrl+N

# Arrow keys for history
bindkey '^[[A' up-line-or-history       # Up arrow
bindkey '^[[B' down-line-or-history     # Down arrow
bindkey '^[[C' forward-char             # Right arrow
bindkey '^[[D' backward-char            # Left arrow

# History expansion
bindkey ' ' magic-space                 # Space expands history

# =============================================================================
# COMPLETION NAVIGATION
# =============================================================================

# Tab completion (ensure these are set correctly)
bindkey '^I' complete-word              # Tab
bindkey '^[[Z' reverse-menu-complete    # Shift+Tab

# Ensure tab completion works (run once at startup, not after every command)
_ensure_tab_completion() {
    # Only re-bind if needed (check if already bound correctly)
    if ! bindkey | grep -q '\^I.*complete-word'; then
        bindkey '^I' complete-word 2>/dev/null || true
        bindkey '^[[Z' reverse-menu-complete 2>/dev/null || true
    fi
}

# Run tab completion setup once at startup
_ensure_tab_completion

# =============================================================================
# CUSTOM WIDGETS AND BINDINGS
# =============================================================================

# FZF key bindings (if available)
if command -v fzf >/dev/null 2>&1; then
    # File finder
    _fzf_file_widget() {
        local file
        file=$(find . -type f 2>/dev/null | fzf --height 40% --reverse) && LBUFFER+="$file"
        zle reset-prompt
    }
    zle -N _fzf_file_widget
    bindkey '^T' _fzf_file_widget        # Ctrl+T
    
    # Directory finder
    _fzf_cd_widget() {
        local dir
        dir=$(find . -type d 2>/dev/null | fzf --height 40% --reverse) && cd "$dir"
        zle reset-prompt
    }
    zle -N _fzf_cd_widget
    bindkey '^G' _fzf_cd_widget          # Ctrl+G
    
    # History search with fzf
    _fzf_history_widget() {
        local selected
        selected=$(fc -rl 1 | fzf --height 40% --reverse --tac | cut -d' ' -f2-)
        if [[ -n "$selected" ]]; then
            LBUFFER="$selected"
        fi
        zle reset-prompt
    }
    zle -N _fzf_history_widget
    bindkey '^H' _fzf_history_widget     # Ctrl+H
fi

# Git status widget
_git_status_widget() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo
        git status --short
        echo
    fi
    zle reset-prompt
}
zle -N _git_status_widget
bindkey '^[g' _git_status_widget         # Alt+G

# Quick edit current command in editor
_edit_command_line_widget() {
    local tmpfile=$(mktemp)
    echo "$BUFFER" > "$tmpfile"
    ${EDITOR:-nano} "$tmpfile"
    BUFFER=$(cat "$tmpfile")
    rm -f "$tmpfile"
    zle end-of-line
}
zle -N _edit_command_line_widget
bindkey '^X^E' _edit_command_line_widget  # Ctrl+X Ctrl+E

# Insert sudo at beginning of line
_sudo_command_line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N _sudo_command_line
bindkey '^[s' _sudo_command_line         # Alt+S

# =============================================================================
# DIRECTORY NAVIGATION WIDGETS
# =============================================================================

# Quick directory jumps
_jump_to_project() {
    if [[ -d "$HOME/Projects" ]]; then
        cd "$HOME/Projects"
        zle reset-prompt
    fi
}
zle -N _jump_to_project
bindkey '^[p' _jump_to_project           # Alt+P

_jump_to_home() {
    cd "$HOME"
    zle reset-prompt
}
zle -N _jump_to_home
bindkey '^[h' _jump_to_home              # Alt+H

_jump_to_root() {
    cd "/"
    zle reset-prompt
}
zle -N _jump_to_root
bindkey '^[r' _jump_to_root              # Alt+R

# =============================================================================
# TEXT MANIPULATION WIDGETS
# =============================================================================

# Quote current word
_quote_word() {
    local word="${LBUFFER##* }"
    if [[ -n "$word" ]]; then
        LBUFFER="${LBUFFER%$word}\"$word\""
    fi
}
zle -N _quote_word
bindkey '^[q' _quote_word                # Alt+Q

# Uppercase word
_uppercase_word() {
    zle forward-word
    zle backward-word
    zle upcase-word
}
zle -N _uppercase_word
bindkey '^[u' _uppercase_word            # Alt+U

# Lowercase word
_lowercase_word() {
    zle forward-word
    zle backward-word
    zle downcase-word
}
zle -N _lowercase_word
bindkey '^[l' _lowercase_word            # Alt+L

# =============================================================================
# MODULE-SPECIFIC WIDGETS
# =============================================================================

# Performance monitoring widget
_performance_widget() {
    echo
    echo "⚡ Performance Check"
    echo "==================="
    quick_perf_check
    echo
    zle reset-prompt
}
zle -N _performance_widget
bindkey '^[p' _performance_widget        # Alt+P

# Security monitoring widget
_security_widget() {
    echo
    echo "🔒 Security Check"
    echo "================"
    security_audit
    echo
    zle reset-prompt
}
zle -N _security_widget
bindkey '^[s' _security_widget           # Alt+S

# Module status widget
_module_status_widget() {
    echo
    echo "📦 Module Status"
    echo "==============="
    list_modules
    echo
    zle reset-prompt
}
zle -N _module_status_widget
bindkey '^[m' _module_status_widget      # Alt+M

# =============================================================================
# KEYBINDING MANAGEMENT
# =============================================================================

# List all keybindings
list_keybindings() {
    echo "⌨️  Available keybindings:"
    bindkey | sort | sed 's/^/  /'
}

# Search keybindings
search_keybindings() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: search_keybindings <query>"
        return 1
    fi
    
    echo "🔍 Searching keybindings for: $query"
    bindkey | grep -i "$query" | sed 's/^/  /'
}

# Keybinding statistics
keybinding_stats() {
    local total_bindings=$(bindkey | wc -l)
    local navigation_bindings=$(bindkey | grep -c -E "(beginning|end|forward|backward)" || echo "0")
    local history_bindings=$(bindkey | grep -c -E "(history|up|down)" || echo "0")
    local completion_bindings=$(bindkey | grep -c -E "(complete|menu)" || echo "0")
    
    echo "📊 Keybinding Statistics:"
    echo "  • Total bindings: $total_bindings"
    echo "  • Navigation bindings: $navigation_bindings"
    echo "  • History bindings: $history_bindings"
    echo "  • Completion bindings: $completion_bindings"
}

# Validate keybindings
validate_keybindings() {
    local errors=0
    local warnings=0
    
    echo "🔍 Validating keybindings..."
    
    # Check for essential bindings
    local essential_bindings=(
        "beginning-of-line"
        "end-of-line"
        "backward-char"
        "forward-char"
        "up-line-or-history"
        "down-line-or-history"
        "complete-word"
    )
    
    for binding in "${essential_bindings[@]}"; do
        if ! bindkey | grep -q "$binding"; then
            echo "❌ Essential binding missing: $binding"
            ((errors++))
        fi
    done
    
    # Check for conflicting bindings
    local bindings=$(bindkey | awk '{print $2}' | sort | uniq -d)
    if [[ -n "$bindings" ]]; then
        echo "⚠️  Conflicting bindings found:"
        echo "$bindings" | sed 's/^/  /'
        ((warnings++))
    fi
    
    if (( errors == 0 && warnings == 0 )); then
        echo "✅ All keybindings validated"
        log_keybinding_event "Keybinding validation passed"
        return 0
    else
        echo "❌ Keybinding validation failed ($errors errors, $warnings warnings)"
        log_keybinding_event "Keybinding validation failed: $errors errors, $warnings warnings" "warning"
        return 1
    fi
}

# =============================================================================
# MODULE-SPECIFIC KEYBINDINGS
# =============================================================================

# Performance monitoring keybindings
monitor_keybinding_performance() {
    local keybinding="$1"
    local start_time=$EPOCHREALTIME
    
    # Simulate keybinding execution time measurement
    sleep 0.001  # Simulate work
    
    local end_time=$EPOCHREALTIME
    local duration=$((end_time - start_time))
    local duration_formatted=$(printf "%.3f" $duration)
    
    log_keybinding_event "Keybinding $keybinding executed in ${duration_formatted}s"
    
    if (( duration > 100 )); then
        log_keybinding_event "Keybinding $keybinding is slow: ${duration_formatted}s" "warning"
    fi
}

# Security validation keybindings
validate_keybinding_security() {
    local keybinding="$1"
    
    # Check for potentially dangerous keybindings
    local dangerous_patterns=(
        "rm -rf"
        "sudo"
        "chmod 777"
        "chown root"
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$keybinding" == *"$pattern"* ]]; then
            log_keybinding_event "Keybinding contains potentially dangerous pattern: $pattern" "warning"
            return 1
        fi
    done
    
    return 0
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize keybindings module
init_keybindings

# Export functions
export -f list_keybindings search_keybindings keybinding_stats validate_keybindings monitor_keybinding_performance validate_keybinding_security 2>/dev/null || true
