# Local environment overrides

Environment configuration lives in three layers, loaded in this order:

1. **`zshenv`** (tracked) — process-level basics: XDG paths, `ZSH_*` dirs,
   `ZDOTDIR`, history, `EDITOR`. Runs for every shell, including non-interactive.
2. **`env/local/environment.env`** (not tracked) — machine-specific exports,
   sourced by `zshrc` *before* modules.
3. **`modules/env.zsh`** (tracked) — runtime module: `add_to_path` /
   `path-status` / `path-clean`, `PAGER`/`LANG`/`LC_ALL` defaults (set only
   when unset), standard user bin dirs (`~/.local/bin`, `~/.cargo/bin`,
   `$GOPATH/bin`, …), and the NVM lazy loader.

After the modules, `zshrc` sources **`env/local/hosts/<hostname>.env`** when it
exists, so per-host overrides win over module defaults.

## Create your local file

```bash
cd "${ZSH_CONFIG_DIR:-$HOME/.config/zsh}/env"
./init-env.sh
${EDITOR:-vi} local/environment.env
```

Use `export NAME=value` for values that must be inherited by programs started
from the shell. Do not commit files in `env/local/`.

## Migrate legacy files

To migrate legacy `env/development.zsh` or `env/local.zsh` files, run
`./migrate-env.sh` from this directory. Check an override for syntax with:

```bash
zsh -n local/environment.env
```
