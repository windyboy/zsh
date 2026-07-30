# Agent Guidelines for Zsh Configuration

## Verify changes

- Full checks: `./test.sh`
- Focused checks: `./test.sh syntax|environment|modules|installer`
- Targeted syntax: `zsh -n <file>`
- ShellCheck runs in GitHub Actions for supported shell scripts.

`./check-project.sh`, standalone status/validation/performance scripts, and category names not listed above are not supported commands.

## Project shape

- `zshenv` establishes XDG and Zsh paths.
- `zshrc` loads modules from `modules/`, optional local environment overrides, and `local.zsh`.
- `themes/prompt.zsh` configures the prompt.
- `plugins/core.list` and `plugins/optional.list` are registry inputs.
- `VERSION` is the canonical version source.

## Changes

- Use `#!/usr/bin/env zsh` for `.zsh` files and `#!/usr/bin/env bash` for `.sh` files.
- Keep shell functions focused, validate arguments, and return meaningful exit codes.
- Use `$ZSH_CONFIG_DIR` and XDG paths rather than hard-coded user paths.
- Do not add scripts or documentation for capabilities that are not implemented and tested.
- Run the applicable test command after editing.
