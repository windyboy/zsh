#!/usr/bin/env zsh
# =============================================================================
# Enhanced Completion System Configuration
# Based on existing plugins with improved functionality
# =============================================================================

# Completion cache
COMPLETION_CACHE_FILE="${ZSH_CACHE_DIR}/zcompdump"

# =============================================================================
# INITIALIZE COMPLETION SYSTEM
# =============================================================================

# Initialize completion system with proper error handling
_init_completion() {
    # Ensure completion system is loaded
    autoload -Uz compinit
    
    # Check if completion cache exists and is recent
    local rebuild_cache=0
    
    if [[ ! -f "$COMPLETION_CACHE_FILE" ]] || \
       [[ $(find "$COMPLETION_CACHE_FILE" -mtime +1 2>/dev/null) ]]; then
        rebuild_cache=1
    fi
    
    # Check if any completion files are newer than cache
    if [[ $rebuild_cache -eq 0 ]]; then
        for comp_dir in $fpath; do
            if [[ -d "$comp_dir" ]] && \
               [[ $(find "$comp_dir" -name '_*' -newer "$COMPLETION_CACHE_FILE" 2>/dev/null | head -1) ]]; then
                rebuild_cache=1
                break
            fi
        done
    fi
    
    if [[ $rebuild_cache -eq 1 ]]; then
        print -P "%F{33}▓▒░ Rebuilding completion cache...%f"
        compinit -d "$COMPLETION_CACHE_FILE" 2>/dev/null || {
            print -P "%F{red}▓▒░ Completion cache rebuild failed, using existing cache%f"
            compinit -C -d "$COMPLETION_CACHE_FILE" 2>/dev/null || true
        }
        
        # Compile the completion cache for faster loading
        if [[ -f "$COMPLETION_CACHE_FILE" ]] && [[ ! -f "${COMPLETION_CACHE_FILE}.zwc" ]]; then
            zcompile "$COMPLETION_CACHE_FILE" 2>/dev/null || true
        fi
    else
        compinit -C -d "$COMPLETION_CACHE_FILE"
    fi
    
    # Ensure basic completion functions are loaded
    autoload -Uz _files _cd _ls _cp _mv _rm _cat _less _more _head _tail
}

# Initialize completion system
_init_completion

# =============================================================================
# ENHANCED COMPLETION STYLES (BASED ON PLUGINS)
# =============================================================================

# Core completion behavior - ensure tab completion works
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/completion"

# Enhanced matching for better file completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Completion descriptions
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'

# =============================================================================
# FILE AND DIRECTORY COMPLETION (ENHANCED)
# =============================================================================

# Enhanced file completion - show all files including hidden ones
zstyle ':completion:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
zstyle ':completion:*' squeeze-slashes true

# Directory completion with better navigation
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:cd:*' extra-verbose true

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

# Show file types and sizes
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' group-order files directories all-files

# =============================================================================
# PROCESS COMPLETION
# =============================================================================

# Process completion with better display
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

# =============================================================================
# HISTORY COMPLETION
# =============================================================================

# History completion with better matching
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# =============================================================================
# SSH/SCP COMPLETION
# =============================================================================

# SSH/SCP completion with host matching
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

# Load custom completions if directory exists
if [[ -d "$ZSH_CONFIG_DIR/completions" ]]; then
    local completion_files=("$ZSH_CONFIG_DIR/completions"/_*(N))
    for completion in $completion_files; do
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

# Ensure tab completion works properly
_enhance_tab_completion() {
    # Bind tab to complete-word
    bindkey '^I' complete-word 2>/dev/null || true
    bindkey '^[[Z' reverse-menu-complete 2>/dev/null || true
    
    # Enable menu selection
    zstyle ':completion:*' menu select
    
    # Show completion menu immediately
    zstyle ':completion:*' auto-description 'specify: %d'
    
    # Better completion behavior
    zstyle ':completion:*' accept-exact '*(N)'
    zstyle ':completion:*' force-list always
    zstyle ':completion:*' insert-tab pending
    
    # Ensure file completion works
    zstyle ':completion:*' completer _complete _files _match _approximate
}

# Initialize enhanced tab completion
_enhance_tab_completion

# =============================================================================
# FZF-TAB INTEGRATION (IF AVAILABLE)
# =============================================================================

