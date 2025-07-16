#!/usr/bin/env zsh
# =============================================================================
# Completion Module - Simplified Completion System
# Version: 4.0 - Streamlined Completion Management
# =============================================================================

# =============================================================================
# COMPLETION CACHE
# =============================================================================

# Completion cache file
COMPLETION_CACHE_FILE="$ZSH_CACHE_DIR/zcompdump"

# =============================================================================
# INITIALIZE COMPLETION SYSTEM
# =============================================================================

# Initialize completion system
_init_completion() {
    autoload -Uz compinit
    
    # Check if cache needs rebuilding
    local rebuild_cache=0
    
    if [[ ! -f "$COMPLETION_CACHE_FILE" ]] || \
       [[ $(find "$COMPLETION_CACHE_FILE" -mtime +1 2>/dev/null) ]]; then
        rebuild_cache=1
    fi
    
    # Check for newer completion files
    if [[ $rebuild_cache -eq 0 ]]; then
        for comp_dir in $fpath; do
            if [[ -d "$comp_dir" ]] && \
               [[ $(find "$comp_dir" -name '_*' -newer "$COMPLETION_CACHE_FILE" 2>/dev/null | head -1) ]]; then
                rebuild_cache=1
                break
            fi
        done
    fi
    
    # Rebuild cache if needed
    if [[ $rebuild_cache -eq 1 ]]; then
        print -P "%F{33}▓▒░ Rebuilding completion cache...%f"
        compinit -d "$COMPLETION_CACHE_FILE" 2>/dev/null || {
            print -P "%F{red}▓▒░ Using existing cache%f"
            compinit -C -d "$COMPLETION_CACHE_FILE" 2>/dev/null || true
        }
        
        # Compile cache for faster loading
        [[ -f "$COMPLETION_CACHE_FILE" ]] && [[ ! -f "${COMPLETION_CACHE_FILE}.zwc" ]] && \
            zcompile "$COMPLETION_CACHE_FILE" 2>/dev/null || true
    else
        compinit -C -d "$COMPLETION_CACHE_FILE"
    fi
    
    # Load essential completion functions
    autoload -Uz _files _cd _ls _cp _mv _rm
}

# Initialize completion system
_init_completion

# =============================================================================
# CORE COMPLETION STYLES
# =============================================================================

# Basic completion behavior
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/completion"

# Enhanced matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Completion descriptions
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'

# =============================================================================
# FILE AND DIRECTORY COMPLETION
# =============================================================================

# File completion patterns
zstyle ':completion:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' group-order files directories all-files

# Directory completion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# File completion for common commands
zstyle ':completion:*:ls:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:cp:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:mv:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:rm:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*:cat:*' file-patterns '%p(^-/):files'
zstyle ':completion:*:less:*' file-patterns '%p(^-/):files'
zstyle ':completion:*:more:*' file-patterns '%p(^-/):files'
zstyle ':completion:*:head:*' file-patterns '%p(^-/):files'
zstyle ':completion:*:tail:*' file-patterns '%p(^-/):files'

# =============================================================================
# PROCESS COMPLETION
# =============================================================================

# Process completion
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

# =============================================================================
# SSH/SCP COMPLETION
# =============================================================================

# SSH/SCP completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# =============================================================================
# MAN PAGE COMPLETION
# =============================================================================

# Man page completion
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-tab true

# =============================================================================
# TOOL-SPECIFIC COMPLETIONS
# =============================================================================

# Git completion
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-*:*' group-order 'main commands' 'alias commands' 'external commands'

# Docker completion
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# NPM completion
zstyle ':completion:*:*:npm:*' tag-order 'common-commands'

# =============================================================================
# CUSTOM COMPLETIONS
# =============================================================================

# Load custom completions
if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
    for completion in "$ZSH_CONFIG_DIR/completions"/_*(N); do
        [[ -f "$completion" ]] && source "$completion"
    done
fi

