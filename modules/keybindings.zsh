#!/usr/bin/env zsh
# =============================================================================
# Keybindings Module - Simplified Keybinding Management
# Version: 4.0 - Streamlined Keybinding System
# =============================================================================

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

# Tab completion
bindkey '^I' complete-word              # Tab
bindkey '^[[Z' reverse-menu-complete    # Shift+Tab

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
# UTILITY WIDGETS
# =============================================================================

# Performance monitoring widget
_performance_widget() {
    echo
    echo "⚡ Performance Check"
    echo "==================="
    perf
    echo
    zle reset-prompt
}
zle -N _performance_widget
bindkey '^[p' _performance_widget        # Alt+P

# Status check widget
_status_widget() {
    echo
    echo "📊 Status Check"
    echo "==============="
    status
    echo
    zle reset-prompt
}
zle -N _status_widget
bindkey '^[s' _status_widget             # Alt+S

# Error report widget
_errors_widget() {
    echo
    echo "❌ Error Report"
    echo "==============="
    errors
    echo
    zle reset-prompt
}
zle -N _errors_widget
bindkey '^[e' _errors_widget             # Alt+E

# =============================================================================
# DEVELOPMENT WIDGETS
# =============================================================================

# Quick git commit
_git_commit_widget() {
    local message
    vared -p "Commit message: " message
    if [[ -n "$message" ]]; then
        gcm "$message"
    fi
    zle reset-prompt
}
zle -N _git_commit_widget
bindkey '^[c' _git_commit_widget         # Alt+C

# Quick directory creation
_mkcd_widget() {
    local dir
    vared -p "Directory name: " dir
    if [[ -n "$dir" ]]; then
        mkcd "$dir"
    fi
    zle reset-prompt
}
zle -N _mkcd_widget
bindkey '^[m' _mkcd_widget               # Alt+M

# =============================================================================
# SYSTEM WIDGETS
# =============================================================================

# System information widget
_sysinfo_widget() {
    echo
    echo "🖥️  System Info"
    echo "=============="
    sysinfo
    echo
    zle reset-prompt
}
zle -N _sysinfo_widget
bindkey '^[i' _sysinfo_widget            # Alt+I

# Disk usage widget
_diskusage_widget() {
    echo
    echo "💾 Disk Usage"
    echo "============="
    diskusage
    echo
    zle reset-prompt
}
zle -N _diskusage_widget
bindkey '^[d' _diskusage_widget          # Alt+D

# Memory usage widget
_memusage_widget() {
    echo
    echo "🧠 Memory Usage"
    echo "==============="
    memusage
    echo
    zle reset-prompt
}
zle -N _memusage_widget
bindkey '^[m' _memusage_widget           # Alt+M

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Show key bindings
keybindings() {
    echo "⌨️  Key Bindings"
    echo "==============="
    echo "Navigation:"
    echo "  Ctrl+A - Beginning of line"
    echo "  Ctrl+E - End of line"
    echo "  Ctrl+B/F - Backward/Forward char"
    echo "  Alt+B/F - Backward/Forward word"
    echo ""
    echo "History:"
    echo "  Ctrl+R - History search"
    echo "  Ctrl+P/N - Up/Down history"
    echo "  Up/Down arrows - History navigation"
    echo ""
    echo "Editing:"
    echo "  Ctrl+K - Kill to end of line"
    echo "  Ctrl+U - Kill whole line"
    echo "  Ctrl+W - Kill word backward"
    echo "  Ctrl+Y - Yank (paste)"
    echo ""
    echo "Completion:"
    echo "  Tab - Complete word"
    echo "  Shift+Tab - Reverse menu complete"
    echo ""
    echo "Custom:"
    echo "  Alt+G - Git status"
    echo "  Alt+S - Insert sudo"
    echo "  Alt+P - Jump to projects"
    echo "  Alt+H - Jump to home"
    echo "  Alt+R - Jump to root"
    echo "  Alt+Q - Quote word"
    echo "  Alt+U/L - Uppercase/Lowercase word"
    echo ""
    echo "FZF (if available):"
    echo "  Ctrl+T - File finder"
    echo "  Ctrl+G - Directory finder"
    echo "  Ctrl+H - History search"
}

# Check for key binding conflicts
check_keybindings() {
    echo "🔍 Checking for key binding conflicts..."
    
    local conflicts=0
    local bindings=$(bindkey | awk '{print $2}' | sort | uniq -d)
    
    if [[ -n "$bindings" ]]; then
        echo "⚠️  Duplicate key bindings found:"
        echo "$bindings"
        ((conflicts++))
    else
        echo "✅ No key binding conflicts detected"
    fi
    
    return $conflicts
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Mark keybindings module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED keybindings"

log "Keybindings module initialized" "success" "keybindings" 