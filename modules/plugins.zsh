#!/usr/bin/env zsh
# =============================================================================
# Plugin Management with Zinit
# =============================================================================

# Zinit installation and setup
ZINIT_HOME="${ZSH_DATA_DIR}/zinit/zinit.git"

# Install zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
    print -P "%F{33}▓▒░ Installing Zinit...%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
        print -P "%F{34}▓▒░ Installation successful.%f" || \
        print -P "%F{160}▓▒░ Installation failed.%f"
fi

# Load zinit
if [[ -f "${ZINIT_HOME}/zinit.zsh" ]]; then
    source "${ZINIT_HOME}/zinit.zsh"
else
    print -P "%F{160}▓▒░ Zinit not found, some features may not work.%f"
    return 1
fi

# Add completions to FPATH
if [[ ":$FPATH:" != *":$ZSH_CONFIG_DIR/completions:"* ]]; then 
    export FPATH="$ZSH_CONFIG_DIR/completions:$FPATH"
fi

# =============================================================================
# ESSENTIAL PLUGINS (Immediate loading)
# =============================================================================

# FZF - Essential for workflow
zinit ice from"gh-r" as"program" pick"*/fzf"
zinit light junegunn/fzf

# =============================================================================
# ANNEXES (Delayed loading)
# =============================================================================
zinit wait"0a" lucid light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# =============================================================================
# CORE PLUGINS (Delayed loading)
# =============================================================================

# Syntax highlighting
zinit wait"0b" lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting

# Auto suggestions
zinit wait"0c" lucid for \
    atload"_zsh_autosuggest_start; ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'; ZSH_AUTOSUGGEST_STRATEGY=(history completion)" \
        zsh-users/zsh-autosuggestions

# Additional completions
zinit wait"0d" lucid for \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions

# =============================================================================
# ENHANCED PLUGINS (Further delayed)
# =============================================================================

# FZF tab completion
zinit wait"1" lucid for \
    Aloxaf/fzf-tab

# Zeno (snippet manager)
zinit wait"1a" lucid for \
    depth"1" blockf \
        yuki-yano/zeno.zsh

# FZF integration pack
zinit wait"1b" lucid for \
    pack"default+keys" fzf

# Enhanced directory navigation
zinit wait"1c" lucid for \
    atload"export _ZO_DATA_DIR=$ZSH_DATA_DIR/zoxide" \
        agkozak/zsh-z

# Better directory listings
zinit wait"1d" lucid for \
    atload"alias ls='eza --icons --group-directories-first'" \
        eza-community/eza

# Git enhancements
zinit wait"1e" lucid for \
    atload"alias g='git'" \
        wfxr/forgit

# Better history search
zinit wait"1f" lucid for \
    atload"bindkey '^R' zaw-history" \
        zsh-users/zaw

# Docker completion
zinit wait"1g" lucid for \
    as"completion" \
    atpull"zinit creinstall -q ." \
        docker/cli

# =============================================================================
# PLUGIN CONFIGURATION
# =============================================================================

# Auto-suggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"

# Fast-syntax-highlighting configuration
if [[ -n "$FAST_HIGHLIGHT_STYLES" ]] || typeset -A FAST_HIGHLIGHT_STYLES 2>/dev/null; then
    FAST_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
    FAST_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
    FAST_HIGHLIGHT_STYLES[alias]='fg=green'
    FAST_HIGHLIGHT_STYLES[builtin]='fg=green'
    FAST_HIGHLIGHT_STYLES[function]='fg=green'
    FAST_HIGHLIGHT_STYLES[command]='fg=green'
    FAST_HIGHLIGHT_STYLES[precommand]='fg=green,underline'
    FAST_HIGHLIGHT_STYLES[commandseparator]='fg=blue'
    FAST_HIGHLIGHT_STYLES[path]='fg=cyan'
    FAST_HIGHLIGHT_STYLES[path_prefix]='fg=cyan,underline'
    FAST_HIGHLIGHT_STYLES[globbing]='fg=magenta'
    FAST_HIGHLIGHT_STYLES[single-hyphen-option]='fg=blue'
    FAST_HIGHLIGHT_STYLES[double-hyphen-option]='fg=blue'
    FAST_HIGHLIGHT_STYLES[back-quoted-argument]='fg=magenta'
    FAST_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
    FAST_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
    FAST_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
    FAST_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
    FAST_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=cyan'
    FAST_HIGHLIGHT_STYLES[assign]='fg=blue'
fi

# FZF configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# Zoxide configuration
eval "$(zoxide init zsh)"

# Zinit completions
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
