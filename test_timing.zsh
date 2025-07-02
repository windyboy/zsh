#!/usr/bin/env zsh
# Test script to verify timing calculation

echo "Testing Zsh startup timing..."

# Test 1: Direct timing measurement
echo "Test 1: Direct timing measurement"
time zsh -c "source ~/.zshrc; exit" 2>&1 | grep real

# Test 2: Interactive shell timing
echo "Test 2: Interactive shell timing"
time zsh -i -c "exit" 2>&1 | grep real

# Test 3: Check if timing variables are set correctly
echo "Test 3: Checking timing variables"
zsh -c "
source ~/.zshrc
echo 'ZSH_STARTUP_TIME_BEGIN: '\$ZSH_STARTUP_TIME_BEGIN
echo 'ZSHRC_LOAD_START: '\$ZSHRC_LOAD_START
echo 'ZSHRC_LOAD_END: '\$ZSHRC_LOAD_END
"

echo "Timing test completed" 