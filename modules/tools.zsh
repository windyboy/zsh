#!/usr/bin/env zsh
# =============================================================================
# Unified Tools Detection System
# =============================================================================

# Load logging system
if [[ -f "$ZSH_CONFIG_DIR/modules/logging.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/modules/logging.zsh"
fi

# Tools cache
typeset -A _TOOLS_CACHE

# Check if a tool is available and cache the result
has_tool() {
    local tool="$1"
    
    # Return cached result if available
    if [[ -n "${_TOOLS_CACHE[$tool]}" ]]; then
        return ${_TOOLS_CACHE[$tool]}
    fi
    
    # Check if tool exists
    if command -v "$tool" >/dev/null 2>&1; then
        _TOOLS_CACHE[$tool]=0
        return 0
    else
        _TOOLS_CACHE[$tool]=1
        return 1
    fi
}

# Get tool version
get_tool_version() {
    local tool="$1"
    
    if has_tool "$tool"; then
        case "$tool" in
            "git") git --version 2>/dev/null | head -1 ;;
            "node") node --version 2>/dev/null ;;
            "npm") npm --version 2>/dev/null ;;
            "yarn") yarn --version 2>/dev/null ;;
            "bun") bun --version 2>/dev/null ;;
            "python3") python3 --version 2>/dev/null ;;
            "docker") docker --version 2>/dev/null ;;
            "fzf") fzf --version 2>/dev/null ;;
            "eza") eza --version 2>/dev/null ;;
            "zoxide") zoxide --version 2>/dev/null ;;
            "zinit") echo "zinit (plugin manager)" ;;
            *) echo "version unknown" ;;
        esac
    else
        echo "not installed"
    fi
}

# Check multiple tools and report status
check_tools() {
    local tools=("$@")
    local available=0
    local total=${#tools[@]}
    
    echo "🔧 Tools Status Check"
    echo "===================="
    
    for tool in "${tools[@]}"; do
        if has_tool "$tool"; then
            local version=$(get_tool_version "$tool")
            success "$tool: $version"
            ((available++))
        else
            error "$tool: not installed"
        fi
    done
    
    echo ""
    echo "📊 Summary: $available/$total tools available"
    
    if [[ $available -eq $total ]]; then
        success "All tools are available"
    elif [[ $available -gt $((total/2)) ]]; then
        warning "Most tools are available"
    else
        error "Many tools are missing"
    fi
}

# Common development tools
check_dev_tools() {
    local dev_tools=(
        "git"
        "node"
        "npm"
        "python3"
        "docker"
    )
    
    check_tools "${dev_tools[@]}"
}

# Common system tools
check_system_tools() {
    local system_tools=(
        "fzf"
        "eza"
        "zoxide"
        "htop"
        "bat"
    )
    
    check_tools "${system_tools[@]}"
}

# Plugin tools
check_plugin_tools() {
    local plugin_tools=(
        "zinit"
        "fzf"
        "zoxide"
        "eza"
    )
    
    check_tools "${plugin_tools[@]}"
}

# Get list of available tools
get_available_tools() {
    local tools=("$@")
    local available=()
    
    for tool in "${tools[@]}"; do
        if has_tool "$tool"; then
            available+=("$tool")
        fi
    done
    
    echo "${available[@]}"
}

# Get list of missing tools
get_missing_tools() {
    local tools=("$@")
    local missing=()
    
    for tool in "${tools[@]}"; do
        if ! has_tool "$tool"; then
            missing+=("$tool")
        fi
    done
    
    echo "${missing[@]}"
} 