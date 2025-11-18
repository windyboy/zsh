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

# Validate theme file (shared validation logic)
_validate_downloaded_theme() {
    local theme_file="$1"
    [[ -f "$theme_file" ]] || return 1
    [[ $(wc -c < "$theme_file") -gt 100 ]] || return 1
    
    # Check for HTTP error responses (only at start of line or as HTML)
    # This avoids matching legitimate template variables like .Error
    if grep -qiE "^(404|Not Found|<!DOCTYPE|<html)" "$theme_file" 2>/dev/null; then
        return 1
    fi
    
    # Validate based on file type
    if [[ "$theme_file" == *.omp.json ]]; then
        if command -v python3 >/dev/null 2>&1; then
            python3 -m json.tool "$theme_file" >/dev/null 2>&1 || return 1
        elif command -v jq >/dev/null 2>&1; then
            jq empty "$theme_file" >/dev/null 2>&1 || return 1
        fi
    elif [[ "$theme_file" == *.omp.yaml ]]; then
        if command -v yq >/dev/null 2>&1; then
            yq eval . "$theme_file" >/dev/null 2>&1 || return 1
        elif command -v python3 >/dev/null 2>&1; then
            python3 -c "import yaml; yaml.safe_load(open('$theme_file'))" >/dev/null 2>&1 || return 1
        fi
    fi
    
    return 0
}

# Install all themes
install_all_themes() {
    log "Starting Oh My Posh theme installation..."
    
    local themes_dir="$HOME/.poshthemes"
    mkdir -p "$themes_dir"
    
    # Store original directory and create temporary directory
    local original_dir
    original_dir=$(pwd)
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Set up cleanup trap
    trap "cd '$original_dir' 2>/dev/null; rm -rf '$temp_dir' 2>/dev/null" EXIT INT TERM
    
    cd "$temp_dir" || {
        error "Failed to change to temporary directory"
        return 1
    }
    
    log "Cloning Oh My Posh GitHub repository..."
    if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
        success "GitHub repository cloned successfully"
        
        # Copy all theme files
        if [[ -d "oh-my-posh/themes" ]]; then
            local theme_count=0
            local json_count=0
            local yaml_count=0
            
            # Enable nullglob to handle empty globs gracefully
            shopt -s nullglob
            
            # Copy JSON themes
            for theme_file in oh-my-posh/themes/*.omp.json; do
                local theme_name
                theme_name=$(basename "$theme_file")
                if cp "$theme_file" "$themes_dir/"; then
                    if _validate_downloaded_theme "$themes_dir/$theme_name"; then
                        ((theme_count++))
                        ((json_count++))
                        log "Theme ${theme_name} copied and validated successfully"
                    else
                        warning "Theme ${theme_name} copied but validation failed, removing"
                        rm -f "$themes_dir/$theme_name"
                    fi
                else
                    warning "Failed to copy theme ${theme_name}"
                fi
            done
            
            # Copy YAML themes
            for theme_file in oh-my-posh/themes/*.omp.yaml; do
                local theme_name
                theme_name=$(basename "$theme_file")
                if cp "$theme_file" "$themes_dir/"; then
                    if _validate_downloaded_theme "$themes_dir/$theme_name"; then
                        ((theme_count++))
                        ((yaml_count++))
                        log "Theme ${theme_name} copied and validated successfully"
                    else
                        warning "Theme ${theme_name} copied but validation failed, removing"
                        rm -f "$themes_dir/$theme_name"
                    fi
                else
                    warning "Failed to copy theme ${theme_name}"
                fi
            done
            
            # Restore nullglob
            shopt -u nullglob
            
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
    
    # Clean up (trap will also handle this, but explicit cleanup is good)
    cd "$original_dir" || true
    rm -rf "$temp_dir"
    trap - EXIT INT TERM
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
        local downloaded=0
        
        # Try to download JSON format
        if curl -sS "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$themes_dir/${theme}.omp.json"; then
            if _validate_downloaded_theme "$themes_dir/${theme}.omp.json"; then
                log "Theme ${theme}.omp.json downloaded and validated successfully"
                ((success_count++))
                downloaded=1
            else
                warning "Theme ${theme}.omp.json downloaded but validation failed, removing"
                rm -f "$themes_dir/${theme}.omp.json"
            fi
        fi
        
        # Try to download YAML format if JSON failed
        if [[ $downloaded -eq 0 ]]; then
            if curl -sS "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.yaml" -o "$themes_dir/${theme}.omp.yaml"; then
                if _validate_downloaded_theme "$themes_dir/${theme}.omp.yaml"; then
                    log "Theme ${theme}.omp.yaml downloaded and validated successfully"
                    ((success_count++))
                    downloaded=1
                else
                    warning "Theme ${theme}.omp.yaml downloaded but validation failed, removing"
                    rm -f "$themes_dir/${theme}.omp.yaml"
                fi
            fi
        fi
        
        if [[ $downloaded -eq 0 ]]; then
            warning "Failed to download or validate theme ${theme}"
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
    
    # Store original directory
    local original_dir
    original_dir=$(pwd)
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Set up cleanup trap
    trap "cd '$original_dir' 2>/dev/null; rm -rf '$temp_dir' 2>/dev/null" EXIT INT TERM
    
    cd "$temp_dir" || {
        error "Failed to change to temporary directory"
        return 1
    }
    
    if git clone --depth 1 https://github.com/JanDeDobbeleer/oh-my-posh.git; then
        if [[ -d "oh-my-posh/themes" ]]; then
            echo "📋 Available Oh My Posh themes:"
            echo ""
            
            # Enable nullglob to handle empty globs gracefully
            shopt -s nullglob
            
            # JSON themes
            echo "JSON format themes:"
            local json_found=0
            for theme_file in oh-my-posh/themes/*.omp.json; do
                local theme_name
                theme_name=$(basename "$theme_file" .omp.json)
                echo "  - $theme_name"
                json_found=1
            done
            [[ $json_found -eq 0 ]] && echo "  (none)"
            
            echo ""
            echo "YAML format themes:"
            local yaml_found=0
            for theme_file in oh-my-posh/themes/*.omp.yaml; do
                local theme_name
                theme_name=$(basename "$theme_file" .omp.yaml)
                echo "  - $theme_name"
                yaml_found=1
            done
            [[ $yaml_found -eq 0 ]] && echo "  (none)"
            
            # Restore nullglob
            shopt -u nullglob
        else
            error "Theme directory not found"
        fi
    else
        error "Unable to fetch theme list"
    fi
    
    # Clean up
    cd "$original_dir" || true
    rm -rf "$temp_dir"
    trap - EXIT INT TERM
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
