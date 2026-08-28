# Local environment overrides

`zshrc` sources `env/local/environment.env` when it exists. Create it from the
tracked template, then add only machine-specific exports:

```bash
cd "${ZSH_CONFIG_DIR:-$HOME/.config/zsh}/env"
./init-env.sh
$EDITOR local/environment.env
```

Use `export NAME=value` for values that must be inherited by programs started
from the shell. Do not commit files in `env/local/`.

### Which file should I edit?

| What you're changing | File |
| --- | --- |
| Machine-specific env vars (tool paths, mirrors, PATH, tokens) | `env/local/environment.env`, or `env/local/hosts/<hostname>.env` for per-machine overrides |
| Repo-wide defaults (XDG dirs, history, editor) | `zshenv` |
| PATH entries / runtime defaults (`add_to_path`, PAGER, LANG) | `modules/env.zsh` |
| Personal tweaks | `local.zsh` (optional) |

For day-to-day machine config, edit `env/local/environment.env` (create it with
`./init-env.sh`) or `env/local/hosts/$(hostname).env` — both are gitignored, so
secrets are safe. Use `add_to_path "<dir>" prepend|append` for PATH entries
(defined in `modules/env.zsh`; dedups automatically).

**Loading order matters:** `environment.env` is sourced *before* modules, so it
holds `export`s and feature toggles (e.g. `ZSH_ENABLE_PLUGINS`, which
`plugins.zsh` reads at load time). The per-host file is sourced *after*
modules, so `add_to_path` is available there — put PATH additions in it.

### How to make the change take effect

1. Add the variable with `export` (no `export` → child programs won't see it).
2. Apply it: run `reload` (or `zreload`) to re-read the configuration — it
   resets module tracking and PATH additions dedup automatically. You can also
   `source ~/.config/zsh/zshrc` in a pinch, or open a new terminal (all new
   shells).
3. Verify: `echo $MY_VAR` or `env | grep MY_VAR`.

Changes only affect shells started after the edit — `source` gets them into the
shell you're already in.

To migrate legacy `env/development.zsh` or `env/local.zsh` files, run
`./migrate-env.sh` from this directory. Check an override for syntax with:

```bash
zsh -n local/environment.env
```
