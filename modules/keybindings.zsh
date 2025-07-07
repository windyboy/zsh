#!/usr/bin/env zsh
# =============================================================================
# Key Bindings Configuration
# =============================================================================

# Set keymap mode
bindkey -e  # Emacs mode (use -v for Vi mode)

# =============================================================================
# BASIC NAVIGATION
# =============================================================================

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

# Ensure tab completion works even if other plugins override it
_ensure_tab_completion() {
    # Re-bind tab if it was overridden
    bindkey '^I' complete-word 2>/dev/null || true
    bindkey '^[[Z' reverse-menu-complete 2>/dev/null || true
}

# Set up the hook if add-zsh-hook is available
if (( ${+functions[add-zsh-hook]} )); then
    add-zsh-hook precmd _ensure_tab_completion
else
    # Fallback: call the function directly
    _ensure_tab_completion
fi

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

# Clear screen and show system info
_clear_and_info() {
    clear
    if command -v neofetch >/dev/null 2>&1; then
        neofetch
    else
        echo "System: $(uname -s) $(uname -r)"
        echo "Uptime: $(uptime | cut -d',' -f1 | cut -d' ' -f4-)"
    fi
    zle reset-prompt
}
zle -N _clear_and_info
bindkey '^L' _clear_and_info             # Ctrl+L

# Show current directory contents
_show_directory() {
    echo
    if command -v eza >/dev/null 2>&1; then
        eza -la --color=always --group-directories-first --icons
    else
        ls -la --color=auto
    fi
    echo
    zle reset-prompt
}
zle -N _show_directory
bindkey '^[.' _show_directory            # Alt+.

# =============================================================================
# SPECIAL KEY BINDINGS
# =============================================================================

# Fix common key issues
bindkey '^[[1~' beginning-of-line       # Home
bindkey '^[[4~' end-of-line             # End
bindkey '^[[3~' delete-char             # Delete
bindkey '^[[2~' overwrite-mode          # Insert

# Function keys
bindkey '^[[11~' _git_status_widget     # F1 - Git status
bindkey '^[[12~' _show_directory        # F2 - Show directory
bindkey '^[[13~' _clear_and_info        # F3 - Clear and info

# =============================================================================
# TERMINAL SPECIFIC BINDINGS
# =============================================================================

# iTerm2 specific
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    bindkey '^[[1;9D' backward-word     # Option+Left
    bindkey '^[[1;9C' forward-word      # Option+Right
fi

# VS Code terminal specific
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    bindkey '^[[1;5D' backward-word     # Ctrl+Left
    bindkey '^[[1;5C' forward-word      # Ctrl+Right
fi

# =============================================================================
# COMPLETION MENU NAVIGATION
# =============================================================================

# Function to setup menu select bindings
_setup_menu_select() {
    # Load complist module if available
    if zmodload -e zsh/complist 2>/dev/null || zmodload zsh/complist 2>/dev/null; then
        # Menu selection navigation (Vim-style)
        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
        bindkey -M menuselect 'j' vi-down-line-or-history
        
        # Arrow key navigation
        bindkey -M menuselect '^[[A' vi-up-line-or-history
        bindkey -M menuselect '^[[B' vi-down-line-or-history
        bindkey -M menuselect '^[[C' vi-forward-char
        bindkey -M menuselect '^[[D' vi-backward-char
        
        # Other navigation keys
        bindkey -M menuselect '^[[Z' reverse-menu-complete
        bindkey -M menuselect '^M' accept-line
        bindkey -M menuselect '^[' send-break
        bindkey -M menuselect '^I' accept-line  # Tab to accept
        bindkey -M menuselect ' ' accept-line   # Space to accept
    fi
}

# Setup menu select bindings after completion is loaded
autoload -Uz add-zsh-hook
add-zsh-hook precmd _setup_menu_select

# =============================================================================
# HELP WIDGET
# =============================================================================

_show_keybindings_help() {
    echo ""
    echo "ZSH Key Bindings Help"
    echo "====================="
    echo ""
    echo "Navigation:"
    echo "  Ctrl+A/E    - Beginning/End of line"
    echo "  Ctrl+B/F    - Backward/Forward character"
    echo "  Alt+B/F     - Backward/Forward word"
    echo "  Ctrl+←/→    - Backward/Forward word"
    echo ""
    echo "Editing:"
    echo "  Ctrl+K      - Kill to end of line"
    echo "  Ctrl+U      - Kill whole line"
    echo "  Ctrl+W      - Kill word backward"
    echo "  Alt+D       - Kill word forward"
    echo "  Ctrl+Y      - Paste (yank)"
    echo ""
    echo "History:"
    echo "  Ctrl+R      - History search backward"
    echo "  Ctrl+P/N    - Previous/Next history"
    echo "  ↑/↓         - History navigation"
    echo ""
    echo "Custom:"
    echo "  Ctrl+T      - File finder (fzf)"
    echo "  Ctrl+G      - Directory finder (fzf)"
    echo "  Ctrl+H      - History search (fzf)"
    echo "  Alt+G       - Git status"
    echo "  Alt+S       - Toggle sudo"
    echo "  Alt+P       - Jump to Projects"
    echo "  Ctrl+L      - Clear and show info"
    echo "  F1-F3       - Various utilities"
    echo ""
    echo "Press any key to continue..."
    read -k1
    zle reset-prompt
}
zle -N _show_keybindings_help
bindkey '^[?' _show_keybindings_help     # Alt+?

# Function to list all custom key bindings
list_keybindings() {
    echo "Custom Key Bindings:"
    echo "==================="
    bindkey | grep -E "(fzf|git|sudo|jump|quote|clear)" | sort
}
