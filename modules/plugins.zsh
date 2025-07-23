#!/usr/bin/env zsh
# =============================================================================
# Plugins Module - Plugin Management and Enhancement
# Description: Only essential, high-frequency plugins with clear comments and unified naming.
# =============================================================================

# Color output tools
plugins_color_red()   { echo -e "\033[31m$1\033[0m"; }
plugins_color_green() { echo -e "\033[32m$1\033[0m"; }

# -------------------- zinit Installation and Loading --------------------
if [[ -z "$ZINIT" ]]; then
    local ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"
    local ZINIT_BIN="${ZINIT_HOME}/zinit.git"
    [[ ! -f "$ZINIT_BIN/zinit.zsh" ]] && echo "📦 Installing zinit..." && mkdir -p "$ZINIT_HOME" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_BIN"
    source "$ZINIT_BIN/zinit.zsh" 2>/dev/null
    ZINIT[MUTE_WARNINGS]=1 2>/dev/null || true
    ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1 2>/dev/null || true
    ZINIT[COMPINIT_OPTS]="-C" 2>/dev/null || true
    ZINIT[NO_ALIASES]=1 2>/dev/null || true
fi

# -------------------- Essential Plugins (High Frequency) --------------------
if [[ -o interactive ]]; then
    zinit ice wait"0" lucid
    zinit light zdharma-continuum/fast-syntax-highlighting 2>/dev/null || true
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-autosuggestions 2>/dev/null || true
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-completions 2>/dev/null || true
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/history/history.plugin.zsh
fi

# -------------------- Optional Enhancement Plugins --------------------
if command -v fzf >/dev/null 2>&1; then
    zinit ice wait"0" lucid
    zinit light Aloxaf/fzf-tab 2>/dev/null || true
fi
if ! bindkey | /usr/bin/grep -q '\^\[\[A.*history-substring-search-up'; then
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-history-substring-search 2>/dev/null || true
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
if command -v eza >/dev/null 2>&1; then
    alias lt='eza -T --icons --group-directories-first'
fi

# -------------------- Plugin Configuration --------------------
# ZSH Autosuggestions Configuration
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
# Configure fzf-tab if available
if command -v fzf >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:*' fzf-flags --preview-window=right:60%:wrap
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' continuous-trigger 'space'
    zstyle ':fzf-tab:*' accept-line 'ctrl-space'
fi

# -------------------- Common Functions --------------------
plugins() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && echo "Usage: plugins" && return 0
    
    # Check zinit plugins
    local zinit_plugins=(
        "fast-syntax-highlighting:Syntax Highlighting"
        "zsh-autosuggestions:Auto Suggestions"
        "zsh-completions:Enhanced Completions"
        "fzf-tab:FZF Tab Completion"
    )
    
    # Check tool plugins
    local tool_plugins=(
        "fzf:Fuzzy Finder"
        "zoxide:Smart Navigation"
        "eza:Enhanced ls"
    )
    
    # Check builtin plugins
    local builtin_plugins=(
        "git:Git Integration"
        "history:History Management"
    )
    
    # Check zinit plugins
    for plugin in "${zinit_plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        if [[ -n "$ZINIT" ]] && [[ -d "$ZINIT_HOME/plugins" ]]; then
            plugins_color_green "✅ $name - $desc"
        else
            plugins_color_red "❌ $name - $desc"
        fi
    done
    
    # Check tool plugins
    for plugin in "${tool_plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        if command -v "$name" >/dev/null 2>&1; then
            plugins_color_green "✅ $name - $desc"
        else
            plugins_color_red "❌ $name - $desc"
        fi
    done
    
    # Check builtin plugins
    for plugin in "${builtin_plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        plugins_color_green "✅ $name - $desc"
    done
}

