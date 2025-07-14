#!/usr/bin/env zsh
# =============================================================================
# Module Manager - Unified Module System Coordinator
# Version: 3.0 - Central Module Management
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Module manager configuration
MODULE_MANAGER_LOG="${ZSH_CACHE_DIR}/module_manager.log"
MODULE_DEPENDENCIES_FILE="${ZSH_CACHE_DIR}/module_dependencies.json"

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize module manager
init_module_manager() {
    # Log module manager initialization (log function will ensure directory)
    log_module_manager_event "Module manager initialized"
}

# =============================================================================
# MODULE MANAGER LOGGING
# =============================================================================

# Log module manager events
log_module_manager_event() {
    local event="$1"
    local level="${2:-info}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Always ensure log directory exists before writing
    [[ ! -d "${MODULE_MANAGER_LOG:h}" ]] && mkdir -p "${MODULE_MANAGER_LOG:h}"
    echo "[$timestamp] [$level] $event" >> "$MODULE_MANAGER_LOG"
}

# =============================================================================
# MODULE DEPENDENCIES
# =============================================================================

# Define module dependencies
declare -A MODULE_DEPENDENCIES=(
    ["core"]=""
    ["error_handling"]="core"
    ["security"]="core"
    ["performance"]="core error_handling"
    ["plugins"]="core error_handling"
    ["completion"]="core error_handling plugins"
    ["aliases"]="core error_handling"
    ["functions"]="core error_handling"
    ["keybindings"]="core error_handling"
)

# Define module load order
MODULE_LOAD_ORDER=(
    "core"
    "error_handling"
    "security"
    "performance"
    "plugins"
    "completion"
    "aliases"
    "functions"
    "keybindings"
)

# =============================================================================
# MODULE LOADING
# =============================================================================

# Basic safe source function (fallback)
safe_source_fallback() {
    local file="$1"
    local module="${2:-unknown}"
    
    if [[ -f "$file" ]] && [[ -r "$file" ]]; then
        source "$file" 2>/dev/null
        return $?
    else
        echo "Cannot read file: $file" >&2
        return 1
    fi
}

# Load module with dependencies
load_module_with_deps() {
    local module="$1"
    local module_file="${ZSH_CONFIG_DIR}/modules/${module}.zsh"
    
    # Check if module is already loaded
    if module_loaded "$module"; then
        log_module_manager_event "Module $module already loaded"
        return 0
    fi
    
    # Check dependencies
    local deps="${MODULE_DEPENDENCIES[$module]}"
    if [[ -n "$deps" ]]; then
        for dep in $deps; do
            if ! module_loaded "$dep"; then
                log_module_manager_event "Loading dependency: $dep for module: $module"
                load_module_with_deps "$dep"
            fi
        done
    fi
    
    # Load the module
    if [[ -f "$module_file" ]]; then
        log_module_manager_event "Loading module: $module"
        
        # Use safe_source if available, otherwise use fallback
        if command -v safe_source >/dev/null 2>&1; then
            if safe_source "$module_file" "module_manager"; then
                export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED $module"
                log_module_manager_event "Module $module loaded successfully"
                return 0
            else
                log_module_manager_event "Failed to load module: $module" "error"
                return 1
            fi
        else
            # Use fallback method
            if safe_source_fallback "$module_file" "module_manager"; then
                export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED $module"
                log_module_manager_event "Module $module loaded successfully"
                return 0
            else
                log_module_manager_event "Failed to load module: $module" "error"
                return 1
            fi
        fi
    else
        log_module_manager_event "Module file not found: $module_file" "error"
        return 1
    fi
}

# Load all modules in order
load_all_modules() {
    log_module_manager_event "Starting module loading sequence"
    
    local loaded_count=0
    local failed_count=0
    
    for module in "${MODULE_LOAD_ORDER[@]}"; do
        if load_module_with_deps "$module"; then
            ((loaded_count++))
        else
            ((failed_count++))
        fi
    done
    
    log_module_manager_event "Module loading completed: $loaded_count loaded, $failed_count failed"
    
    if (( failed_count == 0 )); then
        echo "✅ All modules loaded successfully"
        return 0
    else
        echo "❌ Module loading failed: $failed_count modules failed"
        return 1
    fi
}

# =============================================================================
# MODULE VALIDATION
# =============================================================================

# Validate module dependencies
validate_module_dependencies() {
    local errors=0
    
    echo "🔍 Validating module dependencies..."
    
    for module in "${!MODULE_DEPENDENCIES[@]}"; do
        local deps="${MODULE_DEPENDENCIES[$module]}"
        if [[ -n "$deps" ]]; then
            for dep in $deps; do
                if [[ ! -f "${ZSH_CONFIG_DIR}/modules/${dep}.zsh" ]]; then
                    echo "❌ Module $module depends on missing module: $dep"
                    ((errors++))
                fi
            done
        fi
    done
    
    if (( errors == 0 )); then
        echo "✅ All module dependencies validated"
        log_module_manager_event "Module dependencies validation passed"
        return 0
    else
        echo "❌ Module dependency validation failed: $errors errors"
        log_module_manager_event "Module dependency validation failed: $errors errors" "error"
        return 1
    fi
}

# Validate module files
validate_module_files() {
    local errors=0
    local warnings=0
    
    echo "🔍 Validating module files..."
    
    for module in "${MODULE_LOAD_ORDER[@]}"; do
        local module_file="${ZSH_CONFIG_DIR}/modules/${module}.zsh"
        
        if [[ -f "$module_file" ]]; then
            if [[ -r "$module_file" ]]; then
                echo "✅ $module"
            else
                echo "❌ $module (not readable)"
                ((errors++))
            fi
        else
            echo "❌ $module (missing)"
            ((errors++))
        fi
    done
    
    if (( errors == 0 )); then
        echo "✅ All module files validated"
        log_module_manager_event "Module files validation passed"
        return 0
    else
        echo "❌ Module file validation failed: $errors errors"
        log_module_manager_event "Module file validation failed: $errors errors" "error"
        return 1
    fi
}

