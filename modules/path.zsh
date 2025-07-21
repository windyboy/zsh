#!/usr/bin/env zsh
# =============================================================================
# PATH Management Module - Minimal Configuration
# =============================================================================

# PATH Configuration Variables
export PATH_MANAGEMENT_ENABLED=1
export PATH_DEBUG=0
export PATH_AUTO_CLEANUP=1

# Core system paths (ensure these are always available)
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

# User local paths
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.bin" ]] && export PATH="$HOME/.bin:$PATH"

# Development paths
[[ -d "$HOME/.bun/bin" ]] && export PATH="$HOME/.bun/bin:$PATH"
[[ -d "$HOME/.deno/bin" ]] && export PATH="$HOME/.deno/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"
#[[ -d "$HOME/.nix-profile/bin" ]] && export PATH="$HOME/.nix-profile/bin:$PATH"
#[[ -d "/nix/var/nix/profiles/default/bin" ]] && export PATH="/nix/var/nix/profiles/default/bin:$PATH"
[[ -d "/opt/homebrew/bin" ]] && export PATH="/opt/homebrew/bin:$PATH"
#[[ -d "/run/current-system/sw/bin" ]] && export PATH="/run/current-system/sw/bin:$PATH"

# Go paths
[[ -n "$GOROOT" && -d "$GOROOT/bin" ]] && export PATH="$GOROOT/bin:$PATH"
[[ -d "/usr/local/opt/go/libexec/bin" ]] && export PATH="/usr/local/opt/go/libexec/bin:$PATH"
[[ -n "$GOPATH" && -d "$GOPATH/bin" ]] && export PATH="$GOPATH/bin:$PATH"

# Android paths
[[ -n "$ANDROID_HOME" && -d "$ANDROID_HOME/tools" ]] && export PATH="$ANDROID_HOME/tools:$PATH"
[[ -n "$ANDROID_HOME" && -d "$ANDROID_HOME/platform-tools" ]] && export PATH="$ANDROID_HOME/platform-tools:$PATH"

# Enable path uniqueness
typeset -U path

# Mark module as loaded
export ZSH_MODULES_LOADED="$ZSH_MODULES_LOADED path"
