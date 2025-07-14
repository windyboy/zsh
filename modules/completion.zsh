#!/usr/bin/env zsh
# =============================================================================
# Completion System Configuration
# =============================================================================

# Completion cache
COMPLETION_CACHE_FILE="${ZSH_CACHE_DIR}/zcompdump"

# Initialize completion system with caching
_init_completion() {
    # Check if Zinit has already initialized completion
    if [[ -n "$ZINIT" ]] && (( ${+_comps} )); then
        print -P "%F{33}▓▒░ Zinit has already initialized completion system%f"
        return 0
    fi
    
    # Check if we need to regenerate the completion cache
    local rebuild_cache=0
    
    # Rebuild if cache doesn't exist or is older than 24 hours
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
        # Add timeout protection (macOS compatible)
        if command -v timeout >/dev/null 2>&1; then
            timeout 10s autoload -Uz compinit && compinit -d "$COMPLETION_CACHE_FILE" 2>/dev/null || {
                print -P "%F{red}▓▒░ Completion cache rebuild failed, using existing cache%f"
                compinit -C -d "$COMPLETION_CACHE_FILE" 2>/dev/null || true
            }
        else
            # Fallback for macOS (no timeout command)
            autoload -Uz compinit && compinit -d "$COMPLETION_CACHE_FILE" 2>/dev/null || {
                print -P "%F{red}▓▒░ Completion cache rebuild failed, using existing cache%f"
                compinit -C -d "$COMPLETION_CACHE_FILE" 2>/dev/null || true
            }
        fi
        # Compile the completion cache for faster loading
        [[ -f "$COMPLETION_CACHE_FILE" ]] && [[ ! -f "${COMPLETION_CACHE_FILE}.zwc" ]] && \
            (command -v timeout >/dev/null 2>&1 && timeout 5s zcompile "$COMPLETION_CACHE_FILE" 2>/dev/null || zcompile "$COMPLETION_CACHE_FILE" 2>/dev/null) || true
    else
        autoload -Uz compinit
        compinit -C -d "$COMPLETION_CACHE_FILE"
    fi
}

# Initialize completion system
_init_completion

# Ensure completion system is properly set up even if Zinit is present
if [[ -n "$ZINIT" ]]; then
    # Make sure completion styles are applied even with Zinit
    autoload -Uz compinit
    if (( ! ${+_comps} )); then
        compinit -C -d "$COMPLETION_CACHE_FILE"
    fi
fi

# =============================================================================
# COMPLETION STYLES
# =============================================================================

# General completion behavior
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/completion"

# Completion descriptions
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'

# Process completion
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

# Directory completion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' squeeze-slashes true

# History completion
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# SSH/SCP completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Man page completion
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-tab true

# =============================================================================
# TOOL-SPECIFIC COMPLETIONS
# =============================================================================

# Git completion optimization
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
    # Only source files that actually exist
    local completion_files=("$ZSH_CONFIG_DIR/completions"/_*(N))
    for completion in $completion_files; do
        [[ -f "$completion" ]] && source "$completion"
    done
fi

# Completion for common tools
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

# Load tool completions synchronously to prevent hanging
if (( ${+functions[_load_tool_completions]} )); then
    # Add timeout protection (macOS compatible)
    if command -v timeout >/dev/null 2>&1; then
        timeout 5s _load_tool_completions 2>/dev/null || true
    else
        # Fallback for macOS (no timeout command)
        _load_tool_completions 2>/dev/null || true
    fi
fi

# =============================================================================
# ENHANCED FILE & DIRECTORY COMPLETION
# =============================================================================

# Enhanced file completion with better performance
_enhanced_file_completion() {
    # Enable menu selection for file completion
    zstyle ':completion:*' menu select
    
    # Show hidden files in completion
    zstyle ':completion:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
    
    # Better file matching
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    
    # Show file types with colors
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    
    # Group files and directories
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
}

# Initialize enhanced file completion
_enhanced_file_completion

# =============================================================================
# SMART DIRECTORY COMPLETION
# =============================================================================

# Smart directory completion that shows contents
_smart_dir_completion() {
    # For cd command, show directory contents
    zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
    zstyle ':completion:*:cd:*' ignore-parents parent pwd
    
    # Show directory contents in completion
    zstyle ':completion:*:cd:*' extra-verbose true
    zstyle ':completion:*:cd:*' squeeze-slashes true
    
    # For ls command, show files with details
    zstyle ':completion:*:ls:*' file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
    zstyle ':completion:*:ls:*' extra-verbose true
}

# Initialize smart directory completion
_smart_dir_completion

# =============================================================================
# REAL-TIME FILE SUGGESTIONS (SAFE VERSION)
# =============================================================================

# Safe real-time file suggestions without hanging
_safe_file_suggestions() {
    # Only enable for specific commands that need file suggestions
    local file_commands=(ls cd cp mv rm cat less more head tail)
    
    for cmd in $file_commands; do
        # Enable real-time suggestions with timeout protection
        zstyle ":completion:*:$cmd:*" completer _complete _files _match
        zstyle ":completion:*:$cmd:*" file-patterns '%p(D-/):directories %p(-/):directories %p(^-/):files %p(-/):directories'
    done
}

# Initialize safe file suggestions
_safe_file_suggestions
