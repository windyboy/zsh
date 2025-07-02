#!/usr/bin/env zsh
# =============================================================================
# ZSH Test Runner - Minimal Version
# =============================================================================

# Set startup time tracking for test
if [[ -n "$EPOCHREALTIME" ]]; then
  export ZSH_STARTUP_TIME_BEGIN="$EPOCHREALTIME"
else
  export ZSH_STARTUP_TIME_BEGIN="$(date +%s.%N)"
fi

# Load the full zsh configuration first
source "$HOME/.config/zsh/zshrc"

# Load the test framework
source "$HOME/.config/zsh/tests/test_framework.zsh"

# Run the tests
run_zsh_tests 