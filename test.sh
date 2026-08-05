#!/usr/bin/env bash
# =============================================================================
# Simplified ZSH Test Suite
# =============================================================================

# Shared logging
color_red()    { echo -e "\033[31m$*\033[0m"; }
color_green()  { echo -e "\033[32m$*\033[0m"; }
color_yellow() { echo -e "\033[33m$*\033[0m"; }

log_test() { echo -n "Testing $1... "; }
log_pass() { color_green "PASSED"; }
log_fail() { color_red "FAILED"; exit 1; }

# 1. Syntax Check
test_syntax() {
    log_test "Syntax"
    zsh -n zshrc zshenv || log_fail "main configuration"
    [[ -d modules && -d themes ]] || log_fail "module or theme directory missing"

    local zsh_files
    zsh_files="$(find modules themes -type f -name '*.zsh' -print)" || log_fail "could not list Zsh files"
    while IFS= read -r f; do
        [[ -n "$f" ]] || continue
        zsh -n "$f" || log_fail "$f"
    done <<< "$zsh_files"
    bash -n install.sh release.sh test.sh update.sh || log_fail "shell scripts"
    log_pass
}

# 2. Variable Check
test_vars() {
    log_test "Core Variables"
    zsh -c '
        source ./zshenv
        [[ -n "$ZSH_CONFIG_DIR" ]] || exit 1
        [[ -n "$ZINIT_HOME" ]] || exit 1
    ' || log_fail "Core variables"
    log_pass
}

test_startup_timing() {
    log_test "Startup timing"
    env HOME=/tmp/zsh-config-test-home PATH=/usr/bin:/bin ZSH_CONFIG_DIR="$PWD" zsh -dfc '
        export ZSH_ENV_LOADED=1 ZSH_STARTUP_START=1
        source ./zshenv
        export -p | grep -q "ZSH_ENV_LOADED" && exit 1

        export ZSH_ENV_LOADED=1 ZSH_STARTUP_START=1
        source ./zshrc >/dev/null 2>&1
        export -p | grep -q "ZSH_STARTUP_START" && exit 1
        (( ${ZSH_STARTUP_TIME%.*} >= 0 && ${ZSH_STARTUP_TIME%.*} < 60 ))
    ' || log_fail "stale startup timestamp"
    log_pass
}

test_per_host_config() {
    log_test "Per-host config"
    local host host_dir
    # Resolve the host the same way zshrc does (zsh's $HOST), so the filename
    # written here matches the one zshrc sources, without depending on a
    # `hostname` binary being present in PATH.
    host="$(zsh -dfc 'print -r -- "${HOST:-$(hostname 2>/dev/null)}"')"
    host_dir="$PWD/env/local/hosts"
    mkdir -p "$host_dir"
    printf 'export ZSH_TEST_PERHOST=1\n' > "$host_dir/$host.env"
    local loaded
    loaded="$(ZSH_CONFIG_DIR="$PWD" ZDOTDIR="$PWD" zsh -dfc '
        export ZSH_ENV_LOADED=1 ZSH_STARTUP_START=1
        source ./zshrc >/dev/null 2>&1
        print -r -- "${ZSH_TEST_PERHOST:-0}"
    ')"
    rm -f "$host_dir/$host.env"
    [[ "$loaded" == "1" ]] || log_fail "per-host env not loaded from env/local/hosts/$host.env"
    log_pass
}

# 3. Module Check
test_modules() {
    log_test "Modules"
    # Mock source to just check existence
    for m in colors core navigation plugins completion aliases keybindings; do
        [[ -f "./modules/$m.zsh" ]] || log_fail "$m module missing"
    done
    log_pass
}

test_documentation() {
    log_test "Documentation"

    local project_version
    project_version="$(<VERSION)"
    [[ -n "$project_version" ]] || log_fail "VERSION file is empty"
    grep -Fqx "# Zsh Configuration v$project_version" README.md || log_fail "README version does not match VERSION"

    local command
    for command in reload validate status perf version config; do
        grep -Eq "^${command}\\(\\)" modules/core.zsh modules/utils.zsh || log_fail "documented command missing: $command"
    done

    for command in mkcd up backup ff fd grepc posh_theme posh_themes change_theme; do
        grep -REq "^${command}\\(\\)" modules themes || log_fail "documented helper missing: $command"
    done

    [[ -f REFERENCE.md && -f CHANGELOG.md ]] || log_fail "README documentation link target missing"

    # Per-machine customization layer: local.zsh must stay untracked and the
    # per-host dir ignored, so machine-specific config is never committed/pushed.
    [[ -f env/templates/local.zsh.template ]] || log_fail "local.zsh template missing"
    if git ls-files --error-unmatch local.zsh >/dev/null 2>&1; then
        log_fail "local.zsh must not be tracked by git"
    fi
    git check-ignore -q local.zsh || log_fail "local.zsh is not gitignored"
    git check-ignore -q env/local/hosts/somehost.env || log_fail "per-host env dir is not gitignored"
    log_pass
}

