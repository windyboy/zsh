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
    # Check each file individually: `zsh -n a b` only parses `a` (b becomes a
    # positional parameter), so a single multi-file call silently skips files.
    local f
    for f in zshrc zshenv; do
        zsh -n "$f" || log_fail "$f"
    done
    [[ -d modules && -d themes ]] || log_fail "module or theme directory missing"

    local zsh_files
    zsh_files="$(find modules themes -type f -name '*.zsh' -print)" || log_fail "could not list Zsh files"
    while IFS= read -r f; do
        [[ -n "$f" ]] || continue
        zsh -n "$f" || log_fail "$f"
    done <<< "$zsh_files"
    for f in install.sh test.sh update.sh; do
        bash -n "$f" || log_fail "$f"
    done
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
    # Use a synthetic hostname that can never match a real machine, so the test
    # never overwrites or deletes a real env/local/hosts/<host>.env file
    # (the old code resolved the real host and clobbered it — W1N-221).
    local host="zsh-perhost-test" host_dir
    host_dir="$PWD/env/local/hosts"
    mkdir -p "$host_dir"
    printf 'export ZSH_TEST_PERHOST=1\n' > "$host_dir/$host.env"
    local loaded
    loaded="$(HOST="$host" ZSH_CONFIG_DIR="$PWD" ZDOTDIR="$PWD" zsh -dfc '
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
    # zshrc's module_list is the authoritative registry; verify both directions:
    # every listed module has a file, and every file in modules/ is listed.
    local names f base
    names="$(sed -n 's/.*module_list=(\([^)]*\)).*/\1/p' zshrc)"
    [[ -n "$names" ]] || log_fail "could not extract module_list from zshrc"
    # shellcheck disable=SC2086  # word splitting of the module names is intended
    for base in $names; do
        [[ -f "./modules/$base.zsh" ]] || log_fail "$base module missing"
    done
    for f in modules/*.zsh; do
        base="$(basename "$f" .zsh)"
        [[ " $names " == *" $base "* ]] || log_fail "$base.zsh exists but is not loaded by zshrc"
    done

    # safe_rm's ownership check relies on zstat's `uid` element; a previous
    # version used the nonexistent `+owner`, silently disabling the check.
    zsh -fc 'zmodload -F zsh/stat b:zstat 2>/dev/null; f="$(mktemp)"; [[ "$(zstat +uid -- "$f")" == "$EUID" ]]; rc=$?; rm -f "$f"; exit "$rc"' \
        || log_fail "zstat +uid does not report the caller EUID (safe_rm ownership check broken)"

    # completion.zsh must run compinit with -u: a promptable compinit blocks on
    # stdin at startup (invisibly, if silenced) and, on abort/EOF, unfunctions
    # compinit and compdef ("command not found: compinit").
    grep -q 'compinit -u -d' modules/completion.zsh \
        || log_fail "completion.zsh compinit must use -u (never prompt at startup)"
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

    # Machine-local state must stay untracked and ignored: .zsh_history is
    # private, and posh_theme rewrites theme-preference (a dirty tracked file
    # would break update.sh's git pull --ff-only self-update).
    local state_file
    for state_file in .zsh_history themes/theme-preference; do
        if git ls-files --error-unmatch "$state_file" >/dev/null 2>&1; then
            log_fail "$state_file must not be tracked by git"
        fi
        git check-ignore -q "$state_file" || log_fail "$state_file is not gitignored"
    done
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

    # Sandboxed link logic test: run in a subshell against a temp HOME so the
    # real one is never touched, and install.sh's `set -euo pipefail` cannot
    # leak into the test runner process. install.sh guards main(), so sourcing
    # exposes its functions without executing the installer.
    local sandbox sandbox_rc
    sandbox="$(mktemp -d)"
    (
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
    )
    sandbox_rc=$?
    rm -rf "$sandbox"
    if [[ $sandbox_rc -ne 0 ]]; then
        exit 1  # log_fail inside the subshell already reported the reason
    fi
    log_pass
}

test_update_script() {
    log_test "Update script"
    bash -n update.sh || log_fail "update.sh syntax"

    # 1. update.sh uses set -euo pipefail (W1N-43)
    head -6 update.sh | grep -q "set -euo pipefail" || log_fail "update.sh missing set -euo pipefail"

    # 2. zinit path derivation agrees across runtime / updater / validator (W1N-41)
    local updater_path validator_path runtime_path
    updater_path="$(sed -n 's/^ZINIT_DIR=//p' update.sh)"
    validator_path="$(grep -F 'zinit_dir=' modules/lib/validation.zsh)"
    runtime_path='${ZINIT_HOME:-$HOME/.local/share/zinit}/zinit.git'
    [[ "$updater_path" == *"$runtime_path"* ]] || log_fail "update.sh zinit path not derived from ZINIT_HOME"
    [[ "$validator_path" == *"$runtime_path"* ]] || log_fail "validation.zsh zinit path not derived from ZINIT_HOME"
    grep -q '\.local/share/zsh/zinit' update.sh modules/lib/validation.zsh && log_fail "stale zinit path still present"
    grep -q '\.local/share/zsh/zinit' modules/plugins.zsh zshenv && log_fail "stale zinit path in runtime files"

    # 3. self-update plumbing (W1N-42): function, flag, main wiring
    grep -q '^update_framework()' update.sh || log_fail "update_framework function missing"
    grep -q -- '--skip-self' update.sh || log_fail "--skip-self flag missing"
    grep -q 'update_framework' update.sh || log_fail "update_framework not wired into main"

    # 4. oh-my-posh: install path derives from the existing binary (never a
    # hardcoded /usr/local/bin), downloads are SHA256-verified, brew-managed
    # installs go through brew
    grep -q 'install_path="/usr/local/bin/oh-my-posh"' update.sh && log_fail "oh-my-posh install path is hardcoded to /usr/local/bin"
    grep -q 'install_path="$(readlink -f "$(command -v oh-my-posh)"' update.sh || log_fail "oh-my-posh install path not derived from the existing binary"
    grep -q 'checksums.txt' update.sh || log_fail "oh-my-posh download is not SHA256-verified"
    grep -q 'brew list --versions oh-my-posh' update.sh || log_fail "brew-managed oh-my-posh branch missing"
    grep -q 'install_path=""' update.sh && log_fail "dead install_path initializer still present"

    # 5. update_zinit uses a tracking-branch pull, not a hardcoded branch name
    grep -q 'git -C "$ZINIT_DIR" pull --ff-only' update.sh || log_fail "update_zinit does not use tracking-branch pull"
    grep -q 'origin/master' update.sh && log_fail "update_zinit still hardcodes origin/master"

    # 6. backup paths derive from ZSH_CONFIG_DIR, not hardcoded ~/.config/zsh
    grep -q 'BACKUP_DIR="$ZSH_CONFIG_DIR/backup' update.sh || log_fail "BACKUP_DIR not derived from ZSH_CONFIG_DIR"
    grep -q 'backup_root="$HOME/.config/zsh' update.sh && log_fail "backup_root still hardcodes ~/.config/zsh"
    grep -q 'install.sh first' update.sh && log_fail "update_zinit error still points at install.sh (which never installed zinit)"

    log_pass
}

test_machine_specific_moved() {
    log_test "Machine-specific moved out"
    # W1N-45: zshrc must not contain machine-specific hacks (the ../bin/env hack;
    # the opencode PATH entry was removed from the suite when opencode stopped
    # being installed on the reference machine)
    grep -q 'opencode/bin' zshrc && log_fail "opencode PATH still in shared zshrc"
    grep -q '\.local/share/../bin/env' zshrc && log_fail "../bin/env hack still in shared zshrc"

    # env/local/environment.env is gitignored machine-local config: it only
    # exists on machines that created it (not CI or fresh clones). When it
    # does exist, verify the moved hacks actually live there.
    if [[ -f env/local/environment.env ]]; then
        grep -q '\.local/bin/env' env/local/environment.env || log_fail "bin/env source not in local override"
    else
        echo -n "(no local env file, content checks skipped) "
    fi
    git check-ignore -q env/local/environment.env || log_fail "env/local/environment.env is not gitignored"
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
    test_update_script
    test_machine_specific_moved
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
    update) test_update_script ; test_machine_specific_moved ;;
    --help|-h)
        echo "Usage: $0 [all|syntax|environment|modules|installer|update]"
        ;;
    *)
        color_red "Unknown test group: $1"
        echo "Usage: $0 [all|syntax|environment|modules|installer|update]" >&2
        exit 2
        ;;
esac
