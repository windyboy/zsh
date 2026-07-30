#!/usr/bin/env bash
# =============================================================================
# Release Script for Zsh Configuration
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"
CURRENT_VERSION="$(<"$VERSION_FILE")"

usage() {
    cat <<EOF
Usage: $0 --version VERSION [--skip-checks] [--skip-push]

Creates a release commit, annotated tag, and release notes from this repository.
EOF
}

new_version=""
skip_checks=0
skip_push=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version|-v)
            [[ $# -ge 2 ]] || { echo "--version requires a value" >&2; exit 2; }
            new_version="$2"
            shift 2
            ;;
        --skip-checks|-s) skip_checks=1; shift ;;
        --skip-push|-p) skip_push=1; shift ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

[[ -n "$new_version" ]] || { echo "Current version: $CURRENT_VERSION"; usage >&2; exit 2; }
[[ "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "Invalid semantic version: $new_version" >&2; exit 2; }
git rev-parse --is-inside-work-tree >/dev/null
[[ -z "$(git status --porcelain)" ]] || { echo "Working tree is not clean" >&2; exit 1; }

if (( ! skip_checks )); then
    ./test.sh
fi

printf '%s\n' "$new_version" > "$VERSION_FILE"
notes_file="RELEASE_NOTES_${new_version}.md"
printf '# Release v%s\n\n- Lightweight Zsh configuration release.\n- See CHANGELOG.md for maintenance notes.\n' "$new_version" > "$notes_file"

git add VERSION "$notes_file"
git commit -m "release: v$new_version"
git tag -a "v$new_version" -m "Release v$new_version"

if (( ! skip_push )); then
    git push origin HEAD
    git push origin "v$new_version"
fi

echo "Released v$new_version"
