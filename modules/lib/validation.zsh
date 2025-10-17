#!/usr/bin/env zsh
# =============================================================================
# Validation Library - Shared configuration validation utilities
# =============================================================================

[[ -n "${__ZSH_VALIDATION_LIB_LOADED:-}" ]] && return 0
__ZSH_VALIDATION_LIB_LOADED=1

typeset -gi VALIDATION_ERRORS=0
typeset -gi VALIDATION_WARNINGS=0
typeset -ga __VALIDATION_MESSAGES=()
typeset -g __VALIDATION_FIX_MODE="false"

__get_file_perms() {
    {
        setopt local_options no_xtrace 2>/dev/null
        local target_file="$1"
        local result
        result=$(stat -f %Lp "$target_file" 2>/dev/null || stat -c %a "$target_file" 2>/dev/null)
        print -r -- "$result"
    } 2>/dev/null
}

validation_reset_context() {
    local fix_mode="${1:-false}"
    __VALIDATION_MESSAGES=()
    __VALIDATION_FIX_MODE="$fix_mode"
    VALIDATION_ERRORS=0
    VALIDATION_WARNINGS=0
}

validation_add() {
    local level="$1"
    local message="$2"
    __VALIDATION_MESSAGES+=("$level|$message")
    case "$level" in
        error) 
            (( VALIDATION_ERRORS++ ))
            ;;
        warning) 
            (( VALIDATION_WARNINGS++ ))
            ;;
    esac
}

validation_attempt_fix() {
    local description="$1"
    local command="$2"

    [[ "$__VALIDATION_FIX_MODE" == "true" ]] || return 1

    validation_add info "Attempting to fix: $description"
    if [[ "$command" =~ ^(mkdir|chmod|chown|ln|cp|mv|rm)\  ]]; then
        if eval "$command" 2>/dev/null; then
            validation_add success "Fixed: $description"
            return 0
        fi
        validation_add warning "Failed to fix: $description"
        return 1
    fi

    validation_add warning "Skipping potentially unsafe command: $command"
    return 1
}