# Configure FZF-tab if available (from plugins)
if (( ${+_comps[fzf-tab]} )); then
    # FZF-tab configuration for better file completion
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then
        echo "📁 Directory: $realpath"
        ls -la "$realpath" | head -10 2>/dev/null || echo "Contents not available"
    elif [[ -f $realpath ]]; then
        echo "📄 File: $realpath"
        ls -lh "$realpath" 2>/dev/null || echo "File info not available"
    else
        echo "❓ Unknown: $realpath"
    fi'
    
    # FZF-tab fallback configuration
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' continuous-trigger 'space'
    zstyle ':fzf-tab:*' accept-line 'ctrl-space'
fi

# =============================================================================
# COMPLETION SYSTEM VERIFICATION
# =============================================================================

# Verify completion system is working
_verify_completion_system() {
    echo "🔍 Verifying completion system..."
    
    # Check if completion is initialized
    if (( ${+_comps} )); then
        echo "✅ Completion system initialized"
    else
        echo "❌ Completion system not initialized"
        return 1
    fi
    
    # Check if tab completion is bound
    if bindkey | grep -q '\^I.*complete-word'; then
        echo "✅ Tab completion bound"
    else
        echo "❌ Tab completion not bound"
        return 1
    fi
    
    # Check if menu completion is enabled
    if zstyle -L ':completion:*' | grep -q 'menu select'; then
        echo "✅ Menu completion enabled"
    else
        echo "❌ Menu completion not enabled"
        return 1
    fi
    
    echo "✅ Completion system verification passed"
    return 0
}

# Export verification function
export -f _verify_completion_system 2>/dev/null || true

# =============================================================================
# COMPLETION DEBUGGING
# =============================================================================

# Function to debug completion issues
_debug_completion() {
    echo "🔍 Completion Debug Info:"
    echo "=========================="
    
    # Check completion system
    echo "1. Completion system status:"
    if (( ${+_comps} )); then
        echo "   ✅ _comps is set"
        echo "   Number of completion functions: ${#_comps}"
    else
        echo "   ❌ _comps is not set"
    fi
    
    # Check tab binding
    echo "2. Tab key binding:"
    local tab_binding=$(bindkey | grep '\^I')
    if [[ -n "$tab_binding" ]]; then
        echo "   ✅ Tab bound to: $tab_binding"
    else
        echo "   ❌ Tab not bound to complete-word"
    fi
    
    # Check completion styles
    echo "3. Completion styles:"
    local menu_style=$(zstyle -L ':completion:*' | grep 'menu select')
    if [[ -n "$menu_style" ]]; then
        echo "   ✅ Menu selection enabled"
    else
        echo "   ❌ Menu selection not enabled"
    fi
    
    # Check completion cache
    echo "4. Completion cache:"
    if [[ -f "$COMPLETION_CACHE_FILE" ]]; then
        echo "   ✅ Cache file exists: $COMPLETION_CACHE_FILE"
        echo "   Cache size: $(ls -lh "$COMPLETION_CACHE_FILE" | awk '{print $5}')"
    else
        echo "   ❌ Cache file missing: $COMPLETION_CACHE_FILE"
    fi
    
    # Test basic completion
    echo "5. Testing basic completion:"
    if (( ${+_comps[cd]} )); then
        echo "   ✅ cd completion available"
    else
        echo "   ❌ cd completion not available"
    fi
    
    # Test file completion
    echo "6. Testing file completion:"
    if (( ${+_comps[_files]} )); then
        echo "   ✅ _files completion available"
    else
        echo "   ❌ _files completion not available"
    fi
}

# Export debug function
export -f _debug_completion 2>/dev/null || true

# =============================================================================
# FINAL TAB COMPLETION ENFORCEMENT
# =============================================================================

# Force tab completion to work after all modules are loaded
_enforce_tab_completion() {
    # Ensure tab is bound to complete-word
    bindkey '^I' complete-word 2>/dev/null || true
    
    # Ensure menu completion is enabled
    zstyle ':completion:*' menu select 2>/dev/null || true
    
    # Ensure completion system is properly initialized
    if (( ! ${+_comps} )); then
        autoload -Uz compinit
        compinit -C 2>/dev/null || true
    fi
}

# Run enforcement after a short delay to ensure all modules are loaded
# This is a workaround for module loading order issues
if [[ -o interactive ]]; then
    # Use a simple timer to run after all modules are loaded
    (sleep 0.1 && _enforce_tab_completion) &
fi
