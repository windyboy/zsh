#!/usr/bin/env zsh
# =============================================================================
# Local Configuration - User Customizations
# =============================================================================

# Personal aliases
# alias myalias='command'

# Personal functions
# myfunction() {
#     # Your code here
# }

# Personal environment variables
export EDITOR='nvim'
export VISUAL='nvim'

# Machine-specific configurations
case "$(uname)" in
    Darwin)
        export BROWSER="open"
        ;;
    Linux)
        export BROWSER="xdg-open"
        ;;
esac
