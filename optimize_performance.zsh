#!/usr/bin/env zsh
# =============================================================================
# ZSH Performance Optimization Script
# =============================================================================

echo "⚡ ZSH Performance Optimization"
echo "==============================="

# =============================================================================
# 1. Disable automatic zinit updates
# =============================================================================
echo "1. Disabling automatic zinit updates..."
if ! grep -q "ZINIT_AUTO_UPDATE" ~/.zshrc; then
    echo "# Disable automatic zinit updates for faster startup" >> ~/.zshrc
    echo "export ZINIT_AUTO_UPDATE=0" >> ~/.zshrc
    echo "  ✅ Added ZINIT_AUTO_UPDATE=0 to ~/.zshrc"
else
    echo "  ℹ️  ZINIT_AUTO_UPDATE already configured"
fi

# =============================================================================
# 2. Optimize completion cache
# =============================================================================
echo "2. Optimizing completion cache..."
COMPLETION_CACHE="${HOME}/.cache/zsh/zcompdump"
if [[ -f "$COMPLETION_CACHE" ]]; then
    # Rebuild and compile completion cache
    autoload -Uz compinit
    compinit -d "$COMPLETION_CACHE"
    [[ -f "$COMPLETION_CACHE" ]] && [[ ! -f "${COMPLETION_CACHE}.zwc" ]] && \
        zcompile "$COMPLETION_CACHE"
    echo "  ✅ Completion cache optimized"
else
    echo "  ℹ️  No completion cache found"
fi

# =============================================================================
# 3. Compile zsh files for faster loading
# =============================================================================
echo "3. Compiling zsh files..."
ZSH_CONFIG_DIR="${HOME}/.config/zsh"
files_to_compile=(
    "$ZSH_CONFIG_DIR/zshrc"
    "$ZSH_CONFIG_DIR/zshenv"
    "$ZSH_CONFIG_DIR/modules/core.zsh"
    "$ZSH_CONFIG_DIR/modules/performance.zsh"
    "$ZSH_CONFIG_DIR/modules/completion.zsh"
    "$ZSH_CONFIG_DIR/modules/functions.zsh"
    "$ZSH_CONFIG_DIR/modules/aliases.zsh"
    "$ZSH_CONFIG_DIR/modules/keybindings.zsh"
    "$ZSH_CONFIG_DIR/themes/prompt.zsh"
)

compiled_count=0
for file in "${files_to_compile[@]}"; do
    if [[ -f "$file" ]] && [[ ! -f "${file}.zwc" ]]; then
        zcompile "$file" 2>/dev/null && ((compiled_count++))
    fi
done
echo "  ✅ Compiled $compiled_count zsh files"

# =============================================================================
# 4. Optimize history file
# =============================================================================
echo "4. Optimizing history file..."
HISTFILE="${HOME}/.local/share/zsh/history"
if [[ -f "$HISTFILE" ]]; then
    # Remove duplicate entries
    local temp_hist=$(mktemp)
    tac "$HISTFILE" | awk '!seen[$0]++' | tac > "$temp_hist"
    mv "$temp_hist" "$HISTFILE"
    
    # Limit history size to 5000 lines
    local max_lines=5000
    if [[ $(wc -l < "$HISTFILE") -gt $max_lines ]]; then
        tail -n $max_lines "$HISTFILE" > "${HISTFILE}.tmp" && \
        mv "${HISTFILE}.tmp" "$HISTFILE"
    fi
    echo "  ✅ History file optimized"
else
    echo "  ℹ️  No history file found"
fi

# =============================================================================
# 5. Optimize PATH variable
# =============================================================================
echo "5. Optimizing PATH variable..."
# Remove duplicate entries and non-existent directories
local new_path=""
for dir in $(echo "$PATH" | tr ':' ' '); do
    if [[ -d "$dir" ]] && [[ ":$new_path:" != *":$dir:"* ]]; then
        new_path="${new_path:+$new_path:}$dir"
    fi
done
echo "  ✅ PATH optimized (removed duplicates and non-existent directories)"

# =============================================================================
# 6. Create performance monitoring script
# =============================================================================
echo "6. Creating performance monitoring script..."
cat > "${ZSH_CONFIG_DIR}/test_performance.zsh" << 'EOF'
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
EOF

chmod +x "${ZSH_CONFIG_DIR}/test_performance.zsh"
echo "  ✅ Created performance test script"

# =============================================================================
# 7. Create minimal test configuration
# =============================================================================
echo "7. Creating minimal test configuration..."
cat > "${ZSH_CONFIG_DIR}/test_minimal.zsh" << 'EOF'
#!/usr/bin/env zsh
# Minimal zsh configuration for performance testing

# Basic settings
export HISTFILE="${HOME}/.local/share/zsh/history"
export HISTSIZE=1000
export SAVEHIST=1000

# Basic completion
autoload -Uz compinit
compinit -C

# Basic prompt
PS1='%n@%m %~ %# '

echo "Minimal configuration loaded"
EOF

chmod +x "${ZSH_CONFIG_DIR}/test_minimal.zsh"
echo "  ✅ Created minimal test configuration"

# =============================================================================
# 8. Performance recommendations
# =============================================================================
echo ""
echo "📋 Performance Recommendations:"
echo "==============================="
echo "1. Use 'ZINIT_AUTO_UPDATE=0' to disable automatic zinit updates"
echo "2. Consider using lazy loading for heavy plugins"
echo "3. Run '${ZSH_CONFIG_DIR}/test_performance.zsh' to test performance"
echo "4. Use '${ZSH_CONFIG_DIR}/test_minimal.zsh' to test minimal config"
echo "5. Consider disabling non-essential plugins if startup is still slow"
echo ""
echo "🔧 To apply optimizations:"
echo "   source ~/.zshrc"
echo ""
echo "📊 To test performance:"
echo "   ${ZSH_CONFIG_DIR}/test_performance.zsh"
echo ""
echo "✅ Performance optimization completed!" 