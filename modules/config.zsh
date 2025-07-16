#!/usr/bin/env zsh
# =============================================================================
# Unified Configuration Management System
# =============================================================================

# Load logging system
if [[ -f "$ZSH_CONFIG_DIR/modules/logging.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/logging.zsh"
fi

# Configuration file mapping
typeset -A CONFIG_FILES
CONFIG_FILES=(
    "zshrc" "$ZSH_CONFIG_DIR/zshrc"
    "core" "$ZSH_CONFIG_DIR/modules/core.zsh"
    "plugins" "$ZSH_CONFIG_DIR/modules/plugins.zsh"
    "completion" "$ZSH_CONFIG_DIR/modules/completion.zsh"
    "aliases" "$ZSH_CONFIG_DIR/modules/aliases.zsh"
    "keybindings" "$ZSH_CONFIG_DIR/modules/keybindings.zsh"
    "utils" "$ZSH_CONFIG_DIR/modules/utils.zsh"
    "logging" "$ZSH_CONFIG_DIR/modules/logging.zsh"
    "performance" "$ZSH_CONFIG_DIR/modules/performance.zsh"
    "tools" "$ZSH_CONFIG_DIR/modules/tools.zsh"
)

# Edit configuration file
config() {
    local config_name="$1"
    
    if [[ -z "$config_name" ]]; then
        echo "Usage: config <file>"
        echo "Available files:"
        for name in "${(@k)CONFIG_FILES}"; do
            local file="${CONFIG_FILES[$name]}"
            if [[ -f "$file" ]]; then
                echo "  $name - $file"
            else
                echo "  $name - $file (missing)"
            fi
        done
        return 1
    fi
    
    local file="${CONFIG_FILES[$config_name]}"
    if [[ -z "$file" ]]; then
        error "Unknown configuration file: $config_name"
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        error "Configuration file not found: $file"
        return 1
    fi
    
    log "Opening configuration file: $config_name"
    ${EDITOR:-code} "$file"
}

# List all configuration files
list_configs() {
    echo "📁 Configuration Files"
    echo "====================="
    
    local found=0
    local total=0
    
    for name in "${(@k)CONFIG_FILES}"; do
        local file="${CONFIG_FILES[$name]}"
        ((total++))
        
        if [[ -f "$file" ]]; then
            local size=$(ls -lh "$file" | awk '{print $5}')
            success "$name ($size)"
            ((found++))
        else
            error "$name (missing)"
        fi
    done
    
    echo ""
    echo "📊 Summary: $found/$total files found"
}

# Validate configuration files
validate_configs() {
    echo "🔍 Validating Configuration Files"
    echo "==============================="
    
    local errors=0
    
    for name in "${(@k)CONFIG_FILES}"; do
        local file="${CONFIG_FILES[$name]}"
        
        if [[ -f "$file" ]]; then
            # Check if file is readable
            if [[ -r "$file" ]]; then
                # Check for syntax errors
                if zsh -n "$file" 2>/dev/null; then
                    success "$name - syntax OK"
                else
                    error "$name - syntax errors"
                    ((errors++))
                fi
            else
                error "$name - not readable"
                ((errors++))
            fi
        else
            error "$name - missing"
            ((errors++))
        fi
    done
    
    echo ""
    if (( errors == 0 )); then
        success "All configuration files are valid"
        return 0
    else
        error "$errors configuration files have issues"
        return 1
    fi
}

# Backup configuration
backup_config() {
    local backup_dir="$ZSH_CONFIG_DIR/backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    log "Creating configuration backup..."
    
    local backed_up=0
    for name in "${(@k)CONFIG_FILES}"; do
        local file="${CONFIG_FILES[$name]}"
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_dir/"
            log "Backed up: $name"
            ((backed_up++))
        fi
    done
    
    # Backup custom directory
    if [[ -d "$ZSH_CONFIG_DIR/custom" ]]; then
        cp -r "$ZSH_CONFIG_DIR/custom" "$backup_dir/"
        log "Backed up: custom/"
    fi
    
    success "Backup created: $backup_dir ($backed_up files)"
}

# Restore configuration
restore_config() {
    local backup_dir="$1"
    
    if [[ -z "$backup_dir" ]]; then
        echo "Usage: restore_config <backup_directory>"
        echo "Available backups:"
        ls -la "$ZSH_CONFIG_DIR/backup/" 2>/dev/null || echo "No backups found"
        return 1
    fi
    
    if [[ ! -d "$backup_dir" ]]; then
        error "Backup directory not found: $backup_dir"
        return 1
    fi
    
    log "Restoring configuration from: $backup_dir"
    
    local restored=0
    for name in "${(@k)CONFIG_FILES}"; do
        local file="${CONFIG_FILES[$name]}"
        local backup_file="$backup_dir/$(basename "$file")"
        
        if [[ -f "$backup_file" ]]; then
            cp "$backup_file" "$file"
            log "Restored: $name"
            ((restored++))
        fi
    done
    
    # Restore custom directory
    if [[ -d "$backup_dir/custom" ]]; then
        cp -r "$backup_dir/custom" "$ZSH_CONFIG_DIR/"
        log "Restored: custom/"
    fi
    
    success "Configuration restored ($restored files)"
    log "Run 'reload' to apply changes"
}

# Show configuration status
config_status() {
    echo "📊 Configuration Status"
    echo "======================"
    
    local total="${#CONFIG_FILES}"
    local found=0
    local valid=0
    
    for name in "${(@k)CONFIG_FILES}"; do
        local file="${CONFIG_FILES[$name]}"
        
        if [[ -f "$file" ]]; then
            ((found++))
            if zsh -n "$file" 2>/dev/null; then
                ((valid++))
                success "$name"
            else
                error "$name (syntax errors)"
            fi
        else
            error "$name (missing)"
        fi
    done
    
    echo ""
    echo "📈 Summary:"
    echo "  Total files: $total"
    echo "  Found: $found"
    echo "  Valid: $valid"
    echo "  Missing: $((total - found))"
    echo "  Invalid: $((found - valid))"
} 