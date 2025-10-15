#!/usr/bin/env bash
# =============================================================================
# Environment Variables Migration Script
# Description: Help users migrate from old environment variable configuration to new configuration system
# Usage: ./migrate-env.sh
# =============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSH_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# Shared logging
# shellcheck disable=SC1091
if [[ -f "$ZSH_CONFIG_DIR/scripts/lib/logging.sh" ]]; then
    source "$ZSH_CONFIG_DIR/scripts/lib/logging.sh"
else
    # Fallback if shared logging not available
    log()     { echo "ℹ️  $1"; }
    info()    { echo "📋 $1"; }
    success() { echo "✅ $1"; }
    warning() { echo "⚠️  $1"; }
    error()   { echo "❌ $1"; }
fi

printf '%b╔══════════════════════════════════════════════════════════════╗%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
printf '%b║      Environment Variables Configuration Migration          ║%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
printf '%b╚══════════════════════════════════════════════════════════════╝%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
echo

# Check if migration is needed
log "Checking existing configuration..."
echo

# Check old configuration files
old_files=()
if [[ -f "$ZSH_CONFIG_DIR/env/development.zsh" ]]; then
    old_files+=("development.zsh")
fi

if [[ -f "$ZSH_CONFIG_DIR/env/local.zsh" ]]; then
    old_files+=("local.zsh")
fi

if [[ ${#old_files[@]} -eq 0 ]]; then
    success "No old configuration files found that need migration"
    echo
    echo "Recommend running initialization script to create new configuration:"
    echo "  $SCRIPT_DIR/init-env.sh"
    exit 0
fi

warning "Found the following old configuration files:"
for file in "${old_files[@]}"; do
    echo "  • $file"
done
echo

# Confirm migration
info "Migration Instructions:"
echo "• Old configuration files will be backed up to backup/ directory"
echo "• New environment configuration files will be created"
echo "• You can manually copy custom settings from old configuration to new configuration"
echo

read -n 1 -r -p "Continue with migration? (y/N): " REPLY
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warning "Migration cancelled"
    exit 0
fi

echo
log "Starting migration..."
echo

# Create backup directory
backup_dir="$SCRIPT_DIR/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
success "Created backup directory: $backup_dir"

# Migrate development.zsh
if [[ -f "$ZSH_CONFIG_DIR/env/development.zsh" ]]; then
    echo
    info "Migrating development.zsh..."
    
    # Backup old file
    cp "$ZSH_CONFIG_DIR/env/development.zsh" "$backup_dir/"
    success "  Backup: $ZSH_CONFIG_DIR/env/development.zsh -> $backup_dir/development.zsh"
    
    # Create new local configuration file
    if [[ ! -f "$SCRIPT_DIR/local/environment.env" ]]; then
        cp "$SCRIPT_DIR/templates/environment.env.template" "$SCRIPT_DIR/local/environment.env"
        success "  Created: $SCRIPT_DIR/local/environment.env"
        
        # Extract environment variables and add to new configuration
        echo
        log "  Extracting environment variables..."
        
        # Read export statements from old file
        while IFS= read -r line; do
            if [[ $line =~ ^export[[:space:]]+([^=]+)= ]]; then
                var_name="${BASH_REMATCH[1]}"
                echo "  Found variable: $var_name"
                
                # Find and uncomment corresponding variables in new configuration file
                case $var_name in
                    BUN_INSTALL|DENO_INSTALL|PNPM_HOME)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    GOPATH|GOROOT|GOPROXY|GO111MODULE)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    RUSTUP_DIST_SERVER|RUSTUP_UPDATE_ROOT)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    PUB_HOSTED_URL|FLUTTER_STORAGE_BASE_URL)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    ANDROID_HOME|ANDROID_SDK_ROOT)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    SDKMAN_DIR)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                    HOMEBREW_BREW_GIT_REMOTE)
                        sed -i.bak "s/^# export $var_name=/export $var_name=/" "$SCRIPT_DIR/local/environment.env"
                        ;;
                esac
            fi
        done < "$ZSH_CONFIG_DIR/env/development.zsh"
        
        # Clean up backup files
        rm -f "$SCRIPT_DIR/local/environment.env.bak"
        
        success "  Environment variables extraction completed"
    else
        warning "  Skipped: Local configuration file already exists"
    fi
fi

# Migrate local.zsh
if [[ -f "$ZSH_CONFIG_DIR/env/local.zsh" ]]; then
    echo
    info "Migrating local.zsh..."
    
    # Backup old file
    cp "$ZSH_CONFIG_DIR/env/local.zsh" "$backup_dir/"
    success "  Backup: $ZSH_CONFIG_DIR/env/local.zsh -> $backup_dir/local.zsh"
    
    # Create custom configuration section
    echo
    log "  Creating custom configuration section..."
    
    # Add custom configuration to environment.env
    if [[ -f "$SCRIPT_DIR/local/environment.env" ]]; then
        echo "" >> "$SCRIPT_DIR/local/environment.env"
        echo "# =============================================================================" >> "$SCRIPT_DIR/local/environment.env"
        echo "# Custom configuration migrated from local.zsh" >> "$SCRIPT_DIR/local/environment.env"
        echo "# =============================================================================" >> "$SCRIPT_DIR/local/environment.env"
        echo "" >> "$SCRIPT_DIR/local/environment.env"
        
        # Extract export statements and add to environment.env
        while IFS= read -r line; do
            if [[ $line =~ ^export[[:space:]]+([^=]+)= ]]; then
                echo "$line" >> "$SCRIPT_DIR/local/environment.env"
                var_name="${BASH_REMATCH[1]}"
                echo "  Added variable: $var_name"
            fi
        done < "$ZSH_CONFIG_DIR/env/local.zsh"
        
        success "  Custom configuration added to environment.env"
    else
        warning "  Skipped: environment.env does not exist, please run init-env.sh first"
    fi
fi

# Migration completed
echo
printf '%b╔══════════════════════════════════════════════════════════════╗%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
printf '%b║                  Migration Completed                         ║%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
printf '%b╚══════════════════════════════════════════════════════════════╝%b\n' "${LOG_COLOR_CYAN:-}" "${LOG_COLOR_RESET:-}"
echo

echo "Migration Statistics:"
echo "  Backup files: $backup_dir/"
echo "  Migrated files: ${#old_files[@]} files"
echo

success "Next Steps:"
echo "1. Check the newly created configuration file:"
echo "   ${EDITOR:-code} $SCRIPT_DIR/local/environment.env"

echo
echo "2. Adjust configuration values according to your actual environment"

echo
echo "3. Reload ZSH configuration:"
echo "   source ~/.config/zsh/zshrc"

echo
echo "4. Verify configuration is correct:"
echo "   env | grep -E '(GOPATH|ANDROID_HOME|BUN_INSTALL)'"

echo
info "Important Notes:"
echo "• Old configuration files have been backed up to: $backup_dir/"
echo "• It's recommended to check paths and settings in the new configuration file"
echo "• If there are issues, you can restore from backup files"

echo
success "Migration completed!"