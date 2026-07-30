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

The installer verifies Zsh and Git, then creates `~/.zshenv` only when it does not already exist. It never overwrites an existing `~/.zshenv` or installs system packages.

## Configuration

`zshenv` sets XDG paths and `ZDOTDIR`; `zshrc` loads modules, an optional `env/local/environment.env`, and optional `local.zsh` personalizations.

Main areas:

- `modules/` — shell behaviour, aliases, navigation, plugins, completion, and utilities
- `themes/prompt.zsh` — Oh My Posh integration with a fallback prompt
- `plugins/core.list` and `plugins/optional.list` — plugin registry inputs
- `env/templates/environment.env.template` — optional local environment template

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

`./update.sh` remains available for updating installed optional components. Review its output carefully: it may download software, use package managers, or create backups.

## Documentation

- [REFERENCE.md](REFERENCE.md) — runtime commands and configuration reference
- [CHANGELOG.md](CHANGELOG.md) — release history and maintenance notes
- [docs/history](docs/history/) — archived review and refactoring reports

## License

[MIT](LICENSE)
