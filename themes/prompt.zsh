#!/usr/bin/env zsh
# =============================================================================
# Oh My Posh Theme Configuration - Clean and Simple
# =============================================================================

# Validate theme file
_validate_theme_file() {
    local theme_file="$1"
    [[ -f "$theme_file" ]] && [[ $(wc -c < "$theme_file") -gt 100 ]] && \
    ! grep -q "404\|Not Found\|Error\|error" "$theme_file" 2>/dev/null && \
    python3 -m json.tool "$theme_file" >/dev/null 2>&1
}

# Simple prompt cleanup
_clean_prompt() {
    [[ -n "$PROMPT" ]] && PROMPT="${PROMPT%[[:space:]]}"
    [[ -n "$RPROMPT" ]] && RPROMPT="${RPROMPT%[[:space:]]}"
}

# Register cleanup hook
autoload -Uz add-zsh-hook 2>/dev/null
add-zsh-hook precmd _clean_prompt 2>/dev/null

# Initialize Oh My Posh if available
if command -v oh-my-posh >/dev/null 2>&1; then
    local themes_dir="$HOME/.poshthemes"
    local preferred_themes=(
        "1_shell.omp.json"
        "agnoster.omp.json" 
        "jandedobbeleer.omp.json"
        "atomic.omp.json"
        "dracula.omp.json"
        "gruvbox.omp.json"
        "paradox.omp.json"
        "robbyrussell.omp.json"
    )
    
    # Find first valid theme
    local theme_file=""
    for theme in "${preferred_themes[@]}"; do
        local candidate="$themes_dir/$theme"
        if _validate_theme_file "$candidate"; then
            theme_file="$candidate"
            break
        elif [[ -f "$candidate" ]]; then
            rm -f "$candidate"  # Remove invalid theme
        fi
    done
    
    # Configure and initialize
    export OMP_DEBUG=0
    export OMP_TRANSIENT=1
    
    if [[ -n "$theme_file" ]]; then
        eval "$(oh-my-posh init zsh --config "$theme_file")"
    else
        eval "$(oh-my-posh init zsh)"
    fi
else
    # Fallback custom prompt
    autoload -Uz vcs_info
    precmd() { 
        git rev-parse --is-inside-work-tree >/dev/null 2>&1 && vcs_info
    }
    
    zstyle ':vcs_info:git:*' formats '%F{blue}(%b)%f'
    zstyle ':vcs_info:*' enable git
    setopt PROMPT_SUBST
    
    PROMPT='%F{green}%n@%m%f:%F{cyan}%~%f${vcs_info_msg_0_} %# '
    RPROMPT='%F{yellow}[%D{%H:%M:%S}]%f'
fi

# Theme switching function
posh_theme() {
    local theme_name="$1"
    [[ -z "$theme_name" ]] && { echo "Usage: posh_theme <theme_name>"; return 1; }
    
    local themes_dir="$HOME/.poshthemes"
    local theme_file="$themes_dir/${theme_name}.omp.json"
    [[ ! -f "$theme_file" ]] && theme_file="$themes_dir/${theme_name}.omp.yaml"
    
    if [[ -f "$theme_file" ]]; then
        if ! _validate_theme_file "$theme_file"; then
            echo "Invalid theme: $theme_name"
            rm -f "$theme_file"
            return 1
        fi
        
        # Update preferred themes list
        local config_file="${BASH_SOURCE[0]:-$0}"
        local temp_file=$(mktemp) || return 1
        
        sed "s/\"[^\"]*\.omp\.json\"/\"$(basename "$theme_file")\"/" "$config_file" > "$temp_file" && \
        mv "$temp_file" "$config_file" && \
        echo "Switched to theme: $theme_name (reload with: source ~/.zshrc)"
    else
        echo "Theme not found: $theme_name"
        echo "Available themes:"
        ls -1 "$themes_dir"/*.omp.* 2>/dev/null | sed 's/.*\///; s/\.omp\.\(json\|yaml\)$//' | sort | head -10
    fi
}

# List available themes
posh_themes() {
    if command -v oh-my-posh >/dev/null 2>&1; then
        local theme_dir="$HOME/.poshthemes"
        echo "Available Oh My Posh themes:"
        echo "=============================="
        
        if [[ -d "$theme_dir" ]]; then
            ls -1 "$theme_dir"/*.omp.json 2>/dev/null | sed 's/.*\///; s/\.omp\.json$//' | sort
        else
            echo "No themes found. Install with: oh-my-posh theme install"
        fi
        
        echo ""
        echo "Usage: posh_theme <theme_name>"
    else
        echo "Oh My Posh not installed. Install with: brew install oh-my-posh"
    fi
}

# Export functions
export -f posh_themes posh_theme 2>/dev/null || true