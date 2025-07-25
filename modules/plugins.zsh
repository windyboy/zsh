#!/usr/bin/env zsh
# =============================================================================
# Plugins Module - Plugin Management and Enhancement
# Description: Only essential, high-frequency plugins with clear comments and unified naming.
# =============================================================================

# Color output tools
# Load centralized color functions
source "$ZSH_CONFIG_DIR/modules/colors.zsh"

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
    # zinit ice wait"0" lucid
    # zinit light zsh-users/zsh-autosuggestions 2>/dev/null || true
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

# Load history substring search plugin
zinit ice wait"0" lucid
zinit light zsh-users/zsh-history-substring-search 2>/dev/null || true
# Configure history substring search (official recommendation)
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
# Ensure the plugin is loaded by sourcing it directly if zinit fails
if ! (( ${+functions[history-substring-search-up]} )); then
    source "$ZINIT_HOME/plugins/zsh-users---zsh-history-substring-search/zsh-history-substring-search.zsh" 2>/dev/null || true
fi

# Load file extraction tool (le0me55i/zsh-extract) - Smart file extraction
# Supports: tar, gz, bz2, xz, zip, rar, 7z, lzma, lzop, cab, ar, deb, rpm, iso
zinit ice wait"0" lucid
zinit light le0me55i/zsh-extract 2>/dev/null || true

# Load directory jump tool (rupa/z) - Smart directory navigation
zinit ice wait"0" lucid
zinit light rupa/z 2>/dev/null || true

# Load performance benchmark tool (romkatv/zsh-bench) - Optional for development
# Uncomment the following lines if you need performance testing
# zinit ice wait"0" lucid
# zinit light romkatv/zsh-bench 2>/dev/null || true

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
export ZSH_AUTOSUGGEST_USE_ASYNC=0
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
export ZSH_AUTOSUGGEST_COMPLETION_IGNORE="cd *"
# Increase function nesting limit to prevent FUNCNEST errors
export FUNCNEST=100
# Configure fzf-tab if available
if command -v fzf >/dev/null 2>&1; then
    # Set FZF default options for consistent behavior
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --margin=1,4"

    # Essential fzf-tab configurations (based on official recommendations)
    # Disable sort when completing git checkout to preserve order
    zstyle ':completion:*:git-checkout:*' sort false

    # Set descriptions format to enable group support
    # Note: Don't use escape sequences here, fzf-tab will ignore them
    zstyle ':completion:*:descriptions' format '[%d]'

    # Set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

    # Force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
    # This overrides the menu yes setting from completion.zsh
    zstyle ':completion:*' menu no

    # Custom fzf flags for fzf-tab
    # Note: fzf-tab does not follow FZF_DEFAULT_OPTS by default
    zstyle ':fzf-tab:complete:*' fzf-flags --preview-window=right:60%:wrap --color=fg:1,fg+:2 --bind=tab:accept

    # Switch group using ',' and '.'
    zstyle ':fzf-tab:*' switch-group ',' '.'

    # Show group headers
    zstyle ':fzf-tab:*' show-group full

    # Continuous trigger for multi-selection
    zstyle ':fzf-tab:*' continuous-trigger 'space'

    # Accept line with ctrl-space (disabled to avoid conflicts with autosuggest)
    # zstyle ':fzf-tab:*' accept-line 'ctrl-space'

    # Preview configurations (smart content detection)
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la "$realpath"'
    zstyle ':fzf-tab:complete:*:*' fzf-preview '
        if [ -d "$realpath" ]; then
            ls -la "$realpath"
        elif [ -f "$realpath" ]; then
            if command -v bat >/dev/null 2>&1; then
                bat --style=numbers --color=always --line-range :50 "$realpath" 2>/dev/null
            else
                head -50 "$realpath" 2>/dev/null
            fi
        else
            echo "$realpath"
        fi
    '
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
        "z:Directory Jump"
        "zsh-extract:Enhanced File Extraction"
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
            color_green "✅ $name - $desc"
        else
            color_red "❌ $name - $desc"
        fi
    done

    # Check tool plugins
    for plugin in "${tool_plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        if command -v "$name" >/dev/null 2>&1; then
            color_green "✅ $name - $desc"
        else
            color_red "❌ $name - $desc"
        fi
    done

    # Check builtin plugins
    for plugin in "${builtin_plugins[@]}"; do
        local name="${plugin%%:*}"
        local desc="${plugin##*:}"
        color_green "✅ $name - $desc"
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
        color_green "✅ No key binding conflicts found"
    fi

    # Check for alias conflicts
    local alias_conflicts=$(alias | cut -d= -f1 | sed 's/^alias //g' | sort | uniq -d)
    if [[ -n "$alias_conflicts" ]]; then
        echo "❌ Duplicate aliases found:"
        echo "$alias_conflicts" | sed 's/^/   • /'
    else
        color_green "✅ No alias conflicts found"
    fi

    # Check for zstyle configuration conflicts
    local zstyle_conflicts=$(zstyle -L | grep -E '^[[:space:]]*:' | awk '{print $1}' | sort | uniq -d)
    if [[ -n "$zstyle_conflicts" ]]; then
        echo "❌ Duplicate zstyle configurations found:"
        echo "$zstyle_conflicts" | sed 's/^/   • /'
    else
        color_green "✅ No zstyle configuration conflicts found"
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
    local duplicate_aliases=$(alias | cut -d= -f1 | sed 's/^alias //g' | sort | uniq -d)
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
        color_green "✅ No conflicts requiring resolution found"
    fi
}

