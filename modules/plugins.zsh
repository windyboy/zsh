#!/usr/bin/env zsh
# =============================================================================
# ZSH Plugins Module - Enhanced with Community Plugins
# Version: 3.1 - Community-Recommended Plugins (Conflict-Free)
# =============================================================================

# Add completions to FPATH
if [[ ":$FPATH:" != *":$ZSH_CONFIG_DIR/completions:"* ]]; then 
    export FPATH="$ZSH_CONFIG_DIR/completions:$FPATH"
fi

# =============================================================================
# ZINIT SETUP
# =============================================================================

# Only load zinit if not already loaded
if [[ -z "$ZINIT" ]]; then
    local ZINIT_HOME="${HOME}/.local/share/zinit"
    local ZINIT_BIN="${HOME}/.local/share/zinit/zinit.git"
    
    # Install zinit if not present
    if [[ ! -f "$ZINIT_BIN/zinit.zsh" ]]; then
        echo "📦 Installing zinit..."
        mkdir -p "$ZINIT_HOME"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_BIN"
    fi
    
    # Load zinit
    source "$ZINIT_BIN/zinit.zsh" 2>/dev/null
    
    # Configure zinit
    ZINIT[MUTE_WARNINGS]=1 2>/dev/null || true
    ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1 2>/dev/null || true
    ZINIT[COMPINIT_OPTS]="-C" 2>/dev/null || true
    ZINIT[NO_ALIASES]=1 2>/dev/null || true
    
    # Initialize completion
    autoload -Uz _zinit 2>/dev/null || true
    (( ${+_comps} )) && _comps[zinit]=_zinit 2>/dev/null || true
fi

# =============================================================================
# CORE PLUGINS (Essential)
# =============================================================================

# Only load plugins in interactive shells
if [[ -o interactive ]]; then
    # Syntax highlighting (must be loaded last)
    zinit ice wait"0" lucid
    zinit light zdharma-continuum/fast-syntax-highlighting 2>/dev/null || true
    
    # Auto suggestions
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-autosuggestions 2>/dev/null || true
    
    # FZF tab completion (lazy load)
    zinit ice wait"0" lucid
    zinit light Aloxaf/fzf-tab 2>/dev/null || true
    
    # Enhanced completions
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-completions 2>/dev/null || true
    
    # Git integration
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
    
    # History management
    zinit ice wait"0" lucid
    zinit light zsh-users/zsh-history-substring-search 2>/dev/null || true
    zinit snippet https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/history/history.plugin.zsh
fi

# =============================================================================
# ENHANCED PLUGINS (Optional but Recommended)
# =============================================================================

# Only load enhanced plugins if explicitly enabled
if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
    # Multi-word history search
    zinit ice wait"0" lucid
    zinit light zdharma-continuum/history-search-multi-word 2>/dev/null || true
    
    # Alias tips
    zinit ice wait"0" lucid
    zinit light zdharma-continuum/alias-tips 2>/dev/null || true
    
    # Auto environment
    zinit ice wait"0" lucid
    zinit light Tarrasch/zsh-autoenv 2>/dev/null || true
    
    # Smart directory jumping (z)
    zinit ice wait"0" lucid
    zinit light agkozak/zsh-z 2>/dev/null || true
    
    # Git prompt (if not using a theme)
    if [[ -z "$ZSH_THEME" ]]; then
        zinit ice wait"0" lucid
        zinit light zsh-users/zsh-git-prompt 2>/dev/null || true
    fi
fi

# =============================================================================
# SYSTEM TOOLS CONFIGURATION
# =============================================================================

# FZF configuration
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || ls -la {}'"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    
    # Load FZF key bindings
    for fzf_binding in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/local/opt/fzf/shell/key-bindings.zsh ~/.fzf/shell/key-bindings.zsh; do
        [[ -f "$fzf_binding" ]] && source "$fzf_binding" && break
    done
fi

