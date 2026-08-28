# Configuration Reference

## Shell commands

These commands are functions loaded by `zshrc`, not standalone scripts.

```zsh
reload                 # Reload the configuration
reload --module core   # Reload one module
validate [--verbose|--fix|--report]
status                 # Print Zsh configuration paths and loaded modules
perf [--modules|--memory|--startup|--profile|--monitor|--optimize]
version                # Read the repository VERSION file
config <target>        # Open a supported configuration file
```

Plugin loading is handled by `modules/plugins.zsh`; there are no `plugins`, `plugins_update`, or `plugins_clean` commands.

## Tests

```bash
./test.sh [all|syntax|environment|modules|installer|update]
```

`all` is the default. Unsupported arguments return a non-zero exit status.

## Installation

Run `./install.sh` from a clone located at `${ZSH_CONFIG_DIR:-$HOME/.config/zsh}`. It verifies prerequisites (Zsh and Git) and links `~/.zshenv` to the config's `zshenv` so ZDOTDIR redirection loads this repo's `zshrc`. It does not install packages.

- Before linking, it warns about any existing `~/.zshrc`, `~/.zprofile`, or `~/.zlogin` that ZDOTDIR redirection will ignore, and suggests a backup command. It never modifies those files.
- By default it never overwrites an existing `~/.zshenv`. Re-run with `--force` to back it up to `~/.zshenv.bak.<timestamp>` and link anyway.
- After installing, start a new shell to load the configuration: `exec zsh`.

## Environment overrides

Paths and files:

- `ZSH_CONFIG_DIR`, `ZSH_CACHE_DIR`, `ZSH_DATA_DIR`, and `ZINIT_HOME` are initialized in `zshenv`.
- `env/local/environment.env`, when present, is sourced by `zshrc`.
- `local.zsh`, when present, is sourced after the modules for personal shell customizations. The per-host file below loads after it. It is not tracked by git; copy `env/templates/local.zsh.template` to create it.
- `env/local/hosts/<hostname>.env`, when present, is sourced on that host for per-server overrides; it is the last file `zshrc` loads. It is not tracked by git.

Feature toggles (set in `env/local/environment.env` unless noted):

| Variable | Default | Effect |
| --- | --- | --- |
| `ZSH_ENABLE_PLUGINS` | `0` | `1` enables zinit and loads `plugins/core.list` (registry parsed by `modules/plugins.zsh`). |
| `ZSH_POSH_THEME` | bundled theme | Selects an Oh My Posh theme when no saved preference exists. `posh_theme` persists the choice to `$ZSH_CACHE_DIR/theme-preference` (per-machine, not tracked), and that saved preference outranks this variable on every load — a value pinned in `env/local/*.env` cannot shadow an explicit `posh_theme` switch. Delete the preference file to restore variable control. |
| `ZSH_ENABLE_POSH` | `1` | `0` disables Oh My Posh. `1` forces it on for SSH sessions whose terminal cannot be detected. |
| `ZSH_DISABLE_POSH` | `0` | `1` disables Oh My Posh unconditionally (wins over `ZSH_ENABLE_POSH`). |
| `ZSH_OMP_TRANSIENT` | `0` | `1` enables the Oh My Posh transient prompt. |
| `ZSH_PROFILE` | `0` | `1` prints the startup-time banner after `zshrc` loads. Use `perf --startup` for real timing. |
| `ZSH_DEBUG` | `0` | `1` enables theme-loader debug output. |
| `ZSH_MAX_FUNCTIONS` | `200` | `perf`/`validate` threshold for defined functions. |
| `ZSH_MAX_ALIASES` | `100` | `perf`/`validate` threshold for aliases. |
| `ZSH_MAX_MEMORY_MB` | `10` | `perf`/`validate` threshold for shell RSS. |
| `ZSH_MAX_STARTUP_SEC` | `2` | `perf`/`validate` threshold for startup seconds. |
| `ZSH_UPDATE_SELF_SKIP` | `0` | `1` makes `update.sh` skip the framework `git pull` (also set internally when it re-execs its updated copy). |

## Useful helpers

`mkcd`, `up`, `backup`, `ff`, `fd`, `grepc`, `posh_theme`, `posh_themes`, and `change_theme` are implemented in the modules and theme loader. Use `function_name --help` where supported.

## Project version

`VERSION` is the canonical version source. Runtime `version` and `install.sh` use it.
