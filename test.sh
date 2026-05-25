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
    for f in zshrc zshenv modules/*.zsh; do
        zsh -n "$f" || log_fail "$f"
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

# 3. Module Check
test_modules() {
    log_test "Modules"
    # Mock source to just check existence
    for m in colors core navigation plugins completion aliases keybindings; do
        [[ -f "./modules/$m.zsh" ]] || log_fail "$m module missing"
    done
    log_pass
}

# Main
echo "🚀 Running ZSH Regression Tests..."
test_syntax
test_vars
test_modules
echo "✨ All tests passed!"
