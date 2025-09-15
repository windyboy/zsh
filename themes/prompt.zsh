#!/usr/bin/env zsh
# =============================================================================
# Oh My Posh Theme Configuration
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

# Function to clean up prompt and remove extra spaces
_clean_prompt() {
    # Remove trailing spaces from PROMPT and RPROMPT
    PROMPT="${PROMPT%[[:space:]]}"
    RPROMPT="${RPROMPT%[[:space:]]}"
    
    # Remove any double spaces
    PROMPT="${PROMPT//  / }"
    RPROMPT="${RPROMPT//  / }"
    
    # Remove trailing % characters (Oh My Posh artifact)
    PROMPT="${PROMPT%%%}"
    RPROMPT="${RPROMPT%%%}"
    
    # Ensure proper newline handling
    if [[ "$PROMPT" =~ %$ ]]; then
        PROMPT="${PROMPT%%%}"
    fi
}

# Check if Oh My Posh is available
if command -v oh-my-posh >/dev/null 2>&1; then
    # Initialize Oh My Posh with optimized configuration
    # Try multiple themes in order of preference
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
                echo "⚠️  Removing invalid theme file: $theme" >&2
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
    
    # Also clean up after Oh My Posh sets the prompt
    add-zsh-hook preexec _clean_prompt
    
    # Popular official themes you can use:
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/agnoster.omp.json)"      # Classic powerline
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/atomic.omp.json)"        # Modern atomic
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/blueish.omp.json)"       # Blue theme
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/catppuccin.omp.json)"    # Catppuccin colors
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/dracula.omp.json)"       # Dracula theme
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/gruvbox.omp.json)"       # Gruvbox colors
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/jandedobbeleer.omp.json)" # Author's theme
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/m365princess.omp.json)"   # Princess theme
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/paradox.omp.json)"       # Paradox theme
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/robbyrussell.omp.json)"  # Robby Russell classic style
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/star.omp.json)"          # Star theme
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/tokyonight.omp.json)"    # Tokyo Night
else
    # Fallback to custom prompt if Oh My Posh is not available
    _setup_custom_prompt() {
        # Load vcs_info for git status (optimized)
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

# =============================================================================
# Oh My Posh Theme Management Functions
# =============================================================================

# Function to list available themes
posh_themes() {
    if command -v oh-my-posh >/dev/null 2>&1; then
        echo "🎨 Available Oh My Posh themes:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # List official themes
        local theme_dir="$HOME/.poshthemes"
        if [[ -d "$theme_dir" ]]; then
            echo "📁 Official themes ($theme_dir):"
            ls -1 "$theme_dir"/*.omp.json 2>/dev/null | sed 's/.*\///' | sed 's/\.omp\.json$//' | sort
        else
            echo "📦 No themes found. Install with: oh-my-posh theme install"
        fi
        
        echo ""
        echo "💡 Usage:"
        echo "  posh_theme <theme_name>     # Switch to an official theme"
        echo "  posh_theme_list            # List all available themes"
        echo "  posh_theme_install         # Install official themes"
    else
        echo "❌ Oh My Posh is not installed"
        echo "📦 Install with: brew install oh-my-posh (macOS) or follow official docs"
    fi
}

# Function to switch themes
posh_theme() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: posh_theme <theme_name>"
        echo "Example: posh_theme agnoster"
        echo ""
        echo "Popular themes:"
        echo "  agnoster, atomic, blueish, catppuccin, dracula"
        echo "  gruvbox, jandedobbeleer, m365princess, paradox"
        echo "  robbyrussell, star, tokyonight"
        return 1
    fi
    
    local theme_name="$1"
    local theme_file="$HOME/.poshthemes/${theme_name}.omp.json"
    
    if [[ -f "$theme_file" ]]; then
        # Create a backup of the current prompt.zsh
        cp ~/.config/zsh/themes/prompt.zsh ~/.config/zsh/themes/prompt.zsh.backup
        
        # Update the preferred themes array to put the selected theme first
        local temp_file=$(mktemp)
        awk -v theme="${theme_name}.omp.json" '
        /local preferred_themes=\(/ {
            print $0
            print "        \"" theme "\""
            next
        }
        /^[[:space:]]*"[^"]*\.omp\.json"/ && !printed {
            if ($0 !~ theme) {
                print "        \"" theme "\""
                printed = 1
            }
        }
        { print }
        ' ~/.config/zsh/themes/prompt.zsh > "$temp_file"
        
        if [[ -s "$temp_file" ]]; then
            mv "$temp_file" ~/.config/zsh/themes/prompt.zsh
            echo "✅ Switched to theme: $theme_name"
            echo "🔄 Reload your shell with: source ~/.zshrc"
        else
            echo "❌ Failed to update theme configuration"
            rm -f "$temp_file"
        fi
    else
        echo "❌ Theme not found: $theme_file"
        echo "💡 Install themes with: posh_theme_install"
        echo "💡 Available themes:"
        ls -1 "$HOME/.poshthemes"/*.omp.json 2>/dev/null | sed 's/.*\///' | sed 's/\.omp\.json$//' | head -10
    fi
}

# Function to list all available themes
posh_theme_list() {
    if command -v oh-my-posh >/dev/null 2>&1; then
        echo "📋 All available Oh My Posh themes:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        oh-my-posh theme list
    else
        echo "❌ Oh My Posh is not installed"
    fi
}

# Function to install official themes
posh_theme_install() {
    if command -v oh-my-posh >/dev/null 2>&1; then
        echo "📦 Installing Oh My Posh themes..."
        echo "💡 This will install themes using the same method as install-themes.sh"
        
        # Use the install-themes.sh script if available
        if [[ -f "$HOME/.config/zsh/install-themes.sh" ]]; then
            "$HOME/.config/zsh/install-themes.sh" --all
        elif [[ -f "./install-themes.sh" ]]; then
            ./install-themes.sh --all
        else
            # Fallback to oh-my-posh theme install
            oh-my-posh theme install
        fi
        
        echo "✅ Themes installed successfully"
        echo "💡 Use 'posh_themes' to see available themes"
    else
        echo "❌ Oh My Posh is not installed"
        echo "📦 Install with: ./install-deps.sh"
    fi
}

# Export theme functions
export -f posh_themes posh_theme posh_theme_list posh_theme_install 2>/dev/null || true
