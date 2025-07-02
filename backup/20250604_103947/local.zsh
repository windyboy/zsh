#!/usr/bin/env zsh
# =============================================================================
# Local ZSH Configuration Template
# Copy this file to local.zsh and customize as needed
# =============================================================================

# =============================================================================
# PERSONAL SETTINGS
# =============================================================================

# Override default editor
# export EDITOR="vim"
# export VISUAL="$EDITOR"

# Custom PATH additions
# export PATH="$HOME/bin:$PATH"
# export PATH="$HOME/.local/bin:$PATH"

# =============================================================================
# WORK-SPECIFIC SETTINGS
# =============================================================================

# Company-specific aliases
# alias deploy='./scripts/deploy.sh'
# alias logs='kubectl logs -f'
# alias staging='ssh user@staging.company.com'

# Project shortcuts
# alias myproject='cd ~/work/important-project'
# alias frontend='cd ~/work/frontend && npm start'
# alias backend='cd ~/work/backend && ./run.sh'

# =============================================================================
# MACHINE-SPECIFIC SETTINGS
# =============================================================================

# Home vs Work machine differences
# if [[ "$(hostname)" == "work-laptop" ]]; then
#     export WORK_MODE=true
#     # Work-specific settings
# else
#     export PERSONAL_MODE=true
#     # Personal settings
# fi

# =============================================================================
# SENSITIVE INFORMATION
# =============================================================================

# API keys and tokens (never commit these!)
# export GITHUB_TOKEN="your_token_here"
# export AWS_ACCESS_KEY_ID="your_key_here"
# export DATABASE_URL="your_db_url_here"

# =============================================================================
# CUSTOM FUNCTIONS
# =============================================================================

# Work-specific functions
# work_setup() {
#     echo "Setting up work environment..."
#     # Your setup commands here
# }

# Personal functions
# backup_photos() {
#     rsync -av ~/Pictures/ /backup/photos/
# }

# =============================================================================
# CONDITIONAL LOADING
# =============================================================================

# Load additional configurations based on conditions
# if [[ -f ~/.work_config ]]; then
#     source ~/.work_config
# fi

# Load machine-specific configurations
# case "$(uname)" in
#     Darwin)
#         # macOS specific settings
#         ;;
#     Linux)
#         # Linux specific settings
#         ;;
# esac

# =============================================================================
# PLUGIN OVERRIDES
# =============================================================================

# Override plugin settings
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'
# FAST_HIGHLIGHT_STYLES[comment]='fg=green'

# Disable specific features if needed
# unset ZSH_AUTOSUGGEST_USE_ASYNC

# =============================================================================
# PERFORMANCE OVERRIDES
# =============================================================================

# Enable performance monitoring for this session
# export ZSH_PROF=1
# export ZSH_BENCHMARK=1

# =============================================================================
# THEME CUSTOMIZATION
# =============================================================================

# Override theme settings
# export POSH_THEME="$HOME/.config/oh-my-posh/custom-theme.json"

# Custom prompt elements
# if [[ -n "$WORK_MODE" ]]; then
#     # Add work indicator to prompt
# fi
