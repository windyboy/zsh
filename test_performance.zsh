#!/usr/bin/env zsh
# Quick performance test script

echo "🚀 ZSH Performance Test"
echo "======================="

# Test startup time
echo "Testing startup time..."
time zsh -c "exit" 2>&1 | grep real

# Test configuration load time
echo "Testing configuration load time..."
time zsh -c "source ~/.zshrc; exit" 2>&1 | grep real

# Test completion system
echo "Testing completion system..."
time (autoload -Uz compinit; compinit -C) 2>&1 | grep real

echo "✅ Performance test completed"