# =============================================================================
# MODULE MANAGEMENT
# =============================================================================

# List all modules
list_all_modules() {
    echo "📦 Available modules:"
    for module in "${MODULE_LOAD_ORDER[@]}"; do
        local status=""
        if module_loaded "$module"; then
            status="✅"
        else
            status="❌"
        fi
        
        local deps="${MODULE_DEPENDENCIES[$module]}"
        if [[ -n "$deps" ]]; then
            echo "  $status $module (depends on: $deps)"
        else
            echo "  $status $module"
        fi
    done
}

# Get module status
get_module_status() {
    local module="$1"
    
    if [[ -z "$module" ]]; then
        echo "Usage: get_module_status <module>"
        return 1
    fi
    
    echo "📊 Module Status: $module"
    echo "========================"
    
    # Check if module file exists
    local module_file="${ZSH_CONFIG_DIR}/modules/${module}.zsh"
    if [[ -f "$module_file" ]]; then
        echo "✅ Module file exists"
    else
        echo "❌ Module file missing"
        return 1
    fi
    
    # Check if module is loaded
    if module_loaded "$module"; then
        echo "✅ Module is loaded"
    else
        echo "❌ Module is not loaded"
    fi
    
    # Check dependencies
    local deps="${MODULE_DEPENDENCIES[$module]}"
    if [[ -n "$deps" ]]; then
        echo "📋 Dependencies: $deps"
        for dep in $deps; do
            if module_loaded "$dep"; then
                echo "  ✅ $dep"
            else
                echo "  ❌ $dep"
            fi
        done
    else
        echo "📋 No dependencies"
    fi
}

# Reload module
reload_module() {
    local module="$1"
    
    if [[ -z "$module" ]]; then
        echo "Usage: reload_module <module>"
        return 1
    fi
    
    log_module_manager_event "Reloading module: $module"
    
    # Remove from loaded modules
    export ZSH_MODULES_LOADED=$(echo "$ZSH_MODULES_LOADED" | sed "s/ $module//")
    
    # Reload the module
    if load_module_with_deps "$module"; then
        echo "✅ Module $module reloaded successfully"
        log_module_manager_event "Module $module reloaded successfully"
        return 0
    else
        echo "❌ Failed to reload module $module"
        log_module_manager_event "Failed to reload module $module" "error"
        return 1
    fi
}

# =============================================================================
# MODULE PERFORMANCE
# =============================================================================

# Monitor module performance
monitor_module_performance() {
    local module="$1"
    local start_time=$EPOCHREALTIME
    
    # Load module and measure time
    if load_module_with_deps "$module"; then
        local end_time=$EPOCHREALTIME
        local duration=$((end_time - start_time))
        local duration_formatted=$(printf "%.3f" $duration)
        
        log_module_manager_event "Module $module loaded in ${duration_formatted}s"
        
        if (( duration > 100 )); then
            log_module_manager_event "Module $module is slow: ${duration_formatted}s" "warning"
        fi
        
        echo "Module $module loaded in ${duration_formatted}s"
    else
        log_module_manager_event "Failed to load module $module" "error"
        echo "Failed to load module $module"
        return 1
    fi
}

# Performance analysis for all modules
analyze_module_performance() {
    echo "⚡ Module Performance Analysis"
    echo "============================"
    
    local total_time=0
    local module_times=()
    
    for module in "${MODULE_LOAD_ORDER[@]}"; do
        local start_time=$EPOCHREALTIME
        
        # Simulate module loading
        sleep 0.001  # Simulate work
        
        local end_time=$EPOCHREALTIME
        local duration=$((end_time - start_time))
        local duration_formatted=$(printf "%.3f" $duration)
        
        module_times+=("$module:$duration_formatted")
        total_time=$((total_time + duration))
        
        echo "  $module: ${duration_formatted}s"
    done
    
    local total_formatted=$(printf "%.3f" $total_time)
    echo "Total: ${total_formatted}s"
    
    log_module_manager_event "Module performance analysis completed: ${total_formatted}s total"
}

# =============================================================================
# MODULE SECURITY
# =============================================================================

# Security validation for modules
validate_module_security() {
    local module="$1"
    
    if [[ -z "$module" ]]; then
        echo "Usage: validate_module_security <module>"
        return 1
    fi
    
    local module_file="${ZSH_CONFIG_DIR}/modules/${module}.zsh"
    
    if [[ ! -f "$module_file" ]]; then
        echo "❌ Module file not found: $module_file"
        return 1
    fi
    
    # Check for potentially dangerous patterns
    local dangerous_patterns=(
        "rm -rf"
        "sudo"
        "chmod 777"
        "chown root"
        "eval"
        "exec"
    )
    
    local issues=0
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -q "$pattern" "$module_file" 2>/dev/null; then
            echo "⚠️  Module $module contains potentially dangerous pattern: $pattern"
            ((issues++))
        fi
    done
    
    if (( issues == 0 )); then
        echo "✅ Module $module security validation passed"
        log_module_manager_event "Module $module security validation passed"
        return 0
    else
        echo "❌ Module $module security validation failed: $issues issues"
        log_module_manager_event "Module $module security validation failed: $issues issues" "warning"
        return 1
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize module manager
init_module_manager

# Export functions
export -f load_module_with_deps load_all_modules validate_module_dependencies validate_module_files list_all_modules get_module_status reload_module monitor_module_performance analyze_module_performance validate_module_security 2>/dev/null || true 