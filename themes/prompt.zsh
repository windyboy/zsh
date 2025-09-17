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
        echo "  posh_theme list             # List all available themes"
        echo "  posh_theme preview <name>   # Preview a theme"
        echo "  posh_theme random           # Apply a random theme"
        echo "  posh_theme search <term>    # Search themes by name"
        echo "  posh_theme favorites        # Manage favorite themes"
        echo "  posh_theme recent            # Show recently used themes"
        echo "  posh_theme backup           # Backup theme configuration"
        echo "  posh_theme restore          # Restore theme configuration"
        echo "  posh_theme_install          # Install official themes"
    else
        echo "❌ Oh My Posh is not installed"
        echo "📦 Install with: brew install oh-my-posh (macOS) or follow official docs"
    fi
}

# Function to switch themes with enhanced features
posh_theme() {
    local theme_name="$1"
    local action="${1:-help}"
    
    # Handle special actions
    case "$action" in
        "help"|"-h"|"--help")
            echo "🎨 Oh My Posh Theme Manager"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "📋 Available Commands:"
            echo "  posh_theme <theme_name>     # Switch to a theme"
            echo "  posh_theme list             # List all available themes"
            echo "  posh_theme preview <name>   # Preview a theme"
            echo "  posh_theme random           # Apply a random theme"
            echo "  posh_theme favorites       # Manage favorite themes"
            echo "  posh_theme search <term>   # Search themes by name"
            echo "  posh_theme recent          # Show recently used themes"
            echo "  posh_theme backup          # Backup current theme config"
            echo "  posh_theme restore         # Restore theme config"
            echo ""
            echo "🎯 Popular themes:"
            echo "  agnoster, atomic, blueish, catppuccin, dracula"
            echo "  gruvbox, jandedobbeleer, m365princess, paradox"
            echo "  robbyrussell, star, tokyonight"
            echo ""
            echo "💡 Examples:"
            echo "  posh_theme agnoster         # Switch to agnoster theme"
            echo "  posh_theme preview dracula  # Preview dracula theme"
            echo "  posh_theme random           # Apply random theme"
            echo "  posh_theme search power     # Find themes with 'power' in name"
            return 0
            ;;
        "list")
            posh_theme_list
            return 0
            ;;
        "preview")
            if [[ $# -lt 2 ]]; then
                echo "❌ Usage: posh_theme preview <theme_name>"
                return 1
            fi
            posh_theme_preview "$2"
            return 0
            ;;
        "random")
            posh_theme_random
            return 0
            ;;
        "favorites")
            posh_theme_favorites "$@"
            return 0
            ;;
        "search")
            if [[ $# -lt 2 ]]; then
                echo "❌ Usage: posh_theme search <search_term>"
                return 1
            fi
            posh_theme_search "$2"
            return 0
            ;;
        "backup")
            posh_theme_backup
            return 0
            ;;
        "restore")
            posh_theme_restore
            return 0
            ;;
        "recent")
            posh_theme_recent
            return 0
            ;;
    esac
    
    # Regular theme switching
    if [[ -z "$theme_name" ]]; then
        echo "❌ Please specify a theme name"
        echo "💡 Use 'posh_theme help' for usage information"
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
            echo "❌ Theme file is corrupted: $theme_name"
            echo "🗑️  Removing corrupted theme file..."
            rm -f "$theme_file"
            echo "💡 Try reinstalling themes with: posh_theme_install"
            return 1
        fi
        
        # Create a backup of the current prompt.zsh
        cp ~/.config/zsh/themes/prompt.zsh ~/.config/zsh/themes/prompt.zsh.backup
        
        # Update the preferred themes array to put the selected theme first
        local temp_file
        temp_file=$(mktemp 2>/dev/null || echo "/tmp/posh_theme_$$.tmp")
        local theme_filename=$(basename "$theme_file")
        
        # Ensure temp file is clean
        [[ -f "$temp_file" ]] && rm -f "$temp_file"
        
        awk -v theme="$theme_filename" '
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
        
        if [[ -s "$temp_file" ]] && [[ -f "$temp_file" ]]; then
            mv "$temp_file" ~/.config/zsh/themes/prompt.zsh
            echo "✅ Switched to theme: $theme_name"
            echo "🔄 Reload your shell with: source ~/.zshrc"
            
            # Add to recent themes
            _add_to_recent_themes "$theme_name"
        else
            echo "❌ Failed to update theme configuration"
            [[ -f "$temp_file" ]] && rm -f "$temp_file"
        fi
    else
        echo "❌ Theme not found: $theme_name"
        echo "💡 Install themes with: posh_theme_install"
        echo "💡 Available themes:"
        ls -1 "$HOME/.poshthemes"/*.omp.* 2>/dev/null | sed 's/.*\///' | sed 's/\.omp\.\(json\|yaml\)$//' | sort | head -10
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

# =============================================================================
# Enhanced Theme Management Functions
# =============================================================================

# Function to preview a theme
posh_theme_preview() {
    local theme_name="$1"
    local theme_file="$HOME/.poshthemes/${theme_name}.omp.json"
    
    # Check for YAML format if JSON not found
    if [[ ! -f "$theme_file" ]]; then
        theme_file="$HOME/.poshthemes/${theme_name}.omp.yaml"
    fi
    
    if [[ -f "$theme_file" ]]; then
        if ! _validate_theme_file "$theme_file"; then
            echo "❌ Theme file is corrupted: $theme_name"
            return 1
        fi
        
        echo "🎨 Previewing theme: $theme_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        if command -v oh-my-posh >/dev/null 2>&1; then
            oh-my-posh print primary --config "$theme_file"
            echo ""
            echo "💡 To apply this theme: posh_theme $theme_name"
        else
            echo "❌ Oh My Posh not available for preview"
        fi
    else
        echo "❌ Theme not found: $theme_name"
        echo "💡 Available themes:"
        ls -1 "$HOME/.poshthemes"/*.omp.* 2>/dev/null | sed 's/.*\///' | sed 's/\.omp\.\(json\|yaml\)$//' | sort | head -10
    fi
}

# Function to apply a random theme
posh_theme_random() {
    local themes_dir="$HOME/.poshthemes"
    local available_themes=()
    
    # Get all available themes
    for theme_file in "$themes_dir"/*.omp.*; do
        if [[ -f "$theme_file" ]] && _validate_theme_file "$theme_file"; then
            local theme_name=$(basename "$theme_file" | sed 's/\.omp\.\(json\|yaml\)$//')
            available_themes+=("$theme_name")
        fi
    done
    
    if [[ ${#available_themes[@]} -eq 0 ]]; then
        echo "❌ No valid themes found"
        echo "💡 Install themes with: posh_theme_install"
        return 1
    fi
    
    # Select random theme
    local random_index=$((RANDOM % ${#available_themes[@]}))
    local random_theme="${available_themes[$random_index]}"
    
    echo "🎲 Random theme selected: $random_theme"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Preview the random theme
    posh_theme_preview "$random_theme"
    
    echo ""
    echo "❓ Apply this theme? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        posh_theme "$random_theme"
    else
        echo "⏭️  Theme not applied"
    fi
}

# Function to search themes by name
posh_theme_search() {
    local search_term="$1"
    local themes_dir="$HOME/.poshthemes"
    local matching_themes=()
    
    if [[ -z "$search_term" ]]; then
        echo "❌ Please provide a search term"
        return 1
    fi
    
    echo "🔍 Searching themes for: $search_term"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Search through available themes
    for theme_file in "$themes_dir"/*.omp.*; do
        if [[ -f "$theme_file" ]] && _validate_theme_file "$theme_file"; then
            local theme_name=$(basename "$theme_file" | sed 's/\.omp\.\(json\|yaml\)$//')
            if [[ "$theme_name" =~ $search_term ]]; then
                matching_themes+=("$theme_name")
            fi
        fi
    done
    
    if [[ ${#matching_themes[@]} -eq 0 ]]; then
        echo "❌ No themes found matching: $search_term"
        echo "💡 Try a different search term or install more themes"
        return 1
    fi
    
    echo "📋 Found ${#matching_themes[@]} matching theme(s):"
    for theme in "${matching_themes[@]}"; do
        echo "  • $theme"
    done
    
    echo ""
    echo "💡 Use 'posh_theme preview <name>' to preview a theme"
    echo "💡 Use 'posh_theme <name>' to apply a theme"
}

# Function to manage favorite themes
posh_theme_favorites() {
    local favorites_file="$HOME/.config/zsh/theme_favorites"
    local action="${1:-list}"
    
    case "$action" in
        "list"|"ls")
            echo "⭐ Favorite Themes"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            if [[ -f "$favorites_file" ]]; then
                local count=0
                while IFS= read -r theme; do
                    [[ -n "$theme" ]] && echo "  $((++count)). $theme"
                done < "$favorites_file"
                echo ""
                echo "💡 Use 'posh_theme favorites add <name>' to add themes"
                echo "💡 Use 'posh_theme favorites remove <name>' to remove themes"
            else
                echo "📝 No favorite themes yet"
                echo "💡 Add themes with: posh_theme favorites add <theme_name>"
            fi
            ;;
        "add")
            if [[ $# -lt 2 ]]; then
                echo "❌ Usage: posh_theme favorites add <theme_name>"
                return 1
            fi
            
            local theme_name="$2"
            local theme_file="$HOME/.poshthemes/${theme_name}.omp.json"
            
            # Check for YAML format if JSON not found
            if [[ ! -f "$theme_file" ]]; then
                theme_file="$HOME/.poshthemes/${theme_name}.omp.yaml"
            fi
            
            if [[ ! -f "$theme_file" ]]; then
                echo "❌ Theme not found: $theme_name"
                return 1
            fi
            
            # Create favorites file if it doesn't exist
            [[ ! -f "$favorites_file" ]] && touch "$favorites_file"
            
            # Check if already in favorites
            if grep -q "^${theme_name}$" "$favorites_file" 2>/dev/null; then
                echo "⭐ Theme '$theme_name' is already in favorites"
            else
                echo "$theme_name" >> "$favorites_file"
                echo "✅ Added '$theme_name' to favorites"
            fi
            ;;
        "remove"|"rm")
            if [[ $# -lt 2 ]]; then
                echo "❌ Usage: posh_theme favorites remove <theme_name>"
                return 1
            fi
            
            local theme_name="$2"
            
            if [[ ! -f "$favorites_file" ]]; then
                echo "📝 No favorites file found"
                return 1
            fi
            
            if grep -q "^${theme_name}$" "$favorites_file" 2>/dev/null; then
                local temp_file
                temp_file=$(mktemp 2>/dev/null || echo "/tmp/posh_favorites_$$.tmp")
                grep -v "^${theme_name}$" "$favorites_file" > "$temp_file" && mv "$temp_file" "$favorites_file"
                echo "✅ Removed '$theme_name' from favorites"
            else
                echo "❌ Theme '$theme_name' not found in favorites"
            fi
            ;;
        "clear")
            if [[ -f "$favorites_file" ]]; then
                rm -f "$favorites_file"
                echo "✅ Cleared all favorite themes"
            else
                echo "📝 No favorites to clear"
            fi
            ;;
        *)
            echo "❌ Unknown action: $action"
            echo "💡 Available actions: list, add, remove, clear"
            ;;
    esac
}

# Function to backup theme configuration
posh_theme_backup() {
    local backup_dir="$HOME/.config/zsh/theme_backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/theme_config_${timestamp}.backup"
    
    mkdir -p "$backup_dir"
    
    # Backup current prompt.zsh
    if [[ -f "$HOME/.config/zsh/themes/prompt.zsh" ]]; then
        cp "$HOME/.config/zsh/themes/prompt.zsh" "$backup_file"
        echo "✅ Theme configuration backed up to: $backup_file"
        
        # Also backup favorites if they exist
        if [[ -f "$HOME/.config/zsh/theme_favorites" ]]; then
            cp "$HOME/.config/zsh/theme_favorites" "$backup_dir/favorites_${timestamp}.backup"
            echo "✅ Theme favorites backed up"
        fi
    else
        echo "❌ No theme configuration found to backup"
    fi
}

# Function to restore theme configuration
posh_theme_restore() {
    local backup_dir="$HOME/.config/zsh/theme_backups"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "❌ No backups found"
        echo "💡 Create a backup first with: posh_theme backup"
        return 1
    fi
    
    echo "📋 Available backups:"
    local count=0
    local backups=()
    
    for backup_file in "$backup_dir"/theme_config_*.backup; do
        if [[ -f "$backup_file" ]]; then
            local filename=$(basename "$backup_file")
            local timestamp=$(echo "$filename" | sed 's/theme_config_\(.*\)\.backup/\1/')
            echo "  $((++count)). $timestamp"
            backups+=("$backup_file")
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        echo "❌ No backups found"
        return 1
    fi
    
    echo ""
    echo "❓ Which backup to restore? (1-$count)"
    read -r choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le $count ]]; then
        local selected_backup="${backups[$((choice-1))]}"
        
        # Restore the configuration
        cp "$selected_backup" "$HOME/.config/zsh/themes/prompt.zsh"
        echo "✅ Theme configuration restored from: $(basename "$selected_backup")"
        echo "🔄 Reload your shell with: source ~/.zshrc"
        
        # Restore favorites if available
        local favorites_backup="$backup_dir/favorites_$(echo "$selected_backup" | sed 's/.*theme_config_\(.*\)\.backup/\1/').backup"
        if [[ -f "$favorites_backup" ]]; then
            cp "$favorites_backup" "$HOME/.config/zsh/theme_favorites"
            echo "✅ Theme favorites restored"
        fi
    else
        echo "❌ Invalid selection"
    fi
}

# Helper function to add theme to recent themes
_add_to_recent_themes() {
    local theme_name="$1"
    local recent_file="$HOME/.config/zsh/theme_recent"
    local max_recent=10
    local temp_file
    
    # Create recent file if it doesn't exist
    [[ ! -f "$recent_file" ]] && touch "$recent_file"
    
    # Create temporary file
    temp_file=$(mktemp 2>/dev/null || echo "/tmp/posh_recent_$$.tmp")
    
    # Remove theme if already in recent list
    grep -v "^${theme_name}$" "$recent_file" > "$temp_file" 2>/dev/null || touch "$temp_file"
    
    # Add theme to the beginning
    echo "$theme_name" > "$recent_file"
    cat "$temp_file" >> "$recent_file"
    rm -f "$temp_file"
    
    # Keep only the most recent themes
    temp_file=$(mktemp 2>/dev/null || echo "/tmp/posh_recent_$$.tmp")
    head -n "$max_recent" "$recent_file" > "$temp_file"
    mv "$temp_file" "$recent_file"
}

# Function to show recent themes
posh_theme_recent() {
    local recent_file="$HOME/.config/zsh/theme_recent"
    
    echo "🕒 Recent Themes"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ -f "$recent_file" ]] && [[ -s "$recent_file" ]]; then
        local count=0
        while IFS= read -r theme; do
            [[ -n "$theme" ]] && echo "  $((++count)). $theme"
        done < "$recent_file"
        echo ""
        echo "💡 Use 'posh_theme <name>' to apply a theme"
    else
        echo "📝 No recent themes"
        echo "💡 Switch themes to build your recent list"
    fi
}

# Export theme functions
export -f posh_themes posh_theme posh_theme_list posh_theme_install posh_theme_preview posh_theme_random posh_theme_search posh_theme_favorites posh_theme_backup posh_theme_restore posh_theme_recent 2>/dev/null || true
