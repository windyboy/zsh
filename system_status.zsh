#!/usr/bin/env zsh
# =============================================================================
# System Status Checker - Unified Module System
# Version: 3.0 - Comprehensive System Diagnostics
# =============================================================================

# =============================================================================
# CONFIGURATION
# =============================================================================

# Status checker configuration
STATUS_LOG="${ZSH_CACHE_DIR}/system_status.log"

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize status checker
init_status_checker() {
    [[ ! -d "$STATUS_LOG:h" ]] && mkdir -p "$STATUS_LOG:h"
}

# =============================================================================
# STATUS LOGGING
# =============================================================================

# Log status events
log_status_event() {
    local event="$1"
    local level="${2:-info}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $event" >> "$STATUS_LOG"
}

# =============================================================================
# SYSTEM STATUS FUNCTIONS
# =============================================================================

# Comprehensive system status check
system_status() {
    log_status_event "System status check started"
    
    echo "🔍 ZSH System Status Check"
    echo "=========================="
    echo
    
    # Check core system
    check_core_system
    
    # Check modules
    check_modules
    
    # Check performance
    check_performance
    
    # Check security
    check_security
    
    # Check configuration
    check_configuration
    
    # Generate summary
    generate_status_summary
    
    log_status_event "System status check completed"
}

# Check core system
check_core_system() {
    echo "📋 Core System Check"
    echo "==================="
    
    local errors=0
    local warnings=0
    
    # Check ZSH version
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "✅ ZSH Version: $ZSH_VERSION"
    else
        echo "❌ ZSH version not detected"
        ((errors++))
    fi
    
    # Check configuration directories
    local dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "✅ Directory exists: $dir"
        else
            echo "❌ Directory missing: $dir"
            ((errors++))
        fi
    done
    
    # Check essential files
    local files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/zshenv")
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "✅ File exists: $(basename "$file")"
        else
            echo "❌ File missing: $(basename "$file")"
            ((errors++))
        fi
    done
    
    # Check PATH
    if [[ -n "$PATH" ]]; then
        local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
        echo "✅ PATH configured: $path_count entries"
        if (( path_count > 20 )); then
            echo "⚠️  PATH has many entries: $path_count"
            ((warnings++))
        fi
    else
        echo "❌ PATH is empty"
        ((errors++))
    fi
    
    echo "Core system: $errors errors, $warnings warnings"
    echo
}

# Check modules
check_modules() {
    echo "📦 Module System Check"
    echo "====================="
    
    local errors=0
    local warnings=0
    
    # Check if modules are loaded
    if [[ -n "$ZSH_MODULES_LOADED" ]]; then
        local module_count=$(echo "$ZSH_MODULES_LOADED" | wc -w)
        echo "✅ Modules loaded: $module_count"
        echo "📋 Loaded modules: $ZSH_MODULES_LOADED"
    else
        echo "❌ No modules loaded"
        ((errors++))
    fi
    
    # Check module files
    local expected_modules=("core" "error_handling" "security" "performance" "plugins" "completion" "aliases" "functions" "keybindings")
    for module in "${expected_modules[@]}"; do
        local module_file="$ZSH_CONFIG_DIR/modules/${module}.zsh"
        if [[ -f "$module_file" ]]; then
            if module_loaded "$module"; then
                echo "✅ $module (loaded)"
            else
                echo "⚠️  $module (exists but not loaded)"
                ((warnings++))
            fi
        else
            echo "❌ $module (missing)"
            ((errors++))
        fi
    done
    
    # Check module manager
    if command -v load_all_modules >/dev/null 2>&1; then
        echo "✅ Module manager available"
    else
        echo "❌ Module manager not available"
        ((errors++))
    fi
    
    echo "Module system: $errors errors, $warnings warnings"
    echo
}