# Load tool completions
_load_tool_completions() {
    # Bun completion
    if command -v bun >/dev/null 2>&1; then
        [[ ! -f "$ZSH_CACHE_DIR/_bun" ]] && bun completions > "$ZSH_CACHE_DIR/_bun" 2>/dev/null
        [[ -f "$ZSH_CACHE_DIR/_bun" ]] && source "$ZSH_CACHE_DIR/_bun"
    fi
    
    # Deno completion
    if command -v deno >/dev/null 2>&1; then
        [[ ! -f "$ZSH_CACHE_DIR/_deno" ]] && deno completions zsh > "$ZSH_CACHE_DIR/_deno" 2>/dev/null
        [[ -f "$ZSH_CACHE_DIR/_deno" ]] && source "$ZSH_CACHE_DIR/_deno"
    fi
    
    # Docker completion
    if command -v docker >/dev/null 2>&1; then
        [[ ! -f "$ZSH_CACHE_DIR/_docker" ]] && docker completion zsh > "$ZSH_CACHE_DIR/_docker" 2>/dev/null
        [[ -f "$ZSH_CACHE_DIR/_docker" ]] && source "$ZSH_CACHE_DIR/_docker"
    fi
}

# Load tool completions
_load_tool_completions

# =============================================================================
# TAB COMPLETION ENHANCEMENT
# =============================================================================

# Enhance tab completion
_enhance_tab_completion() {
    # Bind tab keys
    bindkey '^I' complete-word 2>/dev/null || true
    bindkey '^[[Z' reverse-menu-complete 2>/dev/null || true
    
    # Menu selection
    zstyle ':completion:*' menu select
    zstyle ':completion:*' auto-description 'specify: %d'
    zstyle ':completion:*' accept-exact '*(N)'
    zstyle ':completion:*' force-list always
    zstyle ':completion:*' insert-tab pending
}

# Initialize enhanced tab completion
_enhance_tab_completion

# =============================================================================
# FZF-TAB INTEGRATION
# =============================================================================

# Configure FZF-tab if available
if (( ${+_comps[fzf-tab]} )); then
    # FZF-tab configuration
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then
        echo "📁 Directory: $realpath"
        ls -la "$realpath" | head -10 2>/dev/null || echo "Contents not available"
    elif [[ -f $realpath ]]; then
        echo "📄 File: $realpath"
        ls -lh "$realpath" 2>/dev/null || echo "File info not available"
    else
        echo "❓ Unknown: $realpath"
    fi'
    
    # FZF-tab settings
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' continuous-trigger 'space'
    zstyle ':fzf-tab:*' accept-line 'ctrl-space'
fi

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Verify completion system
completion_status() {
    echo "🔍 Completion System Status"
    echo "==========================="
    
    local errors=0
    
    # Check completion initialization
    if (( ${+_comps} )); then
        echo "✅ Completion system initialized"
    else
        echo "❌ Completion system not initialized"
        ((errors++))
    fi
    
    # Check cache file
    if [[ -f "$COMPLETION_CACHE_FILE" ]]; then
        echo "✅ Completion cache exists"
    else
        echo "❌ Completion cache missing"
        ((errors++))
    fi
    
    # Check cache compilation
    if [[ -f "${COMPLETION_CACHE_FILE}.zwc" ]]; then
        echo "✅ Completion cache compiled"
    else
        echo "⚠️  Completion cache not compiled"
    fi
    
    # Check custom completions
    if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
        local custom_count=$(find "$ZSH_CONFIG_DIR/completions" -name "_*" 2>/dev/null | wc -l)
        echo "✅ Custom completions: $custom_count"
    else
        echo "⚠️  No custom completions directory"
    fi
    
    if (( errors == 0 )); then
        echo "✅ Completion system is healthy"
        return 0
    else
        echo "❌ Completion system has $errors issues"
        return 1
    fi
}

# Rebuild completion cache
rebuild_completion() {
    echo "🔄 Rebuilding completion cache..."
    
    # Remove old cache
    [[ -f "$COMPLETION_CACHE_FILE" ]] && rm "$COMPLETION_CACHE_FILE"
    [[ -f "${COMPLETION_CACHE_FILE}.zwc" ]] && rm "${COMPLETION_CACHE_FILE}.zwc"
    
    # Rebuild cache
    autoload -Uz compinit
    compinit -d "$COMPLETION_CACHE_FILE"
    
    # Compile cache
    [[ -f "$COMPLETION_CACHE_FILE" ]] && zcompile "$COMPLETION_CACHE_FILE"
    
    echo "✅ Completion cache rebuilt"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Mark completion module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED completion"

log "Completion module initialized" "success" "completion" 