# -------------------- Plugin Conflict Detection Functions --------------------
check_plugin_conflicts() {
    echo "🔍 Checking plugin conflicts..."
    
    # Check for key binding conflicts (same key bound to different functions)
    local conflicts_found=false
    local key_bindings=()
    
    # Collect all key bindings
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*([^[:space:]]+)[[:space:]]+(.+)$ ]]; then
            local key="${match[1]}"
            local function="${match[2]}"
            key_bindings+=("$key:$function")
        fi
    done < <(bindkey)
    
    # Detect conflicts
    local seen_keys=()
    for binding in "${key_bindings[@]}"; do
        local key="${binding%%:*}"
        local function="${binding##*:}"
        
        # Check if we've seen this key before
        for seen in "${seen_keys[@]}"; do
            local seen_key="${seen%%:*}"
            local seen_function="${seen##*:}"
            
            if [[ "$key" == "$seen_key" && "$function" != "$seen_function" ]]; then
                if [[ "$conflicts_found" == false ]]; then
                    echo "❌ Key binding conflicts found:"
                    conflicts_found=true
                fi
                echo "   • $key: $seen_function vs $function"
            fi
        done
        
        seen_keys+=("$key:$function")
    done
    
    if [[ "$conflicts_found" == false ]]; then
        plugins_color_green "✅ No key binding conflicts found"
    fi
    
    # Check for alias conflicts
    local alias_conflicts=$(alias | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$alias_conflicts" ]]; then
        echo "❌ Duplicate aliases found:"
        echo "$alias_conflicts" | sed 's/^/   • /'
    else
        plugins_color_green "✅ No alias conflicts found"
    fi
    
    # Check for zstyle configuration conflicts
    local zstyle_conflicts=$(zstyle -L | grep -E '^[[:space:]]*:' | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$zstyle_conflicts" ]]; then
        echo "❌ Duplicate zstyle configurations found:"
        echo "$zstyle_conflicts" | sed 's/^/   • /'
    else
        plugins_color_green "✅ No zstyle configuration conflicts found"
    fi
}

resolve_plugin_conflicts() {
    echo "🔧 Plugin conflict resolution suggestions..."
    
    # Check for key binding conflicts and provide resolution suggestions
    local key_bindings=()
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*([^[:space:]]+)[[:space:]]+(.+)$ ]]; then
            local key="${match[1]}"
            local function="${match[2]}"
            key_bindings+=("$key:$function")
        fi
    done < <(bindkey)
    
    local seen_keys=()
    local conflicts=()
    
    for binding in "${key_bindings[@]}"; do
        local key="${binding%%:*}"
        local function="${binding##*:}"
        
        for seen in "${seen_keys[@]}"; do
            local seen_key="${seen%%:*}"
            local seen_function="${seen##*:}"
            
            if [[ "$key" == "$seen_key" && "$function" != "$seen_function" ]]; then
                conflicts+=("$key:$seen_function:$function")
            fi
        done
        
        seen_keys+=("$key:$function")
    done
    
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        echo "💡 Key binding conflict resolution suggestions:"
        for conflict in "${conflicts[@]}"; do
            local key="${conflict%%:*}"
            local func1="${conflict#*:}"
            local func2="${func1#*:}"
            func1="${func1%%:*}"
            
            echo "   • Key $key conflict:"
            echo "     - $func1"
            echo "     - $func2"
            echo "     💡 Suggestion: Choose one function, use 'bindkey -r $key' to unbind then rebind"
        done
    fi
    
    # Check for alias conflicts
    local duplicate_aliases=$(alias | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$duplicate_aliases" ]]; then
        echo "💡 Alias conflict resolution suggestions:"
        echo "$duplicate_aliases" | while read -r alias_name; do
            echo "   • Alias $alias_name is defined multiple times"
            echo "     💡 Suggestion: Check plugin loading order, remove duplicate definitions"
        done
    fi
    
    # Check for zstyle configuration conflicts
    local duplicate_zstyles=$(zstyle -L | grep -E '^[[:space:]]*:' | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$duplicate_zstyles" ]]; then
        echo "💡 zstyle configuration conflict resolution suggestions:"
        echo "$duplicate_zstyles" | while read -r zstyle_name; do
            echo "   • zstyle $zstyle_name is configured multiple times"
            echo "     💡 Suggestion: Use 'zstyle -d $zstyle_name' to remove duplicate configurations"
        done
    fi
    
    if [[ ${#conflicts[@]} -eq 0 && -z "$duplicate_aliases" && -z "$duplicate_zstyles" ]]; then
        plugins_color_green "✅ No conflicts requiring resolution found"
    fi
}

check_plugins() {
    echo "🔍 Plugin health check..."
    
    # Check if zinit is working properly
    if [[ -n "$ZINIT" ]]; then
        plugins_color_green "✅ zinit loaded"
    else
        plugins_color_red "❌ zinit not loaded"
    fi
    
    # Check critical plugin files
    local critical_plugins=(
        "fast-syntax-highlighting"
        "zsh-autosuggestions"
        "zsh-completions"
    )
    
    for plugin in "${critical_plugins[@]}"; do
        if [[ -d "$ZINIT_HOME/plugins/$plugin" ]]; then
            plugins_color_green "✅ $plugin installed"
        else
            plugins_color_red "❌ $plugin not installed"
        fi
    done
    
    # Check tool dependencies
    local tool_dependencies=(
        "fzf"
        "zoxide"
        "eza"
    )
    
    for tool in "${tool_dependencies[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            plugins_color_green "✅ $tool available"
        else
            plugins_color_red "❌ $tool not available"
        fi
    done
    
    # Check environment variables
    local required_vars=(
        "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
        "ZSH_AUTOSUGGEST_STRATEGY"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -n "${(P)var}" ]]; then
            plugins_color_green "✅ $var set"
        else
            plugins_color_red "❌ $var not set"
        fi
    done
    
    # Run conflict detection
    echo ""
    check_plugin_conflicts
}

# -------------------- Reserved Custom Area --------------------
# Custom plugin configurations can be added in the custom/ directory

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED plugins"
echo "INFO: Plugins module initialized" 