# Check performance
check_performance() {
    echo "⚡ Performance Check"
    echo "==================="
    
    local errors=0
    local warnings=0
    
    # Check function count
    local func_count=$(declare -F | wc -l)
    echo "📊 Functions: $func_count"
    if (( func_count > 500 )); then
        echo "⚠️  High function count: $func_count"
        ((warnings++))
    fi
    
    # Check alias count
    local alias_count=$(alias | wc -l)
    echo "📊 Aliases: $alias_count"
    if (( alias_count > 200 )); then
        echo "⚠️  High alias count: $alias_count"
        ((warnings++))
    fi
    
    # Check PATH entries
    local path_count=$(echo "$PATH" | tr ':' '\n' | wc -l)
    echo "📊 PATH entries: $path_count"
    if (( path_count > 20 )); then
        echo "⚠️  Many PATH entries: $path_count"
        ((warnings++))
    fi
    
    # Check history size
    if [[ -f "$HISTFILE" ]]; then
        local hist_size=$(wc -l < "$HISTFILE" 2>/dev/null || echo "0")
        echo "📊 History size: $hist_size lines"
        if (( hist_size > 10000 )); then
            echo "⚠️  Large history file: $hist_size lines"
            ((warnings++))
        fi
    else
        echo "❌ History file not found"
        ((errors++))
    fi
    
    # Check completion cache
    local comp_cache="$ZSH_CACHE_DIR/zcompdump"
    if [[ -f "$comp_cache" ]]; then
        local cache_size=$(ls -la "$comp_cache" 2>/dev/null | awk '{print $5}' || echo "0")
        echo "📊 Completion cache: $cache_size bytes"
    else
        echo "⚠️  Completion cache not found"
        ((warnings++))
    fi
    
    echo "Performance: $errors errors, $warnings warnings"
    echo
}

# Check security
check_security() {
    echo "🔒 Security Check"
    echo "================"
    
    local errors=0
    local warnings=0
    
    # Check security options
    local security_options=("NO_CLOBBER" "RM_STAR_WAIT" "PIPE_FAIL")
    for opt in "${security_options[@]}"; do
        if [[ -o "$opt" ]]; then
            echo "✅ Security option: $opt"
        else
            echo "❌ Security option not set: $opt"
            ((errors++))
        fi
    done
    
    # Check file permissions
    local config_files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/zshenv")
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            local perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%Lp" "$file" 2>/dev/null)
            if [[ "$perms" == "600" ]] || [[ "$perms" == "644" ]]; then
                echo "✅ File permissions: $(basename "$file") ($perms)"
            else
                echo "⚠️  File permissions: $(basename "$file") ($perms)"
                ((warnings++))
            fi
        fi
    done
    
    # Check for dangerous patterns
    local dangerous_patterns=("rm -rf" "sudo" "chmod 777")
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -r "$pattern" "$ZSH_CONFIG_DIR" 2>/dev/null | head -1 >/dev/null; then
            echo "⚠️  Found potentially dangerous pattern: $pattern"
            ((warnings++))
        fi
    done
    
    echo "Security: $errors errors, $warnings warnings"
    echo
}

# Check configuration
check_configuration() {
    echo "⚙️  Configuration Check"
    echo "======================"
    
    local errors=0
    local warnings=0
    
    # Check environment variables
    local env_vars=("ZSH_CONFIG_DIR" "ZSH_CACHE_DIR" "ZSH_DATA_DIR" "HISTFILE" "HISTSIZE")
    for var in "${env_vars[@]}"; do
        if [[ -n "${(P)var}" ]]; then
            echo "✅ Environment variable: $var"
        else
            echo "❌ Environment variable not set: $var"
            ((errors++))
        fi
    done
    
    # Check ZSH options
    local required_options=("EXTENDED_HISTORY" "SHARE_HISTORY" "AUTO_CD" "EXTENDED_GLOB")
    for opt in "${required_options[@]}"; do
        if [[ -o "$opt" ]]; then
            echo "✅ ZSH option: $opt"
        else
            echo "❌ ZSH option not set: $opt"
            ((errors++))
        fi
    done
    
    # Check keybindings
    local essential_bindings=("beginning-of-line" "end-of-line" "complete-word")
    for binding in "${essential_bindings[@]}"; do
        if bindkey | grep -q "$binding"; then
            echo "✅ Keybinding: $binding"
        else
            echo "❌ Keybinding missing: $binding"
            ((errors++))
        fi
    done
    
    echo "Configuration: $errors errors, $warnings warnings"
    echo
}

