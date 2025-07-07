#!/usr/bin/env zsh
# =============================================================================
# Oh My Posh Theme Configuration
# =============================================================================

# Check if Oh My Posh is available
if command -v oh-my-posh >/dev/null 2>&1; then
    # Initialize Oh My Posh with optimized configuration
    # You can change the theme by modifying this line
    # Using a simpler theme for better performance
    eval "$(oh-my-posh init zsh --config ~/.poshthemes/powerlevel10k_rainbow.omp.json --print)"
    
    # Optimize Oh My Posh performance
    export OMP_DEBUG=0  # Disable debug mode
    export OMP_TRANSIENT=1  # Enable transient prompt for better performance
    
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
    # eval "$(oh-my-posh init zsh --config ~/.poshthemes/robbyrussell.omp.json)"  # Oh My Zsh style
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
        # Update the theme in the prompt.zsh file
        sed -i.bak "s|--config ~/.poshthemes/[^.]*\.omp\.json|--config ~/.poshthemes/${theme_name}.omp.json|" ~/.config/zsh/themes/prompt.zsh
        echo "✅ Switched to theme: $theme_name"
        echo "🔄 Reload your shell with: source ~/.zshrc"
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
        oh-my-posh theme install
        echo "✅ Themes installed successfully"
        echo "💡 Use 'posh_themes' to see available themes"
    else
        echo "❌ Oh My Posh is not installed"
        echo "📦 Install with: brew install oh-my-posh (macOS) or follow official docs"
    fi
}

# Export theme functions
export -f posh_themes posh_theme posh_theme_list posh_theme_install 2>/dev/null || true