# Zoxide smart navigation
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Enhanced directory listing with eza (only if not already aliased)
if command -v eza >/dev/null 2>&1; then
    # Check if ls alias already exists to avoid conflicts
    if ! alias ls >/dev/null 2>&1; then
        alias ls='eza --icons --group-directories-first'
        alias ll='eza -la --icons --group-directories-first'
        alias la='eza -a --icons --group-directories-first'
        alias lt='eza -T --icons --group-directories-first'
    fi
fi

# =============================================================================
# PLUGIN CONFIGURATION (Conflict-Free)
# =============================================================================

# Auto-suggestions optimization
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-add-eol)
export ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-char vi-forward-char)
export ZSH_AUTOSUGGEST_EXECUTE_WIDGETS=(accept-line)

# FZF tab completion configuration
if command -v bat >/dev/null 2>&1; then
    local preview_cmd='bat --color=always --style=numbers --line-range=:500'
else
    local preview_cmd='ls -la'
fi

# FZF tab configuration (only if not already configured)
if ! zstyle -L ':fzf-tab:*' >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:*' fzf-flags --preview-window=right:60%:wrap --timeout=3
    zstyle ':fzf-tab:complete:*:*' fzf-preview "timeout 2s $preview_cmd \$realpath 2>/dev/null || ls -la \$realpath 2>/dev/null || echo \$realpath"
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' continuous-trigger 'space'
    zstyle ':fzf-tab:*' accept-line 'ctrl-space'
fi

# Plugin-specific key bindings (only if not already bound)
_configure_plugin_keybindings() {
    # FZF tab completion
    if ! bindkey | grep -q '\^T.*fzf-tab-complete'; then
        bindkey '^T' fzf-tab-complete 2>/dev/null || true
    fi
    
    # History substring search (only if not already bound)
    if ! bindkey | grep -q '\^\[\[A.*history-substring-search-up'; then
        bindkey '^[[A' history-substring-search-up 2>/dev/null || true
    fi
    
    if ! bindkey | grep -q '\^\[\[B.*history-substring-search-down'; then
        bindkey '^[[B' history-substring-search-down 2>/dev/null || true
    fi
    
    # History incremental search (only if not already bound and not conflicting)
    if ! bindkey | grep -q '\^R.*history-incremental-search-backward'; then
        # Check if Ctrl+R is already bound to something else
        local ctrl_r_binding=$(bindkey | grep '\^R' | head -1)
        if [[ -z "$ctrl_r_binding" ]] || [[ "$ctrl_r_binding" == *"history-incremental-search-backward"* ]]; then
            bindkey '^R' history-incremental-search-backward 2>/dev/null || true
        else
            echo "⚠️  Ctrl+R already bound to: $ctrl_r_binding"
            echo "💡 Skipping history-incremental-search-backward binding"
        fi
    fi
}

# Configure plugin key bindings
_configure_plugin_keybindings

# =============================================================================
# ENHANCED PLUGIN CONFIGURATIONS
# =============================================================================

# Alias tips configuration
if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
    export ZSH_PLUGINS_ALIAS_TIPS_TEXT="💡 Tip: "
    export ZSH_PLUGINS_ALIAS_TIPS_EXCLUDES="_ vi vim nvim"
fi

# Z (smart directory jumping) configuration
if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
    export ZSHZ_DATA="${ZSH_CACHE_DIR}/z"
    export ZSHZ_ECHO=1
    export ZSHZ_TILDE=1
fi

# Autoenv configuration
if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
    export AUTOENV_AUTH_FILE="${ZSH_CACHE_DIR}/autoenv_auth"
    export AUTOENV_FILE_ENTER=".env"
    export AUTOENV_FILE_LEAVE=".env.leave"