check_plugins() {
    echo "🔍 Plugin health check..."

    # Check if zinit is working properly
    if [[ -n "$ZINIT" ]]; then
        color_green "✅ zinit loaded"
    else
        color_red "❌ zinit not loaded"
    fi

    # Check critical plugin files
    local critical_plugins=(
        "fast-syntax-highlighting"
        "zsh-autosuggestions"
        "zsh-completions"
        "z"
        "zsh-extract"
    )

    for plugin in "${critical_plugins[@]}"; do
        if [[ -d "$ZINIT_HOME/plugins/$plugin" ]]; then
            color_green "✅ $plugin installed"
        else
            color_red "❌ $plugin not installed"
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
            color_green "✅ $tool available"
        else
            color_red "❌ $tool not available"
        fi
    done

    # Check environment variables
    local required_vars=(
        "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
        "ZSH_AUTOSUGGEST_STRATEGY"
    )

    for var in "${required_vars[@]}"; do
        if [[ -n "${(P)var}" ]]; then
            color_green "✅ $var set"
        else
            color_red "❌ $var not set"
        fi
    done

    # Run conflict detection
    echo ""
    check_plugin_conflicts

    # Check zsh-extract specific items
    echo ""
    echo "📦 zsh-extract specific checks:"
    check_extract_deps
    check_extract_conflicts
}

# -------------------- New Plugin Configurations --------------------
# rupa/z - Directory jump tool configuration
# Usage: z <directory_name> - Jump to frequently used directories
# The tool automatically learns your directory usage patterns

# -------------------- zsh-extract Configuration --------------------
# le0me55i/zsh-extract - Enhanced file extraction tool
# Usage: extract <file> - Extract various archive formats
#
# Supported formats:
# - Compressed archives: tar.gz, tar.bz2, tar.xz, tar.lzma, tar.lzop
# - Archive formats: tar, zip, rar, 7z, cab, ar
# - Package formats: deb, rpm
# - Disk images: iso
# - Single file compression: gz, bz2, xz, lzma, lzop
# - Note: Uses unar for RAR extraction (universal archive extractor)
#
# Features:
# - Automatic format detection
# - Error handling and fallback
# - Dependency checking
# - Progress indication for large files
#
# Usage examples:
#   extract archive.tar.gz
#   extract archive.zip
#   extract archive.rar
#   extract archive.7z
#   extract archive.tar.gz -C /target/directory  # Extract to specific directory

# romkatv/zsh-bench - Performance benchmark tool (optional)
# Usage: zsh-bench - Run performance benchmarks
# Uncomment the plugin loading lines above to enable this tool
# Useful for development and debugging performance issues

# -------------------- Reserved Custom Area --------------------
# Custom plugin configurations can be added in the custom/ directory

# -------------------- Dependency Check Functions --------------------
# Check extraction tool dependencies
check_extract_deps() {
    local missing_deps=()

    # Essential tools
    command -v tar >/dev/null 2>&1 || missing_deps+=("tar")
    command -v gunzip >/dev/null 2>&1 || missing_deps+=("gunzip")
    command -v bunzip2 >/dev/null 2>&1 || missing_deps+=("bunzip2")
    command -v unxz >/dev/null 2>&1 || missing_deps+=("unxz")
    command -v unzip >/dev/null 2>&1 || missing_deps+=("unzip")

    # Optional tools
    command -v unar >/dev/null 2>&1 || missing_deps+=("unar")
    command -v 7z >/dev/null 2>&1 || missing_deps+=("7z")
    command -v cabextract >/dev/null 2>&1 || missing_deps+=("cabextract")
    command -v ar >/dev/null 2>&1 || missing_deps+=("ar")
    command -v dpkg >/dev/null 2>&1 || missing_deps+=("dpkg")
    command -v rpm2cpio >/dev/null 2>&1 || missing_deps+=("rpm2cpio")

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "⚠️  Missing extraction dependencies: ${missing_deps[*]}"
        echo "💡 Install with: sudo apt install ${missing_deps[*]}  # Ubuntu/Debian"
        echo "💡 Install with: brew install ${missing_deps[*]}      # macOS"
        echo "💡 Note: unar is used for RAR extraction (universal archive extractor)"
    else
        echo "✅ All extraction dependencies available"
    fi
}

# Check for extract function conflicts
check_extract_conflicts() {
    if (( ${+functions[extract]} )) && [[ "$(type extract)" != *"zsh-extract"* ]]; then
        echo "⚠️  Warning: extract function already exists, zsh-extract will override it"
    else
        echo "✅ No extract function conflicts detected"
    fi
}

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED plugins"
echo "INFO: Plugins module initialized"
