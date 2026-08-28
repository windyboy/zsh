#!/usr/bin/env zsh
# =============================================================================
# Environment Module - PATH and Runtime Environment Management
# Description: Safe PATH helpers, environment defaults, and lazy tool loaders.
#              Runtime module only: never redefine ZSH_CONFIG_DIR / ZDOTDIR /
#              history (those belong to zshenv).
# =============================================================================

# Idempotence guard: reload --module env must not double-prepend PATH or
# re-append to ZSH_MODULES_LOADED (same pattern as colors.zsh).
(( ${+ZSH_MODULES_LOADED} )) && (( ${ZSH_MODULES_LOADED[(I)env]} )) && return 0

# -------------------- PATH Management --------------------
# Add a directory to PATH if it exists and is not already present.
# Usage: add_to_path <dir> [prepend|append]
add_to_path() {
    local target_dir="$1"
    local position="${2:-prepend}"

    [[ -z "$target_dir" || ! -d "$target_dir" ]] && return 1

    case ":$PATH:" in
        *":$target_dir:"*) return 0 ;;
    esac

    if [[ "$position" == "append" ]]; then
        export PATH="${PATH:+${PATH}:}${target_dir}"
    else
        export PATH="${target_dir}${PATH:+:${PATH}}"
    fi
}

# Standard user-level binary directories (existence-checked, prepended once).
# Listed lowest-priority first: each entry is prepended in order, so the last
# entry (~/.local/bin) ends up with the highest priority, matching the usual
# pipx/pnpm/cargo expectations.
typeset -a _env_user_bins=(
    "$HOME/.bun/bin"
    "${GOPATH:-$HOME/go}/bin"
    "$HOME/.go/bin"
    "$HOME/.cargo/bin"
    "$HOME/bin"
    "$HOME/.local/bin"
)
for _dir in "${_env_user_bins[@]}"; do
    add_to_path "$_dir" prepend
done
unset _env_user_bins _dir

# PATH inspection/cleanup helpers (moved from utils.zsh: one PATH-policy home)
alias path-status='echo $PATH | tr ":" "\n" | nl'
path-clean() {
    local -a cleaned
    if [[ -z "$PATH" ]]; then
        echo "Warning: PATH is empty, skipping cleanup" >&2
        return 1
    fi
    cleaned=(${(u)=${(s.:.)PATH}})
    (( ${#cleaned} )) || {
        echo "Warning: PATH cleanup resulted in empty PATH, keeping original" >&2
        return 1
    }
    export PATH="${(j.:.)cleaned}"
    echo "PATH cleanup completed"
}

# -------------------- Environment Defaults --------------------
# Only set when unset: never override user/locale-provided values.
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R -F -X}"
export LANG="${LANG:-en_US.UTF-8}"
# LC_ALL is deliberately not defaulted: it overrides LANG and every LC_*
# category, and minimal systems without the en_US.UTF-8 locale would warn
# (setlocale) on every perl/grep invocation. Export it in env/local if wanted.

# -------------------- Lazy Tool Loaders --------------------
# Lazy load NVM to keep startup fast (moved from zshrc verbatim).
# Prefer ~/.nvm when it exists: that is where nvm's official installer puts it.
if [[ -n "${NVM_DIR:-}" ]]; then
    export NVM_DIR
elif [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
else
    export NVM_DIR="$HOME/.config/nvm"
fi
nvm() {
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
        if [[ -s "$NVM_DIR/bash_completion" ]]; then
            source "$NVM_DIR/bash_completion"
        fi
        nvm "$@"
    else
        echo "NVM not installed. Install from https://github.com/nvm-sh/nvm" >&2
        return 1
    fi
}

# Mark module as loaded
ZSH_MODULES_LOADED+=(env)
