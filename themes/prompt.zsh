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

typeset -g POSH_THEME_PREF_FILE="${POSH_THEME_PREF_FILE:-$ZSH_CONFIG_DIR/themes/theme-preference}"

_posh_resolve_theme_name() {
    local name="$1"
    [[ -z "$name" ]] && return 1
    if [[ "$name" == *.omp.json || "$name" == *.omp.yaml ]]; then
        echo "$name"
    else
        echo "${name}.omp.json"
    fi
}

_posh_locate_theme_file() {
    local theme_name="$1"
    local themes_dir="$2"
    local resolved="$(_posh_resolve_theme_name "$theme_name")" || return 1
    local -a candidates=("$resolved")

    if [[ "$resolved" == *.omp.json ]]; then
        candidates+=("${resolved%.omp.json}.omp.yaml")
    fi

    local candidate_name candidate_path
    for candidate_name in "${candidates[@]}"; do
        candidate_path="$themes_dir/$candidate_name"
        if [[ -f "$candidate_path" ]]; then
            echo "$candidate_path"
            return 0
        fi
    done
    return 1
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
    local -a preferred_themes=(
        "1_shell.omp.json"
        "agnoster.omp.json" 
        "jandedobbeleer.omp.json"
        "atomic.omp.json"
        "dracula.omp.json"
        "gruvbox.omp.json"
        "paradox.omp.json"
        "robbyrussell.omp.json"
    )
    local saved_theme=""
    if [[ -n "${ZSH_POSH_THEME:-}" ]]; then
        saved_theme="$(_posh_resolve_theme_name "$ZSH_POSH_THEME")"
    elif [[ -f "$POSH_THEME_PREF_FILE" ]]; then
        saved_theme="$(_posh_resolve_theme_name "$(head -n1 "$POSH_THEME_PREF_FILE" 2>/dev/null)")"
    fi

    if [[ -n "$saved_theme" ]]; then
        local -a ordered=()
        ordered+=("$saved_theme")
        local theme
        for theme in "${preferred_themes[@]}"; do
            [[ "$theme" == "$saved_theme" ]] && continue
            ordered+=("$theme")
        done
        preferred_themes=("${ordered[@]}")
    fi
    
    # Find first valid theme
    local theme_file=""
    for theme in "${preferred_themes[@]}"; do
        local candidate
        candidate="$(_posh_locate_theme_file "$theme" "$themes_dir")" || continue
        if _validate_theme_file "$candidate"; then
            theme_file="$candidate"
            break
        elif [[ -f "$candidate" ]]; then
            rm -f "$candidate"
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
    local theme_file
    theme_file="$(_posh_locate_theme_file "$theme_name" "$themes_dir")" || {
        echo "Theme not found: $theme_name"
        echo "Available themes:"
        ls -1 "$themes_dir"/*.omp.* 2>/dev/null | sed 's/.*\///; s/\.omp\.\(json\|yaml\)$//' | sort | head -10
        return 1
    }

    if ! _validate_theme_file "$theme_file"; then
        echo "Invalid theme: $theme_name"
        return 1
    fi

    mkdir -p "$(dirname "$POSH_THEME_PREF_FILE")"
    local stored_name
    stored_name="$(basename "$theme_file")"
    print -r -- "$stored_name" >"$POSH_THEME_PREF_FILE"
    echo "Saved theme preference: ${stored_name%.*}"
    echo "Reload with: source ~/.zshrc"
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
