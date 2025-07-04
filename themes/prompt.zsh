#!/usr/bin/env zsh
# =============================================================================
# Prompt Theme Configuration
# =============================================================================

# Custom prompt setup
_setup_custom_prompt() {
    # Load vcs_info for git status
    autoload -Uz vcs_info
    precmd() { vcs_info }
    
    # Configure git status display
    zstyle ':vcs_info:git:*' formats '%F{blue}(%b)%f'
    zstyle ':vcs_info:*' enable git
    
    # Enable prompt substitution
    setopt PROMPT_SUBST
    
    # Main prompt with git status
    PROMPT='%F{green}%n@%m%f:%F{cyan}%~%f${vcs_info_msg_0_} %# '
    
    # Right prompt with time
    RPROMPT='%F{yellow}[%D{%H:%M:%S}]%f'
}

# Initialize the custom prompt
_setup_custom_prompt

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
