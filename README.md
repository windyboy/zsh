# Zsh Configuration v5.3.1

A personal, modular Zsh configuration for macOS, Linux, and WSL.

## Requirements

- Zsh 5.8 or newer
- Git

Optional integrations such as zinit, oh-my-posh, fzf, zoxide, and eza are detected at runtime. Install them with your preferred package manager if you want those features.

## Install

Clone the repository to the configuration directory, then run the only supported installer:

```bash
git clone https://github.com/windyboy/zsh.git ~/.config/zsh
cd ~/.config/zsh
./install.sh
exec zsh
```

The installer verifies Zsh and Git, then creates a `~/.zshenv` symlink pointing at this configuration only when one does not already exist. If `~/.zshenv` already exists and does not point here, the installer stops without modifying it; run `./install.sh --force` to back it up to `~/.zshenv.bak.<timestamp>` and replace it. It never installs system packages.

Before linking, the installer warns about any existing `~/.zshrc`, `~/.zprofile`, or `~/.zlogin`: after ZDOTDIR redirection these files are ignored, so back them up if you want to keep them. After a successful install, restart your terminal or run `exec zsh`.

## Configuration

`zshenv` sets XDG paths and `ZDOTDIR`; `zshrc` loads modules, an optional `env/local/environment.env`, optional `local.zsh` personalizations, and an optional per-host file.

Main areas:

- `modules/` — shell behaviour, aliases, navigation, plugins, completion, and utilities
- `themes/prompt.zsh` — Oh My Posh integration with a fallback prompt
- `plugins/core.list` and `plugins/optional.list` — plugin registry inputs
- `env/templates/environment.env.template` — optional local environment template
- `env/templates/local.zsh.template` — starting point for a machine-specific `local.zsh`

### Framework vs per-machine configuration

The tracked files (`zshenv`, `zshrc`, `modules/`, `themes/`) are the shared framework: `git pull` (or `./update.sh`) keeps every machine in sync. Keep machine-specific settings out of the tracked files so they are not pushed to other servers:

- `local.zsh` — personal shell customizations (aliases, functions, exports). Not tracked by git; copy it from `env/templates/local.zsh.template`.
- `env/local/environment.env` — machine-specific environment exports. Not tracked by git; create it with `env/init-env.sh`.
- `env/local/hosts/<hostname>.env` — per-host overrides, sourced only on the matching host. Not tracked by git.

This separation is what makes the same repo usable across multiple servers: the framework updates everywhere, while each machine keeps its own settings.

See [REFERENCE.md](REFERENCE.md) for the available shell functions and configuration files.

## Verify changes

```bash
./test.sh
./test.sh syntax
./test.sh environment
./test.sh modules
./test.sh installer
```

Unknown test groups fail deliberately. `zsh -n <file>` remains useful for a targeted syntax check.

## Maintenance

`./update.sh` updates the framework repo itself (`git pull --ff-only`) and any installed optional components. Review its output carefully: it may download software, use package managers, or create backups.

- `./update.sh --skip-self` (or `-S`) updates components but skips the framework repo pull. Set `ZSH_UPDATE_SELF_SKIP=1` for the same effect.
- `./update.sh --skip-backup` skips the defensive backup.

## Documentation

- [REFERENCE.md](REFERENCE.md) — runtime commands and configuration reference
- [CHANGELOG.md](CHANGELOG.md) — release history and maintenance notes

## License

[MIT](LICENSE)
