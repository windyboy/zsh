# Changelog

## Unreleased

- Unified the zinit directory path across `update.sh`, `validation.zsh`, and the runtime (`ZINIT_HOME`), fixing the stale `…/zsh/zinit` path.
- Added framework self-update to `update.sh` (`git pull --ff-only`) with `--skip-self` / `ZSH_UPDATE_SELF_SKIP=1` opt-out.
- Added `set -euo pipefail` to `update.sh` so failures surface instead of being silently swallowed.
- Collapsed the dead `os`-branch in `update_oh_my_posh`.
- Replaced `update_zinit`'s hardcoded `origin/master` fetch/reset with a tracking-branch `pull --ff-only` (zinit's default branch moved to `main`).
- Moved the opencode PATH and `$HOME/.local/bin/env` hack out of the shared `zshrc` into the gitignored `env/local/environment.env`.
- Added `update` and machine-specific test groups covering the above.
- Aligned the repository with its supported lightweight workflow.
- Added `VERSION` as the canonical version source.
- Made the installer and test command contracts explicit.
- Removed obsolete `docs/history/` review and refactoring archives (Git history retains them).
- Dropped in-repo `TODO.md` in favor of Linear.

## 5.3.1

Historical release baseline for the current configuration. The source of truth for the checked-out version is `VERSION`.

## Earlier releases

Earlier release notes were not reliable descriptions of the current repository and have been intentionally condensed. Consult Git history and tags for historical implementation details.
