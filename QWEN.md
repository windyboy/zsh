# Zsh Configuration Project Context

## Overview

This repository contains a modular Zsh configuration for macOS, Linux, and WSL. The canonical project version is stored in `VERSION`; installation and user-facing configuration are documented in `README.md` and `REFERENCE.md`.

## Runtime layout

- `zshenv` establishes XDG directories, Zsh paths, `ZDOTDIR`, history settings, and editor defaults.
- `.zshenv` is the re-entry point used by nested shells after `ZDOTDIR` has been redirected to the repository.
- `zshrc` loads local environment toggles, modules, the prompt, optional `local.zsh`, and optional host-specific settings.
- `modules/` contains the shared shell behavior. Module order is defined by `module_list` in `zshrc`.
- `plugins/core.list` is the declarative zinit plugin registry.
- `themes/prompt.zsh` configures Oh My Posh when available and provides the fallback prompt.
- `env/templates/` contains templates for ignored, machine-local configuration.

## Installation

The supported installation flow is:

```bash
git clone https://github.com/windyboy/zsh.git ~/.config/zsh
cd ~/.config/zsh
./install.sh
exec zsh
```

`install.sh` checks required commands and safely links `~/.zshenv` to the repository's `zshenv`. It does not install system packages.

## Plugins

Plugins are disabled by default. Set the following in `env/local/environment.env` to enable them:

```zsh
export ZSH_ENABLE_PLUGINS=1
```

On the first enabled interactive startup, zinit and missing plugins are cloned. Entries in `plugins/core.list` load synchronously before completion initialization so completion functions are present when `compinit` runs. The completion module loads fzf-tab afterward because it wraps initialized completion widgets.

## Local configuration

Machine-specific values must remain outside tracked framework files:

- `env/local/environment.env` contains exports and feature toggles needed before module loading.
- `local.zsh` contains personal aliases, functions, and customizations.
- `env/local/hosts/<hostname>.env` contains host-specific settings loaded after modules.

Use the files in `env/templates/` as starting points.

## Verification

Supported checks are:

```bash
./test.sh
./test.sh syntax
./test.sh environment
./test.sh modules
./test.sh installer
./test.sh update
zsh -n path/to/file.zsh
```

ShellCheck for supported shell scripts runs in GitHub Actions.

## Maintenance rules

- Use `#!/usr/bin/env zsh` for Zsh files and `#!/usr/bin/env bash` for Bash files.
- Use `$ZSH_CONFIG_DIR` and XDG paths instead of hard-coded user directories.
- Keep functions focused, validate arguments, and return meaningful statuses.
- Add tests for implemented behavior and run the applicable supported test group after editing.
