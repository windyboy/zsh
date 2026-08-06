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

Run `./install.sh` from a clone located at `${ZSH_CONFIG_DIR:-$HOME/.config/zsh}`. It verifies prerequisites (Zsh and Git) and links `~/.zshenv` to the config's `zshenv` so ZDOTDIR redirection loads this repo's `zshrc`. It does not install packages.

- Before linking, it warns about any existing `~/.zshrc`, `~/.zprofile`, or `~/.zlogin` that ZDOTDIR redirection will ignore, and suggests a backup command. It never modifies those files.
- By default it never overwrites an existing `~/.zshenv`. Re-run with `--force` to back it up to `~/.zshenv.bak.<timestamp>` and link anyway.
- After installing, start a new shell to load the configuration: `exec zsh`.

## Environment overrides

- `ZSH_CONFIG_DIR`, `ZSH_CACHE_DIR`, `ZSH_DATA_DIR`, and `ZINIT_HOME` are initialized in `zshenv`.
- `env/local/environment.env`, when present, is sourced by `zshrc`.
- `local.zsh`, when present, is sourced last for personal shell customizations. It is not tracked by git; copy `env/templates/local.zsh.template` to create it.
- `env/local/hosts/<hostname>.env`, when present, is sourced on that host for per-server overrides. It is not tracked by git.
- `ZSH_ENABLE_PLUGINS=1` enables zinit and loads the plugins listed in `plugins/core.list` (the registry parsed by `modules/plugins.zsh`). Plugins are off by default; set this in `env/local/environment.env`.
- `ZSH_POSH_THEME` selects an Oh My Posh theme. `posh_theme` persists the choice to `$ZSH_CACHE_DIR/theme-preference` (per-machine, not tracked).

## Useful helpers

`mkcd`, `up`, `backup`, `ff`, `fd`, `grepc`, `posh_theme`, `posh_themes`, and `change_theme` are implemented in the modules and theme loader. Use `function_name --help` where supported.

## Project version

`VERSION` is the canonical version source. Runtime `version` and `install.sh` use it.
