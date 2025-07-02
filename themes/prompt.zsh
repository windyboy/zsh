#!/usr/bin/env zsh
# =============================================================================
# Prompt Theme Configuration
# =============================================================================

# Theme configuration
POSH_THEME="${POSH_THEME:-$HOME/.poshthemes/pararussel.omp.json}"

# Check if oh-my-posh is available
if command -v oh-my-posh >/dev/null 2>&1; then
    # Check if theme file exists
    if [[ -f "$POSH_THEME" ]]; then
        # Initialize oh-my-posh
        eval "$(oh-my-posh init zsh --config "$POSH_THEME")"
    else
        print -P "%F{160}▓▒░ Theme file not found: $POSH_THEME%f"
        _setup_fallback_prompt
    fi
else
    print -P "%F{160}▓▒░ oh-my-posh not found, using fallback prompt%f"
    _setup_fallback_prompt
fi

# Fallback prompt function
_setup_fallback_prompt() {
    # Simple but informative prompt
    autoload -Uz vcs_info
    precmd() { vcs_info }
    
    zstyle ':vcs_info:git:*' formats '%F{blue}(%b)%f'
    zstyle ':vcs_info:*' enable git
    
    setopt PROMPT_SUBST
    PROMPT='%F{green}%n@%m%f:%F{cyan}%~%f${vcs_info_msg_0_} %# '
    RPROMPT='%F{yellow}[%D{%H:%M:%S}]%f'
}

# Prompt customization functions
prompt_context() {
    if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        echo -n "%F{yellow}%n@%m%f:"
    fi
}

prompt_dir() {
    echo -n "%F{cyan}%~%f"
}

prompt_git() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        if [[ -n "$branch" ]]; then
            echo -n " %F{blue}($branch)%f"
        fi
    fi
}

# Export theme functions for use in other modules
export -f prompt_context prompt_dir prompt_git 2>/dev/null || true