validation_run() {
    local target_array="$1"
    local fix_mode="${2:-false}"
    local -a modules=("core" "navigation" "aliases" "plugins" "completion" "keybindings" "utils")
    local -a required_dirs=("$ZSH_CONFIG_DIR" "$ZSH_CACHE_DIR" "$ZSH_DATA_DIR")
    local -a required_files=("$ZSH_CONFIG_DIR/zshrc" "$ZSH_CONFIG_DIR/modules/core.zsh")

    validation_reset_context "$fix_mode"

    # 1. Directories
    validation_add info "Checking required directories..."
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            validation_add error "Missing directory: $dir"
            validation_attempt_fix "Create missing directory" "mkdir -p \"$dir\""
        else
            validation_add success "Directory exists: $dir"
        fi
    done

    # 2. Files
    validation_add info "Checking required files..."
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            validation_add error "Missing file: $file"
        else
            validation_add success "File exists: $file"
            local file_perms="$(__get_file_perms "$file")"
            if [[ -n "$file_perms" && $file_perms -gt 644 ]]; then
                validation_add warning "Insecure permissions on $file: $file_perms"
                validation_attempt_fix "Fix file permissions" "chmod 644 \"$file\""
            fi
        fi
    done

    # 3. Environment variables
    validation_add info "Checking environment variables..."
    for var in ZSH_CONFIG_DIR ZSH_CACHE_DIR ZSH_DATA_DIR; do
        local value="${(P)var}"
        if [[ -z "$value" ]]; then
            validation_add error "Environment variable not set: $var"
        else
            validation_add success "Environment variable set: $var=$value"
        fi
    done

    # 4. Module loading
    validation_add info "Checking module loading..."
    for module in "${modules[@]}"; do
        local modfile="$ZSH_CONFIG_DIR/modules/${module}.zsh"
        if [[ -f "$modfile" ]]; then
            if [[ -n "$ZSH_MODULES_LOADED" && "$ZSH_MODULES_LOADED" == *"$module"* ]]; then
                validation_add success "Module loaded: $module"
            else
                validation_add warning "Module file exists but not loaded: $module"
            fi
        else
            validation_add error "Module file missing: $modfile"
        fi
    done

    # 5. Plugin system
    validation_add info "Checking plugin system..."
    if command -v zinit >/dev/null 2>&1; then
        validation_add success "zinit plugin manager available"
    else
        validation_add warning "zinit plugin manager not found"
        local zinit_dir="$HOME/.local/share/zsh/zinit/zinit.git"
        validation_attempt_fix "Install zinit" "git clone https://github.com/zdharma-continuum/zinit.git \"$zinit_dir\""
    fi

    # 6. Completion system
    validation_add info "Checking completion system..."
    if [[ -f "$ZSH_CONFIG_DIR/modules/completion.zsh" ]]; then
        if compdef >/dev/null 2>&1; then
            validation_add success "Completion system working"
        else
            validation_add warning "Completion system not initialized (may be expected in test contexts)"
        fi
    else
        validation_add error "Completion module file missing"
    fi

    # 7. Common issues
    validation_add info "Checking for common issues..."
    local duplicate_aliases duplicate_bindings
    duplicate_aliases=$(alias | cut -d= -f1 | sed 's/^alias //g' | sort | uniq -d)
    if [[ -n "$duplicate_aliases" ]]; then
        validation_add warning "Duplicate aliases found: $duplicate_aliases"
    else
        validation_add success "No duplicate aliases"
    fi

    duplicate_bindings=$(bindkey | grep '^\^T' | wc -l)
    if [[ $duplicate_bindings -gt 1 ]]; then
        validation_add warning "Ctrl+T bound multiple times ($duplicate_bindings bindings)"
    fi

    # 8. Performance metrics
    validation_add info "Checking performance metrics..."
    local func_count alias_count memory_kb memory_mb
    func_count=$(declare -F 2>/dev/null | wc -l 2>/dev/null)
    alias_count=$(alias 2>/dev/null | wc -l 2>/dev/null)
    memory_kb=$(ps -p $$ -o rss 2>/dev/null | awk 'NR==2 {gsub(/ /, "", $1); print $1}')
    memory_mb=$(echo "scale=1; ${memory_kb:-0} / 1024" | bc 2>/dev/null || echo "0")

    if [[ $func_count -gt 200 ]]; then
        validation_add warning "High function count: $func_count (recommended: <200)"
    else
        validation_add success "Function count: $func_count"
    fi

    if [[ $alias_count -gt 100 ]]; then
        validation_add warning "High alias count: $alias_count (recommended: <100)"
    else
        validation_add success "Alias count: $alias_count"
    fi

    if [[ $(echo "$memory_mb > 10" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        validation_add warning "High memory usage: ${memory_mb}MB (recommended: <10MB)"
    else
        validation_add success "Memory usage: ${memory_mb}MB"
    fi

    # 9. Startup time
    validation_add info "Checking startup time..."
    local start_time end_time startup_time
    start_time=$(date +%s.%N)
    source "$ZSH_CONFIG_DIR/zshrc" >/dev/null 2>&1
    end_time=$(date +%s.%N)
    startup_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    if [[ $(echo "$startup_time > 2" | bc 2>/dev/null || echo "0") -eq 1 ]]; then
        validation_add warning "Slow startup time: ${startup_time}s (recommended: <2s)"
    else
        validation_add success "Startup time: ${startup_time}s"
    fi

    # 10. Syntax validation
    validation_add info "Checking for syntax errors..."
    local syntax_errors=0
    for module in "${modules[@]}"; do
        local modfile="$ZSH_CONFIG_DIR/modules/${module}.zsh"
        if [[ -f "$modfile" ]]; then
            if zsh -n "$modfile" 2>/dev/null; then
                validation_add success "Syntax OK: $module.zsh"
            else
                validation_add error "Syntax error in: $module.zsh"
                ((syntax_errors++))
            fi
        fi
    done

    eval "$target_array=(\"\${__VALIDATION_MESSAGES[@]}\")"
    
    (( VALIDATION_ERRORS == 0 ))
}
