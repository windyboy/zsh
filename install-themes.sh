#!/bin/bash

# Oh My Posh Theme Installation Script
# Download all available themes from GitHub

set -euo pipefail

# Shared logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/logging.sh"

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install these tools before running this script"
        return 1
    fi
    
    return 0
}

# Install all themes
install_all_themes() {
    log "Starting Oh My Posh theme installation..."
    
    local themes_dir="$HOME/.poshthemes"
    mkdir -p "$themes_dir"
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    log "Cloning Oh My Posh GitHub repository..."
    if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
        success "GitHub repository cloned successfully"
        
        # Copy all theme files
        if [[ -d "oh-my-posh/themes" ]]; then
            local theme_count=0
            local json_count=0
            local yaml_count=0
            
            # Copy JSON themes
            for theme_file in oh-my-posh/themes/*.omp.json; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name
                    theme_name=$(basename "$theme_file")
                    cp "$theme_file" "$themes_dir/"
                    ((theme_count++))
                    ((json_count++))
                    log "Theme ${theme_name} copied successfully"
                fi
            done
            
            # Copy YAML themes
            for theme_file in oh-my-posh/themes/*.omp.yaml; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name
                    theme_name=$(basename "$theme_file")
                    cp "$theme_file" "$themes_dir/"
                    ((theme_count++))
                    ((yaml_count++))
                    log "Theme ${theme_name} copied successfully"
                fi
            done
            
            success "Theme installation completed!"
            echo "📊 Installation Statistics:"
            echo "   - Total themes: ${theme_count}"
            echo "   - JSON themes: ${json_count}"
            echo "   - YAML themes: ${yaml_count}"
            echo "   - Theme location: $themes_dir"
            echo ""
            echo "💡 Usage examples:"
            echo "   - Preview theme: oh-my-posh print primary --config $themes_dir/agnoster.omp.json"
            echo "   - Use theme: oh-my-posh init zsh --config $themes_dir/agnoster.omp.json"
            echo "   - List themes: ls $themes_dir/*.omp.*"
            
        else
            error "Theme directory not found"
            return 1
        fi
    else
        error "Failed to clone GitHub repository"
        return 1
    fi
    
    # Clean up temporary directory
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Install specific themes
install_specific_themes() {
    local themes=("$@")
    log "Installing specified themes: ${themes[*]}"
    
    local themes_dir="$HOME/.poshthemes"
    mkdir -p "$themes_dir"
    
    local success_count=0
    local fail_count=0
    
    for theme in "${themes[@]}"; do
        # Try to download JSON format
        if curl -sS "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$themes_dir/${theme}.omp.json"; then
            log "Theme ${theme}.omp.json downloaded successfully"
            ((success_count++))
        # Try to download YAML format
        elif curl -sS "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.yaml" -o "$themes_dir/${theme}.omp.yaml"; then
            log "Theme ${theme}.omp.yaml downloaded successfully"
            ((success_count++))
        else
            warning "Failed to download theme ${theme}"
            ((fail_count++))
        fi
    done
    
    echo ""
    success "Theme download completed!"
    echo "📊 Download Statistics:"
    echo "   - Success: ${success_count}"
    echo "   - Failed: ${fail_count}"
    echo "   - Theme location: $themes_dir"
}

# List available themes
list_available_themes() {
    log "Fetching available theme list from GitHub..."
    
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
        if [[ -d "oh-my-posh/themes" ]]; then
            echo "📋 Available Oh My Posh themes:"
            echo ""
            
            # JSON themes
            echo "JSON format themes:"
            for theme_file in oh-my-posh/themes/*.omp.json; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name
                    theme_name=$(basename "$theme_file" .omp.json)
                    echo "  - $theme_name"
                fi
            done
            
            echo ""
            echo "YAML format themes:"
            for theme_file in oh-my-posh/themes/*.omp.yaml; do
                if [[ -f "$theme_file" ]]; then
                    local theme_name
                    theme_name=$(basename "$theme_file" .omp.yaml)
                    echo "  - $theme_name"
                fi
            done
        else
            error "Theme directory not found"
        fi
    else
        error "Unable to fetch theme list"
    fi
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Show help information
show_help() {
    echo "Oh My Posh Theme Installation Script"
    echo ""
    echo "Usage: $0 [options] [theme_names...]"
    echo ""
    echo "Options:"
    echo "  -a, --all          Install all available themes"
    echo "  -l, --list         List all available themes"
    echo "  -h, --help         Show this help information"
    echo ""
    echo "Examples:"
    echo "  $0 --all                    # Install all themes"
    echo "  $0 agnoster powerlevel10k   # Install specified themes"
    echo "  $0 --list                   # List available themes"
    echo ""
    echo "Theme location: ~/.poshthemes/"
}

# Main function
main() {
    # Check parameters
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    case "$1" in
        -a|--all)
            install_all_themes
            ;;
        -l|--list)
            list_available_themes
            ;;
        -h|--help)
            show_help
            ;;
        -*)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            # Install specified themes
            install_specific_themes "$@"
            ;;
    esac
}

main "$@" 
