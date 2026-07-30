# Configuration Reference

## Shell commands

These commands are functions loaded by `zshrc`, not standalone scripts.

```zsh
reload                 # Reload the configuration
reload --module core   # Reload one module
validate [--verbose|--fix|--report]
status                 # Print Zsh configuration paths and loaded modules
perf [--modules|--memory|--profile|--monitor|--optimize]
version                # Read the repository VERSION file
config <target>        # Open a supported configuration file
```

Plugin loading is handled by `modules/plugins.zsh`; there are no `plugins`, `plugins_update`, or `plugins_clean` commands.

## Tests

```bash
./test.sh [all|syntax|environment|modules|installer]
```

`all` is the default. Unsupported arguments return a non-zero exit status.

## Installation

Run `./install.sh` from a clone located at `${ZSH_CONFIG_DIR:-$HOME/.config/zsh}`. It verifies prerequisites and installs only the `~/.zshenv` symlink when safe. It does not install packages or overwrite existing user configuration.

## Environment overrides

- `ZSH_CONFIG_DIR`, `ZSH_CACHE_DIR`, `ZSH_DATA_DIR`, and `ZINIT_HOME` are initialized in `zshenv`.
- `env/local/environment.env`, when present, is sourced by `zshrc`.
- `local.zsh`, when present, is sourced last for personal shell customizations.
- `ZSH_ENABLE_OPTIONAL_PLUGINS=1` enables entries in `plugins/optional.list`.
- `ZSH_POSH_THEME` selects an Oh My Posh theme.

## Useful helpers

`mkcd`, `up`, `backup`, `ff`, `fd`, `grepc`, `posh_theme`, `posh_themes`, and `change_theme` are implemented in the modules and theme loader. Use `function_name --help` where supported.

## Project version

`VERSION` is the canonical version source. Runtime `version`, `install.sh`, and `release.sh` use it.