fi

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Plugin status checker
check_plugins() {
    echo "🔌 Plugin Status:"
    echo "================="
    
    local plugins=(
        "fzf:Fuzzy Finder"
        "zoxide:Smart Navigation"
        "eza:Enhanced ls"
        "bat:Code Preview"
        "zsh-autosuggestions:Auto Suggestions"
        "fast-syntax-highlighting:Syntax Highlighting"
        "fzf-tab:FZF Tab Completion"
        "zsh-completions:Enhanced Completions"
        "git:Git Integration"
        "history:History Management"
        "zsh-history-substring-search:Better History Search"
    )
    
    # Add enhanced plugins if enabled
    if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
        plugins+=(
            "history-search-multi-word:Multi-word History Search"
            "alias-tips:Alias Tips"
            "zsh-autoenv:Auto Environment"
            "zsh-z:Smart Directory Jumping"
            "zsh-git-prompt:Git Prompt"
        )
    fi
    
    for plugin in "${plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        
        if command -v "$name" >/dev/null 2>&1; then
            echo "✅ $desc"
        else
            echo "❌ $desc (not installed)"
        fi
    done
    
    echo ""
    echo "🔌 Zinit Status:"
    if [[ -n "$ZINIT" ]]; then
        echo "✅ Zinit loaded"
        if [[ -d "${ZINIT[HOME_DIR]}/plugins" ]]; then
            echo "📦 Plugins:"
            ls "${ZINIT[HOME_DIR]}/plugins" | sed 's/^/  • /'
        fi
    else
        echo "❌ Zinit not loaded"
    fi
    
    # Show enhanced plugins status
    if [[ -n "$ZSH_LOAD_ENHANCED_PLUGINS" ]]; then
        echo ""
        echo "🚀 Enhanced plugins enabled"
    else
        echo ""
        echo "💡 Enable enhanced plugins with: export ZSH_LOAD_ENHANCED_PLUGINS=1"
    fi
}

