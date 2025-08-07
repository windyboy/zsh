#!/usr/bin/env bash
# =============================================================================
# Environment Variables Initialization Script
# Description: Help users create environment variable configuration files
# Usage: ./init-env.sh
# =============================================================================

# Color output functions
color_red()   { echo -e "\033[31m$1\033[0m"; }
color_green() { echo -e "\033[32m$1\033[0m"; }
color_yellow() { echo -e "\033[33m$1\033[0m"; }
color_blue()  { echo -e "\033[34m$1\033[0m"; }
color_cyan()  { echo -e "\033[36m$1\033[0m"; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "$(color_cyan "=============================================================================")"
echo "$(color_cyan "Environment Variables Configuration Initialization Tool")"
echo "$(color_cyan "=============================================================================")"
echo

# Check if template directory exists
if [[ ! -d "$SCRIPT_DIR/templates" ]]; then
    color_red "Error: Template directory does not exist: $SCRIPT_DIR/templates"
    exit 1
fi

# Create local configuration directory
if [[ ! -d "$SCRIPT_DIR/local" ]]; then
    mkdir -p "$SCRIPT_DIR/local"
    color_green "Created local configuration directory: $SCRIPT_DIR/local"
fi

# Define template files
template_file="environment.env.template"
local_file="environment.env"
template_path="$SCRIPT_DIR/templates/$template_file"
local_path="$SCRIPT_DIR/local/$local_file"

echo "$(color_yellow "Starting environment variables configuration initialization...")"
echo

echo "$(color_blue "Processing: $template_file")"
echo "  Description: User environment variables configuration"

# Check if template file exists
if [[ ! -f "$template_path" ]]; then
    color_red "  Error: Template file does not exist: $template_path"
    exit 1
fi

# Check if local file already exists
if [[ -f "$local_path" ]]; then
    echo "  Status: $(color_yellow "Skipped (already exists)")"
    echo "  File: $local_path"
else
    # Copy template file to local configuration
    if cp "$template_path" "$local_path"; then
        echo "  Status: $(color_green "Created successfully")"
        echo "  File: $local_path"
    else
        color_red "  Error: Failed to create file: $local_path"
        exit 1
    fi
fi

echo
echo "$(color_cyan "=============================================================================")"
echo "$(color_cyan "Initialization Complete")"
echo "$(color_cyan "=============================================================================")"
echo

# Display next steps guide
if [[ ! -f "$local_path" ]]; then
    echo "$(color_green "Next Steps:")"
    echo "1. Edit the newly created configuration file:"
    echo "   ${EDITOR:-code} $local_path"
    echo
    echo "2. Modify configuration values according to your actual environment"
    echo "3. Reload ZSH configuration: source ~/.config/zsh/zshrc"
    echo
fi

# Display usage instructions
echo "$(color_blue "Usage Instructions:")"
echo "• Template files are located at: $SCRIPT_DIR/templates/"
echo "• Local configuration files are located at: $SCRIPT_DIR/local/"
echo "• Do not modify template files directly, they are for version control"
echo "• You can freely modify local configuration files"
echo "• View detailed instructions: cat $SCRIPT_DIR/README.md"
echo

# Check if there are configuration files that need editing
if [[ ! -f "$local_path" ]]; then
    echo "$(color_yellow "Tip: It's recommended to immediately edit the newly created configuration file to adapt to your environment")"
    echo
    read -k 1 "REPLY?Open editor to edit configuration file now? (y/N): "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Opening: $local_path"
        ${EDITOR:-code} "$local_path"
    fi
fi

echo
echo "$(color_green "Environment variables configuration initialization completed!")" 