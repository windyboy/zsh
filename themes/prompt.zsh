#!/usr/bin/env zsh
# =============================================================================
# Oh My Posh Theme Configuration - Clean and Simple
# =============================================================================

# Validate theme file
_validate_theme_file() {
    local theme_file="$1"
    [[ -f "$theme_file" ]] || return 1
    [[ $(wc -c < "$theme_file") -gt 100 ]] || return 1

    # Check for HTTP error responses (only at start of line or as HTML)
    # This avoids matching legitimate template variables like .Error
    if grep -qiE "^(404|Not Found|<!DOCTYPE|<html)" "$theme_file" 2>/dev/null; then
        return 1
    fi

    # Determine file type and validate accordingly
    if [[ "$theme_file" == *.omp.json ]]; then
        # Validate JSON format
        if command -v python3 >/dev/null 2>&1; then
            python3 -m json.tool "$theme_file" >/dev/null 2>&1 || return 1
        elif command -v jq >/dev/null 2>&1; then
            jq empty "$theme_file" >/dev/null 2>&1 || return 1
        else
            # Basic validation: file size check only if no validator available
            [[ $(wc -c < "$theme_file") -ge 100 ]] || return 1
        fi
    elif [[ "$theme_file" == *.omp.yaml ]]; then
        # Validate YAML format (basic check - check if yq or python yaml available)
        if command -v yq >/dev/null 2>&1; then
            yq eval . "$theme_file" >/dev/null 2>&1 || return 1
        elif command -v python3 >/dev/null 2>&1; then
            python3 -c "import yaml; yaml.safe_load(open('''$theme_file'''))" >/dev/null 2>&1 || return 1
        else
            # Basic validation: file size check only if no validator available
            [[ $(wc -c < "$theme_file") -ge 100 ]] || return 1
        fi
    else
        # Unknown format, basic size check
        [[ $(wc -c < "$theme_file") -ge 100 ]] || return 1
    fi

    return 0
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

# Initialize prompt system
_init_prompt_system() {
    # Register cleanup hook
    autoload -Uz add-zsh-hook 2>/dev/null
    add-zsh-hook precmd _clean_prompt 2>/dev/null

    # Initialize Oh My Posh if available
    if command -v oh-my-posh >/dev/null 2>&1; then
        local themes_dir="$HOME/.poshthemes"
        local -a preferred_themes=(
            "atomicBit.omp.json"
            "paradox.omp.json"
            "agnosterplus.omp.json"
            "1_shell.omp.json"
            "aliens.omp.json"
            "amro.omp.json"
            "blue-owl.omp.json"
            "blueish.omp.json"
        )
        local saved_theme=""
        if [[ -n "${ZSH_POSH_THEME:-}" ]]; then
            saved_theme="$(_posh_resolve_theme_name "$ZSH_POSH_THEME")"
        elif [[ -f "$POSH_THEME_PREF_FILE" ]]; then
            local pref_content
            pref_content="$(head -n1 "$POSH_THEME_PREF_FILE" 2>/dev/null | tr -d '[:space:]')"
            [[ -n "$pref_content" ]] && saved_theme="$(_posh_resolve_theme_name "$pref_content")"
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
                [[ "${ZSH_DEBUG:-0}" == "1" ]] && echo "Removing invalid theme: $candidate" >&2
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
        _prompt_vcs_info_pre() {
            git rev-parse --is-inside-work-tree >/dev/null 2>&1 && vcs_info
        }
        add-zsh-hook precmd _prompt_vcs_info_pre

        zstyle ':vcs_info:git:*' formats '%F{blue}(%b)%f'
        zstyle ':vcs_info:*' enable git
        setopt PROMPT_SUBST

        PROMPT='%F{green}%n@%m%f:%F{cyan}%~%f${vcs_info_msg_0_} %# '
        RPROMPT='%F{yellow}[%D{%H:%M:%S}]%f'
    fi
}

# Initialize the prompt system
_init_prompt_system

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
    # Store base name without extension for consistency
    stored_name="$(basename "$theme_file" .omp.json)"
    stored_name="${stored_name%.omp.yaml}"
    print -r -- "$stored_name" >"$POSH_THEME_PREF_FILE"
    echo "Saved theme preference: $stored_name"
    echo "Reload with: source ~/.zshrc"
}

# List available themes
posh_themes() {
    if command -v oh-my-posh >/dev/null 2>&1; then
        local theme_dir="$HOME/.poshthemes"
        echo "Available Oh My Posh themes:"
        echo "=============================="

        if [[ -d "$theme_dir" ]]; then
            # List both JSON and YAML themes, removing duplicates
            {
                ls -1 "$theme_dir"/*.omp.json 2>/dev/null | sed 's/.*\///; s/\.omp\.json$//'
                ls -1 "$theme_dir"/*.omp.yaml 2>/dev/null | sed 's/.*\///; s/\.omp\.yaml$//'
            } | sort -u
        else
            echo "No themes found. Install with: oh-my-posh theme install"
        fi

        echo ""
        echo "Usage: posh_theme <theme_name>"
    else
        echo "Oh My Posh not installed. Install with: brew install oh-my-posh"
    fi
}
# Interactive theme changer with preview
change_theme() {
    if ! command -v oh-my-posh >/dev/null 2>&1; then
        echo "Oh My Posh not installed. Install with: brew install oh-my-posh"
        return 1
    fi

    if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf not available. Falling back to posh_theme command."
        echo "Usage: posh_theme <theme_name>"
        posh_themes
        return 1
    fi

    local themes_dir="$HOME/.poshthemes"
    local selected_theme

    # Get list of available themes (both JSON and YAML)
    local themes_list
    themes_list=$({
        ls -1 "$themes_dir"/*.omp.json 2>/dev/null | sed 's|.*/||; s|\.omp\.json$||'
        ls -1 "$themes_dir"/*.omp.yaml 2>/dev/null | sed 's|.*/||; s|\.omp\.yaml$||'
    } | sort -u)

    if [[ -z "$themes_list" ]]; then
        echo "No themes found in $themes_dir"
        return 1
    fi

    # Use fzf to select theme with preview (try JSON first, then YAML)
    local preview_cmd
    preview_cmd="if [ -f \"$themes_dir/{}.omp.json\" ]; then oh-my-posh print primary --config \"$themes_dir/{}.omp.json\" 2>/dev/null; elif [ -f \"$themes_dir/{}.omp.yaml\" ]; then oh-my-posh print primary --config \"$themes_dir/{}.omp.yaml\" 2>/dev/null; else echo \"Preview not available\"; fi"
    selected_theme=$(printf '%s\n' "$themes_list" | fzf --prompt="Select theme: " --preview="$preview_cmd" --preview-window=right:50%:wrap --height=40% --border)

    if [[ -n "$selected_theme" ]]; then
        echo "Switching to theme: $selected_theme"
        posh_theme "$selected_theme"
        echo "Theme changed! Run 'source ~/.zshrc' to apply."
    else
        echo "No theme selected."
    fi
}

# Quick theme switcher (alias for change_theme)
ct() {
    change_theme "$@"
}

# Functions are automatically available in zsh, no export needed
# (export -f is bash-specific and doesn't work in zsh)
