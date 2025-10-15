#!/usr/bin/env bash
# Plugin Installation Automation Script
# shellcheck disable=SC1091

set -euo pipefail

# Shared logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/logging.sh"

ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"
PLUGIN_REGISTRY_DIR="${SCRIPT_DIR}/plugins"
CORE_REGISTRY_FILE="${PLUGIN_REGISTRY_DIR}/core.list"
OPTIONAL_REGISTRY_FILE="${PLUGIN_REGISTRY_DIR}/optional.list"

declare -a CORE_PLUGIN_REPOS=()
declare -a OPTIONAL_PLUGIN_REPOS=()

read_plugin_list() {
    local file="$1"
    local -n target="$2"
    target=()

    [[ -f "$file" ]] || return 0

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        target+=("$line")
    done < "$file"
}

read_plugin_list "$CORE_REGISTRY_FILE" CORE_PLUGIN_REPOS
read_plugin_list "$OPTIONAL_REGISTRY_FILE" OPTIONAL_PLUGIN_REPOS

# Allow overrides via plugins.conf (supports legacy declare -A PLUGINS)
if [[ -f "$ZSH_CONFIG_DIR/plugins.conf" ]]; then
    # shellcheck disable=SC1091
    source "$ZSH_CONFIG_DIR/plugins.conf"

    if declare -p PLUGINS >/dev/null 2>&1; then
        CORE_PLUGIN_REPOS=()
        for repo in "${PLUGINS[@]}"; do
            CORE_PLUGIN_REPOS+=("$repo")
        done
    elif declare -p CORE_PLUGINS >/dev/null 2>&1; then
        CORE_PLUGIN_REPOS=("${CORE_PLUGINS[@]}")
    fi

    if declare -p OPTIONAL_PLUGINS >/dev/null 2>&1; then
        OPTIONAL_PLUGIN_REPOS=("${OPTIONAL_PLUGINS[@]}")
    fi
fi

# Fallback defaults (should rarely trigger if registry files exist)
if [[ ${#CORE_PLUGIN_REPOS[@]} -eq 0 ]]; then
    CORE_PLUGIN_REPOS=(
        "zdharma-continuum/fast-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-completions"
        "zsh-users/zsh-history-substring-search"
        "le0me55i/zsh-extract"
        "rupa/z"
        "Aloxaf/fzf-tab"
    )
fi

INSTALL_OPTIONAL_PLUGINS="${ZSH_ENABLE_OPTIONAL_PLUGINS:-1}"

target_plugins() {
    local -n out="$1"
    out=("${CORE_PLUGIN_REPOS[@]}")
    if [[ "${INSTALL_OPTIONAL_PLUGINS}" != "0" ]]; then
        out+=("${OPTIONAL_PLUGIN_REPOS[@]}")
    fi
}

install_zinit() {
    log "Ensuring zinit plugin manager is available..."
    if [[ -d "$ZINIT_HOME/zinit.git" ]]; then
        success "zinit already installed"
        return 0
    fi
    if git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME/zinit.git" 2>/dev/null; then
        success "zinit installed successfully"
        return 0
    fi
    error "Failed to install zinit"
    return 1
}

plugin_repo_dir() {
    local repo="$1"
    printf '%s/plugins/%s\n' "$ZINIT_HOME" "${repo//\//---}"
}

install_plugin() {
    local plugin_repo="$1"
    local plugin_name="${plugin_repo##*/}"
    local plugin_dir
    plugin_dir="$(plugin_repo_dir "$plugin_repo")"

    if [[ -d "$plugin_dir" ]]; then
        success "Plugin already present: $plugin_name"
        return 0
    fi

    log "Installing plugin: $plugin_name"
    mkdir -p "$(dirname "$plugin_dir")"

    if git clone "https://github.com/$plugin_repo.git" "$plugin_dir" 2>/dev/null; then
        success "Plugin installed: $plugin_name"
        return 0
    fi

    error "Failed to install plugin: $plugin_name"
    return 1
}

install_all_plugins() {
    local -a plugins_to_install=()
    target_plugins plugins_to_install

    log "Installing ${#plugins_to_install[@]} plugin(s)..."
    local installed_count=0

    for repo in "${plugins_to_install[@]}"; do
        if install_plugin "$repo"; then
            ((installed_count++))
        fi
    done

    echo
    success "Installed $installed_count/${#plugins_to_install[@]} plugin(s)"
}

health_check() {
    local -a plugins_to_check=()
    target_plugins plugins_to_check

    log "Running plugin health check..."
    local errors=0

    for repo in "${plugins_to_check[@]}"; do
        local plugin_name="${repo##*/}"
        local plugin_dir
        plugin_dir="$(plugin_repo_dir "$repo")"
        if [[ -d "$plugin_dir" ]]; then
            success "Plugin healthy: $plugin_name"
        else
            error "Plugin missing: $plugin_name"
            ((errors++))
        fi
    done

    echo
    if [[ $errors -eq 0 ]]; then
        success "All plugins are installed"
        return 0
    fi
    error "Health check failed: $errors plugin(s) missing"
    return 1
}

list_plugins() {
    local -a core=("${CORE_PLUGIN_REPOS[@]}")
    local -a optional=("${OPTIONAL_PLUGIN_REPOS[@]}")

    echo "Core plugins:"
    for repo in "${core[@]}"; do
        printf "  - %s\n" "$repo"
    done

    if [[ ${#optional[@]} -gt 0 ]]; then
        echo "Optional plugins:"
        for repo in "${optional[@]}"; do
            printf "  - %s\n" "$repo"
        done
    fi
}

main() {
    printf '%b╔══════════════════════════════════════════════════════════════╗%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    printf '%b║                🔌 Plugin Installation Manager               ║%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    printf '%b╚══════════════════════════════════════════════════════════════╝%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    echo

    case "${1:-install}" in
        install)
            install_zinit
            install_all_plugins
            ;;
        health)
            health_check
            ;;
        list)
            list_plugins
            ;;
        help|-h|--help)
            echo "Usage: $0 [install|health|list|help]"
            echo
            echo "Registries:"
            echo "  Core:     $CORE_REGISTRY_FILE"
            echo "  Optional: $OPTIONAL_REGISTRY_FILE"
            echo
            echo "Overrides:"
            echo "  - plugins.conf (PLUGINS associative array or CORE_PLUGINS list)"
            echo "  - OPTIONAL_PLUGINS array for optional entries"
            ;;
        *)
            error "Unknown command: ${1:-}"
            echo "Run '$0 help' for usage details"
            exit 1
            ;;
    esac
}

main "$@"
