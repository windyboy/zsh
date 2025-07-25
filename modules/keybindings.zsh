#!/usr/bin/env zsh
# =============================================================================
# Keybindings Module - Key Binding Configuration
# Description: Only high-frequency, essential, minimal key bindings with clear comments and unified naming.
# =============================================================================

# Color output tools
# Load centralized color functions
source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# Module specific wrappers
kb_color_red()   { color_red "$@"; }
kb_color_green() { color_green "$@"; }

# -------------------- Basic Editing/Navigation --------------------
bindkey -e
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^B' backward-char
bindkey '^F' forward-char
bindkey '^D' delete-char
bindkey '^H' backward-delete-char
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^Y' yank
bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[d' kill-word
bindkey '^[^?' backward-kill-word
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
# Tab completion - ensure this is properly bound
bindkey '^I' complete-word
bindkey '^[[Z' reverse-menu-complete

# VS Code Terminal Fix - Add alternative completion triggers
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # Alternative completion triggers for VS Code terminal
    bindkey '^ ' autosuggest-accept 2>/dev/null || true
    bindkey '^@' complete-word 2>/dev/null || true
    # Force menu completion for VS Code (only if fzf-tab is not available)
    if ! command -v fzf >/dev/null 2>&1; then
        zstyle ':completion:*' menu yes select=1
        zstyle ':completion:*' force-list always
    fi
fi
bindkey '^T' transpose-chars
bindkey '^Z' undo
bindkey '^[z' redo

# -------------------- Custom Function Bindings --------------------
# Smart cd
_smart_cd() {
    if [[ $# -eq 0 ]]; then cd ~
    elif [[ -d "$1" ]]; then cd "$1"
    else local dir=$(find . -type d -name "*$1*" 2>/dev/null | head -1)
        [[ -n "$dir" ]] && cd "$dir" || kb_color_red "Not found: $1"
    fi
}
# Quick edit
_quick_edit() {
    local file="$1"
    [[ -z "$file" ]] && kb_color_red "Usage: _quick_edit <file>" && return 1
    [[ -f "$file" ]] && ${EDITOR:-code} "$file" || kb_color_red "Not found: $file"
}
bindkey -s '^[e' '_quick_edit\n'
bindkey -s '^[d' '_smart_cd\n'

# -------------------- Plugin-Related Bindings --------------------
# FZF widgets - Use safe binding to avoid zsh-syntax-highlighting warnings
if command -v fzf >/dev/null 2>&1; then
    # Ensure FZF widgets are properly registered to avoid zsh-syntax-highlighting warnings
    autoload -Uz fzf-file-widget fzf-history-widget fzf-cd-widget 2>/dev/null || true
    zle -N fzf-file-widget 2>/dev/null || true
    zle -N fzf-history-widget 2>/dev/null || true
    zle -N fzf-cd-widget 2>/dev/null || true

    # Bind FZF widgets (avoiding conflicts with existing bindings)
    bindkey '^[f' fzf-file-widget 2>/dev/null || true
    bindkey '^[r' fzf-history-widget 2>/dev/null || true
    # Note: ^[d is already bound to _smart_cd, so we'll use a different key for fzf-cd-widget
    bindkey '^[c' fzf-cd-widget 2>/dev/null || true
fi
if (( ${+_comps[zsh-autosuggestions]} )); then
    bindkey '^[;' autosuggest-accept 2>/dev/null || true
    bindkey '^[,' autosuggest-execute 2>/dev/null || true
    bindkey '^[/' autosuggest-toggle 2>/dev/null || true
fi
# History substring search keybindings (check if functions exist)
if (( ${+functions[history-substring-search-up]} )); then
    bindkey '^[[A' history-substring-search-up 2>/dev/null || true
    bindkey '^[[B' history-substring-search-down 2>/dev/null || true
    bindkey '^P' history-substring-search-up 2>/dev/null || true
    bindkey '^N' history-substring-search-down 2>/dev/null || true
fi

# -------------------- Completion Menu Navigation --------------------
_setup_menu_select() {
    if zmodload -e zsh/complist 2>/dev/null || zmodload zsh/complist 2>/dev/null; then
        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
        bindkey -M menuselect 'j' vi-down-line-or-history
        bindkey -M menuselect '^[[Z' reverse-menu-complete
        bindkey -M menuselect '^M' accept-line
        bindkey -M menuselect '^[' send-break
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _setup_menu_select

# -------------------- System Platform Adaptation --------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    bindkey '^[^[[D' backward-word 2>/dev/null || true
    bindkey '^[^[[C' forward-word 2>/dev/null || true
    bindkey '^[^?' backward-kill-word 2>/dev/null || true
fi
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    bindkey '^[[H' beginning-of-line 2>/dev/null || true
    bindkey '^[[F' end-of-line 2>/dev/null || true
    bindkey '^[[3~' delete-char 2>/dev/null || true
fi

# -------------------- Common Functions --------------------
list_bindings() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "Usage: list_bindings" && return 0
    echo "⌨️  Common Shortcuts:"
    echo "Ctrl+A/E: Line start/end  Ctrl+B/F: Left/right move  Ctrl+D/H: Delete/backspace"
    echo "Ctrl+K/U: Delete to line end/start  Ctrl+W: Delete word  Ctrl+Y: Paste"
    echo "Alt+B/F/D: Word left/right/delete  Ctrl+R/S: History search  Ctrl+P/N: Up/down history"
    echo "Tab/Shift+Tab: Complete/reverse complete  Ctrl+T: Swap chars  Ctrl+Z: Undo"
}
test_bindings() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "Usage: test_bindings" && return 0
    local errors=0
    local test_bindings=("beginning-of-line:^A" "end-of-line:^E" "backward-char:^B" "forward-char:^F")
    for binding in "${test_bindings[@]}"; do
        local func="${binding%%:*}"
        local key="${binding##*:}"
        if bindkey | grep -q "$key.*$func"; then
            kb_color_green "✅ $func ($key)"
        else
            kb_color_red "❌ $func ($key)"
            ((errors++))
        fi
    done
    (( errors == 0 )) && kb_color_green "All bindings normal" || kb_color_red "$errors binding issues"
    return $errors
}

# -------------------- Reserved Custom Area --------------------
# Custom key bindings can be added in the custom/ directory

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED keybindings"
echo "INFO: Keybindings module initialized"
