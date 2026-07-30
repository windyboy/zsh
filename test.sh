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
    log_pass
}

run_all() {
    echo "🚀 Running ZSH regression tests..."
    test_syntax
    test_vars
    test_modules
    test_documentation
    test_installer_contract
    echo "✨ All tests passed!"
}

case "${1:-all}" in
    all) run_all ;;
    syntax) test_syntax ;;
    environment) test_vars ;;
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
