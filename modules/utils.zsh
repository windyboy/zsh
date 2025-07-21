#!/usr/bin/env zsh
# =============================================================================
# Utils Module - Common Utility Functions (Minimal High-Frequency)
# Description: Only high-frequency, essential, memorable utility functions with unified lowercase naming and clear comments.
# =============================================================================

# Color output tools
color_red()   { echo -e "\033[31m$1\033[0m"; }
color_green() { echo -e "\033[32m$1\033[0m"; }

# -------------------- File/Directory Operations --------------------
# Backup file
backup() {
    [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]] && echo "Usage: backup <file>" && return 1
    local file="$1"
    [[ ! -f "$file" ]] && color_red "Not found: $file" && return 1
    cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
    color_green "Backed up: ${file}.backup.$(date +%Y%m%d_%H%M%S)"
}
# Find files/directories
ff() { [[ $# -eq 0 ]] && echo "Usage: ff <pattern>" && return 1; find . -name "*$1*" -type f 2>/dev/null; }
fd() { [[ $# -eq 0 ]] && echo "Usage: fd <pattern>" && return 1; find . -name "*$1*" -type d 2>/dev/null; }
# Context search
grepc() { [[ $# -eq 0 ]] && echo "Usage: grepc <pattern> [context_lines]" && return 1; grep -r -n -C "${2:-3}" "$1" . 2>/dev/null; }

# -------------------- System Information --------------------
sysinfo() {
    echo "🖥️  System Info: $(uname -s) $(uname -r) | Arch: $(uname -m) | Host: $(hostname) | User: $USER | Shell: $SHELL | Terminal: $TERM"
    [[ -n "$SSH_CLIENT" ]] && echo "SSH: $SSH_CLIENT"
}

# PATH management shortcuts
alias path-status='echo $PATH | tr ":" "\n" | nl'
alias path-clean='echo "PATH cleanup completed"'
alias path-reload='source modules/path.zsh'
diskusage() { df -h | grep -E '^/dev/' | awk '{print $1, $2, $3, $4, $5, $6}'; }
memusage() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        vm_stat | perl -ne '/page size of (\\d+)/ and $size=$1; /Pages free: (\\d+)/ and printf "Free: %.1f MB\\n", $1 * $size / 1048576'
        top -l 1 -s 0 | grep PhysMem
    else
        free -h
    fi
}
network() {
    ping -c 1 8.8.8.8 >/dev/null 2>&1 && color_green "Internet: Connected" || color_red "Internet: Disconnected"
    [[ -n "$SSH_CLIENT" ]] && color_green "SSH: $SSH_CLIENT" || color_red "SSH: Not connected"
}

# -------------------- Git/Development --------------------
gstatus() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { color_red "Not a git repository"; return 1; }
    git status --short; echo; git log --oneline -5
}
newproject() {
    [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]] && echo "Usage: newproject <name> [type]" && return 1
    local name="$1" type="${2:-basic}"
    mkdir -p "$name" && cd "$name"
    case "$type" in
        node|npm) npm init -y; echo "Node.js project: $name" ;;
        python) echo "# $name" > README.md; echo "Python project: $name" ;;
        git) git init; echo "# $name" > README.md; echo "Git repository: $name" ;;
        *) echo "# $name" > README.md; echo "Project: $name" ;;
    esac
}

# -------------------- Text Processing --------------------
lcount() { [[ $# -eq 0 ]] && echo "Usage: lcount <file...>" && return 1; for f in "$@"; do [[ -f "$f" ]] && echo "$f: $(wc -l < "$f") lines" || color_red "$f: Not found"; done; }
rmempty() { [[ $# -eq 0 ]] && echo "Usage: rmempty <file>" && return 1; sed -i '/^[[:space:]]*$/d' "$1" && color_green "Removed empty lines: $1"; }
tolower() { [[ $# -eq 0 ]] && echo "Usage: tolower <file>" && return 1; tr '[:upper:]' '[:lower:]' < "$1" > "${1}.tmp" && mv "${1}.tmp" "$1" && color_green "Converted to lowercase: $1"; }

# -------------------- Process/Network --------------------
psfind() { [[ $# -eq 0 ]] && echo "Usage: psfind <process_name>" && return 1; ps aux | grep -i "$1" | grep -v grep; }
pkill() { [[ $# -eq 0 ]] && echo "Usage: pkill <process_name>" && return 1; ps aux | grep -i "$1" | grep -v grep | awk '{print $2}' | xargs kill -9; }
monitor() { top -l 1 -s 0 | grep "CPU usage" 2>/dev/null || top -b -n1 | head -20; }
myip() { curl -s ifconfig.me 2>/dev/null || color_red "Unable to get external IP"; }
portcheck() { [[ $# -eq 0 ]] && echo "Usage: portcheck <port>" && return 1; nc -z localhost "$1" && color_green "Port $1: Open" || color_red "Port $1: Closed"; }
download() { [[ $# -eq 0 ]] && echo "Usage: download <url>" && return 1; command -v wget >/dev/null 2>&1 && wget --progress=bar "$1" || curl -O "$1"; }

# -------------------- Time/Archive --------------------
timestamp() { date +"%Y-%m-%d %H:%M:%S"; }
countdown() { [[ $# -eq 0 ]] && echo "Usage: countdown <seconds>" && return 1; local s=$1; while ((s>0)); do printf "\rCountdown: %02d:%02d" $((s/60)) $((s%60)); sleep 1; ((s--)); done; echo -e "\nTime's up!"; }
archive() { [[ $# -lt 2 ]] && echo "Usage: archive <name> <files...>" && return 1; local name="$1"; shift; tar -czf "${name}.tar.gz" "$@" && color_green "Archived: ${name}.tar.gz"; }

# -------------------- Configuration Management --------------------
config() {
    [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]] && {
        echo "Usage: config <file>"
        echo "Editable files:"
        echo "  zshrc      - Main configuration file"
        echo "  core       - Core module"
        echo "  plugins    - Plugins module"
        echo "  aliases    - Aliases module"
        echo "  completion - Completion module"
        echo "  keybindings - Keybindings module"
        echo "  utils      - Utils module"
        echo "  env        - Environment configuration"
        return 1
    }

    local file="$1"
    local target_file=""

    case "$file" in
        zshrc) target_file="$ZSH_CONFIG_DIR/zshrc" ;;
        core) target_file="$ZSH_CONFIG_DIR/modules/core.zsh" ;;
        plugins) target_file="$ZSH_CONFIG_DIR/modules/plugins.zsh" ;;
        aliases) target_file="$ZSH_CONFIG_DIR/modules/aliases.zsh" ;;
        completion) target_file="$ZSH_CONFIG_DIR/modules/completion.zsh" ;;
        keybindings) target_file="$ZSH_CONFIG_DIR/modules/keybindings.zsh" ;;
        utils) target_file="$ZSH_CONFIG_DIR/modules/utils.zsh" ;;
        env) target_file="$ZSH_CONFIG_DIR/env/development.zsh" ;;
        *) color_red "Unknown file: $file" && return 1 ;;
    esac

    if [[ -f "$target_file" ]]; then
        ${EDITOR:-code} "$target_file"
    else
        color_red "File does not exist: $target_file"
        return 1
    fi
}

# -------------------- FZF Widget Management --------------------
fzf_widgets() {
    [[ "$1" == "-h" || "$1" == "--help" ]] && {
        echo "Usage: fzf_widgets [enable|disable|status|fix]"
        echo "Manage FZF widget bindings to avoid zsh-syntax-highlighting warnings"
        echo ""
        echo "Commands:"
        echo "  enable   - Enable FZF widget bindings"
        echo "  disable  - Disable FZF widget bindings"
        echo "  status   - View current status"
        echo "  fix      - Fix zsh-syntax-highlighting warnings"
        return 1
    }

    local action="${1:-status}"

    case "$action" in
        enable)
            if command -v fzf >/dev/null 2>&1; then
                autoload -Uz fzf-file-widget fzf-history-widget fzf-cd-widget 2>/dev/null || true
                bindkey '^[f' fzf-file-widget 2>/dev/null || true
                bindkey '^[r' fzf-history-widget 2>/dev/null || true
                bindkey '^[d' fzf-cd-widget 2>/dev/null || true
                color_green "✅ FZF widgets enabled"
                echo "Shortcuts: Alt+F (files), Alt+R (history), Alt+D (directories)"
            else
                color_red "❌ FZF not installed"
            fi
            ;;
        disable)
            bindkey -r '^[f' 2>/dev/null || true
            bindkey -r '^[r' 2>/dev/null || true
            bindkey -r '^[d' 2>/dev/null || true
            color_green "✅ FZF widgets disabled"
            ;;
        fix)
            # Fix zsh-syntax-highlighting warnings
            if command -v fzf >/dev/null 2>&1; then
                # Ensure FZF widgets are properly loaded
                autoload -Uz fzf-file-widget fzf-history-widget fzf-cd-widget 2>/dev/null || true

                # Rebind to ensure correct timing
                bindkey -r '^[f' 2>/dev/null || true
                bindkey -r '^[r' 2>/dev/null || true
                bindkey -r '^[d' 2>/dev/null || true

                # Delayed binding
                zle -N fzf-file-widget 2>/dev/null || true
                zle -N fzf-history-widget 2>/dev/null || true
                zle -N fzf-cd-widget 2>/dev/null || true

                color_green "✅ FZF widgets fixed"
                echo "Please reload configuration: source ~/.zshrc"
            else
                color_red "❌ FZF not installed"
            fi
            ;;
        status)
            echo "🔍 FZF Widget Status:"
            if command -v fzf >/dev/null 2>&1; then
                color_green "✅ FZF installed"
                echo "Binding status:"
                bindkey | grep -E "(fzf-file-widget|fzf-history-widget|fzf-cd-widget)" || echo "  Not bound"
                echo ""
                echo "Widget status:"
                zle -l | grep -E "(fzf-file-widget|fzf-history-widget|fzf-cd-widget)" || echo "  Not registered"
            else
                color_red "❌ FZF not installed"
            fi
            ;;
        *)
            color_red "Unknown operation: $action"
            return 1
            ;;
    esac
}

# -------------------- Reserved Custom Area --------------------
# Custom functions can be added in the custom/ directory

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED utils"
echo "INFO: Utils module initialized"