test_installer_contract() {
    log_test "Installer contract"
    [[ -s VERSION ]] || log_fail "VERSION file missing"
    if ./install.sh --unexpected >/dev/null 2>&1; then
        log_fail "installer accepted an unsupported argument"
    fi
    if "$0" unknown >/dev/null 2>&1; then
        log_fail "test runner accepted an unknown group"
    fi

    # Sandboxed link logic test: run against a temp HOME so the real one is
    # never touched. install.sh guards main(), so sourcing exposes its
    # functions without executing the installer.
    local sandbox saved_home saved_config
    sandbox="$(mktemp -d)"
    saved_home="$HOME"
    saved_config="${ZSH_CONFIG_DIR:-}"

    # shellcheck disable=SC1091
    source ./install.sh
    set +e  # install.sh enables errexit; disable for explicit rc checks

    HOME="$sandbox"
    ZSH_CONFIG_DIR="$PWD"
    export HOME ZSH_CONFIG_DIR

    # (1)+(3) absent ~/.zshenv -> symlink created
    link_zshenv
    local rc=$?
    if [[ $rc -ne 0 ]]; then
        log_fail "link_zshenv failed when ~/.zshenv is absent"
    fi
    [[ -L "$sandbox/.zshenv" ]] || log_fail "~/.zshenv symlink not created"
    [[ "$(readlink "$sandbox/.zshenv")" == "$PWD/zshenv" ]] || log_fail "~/.zshenv symlink target is wrong"

    # (4) existing non-matching ~/.zshenv is NOT overwritten without consent
    rm "$sandbox/.zshenv"
    printf 'existing user config\n' > "$sandbox/.zshenv"
    link_zshenv
    rc=$?
    if [[ $rc -eq 0 ]]; then
        log_fail "link_zshenv overwrote an existing non-matching ~/.zshenv without consent"
    fi
    grep -q 'existing user config' "$sandbox/.zshenv" || log_fail "existing ~/.zshenv was modified without consent"

    # (4b) --force path backs up and links
    backup_and_link_zshenv
    [[ -L "$sandbox/.zshenv" ]] || log_fail "--force did not create the ~/.zshenv symlink"
    local backup
    backup="$(ls -d "$sandbox"/.zshenv.bak.* 2>/dev/null | head -n1)"
    [[ -n "$backup" && -f "$backup" ]] || log_fail "--force did not create a timestamped backup"
    grep -q 'existing user config' "$backup" || log_fail "backup does not preserve the original content"

    # (5) ZDOTDIR redirection resolves the config zshrc
    local zdotdir_zshrc
    zdotdir_zshrc="$(ZDOTDIR="$PWD" zsh -dfc 'print -r -- "$ZDOTDIR/.zshrc"')"
    [[ "$zdotdir_zshrc" == "$PWD/.zshrc" ]] || log_fail "ZDOTDIR does not point at the config zshrc"
    [[ -f "$zdotdir_zshrc" ]] || log_fail "config zshrc is not resolvable via ZDOTDIR"

    # Restore environment and clean up
    HOME="$saved_home"
    if [[ -n "$saved_config" ]]; then
        ZSH_CONFIG_DIR="$saved_config"
    else
        unset ZSH_CONFIG_DIR
    fi
    rm -rf "$sandbox"
    log_pass
}

run_all() {
    echo "🚀 Running ZSH regression tests..."
    test_syntax
    test_vars
    test_startup_timing
    test_per_host_config
    test_modules
    test_documentation
    test_installer_contract
    echo "✨ All tests passed!"
}

case "${1:-all}" in
    all) run_all ;;
    syntax) test_syntax ;;
    environment)
        test_vars
        test_startup_timing
        test_per_host_config
        ;;
    modules) test_modules ;;
    installer) test_installer_contract ;;
    --help|-h)
        echo "Usage: $0 [all|syntax|environment|modules|installer]"
        ;;
    *)
        color_red "Unknown test group: $1"
        echo "Usage: $0 [all|syntax|environment|modules|installer]" >&2
        exit 2
        ;;
esac
