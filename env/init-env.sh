#!/usr/bin/env bash
# =============================================================================
# Environment Variables Initialization Script
# Description: Help users create environment variable configuration files
# Usage: ./init-env.sh
# =============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Shared logging
# shellcheck disable=SC1091
if [[ -f "$PROJECT_ROOT/scripts/lib/logging.sh" ]]; then
    source "$PROJECT_ROOT/scripts/lib/logging.sh"
else
    # Fallback if shared logging not available
    log()     { echo "ℹ️  $1"; }
    info()    { echo "📋 $1"; }
    success() { echo "✅ $1"; }
    warning() { echo "⚠️  $1"; }
    error()   { echo "❌ $1"; }

fi

printf '%b╔══════════════════════════════════════════════════════════════╗%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
printf '%b║    Environment Variables Configuration Initialization       ║%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
printf '%b╚══════════════════════════════════════════════════════════════╝%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
echo

# Check if template directory exists
if [[ ! -d "$SCRIPT_DIR/templates" ]]; then
    error "Template directory does not exist: $SCRIPT_DIR/templates"
    exit 1
fi

# Create local configuration directory
if [[ ! -d "$SCRIPT_DIR/local" ]]; then
    mkdir -p "$SCRIPT_DIR/local"
    success "Created local configuration directory: $SCRIPT_DIR/local"
fi

# Define template files
template_file="environment.env.template"
local_file="environment.env"
template_path="$SCRIPT_DIR/templates/$template_file"
local_path="$SCRIPT_DIR/local/$local_file"

log "Starting environment variables configuration initialization..."
echo

info "Processing: $template_file"
echo "  Description: User environment variables configuration"

# Check if template file exists
if [[ ! -f "$template_path" ]]; then
    error "Template file does not exist: $template_path"
    exit 1
fi

# Check if local file already exists
if [[ -f "$local_path" ]]; then
    warning "Skipped (already exists): $local_path"
else
    # Copy template file to local configuration
    if cp "$template_path" "$local_path"; then
        success "Created successfully: $local_path"
    else
        error "Failed to create file: $local_path"
        exit 1
    fi
fi

echo
printf '%b╔══════════════════════════════════════════════════════════════╗%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
printf '%b║                  Initialization Complete                     ║%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
printf '%b╚══════════════════════════════════════════════════════════════╝%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
echo

# Display next steps guide
if [[ -f "$local_path" ]]; then
    success "Next Steps:"
    echo "1. Edit the newly created configuration file:"
    echo "   ${EDITOR:-code} $local_path"
    echo
    echo "2. Modify configuration values according to your actual environment"
    echo "3. Reload ZSH configuration: source $PROJECT_ROOT/zshrc"
    echo
fi

# Display usage instructions
info "Usage Instructions:"
echo "• Template files are located at: $SCRIPT_DIR/templates/"
echo "• Local configuration files are located at: $SCRIPT_DIR/local/"
echo "• Do not modify template files directly, they are for version control"
echo "• You can freely modify local configuration files"
echo "• View detailed instructions: cat $SCRIPT_DIR/README.md"
echo

# Check if there are configuration files that need editing
if [[ -f "$local_path" ]]; then
    warning "Tip: It's recommended to edit the configuration file to adapt to your environment"
    echo
    read -n 1 -r -p "Open editor to edit configuration file now? (y/N): " REPLY
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Opening: $local_path"
        ${EDITOR:-code} "$local_path"
    fi
fi

echo
success "Environment variables configuration initialization completed!"
