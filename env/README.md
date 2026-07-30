# Local environment overrides

`zshrc` sources `env/local/environment.env` when it exists. Create it from the
tracked template, then add only machine-specific exports:

```bash
cd "${ZSH_CONFIG_DIR:-$HOME/.config/zsh}/env"
./init-env.sh
${EDITOR:-vi} local/environment.env
```

Use `export NAME=value` for values that must be inherited by programs started
from the shell. Do not commit files in `env/local/`.

To migrate legacy `env/development.zsh` or `env/local.zsh` files, run
`./migrate-env.sh` from this directory. Check an override for syntax with:

```bash
zsh -n local/environment.env
```
