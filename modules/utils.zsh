#!/usr/bin/env zsh
# =============================================================================
# Utils Module - Common Utility Functions (Minimal High-Frequency)
# Description: Only high-frequency, essential, memorable utility functions with unified lowercase naming and clear comments.
# =============================================================================

# Color output tools
source "$ZSH_CONFIG_DIR/modules/colors.zsh"

# -------------------- File/Directory Operations --------------------
# Backup file
backup() {
    [[ "$1" == "-h" || "$1" == "--help" || $# -eq 0 ]] && echo "Usage: backup <file>" && return 1
    local file="$1"
    [[ ! -f "$file" ]] && color_red "Not found: $file" && return 1
    cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
    color_green "Backed up: ${file}.backup.$(date +%Y%m%d_%H%M%S)"
}
# Create directory and enter
mkcd() {
    [[ $# -eq 0 ]] && echo "Usage: mkcd <directory_name>" && return 1
    mkdir -p "$1" && cd "$1"
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
alias path-clean='export PATH=$(echo $PATH | tr ":" "\n" | awk "!seen[\$0]++" | tr "\n" ":" | sed "s/:$//") && echo "PATH cleanup completed"'
alias path-reload='source ~/.config/zsh/modules/path.zsh'
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
kill_by_name() { [[ $# -eq 0 ]] && echo "Usage: kill_by_name <process_name>" && return 1; ps aux | grep -i "$1" | grep -v grep | awk '{print $2}' | xargs kill -9; }
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
        echo ""
        echo "📁 Configuration Files:"
        echo "  zshrc      - Main configuration file"
        echo "  zshenv     - Environment variables"
        echo "  core       - Core module"
        echo "  plugins    - Plugins module"
        echo "  aliases    - Aliases module"
        echo "  completion - Completion module"
        echo "  keybindings - Keybindings module"
        echo "  utils      - Utils module"
        echo ""
        echo "🌍 Environment Configuration:"
        echo "  env        - User environment variables (recommended)"
        echo "  env-template - Environment template file"
        echo "  env-init    - Initialize environment configuration"
        echo "  env-migrate - Migrate old environment configuration"
        echo ""
        echo "🔧 System Management:"
        echo "  status     - Show system status"
        echo "  reload     - Reload configuration"
        echo "  validate   - Validate configuration"
        echo "  test       - Run test suite"
        return 1
    }

    local file="$1"
    local target_file=""

    case "$file" in
        # Main configuration files
        zshrc) target_file="$ZSH_CONFIG_DIR/zshrc" ;;
        zshenv) target_file="$ZSH_CONFIG_DIR/zshenv" ;;
        
        # Module files
        core) target_file="$ZSH_CONFIG_DIR/modules/core.zsh" ;;
        plugins) target_file="$ZSH_CONFIG_DIR/modules/plugins.zsh" ;;
        aliases) target_file="$ZSH_CONFIG_DIR/modules/aliases.zsh" ;;
        completion) target_file="$ZSH_CONFIG_DIR/modules/completion.zsh" ;;
        keybindings) target_file="$ZSH_CONFIG_DIR/modules/keybindings.zsh" ;;
        utils) target_file="$ZSH_CONFIG_DIR/modules/utils.zsh" ;;
        
        # Environment configuration
        env) 
            # Check for new environment system first
            if [[ -f "$ZSH_CONFIG_DIR/env/local/environment.env" ]]; then
                target_file="$ZSH_CONFIG_DIR/env/local/environment.env"
            elif [[ -f "$ZSH_CONFIG_DIR/env/development.zsh" ]]; then
                target_file="$ZSH_CONFIG_DIR/env/development.zsh"
            else
                color_yellow "⚠️  No environment configuration found"
                color_cyan "💡 Run 'config env-init' to initialize environment configuration"
                return 1
            fi
            ;;
        env-template) target_file="$ZSH_CONFIG_DIR/env/templates/environment.env.template" ;;
        
        # Environment management commands
        env-init)
            if [[ -f "$ZSH_CONFIG_DIR/env/init-env.sh" ]]; then
                color_cyan "🚀 Initializing environment configuration..."
                "$ZSH_CONFIG_DIR/env/init-env.sh"
                if [[ -f "$ZSH_CONFIG_DIR/env/local/environment.env" ]]; then
                    color_green "✅ Environment configuration initialized"
                    color_cyan "💡 Edit with: config env"
                fi
            else
                color_red "❌ Environment initialization script not found"
            fi
            return 0
            ;;
        env-migrate)
            if [[ -f "$ZSH_CONFIG_DIR/env/migrate-env.sh" ]]; then
                color_cyan "🔄 Migrating environment configuration..."
                "$ZSH_CONFIG_DIR/env/migrate-env.sh"
            else
                color_red "❌ Environment migration script not found"
            fi
            return 0
            ;;
        
        # System management commands
        status)
            if [[ -f "$ZSH_CONFIG_DIR/status.sh" ]]; then
                "$ZSH_CONFIG_DIR/status.sh"
            else
                color_red "❌ Status script not found"
            fi
            return 0
            ;;
        reload)
            color_cyan "🔄 Reloading configuration..."
            source "$ZSH_CONFIG_DIR/zshrc"
            color_green "✅ Configuration reloaded"
            return 0
            ;;
        validate)
            if [[ -f "$ZSH_CONFIG_DIR/test.sh" ]]; then
                "$ZSH_CONFIG_DIR/test.sh" all
            else
                color_red "❌ Test script not found"
            fi
            return 0
            ;;
        test)
            if [[ -f "$ZSH_CONFIG_DIR/test.sh" ]]; then
                "$ZSH_CONFIG_DIR/test.sh" all
            else
                color_red "❌ Test script not found"
            fi
            return 0
            ;;
        
        *) 
            color_red "❌ Unknown configuration: $file"
            color_cyan "💡 Run 'config --help' for available options"
            return 1 
            ;;
    esac

    if [[ -f "$target_file" ]]; then
        color_cyan "📝 Opening: $target_file"
        ${EDITOR:-code} "$target_file"
    else
        color_red "❌ File does not exist: $target_file"
        return 1
    fi
}

# Configuration sync (placeholder)
config_sync() {
    echo "[TODO] Configuration sync feature not implemented yet. Future support for cloud upload/download of ~/.config/zsh/env/local/environment.env and other files."
    echo "For manual sync, please backup and restore configuration files manually."
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
        bindkey '^[c' fzf-cd-widget 2>/dev/null || true
                color_green "✅ FZF widgets enabled"
                echo "Shortcuts: Alt+F (files), Alt+R (history), Alt+D (directories)"
            else
                color_red "❌ FZF not installed"
            fi
            ;;
        disable)
            bindkey -r '^[f' 2>/dev/null || true
            bindkey -r '^[r' 2>/dev/null || true
            bindkey -r '^[c' 2>/dev/null || true
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
                bindkey -r '^[c' 2>/dev/null || true

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
