#!/usr/bin/env zsh
# =============================================================================
# Oh My Posh Theme Configuration - Simplified and Clean
# =============================================================================

# Function to validate theme file
_validate_theme_file() {
    local theme_file="$1"
    
    if [[ ! -f "$theme_file" ]]; then
        return 1
    fi
    
    # Check if file is too small (likely corrupted)
    if [[ $(wc -c < "$theme_file") -lt 100 ]]; then
        return 1
    fi
    
    # Check if file contains error messages
    if grep -q "404\|Not Found\|Error\|error" "$theme_file" 2>/dev/null; then
        return 1
    fi
    
    # Check if file is valid JSON
    if ! python3 -m json.tool "$theme_file" >/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Function to clean up prompt and remove extra spaces (ultra-simplified)
_clean_prompt() {
    # Only clean if PROMPT is set
    if [[ -n "$PROMPT" ]]; then
        # Remove multiple consecutive spaces
        while [[ "$PROMPT" == *"  "* ]]; do
            PROMPT="${PROMPT//  / }"
        done
        
        # Remove empty color codes
        PROMPT="${PROMPT//%\{}"
        PROMPT="${PROMPT//\}/}"
        
        # Remove trailing spaces and tabs
        while [[ "$PROMPT" == *" " ]]; do
            PROMPT="${PROMPT% }"
        done
        while [[ "$PROMPT" == *$'\t' ]]; do
            PROMPT="${PROMPT%$'\t'}"
        done
        
        # Remove Oh My Posh artifacts
        PROMPT="${PROMPT%%%}"
    fi
    
    # Clean RPROMPT similarly
    if [[ -n "$RPROMPT" ]]; then
        while [[ "$RPROMPT" == *"  "* ]]; do
            RPROMPT="${RPROMPT//  / }"
        done
        RPROMPT="${RPROMPT//%\{}"
        RPROMPT="${RPROMPT//\}/}"
        while [[ "$RPROMPT" == *" " ]]; do
            RPROMPT="${RPROMPT% }"
        done
        while [[ "$RPROMPT" == *$'\t' ]]; do
            RPROMPT="${RPROMPT%$'\t'}"
        done
        RPROMPT="${RPROMPT%%%}"
    fi
}

# Check if Oh My Posh is available
if command -v oh-my-posh >/dev/null 2>&1; then
    # Initialize Oh My Posh with optimized configuration
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
    
    local theme_file=""
    local themes_dir="$HOME/.poshthemes"
    
    # Find the first available and valid theme
    for theme in "${preferred_themes[@]}"; do
        local candidate_file="$themes_dir/$theme"
        if _validate_theme_file "$candidate_file"; then
            theme_file="$candidate_file"
            break
        else
            # Remove invalid theme files
            if [[ -f "$candidate_file" ]]; then
                echo "Warning: Removing invalid theme file: $theme" >&2
                rm -f "$candidate_file"
            fi
        fi
    done
    
    # Oh My Posh Configuration
    export OMP_DEBUG=0
    export OMP_TRANSIENT=1
    
    if [[ -n "$theme_file" ]]; then
        # Initialize with the found theme
        eval "$(oh-my-posh init zsh --config "$theme_file")"
    else
        # Fallback to default theme
        eval "$(oh-my-posh init zsh)"
    fi
    
    # Add a hook to clean up prompt on every command
    add-zsh-hook precmd _clean_prompt
    
    # Linux-specific additional cleanup
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        _linux_prompt_cleanup() {
            if [[ -n "$PROMPT" ]]; then
                # More aggressive space cleaning for Linux
                while [[ "$PROMPT" == *"   "* ]]; do
                    PROMPT="${PROMPT//   / }"
                done
                
                # Clean up empty color codes
                PROMPT="${PROMPT//%\{}"
                PROMPT="${PROMPT//\}/}"
                
                # Remove spaces around color codes
                PROMPT="${PROMPT// %\{/%\{}"
                PROMPT="${PROMPT//\}%\{/\}%\{"
                
                # Final space normalization
                while [[ "$PROMPT" == *"  "* ]]; do
                    PROMPT="${PROMPT//  / }"
                done
                while [[ "$PROMPT" == *" " ]]; do
                    PROMPT="${PROMPT% }"
                done
            fi
        }
        add-zsh-hook precmd _linux_prompt_cleanup
    fi
else
    # Fallback to custom prompt if Oh My Posh is not available
    _setup_custom_prompt() {
        # Load vcs_info for git status
        autoload -Uz vcs_info
        precmd() { 
            # Only run vcs_info if we're in a git repository and not in a transient prompt
            if [[ -z "$OMP_TRANSIENT" ]] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                vcs_info
            fi
        }
        
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
fi

# Simple theme switching function
posh_theme() {
    local theme_name="$1"
    
    if [[ -z "$theme_name" ]]; then
        echo "Usage: posh_theme <theme_name>"
        return 1
    fi
    
    local theme_file="$HOME/.poshthemes/${theme_name}.omp.json"
    
    # Check for YAML format if JSON not found
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$HOME/.poshthemes/${theme_name}.omp.yaml"
    fi
    
    if [[ -f "$theme_file" ]]; then
        # Validate theme file
        if ! _validate_theme_file "$theme_file"; then
            echo "Theme file is corrupted: $theme_name"
            echo "Removing corrupted theme file..."
            rm -f "$theme_file"
            return 1
        fi
        
        # Update the preferred themes array to put the selected theme first
        local temp_file
        temp_file=$(mktemp 2>/dev/null || echo "/tmp/posh_theme_$$.tmp")
        local theme_filename=$(basename "$theme_file")
        
        # Ensure temp file is clean
        [[ -f "$temp_file" ]] && rm -f "$temp_file"
        
        # Simple awk script to update theme preference
        awk -v theme="$theme_filename" '
        /local preferred_themes=\(/ {
            print $0
            print "        \"" theme "\""
            next
        }
        /^[[:space:]]*"[a-zA-Z0-9_]*\.omp\.json"/ && !printed {
            if ($0 !~ theme) {
                print "        \"" theme "\""
                printed = 1
            }
        }
        { print }
        ' ~/.config/zsh/themes/prompt.zsh > "$temp_file"
        
        if [[ -s "$temp_file" ]] && [[ -f "$temp_file" ]]; then
            mv "$temp_file" ~/.config/zsh/themes/prompt.zsh
            echo "Switched to theme: $theme_name"
            echo "Reload your shell with: source ~/.zshrc"
        else
            echo "Failed to update theme configuration"
            [[ -f "$temp_file" ]] && rm -f "$temp_file"
        fi
    else
        echo "Theme not found: $theme_name"
        echo "Available themes:"
        ls -1 "$HOME/.poshthemes"/*.omp.* 2>/dev/null | sed 's/.*\///' | sed 's/\.omp\.\(json\|yaml\)$//' | sort | head -10
    fi
}

# Simple theme list function
posh_themes() {
    if command -v oh-my-posh >/dev/null 2>&1; then
        echo "Available Oh My Posh themes:"
        echo "=============================="
        
        # List official themes
        local theme_dir="$HOME/.poshthemes"
        if [[ -d "$theme_dir" ]]; then
            echo "Official themes ($theme_dir):"
            ls -1 "$theme_dir"/*.omp.json 2>/dev/null | sed 's/.*\///' | sed 's/\.omp\.json$//' | sort
        else
            echo "No themes found. Install with: oh-my-posh theme install"
        fi
        
        echo ""
        echo "Usage:"
        echo "  posh_theme <theme_name>     # Switch to a theme"
        echo "  posh_themes                # List all available themes"
    else
        echo "Oh My Posh is not installed"
        echo "Install with: brew install oh-my-posh (macOS) or follow official docs"
    fi
}

# Export theme functions
export -f posh_themes posh_theme 2>/dev/null || true