# Conflict detection function
check_plugin_conflicts() {
    echo "🔍 Plugin Conflict Check:"
    echo "========================"
    
    local conflicts=0
    
    # Check for duplicate key bindings (excluding normal zsh behavior)
    local duplicate_bindings=$(bindkey | awk '{print $2}' | sort | uniq -d)
    if [[ -n "$duplicate_bindings" ]]; then
        echo "🔍 Analyzing key bindings..."
        
        # Filter out normal zsh bindings that are supposed to have multiple keys
        local normal_bindings=(
            "accept-line"      # ^J and ^M are both normal
            "self-insert"      # Multiple key ranges are normal
            "vi-backward-char" # Multiple arrow keys are normal
            "vi-backward-delete-char"
            "vi-forward-char"
            "vi-quoted-insert"
        )
        
        local real_conflicts=""
        while IFS= read -r binding; do
            if [[ -n "$binding" ]]; then
                # Check if this is a normal binding
                local is_normal=0
                for normal in "${normal_bindings[@]}"; do
                    if [[ "$binding" == "$normal" ]]; then
                        is_normal=1
                        break
                    fi
                done
                
                if [[ $is_normal -eq 0 ]]; then
                    real_conflicts="$real_conflicts$binding"$'\n'
                fi
            fi
        done <<< "$duplicate_bindings"
        
        if [[ -n "$real_conflicts" ]]; then
            echo "❌ Real duplicate key bindings found:"
            echo "$real_conflicts" | sed 's/^/  • /'
            ((conflicts++))
        else
            echo "✅ No real duplicate key bindings (normal zsh behavior detected)"
        fi
    else
        echo "✅ No duplicate key bindings"
    fi
    
    # Check for duplicate aliases
    local duplicate_aliases=$(alias | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$duplicate_aliases" ]]; then
        echo "❌ Duplicate aliases found:"
        echo "$duplicate_aliases" | sed 's/^/  • /'
        ((conflicts++))
    else
        echo "✅ No duplicate aliases"
    fi
    
    # Check for duplicate zstyle configurations
    local duplicate_zstyles=$(zstyle -L | grep -E '^[[:space:]]*:' | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$duplicate_zstyles" ]]; then
        echo "❌ Duplicate zstyle configurations found:"
        echo "$duplicate_zstyles" | sed 's/^/  • /'
        ((conflicts++))
    else
        echo "✅ No duplicate zstyle configurations"
    fi
    
    # Check for specific plugin conflicts
    echo ""
    echo "🔍 Checking specific plugin conflicts..."
    
    # Check Ctrl+R conflicts (only exact ^R conflicts)
    local ctrl_r_exact=$(bindkey | grep '^\^R' | wc -l)
    if [[ $ctrl_r_exact -gt 1 ]]; then
        echo "⚠️  Ctrl+R bound multiple times:"
        bindkey | grep '^\^R' | sed 's/^/  • /'
        ((conflicts++))
    else
        echo "✅ Ctrl+R binding is unique"
    fi
    
    # Check Ctrl+T conflicts
    local ctrl_t_bindings=$(bindkey | grep '\^T' | wc -l)
    if [[ $ctrl_t_bindings -gt 1 ]]; then
        echo "⚠️  Ctrl+T bound multiple times:"
        bindkey | grep '\^T' | sed 's/^/  • /'
        ((conflicts++))
    else
        echo "✅ Ctrl+T binding is unique"
    fi
    
    if [[ $conflicts -eq 0 ]]; then
        echo ""
        echo "🎉 No conflicts detected!"
    else
        echo ""
        echo "⚠️  $conflicts conflict(s) detected"
    fi
    
    return $conflicts
}

# Smart conflict resolution function
resolve_plugin_conflicts() {
    echo "🔧 Resolving Plugin Conflicts..."
    echo "==============================="
    
    local resolved=0
    
    # Resolve duplicate key bindings (excluding normal zsh behavior)
    local duplicate_bindings=$(bindkey | awk '{print $2}' | sort | uniq -d)
    if [[ -n "$duplicate_bindings" ]]; then
        echo "🔧 Analyzing key bindings for real conflicts..."
        
        # Filter out normal zsh bindings that are supposed to have multiple keys
        local normal_bindings=(
            "accept-line"      # ^J and ^M are both normal
            "self-insert"      # Multiple key ranges are normal
            "vi-backward-char" # Multiple arrow keys are normal
            "vi-backward-delete-char"
            "vi-forward-char"
            "vi-quoted-insert"
        )
        
        local real_conflicts=""
        while IFS= read -r binding; do
            if [[ -n "$binding" ]]; then
                # Check if this is a normal binding
                local is_normal=0
                for normal in "${normal_bindings[@]}"; do
                    if [[ "$binding" == "$normal" ]]; then
                        is_normal=1
                        break
                    fi
                done
                
                if [[ $is_normal -eq 0 ]]; then
                    real_conflicts="$real_conflicts$binding"$'\n'
                fi
            fi
        done <<< "$duplicate_bindings"
        
        if [[ -n "$real_conflicts" ]]; then
            echo "🔧 Resolving real duplicate key bindings..."
            
            # Get all bindings
            local all_bindings=$(bindkey)
            
            # For each real duplicate binding, keep only the first occurrence
            while IFS= read -r binding; do
                if [[ -n "$binding" ]]; then
                    # Get all occurrences of this binding
                    local occurrences=$(echo "$all_bindings" | grep "$binding")
                    local first_occurrence=$(echo "$occurrences" | head -1)
                    local key=$(echo "$first_occurrence" | awk '{print $1}')
                    local function=$(echo "$first_occurrence" | awk '{print $2}')
                    
                    # Count how many times this binding appears
                    local count=$(echo "$occurrences" | wc -l)
                    
                    if [[ $count -gt 1 ]]; then
                        echo "  🔧 Resolving '$binding' ($count occurrences)..."
                        
                        # Unbind all occurrences of this binding
                        while IFS= read -r occurrence; do
                            local occ_key=$(echo "$occurrence" | awk '{print $1}')
                            if [[ -n "$occ_key" ]]; then
                                bindkey -r "$occ_key" 2>/dev/null || true
                            fi
                        done <<< "$occurrences"
                        
                        # Rebind only the first occurrence
                        if [[ -n "$key" ]] && [[ -n "$function" ]]; then
                            bindkey "$key" "$function" 2>/dev/null || true
                            echo "    ✅ Kept: $key -> $function"
                            ((resolved++))
                        fi
                    fi
                fi
            done <<< "$real_conflicts"
        else
            echo "✅ No real key binding conflicts to resolve"
        fi
    fi
    
    # Resolve duplicate aliases
    local duplicate_aliases=$(alias | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$duplicate_aliases" ]]; then
        echo "🔧 Resolving duplicate aliases..."
        
        while IFS= read -r alias_name; do
            if [[ -n "$alias_name" ]]; then
                # Get all alias definitions for this name
                local alias_definitions=$(alias | grep "^$alias_name=")
                local first_alias=$(echo "$alias_definitions" | head -1)
                local count=$(echo "$alias_definitions" | wc -l)
                
                if [[ $count -gt 1 ]]; then
                    echo "  🔧 Resolving alias '$alias_name' ($count definitions)..."
                    
                    # Remove all definitions
                    unalias "$alias_name" 2>/dev/null || true
                    
                    # Restore only the first definition
                    if [[ -n "$first_alias" ]]; then
                        eval "$first_alias" 2>/dev/null || true
                        echo "    ✅ Kept: $first_alias"
                        ((resolved++))
                    fi
                fi
            fi
        done <<< "$duplicate_aliases"
    fi
    
    # Resolve specific plugin conflicts
    echo "🔧 Checking specific plugin conflicts..."
    
    # Resolve Ctrl+R conflicts (only exact ^R conflicts)
    local ctrl_r_exact=$(bindkey | grep '^\^R')
    local ctrl_r_count=$(echo "$ctrl_r_exact" | wc -l)
    if [[ $ctrl_r_count -gt 1 ]]; then
        echo "  🔧 Resolving Ctrl+R conflicts ($ctrl_r_count bindings)..."
        
        # Keep only the first Ctrl+R binding
        local first_ctrl_r=$(echo "$ctrl_r_exact" | head -1)
        local first_key=$(echo "$first_ctrl_r" | awk '{print $1}')
        local first_func=$(echo "$first_ctrl_r" | awk '{print $2}')
        
        # Unbind all Ctrl+R
        bindkey -r '^R' 2>/dev/null || true
        
        # Rebind only the first
        if [[ -n "$first_key" ]] && [[ -n "$first_func" ]]; then
            bindkey "$first_key" "$first_func" 2>/dev/null || true
            echo "    ✅ Kept: $first_key -> $first_func"
            ((resolved++))
        fi
    fi
    
    # Resolve Ctrl+T conflicts
    local ctrl_t_bindings=$(bindkey | grep '\^T')
    local ctrl_t_count=$(echo "$ctrl_t_bindings" | wc -l)
    if [[ $ctrl_t_count -gt 1 ]]; then
        echo "  🔧 Resolving Ctrl+T conflicts ($ctrl_t_count bindings)..."
        
        # Keep only the first Ctrl+T binding
        local first_ctrl_t=$(echo "$ctrl_t_bindings" | head -1)
        local first_key=$(echo "$first_ctrl_t" | awk '{print $1}')
        local first_func=$(echo "$first_ctrl_t" | awk '{print $2}')
        
        # Unbind all Ctrl+T
        bindkey -r '^T' 2>/dev/null || true
        
        # Rebind only the first
        if [[ -n "$first_key" ]] && [[ -n "$first_func" ]]; then
            bindkey "$first_key" "$first_func" 2>/dev/null || true
            echo "    ✅ Kept: $first_key -> $first_func"
            ((resolved++))
        fi
    fi
    
    if [[ $resolved -gt 0 ]]; then
        echo ""
        echo "🎉 Resolved $resolved conflict(s)!"
    else
        echo ""
        echo "✅ No conflicts to resolve"
    fi
    
    return $resolved
}

# Export functions
export -f check_plugins check_plugin_conflicts resolve_plugin_conflicts 2>/dev/null || true
