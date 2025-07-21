#!/usr/bin/env zsh
# =============================================================================
# Development Environment Configuration
# Description: Contains configurations for various development tools, enable as needed
# =============================================================================

# Application paths
export BUN_INSTALL="$HOME/.bun"
export DENO_INSTALL="$HOME/.deno"

# Go Environment Setup
export GOPATH=~/Projects/lang-go
export GOROOT=/usr/local/opt/go/libexec
export GOPROXY=https://goproxy.io
export GO111MODULE=on

# Rust Setup
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

# Flutter Setup
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# Android SDK Setup
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# PNPM Setup
export PNPM_HOME="$HOME/Library/pnpm"

# SDKMAN Setup
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Homebrew
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"

# Development PATH configuration is now handled by the path module
# This file now only contains environment variable exports