# Generate status summary
generate_status_summary() {
    echo "📊 System Status Summary"
    echo "========================"
    
    # Count loaded modules
    local module_count=$(echo "$ZSH_MODULES_LOADED" | wc -w)
    echo "📦 Modules loaded: $module_count"
    
    # Check for critical issues
    local critical_issues=0
    
    # Check if core module is loaded
    if ! module_loaded "core"; then
        echo "❌ Critical: Core module not loaded"
        ((critical_issues++))
    fi
    
    # Check if error handling is loaded
    if ! module_loaded "error_handling"; then
        echo "❌ Critical: Error handling module not loaded"
        ((critical_issues++))
    fi
    
    # Check if security is loaded
    if ! module_loaded "security"; then
        echo "❌ Critical: Security module not loaded"
        ((critical_issues++))
    fi
    
    # Overall status
    if (( critical_issues == 0 )); then
        echo "✅ System status: HEALTHY"
        log_status_event "System status check: HEALTHY"
    else
        echo "❌ System status: CRITICAL ISSUES DETECTED"
        log_status_event "System status check: CRITICAL ISSUES DETECTED" "error"
    fi
    
    echo
    echo "💡 Recommendations:"
    echo "  • Run 'zsh-check' for detailed validation"
    echo "  • Run 'zsh-perf' for performance analysis"
    echo "  • Run 'security-audit' for security check"
    echo "  • Run 'modules-list' to see loaded modules"
}

# =============================================================================
# QUICK STATUS FUNCTIONS
# =============================================================================

# Quick system check
quick_status() {
    echo "⚡ Quick System Status"
    echo "====================="
    
    # Check core functionality
    local core_ok=true
    
    if ! module_loaded "core"; then
        echo "❌ Core module not loaded"
        core_ok=false
    fi
    
    if ! module_loaded "error_handling"; then
        echo "❌ Error handling not loaded"
        core_ok=false
    fi
    
    if ! module_loaded "security"; then
        echo "❌ Security not loaded"
        core_ok=false
    fi
    
    # Check performance
    local func_count=$(declare -F | wc -l)
    local alias_count=$(alias | wc -l)
    
    if (( func_count > 1000 )); then
        echo "⚠️  High function count: $func_count"
    fi
    
    if (( alias_count > 500 )); then
        echo "⚠️  High alias count: $alias_count"
    fi
    
    # Overall status
    if [[ "$core_ok" == "true" ]]; then
        echo "✅ System is operational"
        return 0
    else
        echo "❌ System has critical issues"
        return 1
    fi
}

# Module status check
module_status() {
    echo "📦 Module Status"
    echo "================"
    
    local loaded_count=0
    local total_count=0
    
    local modules=("core" "error_handling" "security" "performance" "plugins" "completion" "aliases" "functions" "keybindings")
    
    for module in "${modules[@]}"; do
        ((total_count++))
        if module_loaded "$module"; then
            echo "✅ $module"
            ((loaded_count++))
        else
            echo "❌ $module"
        fi
    done
    
    echo
    echo "📊 Summary: $loaded_count/$total_count modules loaded"
    
    if (( loaded_count == total_count )); then
        echo "✅ All modules loaded successfully"
        return 0
    else
        echo "❌ Some modules failed to load"
        return 1
    fi
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize status checker
init_status_checker

# Export functions
export -f system_status quick_status module_status 2>/dev/null || true 