# ZSH Modular Configuration with Oh My Posh

A professional-grade, modular ZSH configuration system with Oh My Posh integration, designed for developers who demand performance, reliability, and extensibility.

**Current Version**: 1.0.0  
**Last Updated**: 2025-07-02

## 🚀 Features

- **Modular Architecture**: Clean separation of concerns with dedicated modules
- **Performance Optimized**: Sub-second startup times with intelligent caching
- **Error Handling**: Comprehensive error recovery and logging
- **Testing Framework**: Built-in testing, validation, and scoring
- **Plugin Management**: Manual plugin system (no Zinit required)
- **Security Module**: Hardened shell with best practices
- **Oh My Posh Integration**: Beautiful, informative prompts
- **XDG Compliance**: Proper file organization following standards

## 📁 Project Structure

```
~/.config/zsh/
├── zshrc                 # Main configuration file
├── zshenv                # Environment variables
├── modules/              # Modular configuration
│   ├── core.zsh         # Core ZSH settings
│   ├── plugins.zsh      # Plugin management (manual)
│   ├── completion.zsh   # Completion system
│   ├── functions.zsh    # Custom functions
│   ├── aliases.zsh      # Aliases
│   ├── keybindings.zsh  # Key bindings
│   ├── performance.zsh  # Performance monitoring
│   ├── error_handling.zsh # Error handling
│   └── security.zsh     # Security hardening
├── themes/
│   └── prompt.zsh       # Oh My Posh configuration
├── tests/
│   └── test_framework.zsh # Testing framework
├── completions/         # Custom completions
├── backup/             # Backup files
├── cache/              # Cache files
└── data/               # Data files

### Key Files

- `optimize_performance.zsh` - Performance optimization tools
- `verify_optimization.zsh` - Performance verification scripts
- `test_performance.zsh` - Performance testing framework
- `test_timing.zsh` - Startup timing analysis
- `test_minimal.zsh` - Minimal configuration testing
- `PERFORMANCE_GUIDE.md` - Performance optimization guide
- `OPTIMIZATION_SUMMARY.md` - Performance optimization summary

## 🛠️ Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh

# Run the installer
cd ~/.config/zsh
chmod +x install.sh
./install.sh
```

### Manual Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh
   ```

2. **Create symlinks**:
   ```bash
   ln -sf ~/.config/zsh/zshrc ~/.zshrc
   ln -sf ~/.config/zsh/zshenv ~/.zshenv
   ```

3. **Set ZSH as default shell**:
   ```bash
   chsh -s $(which zsh)
   ```

4. **Restart your terminal**

### System Requirements

- **ZSH**: Version 5.8 or higher
- **Operating System**: macOS, Linux, or WSL
- **Package Manager**: Homebrew (macOS), apt/yum (Linux)
- **Optional**: Oh My Posh for enhanced prompts

## ⚙️ Configuration

### Environment Variables

Key environment variables in `zshenv`:

```bash
# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# ZSH specific paths
export ZSH_CONFIG_DIR="${XDG_CONFIG_HOME}/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
export ZSH_DATA_DIR="${XDG_DATA_HOME}/zsh"
```

### Local Configuration

Create `~/.config/zsh/local.zsh` for machine-specific settings:

```bash
# Example local.zsh
export EDITOR='nvim'
export BROWSER='firefox'

# Machine-specific aliases
alias myproject='cd ~/Projects/myproject'

# Custom functions
my_custom_function() {
    echo "This is my custom function"
}
```

## 🔒 Security Module (`modules/security.zsh`)

This module enforces best security practices:
- Prevents accidental file overwrites (`NO_CLOBBER`)
- Confirms before `rm *` (`RM_STAR_WAIT`)
- Secure SSH/SCP aliases
- Security audit and suspicious file checks
- Hardened umask and TMPDIR
- Security validation and scoring

Run `validate-security` or `security-audit` for checks.

## 🔧 Modules

### Core Module (`modules/core.zsh`)
Essential ZSH settings and options:
- History configuration
- Directory navigation
- Globbing options
- Correction settings
- Global aliases

### Plugin Module (`modules/plugins.zsh`)
**Manual plugin management**—no Zinit required:
- FZF, Zoxide, Eza, zsh-autosuggestions, zsh-syntax-highlighting, etc.
- Plugins are loaded if available on your system
- Use `check_plugins` to see plugin status

**To install plugins:**
- Use your OS package manager (e.g., `brew install fzf zoxide eza zsh-autosuggestions zsh-syntax-highlighting`)
- No lazy loading or Zinit required

### Completion Module (`modules/completion.zsh`)
Advanced completion system with caching:
- Intelligent cache management
- Tool-specific completions
- Custom completion styles
- Async loading

### Functions Module (`modules/functions.zsh`)
Comprehensive utility functions:
- **Directory Operations**: `mkcd`, `up`, `dirsize`
- **File Operations**: `trash`, `backup`, `extract`
- **Network Operations**: `serve`, `myip`, `portscan`
- **System Information**: `sysinfo`, `process_info`
- **Development Tools**: `git_quick`, `docker_cleanup`

### Performance Module (`modules/performance.zsh`)
Performance monitoring and optimization:
- Startup time tracking
- Function profiling
- Performance metrics and scoring
- Optimization suggestions
- Performance dashboard

### Error Handling Module (`modules/error_handling.zsh`)
Robust error handling and recovery:
- Error logging
- Recovery strategies
- Safe execution
- Emergency recovery mode

## 🧪 Testing & Scoring

### Run Tests

```bash
# Full test suite
zsh-test

# Quick test
zsh-test-quick

# Performance test
test_performance.zsh

# Minimal test
test_minimal.zsh
```

### Test Categories
- Core configuration validation
- Security configuration validation
- Plugin/module loading verification
- Performance analysis and benchmarking
- Custom function validation
- Module loading validation

### Scoring
- The test suite outputs a configuration score out of 10
- Achieve 10/10 for a perfect, professional setup
- Performance metrics and optimization suggestions
- Security validation and scoring

## 📊 Performance

### Monitoring

```bash
# Performance dashboard
zsh-perf

# Performance verification
verify_optimization.zsh

# Performance analysis
test_performance.zsh

# Timing analysis
test_timing.zsh
```

## 🛡️ Troubleshooting

### Common Issues

- **Interactive Shell Required:** Some features (completion, keybindings) only work in an interactive ZSH shell. Always test by opening a new terminal and running `zsh`.
- **Completion Errors:** If you see errors about `zsh/parameter` or `zsh/zle`, delete your completion cache:
  ```sh
  rm ~/.cache/zsh/zcompdump*
  ```
  Then restart your shell.
- **Plugin Not Found:** Install missing plugins with your package manager (e.g., `brew install fzf zoxide eza zsh-autosuggestions zsh-syntax-highlighting`).
- **Default Shell:** Ensure ZSH is your default shell: `chsh -s $(which zsh)`
- **Performance Issues:** Run `optimize_zsh_performance` for optimization suggestions
- **Module Loading Errors:** Use `zsh-test` to validate module loading and identify issues

## 🎖️ Final Notes

- This configuration is now fully modular, secure, and does not require Zinit or any plugin manager.
- All modules are loaded and tracked for reliability and scoring.
- Security and performance are first-class citizens.
- Comprehensive testing framework ensures configuration quality.
- Performance optimization tools help maintain fast startup times.

## 🎨 Oh My Posh Integration

### Theme Configuration

The prompt theme is configured in `themes/prompt.zsh`:

```bash
# Theme path
POSH_THEME="${POSH_THEME:-$HOME/.poshthemes/pararussel.omp.json}"

# Fallback prompt if Oh My Posh is not available
_setup_fallback_prompt() {
    # Custom fallback prompt implementation
}
```

### Installing Oh My Posh

```bash
# macOS
brew install oh-my-posh

# Linux
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
chmod +x /usr/local/bin/oh-my-posh
```

## 🔍 Advanced Troubleshooting

### Performance Issues

#### Slow Startup

```bash
# Check startup time
zsh_perf_analyze

# Optimize performance
optimize_zsh_performance

# Disable startup check temporarily
export ZSH_DISABLE_STARTUP_CHECK=1

# Run performance verification
verify_optimization.zsh
```

#### Memory Usage

```bash
# Monitor memory usage
zsh_perf_memory

# Clean up cache
zsh_maintenance_cleanup
```

### Plugin Issues

```bash
# Check plugin installation
check_plugins

# Verify plugin availability
which fzf zoxide eza
```

### Completion Problems

```bash
# Rebuild completion cache
rm ~/.cache/zsh/zcompdump*
source ~/.zshrc

# Test completion system
zsh-test-quick
```

### Error Recovery

```bash
# Enter recovery mode
enter_recovery_mode

# Check error log
report_errors

# Clear error log
clear_error_log

# Validate configuration
zsh-test
```

### Debug Mode

```bash
# Enable debug mode
export ZSH_DEBUG=1

# Enable profiling
export ZSH_PROF=1
exec zsh

# Test timing
test_timing.zsh
```

## 🛡️ Security

### Best Practices

- **Path Validation**: All PATH modifications are validated
- **Safe File Operations**: Backup mechanisms for critical operations
- **Plugin Security**: Only trusted plugin sources
- **Environment Isolation**: XDG compliance for file organization

### Security Features

- Safe command execution with `safe_exec`
- File operation validation
- Error logging for security events
- Recovery mode for emergency situations

## 🔄 Maintenance

### Regular Maintenance

```bash
# Weekly optimization
optimize_zsh_performance

# Monthly cleanup
zsh_maintenance_cleanup

# Quarterly testing
run_zsh_tests
```

### Backup and Restore

```bash
# Create backup
zsh_backup

# Restore from backup
zsh_restore <backup_file>
```

## 📈 Performance Metrics

### Startup Time Tracking

The configuration tracks startup times and provides optimization suggestions:

- **Good**: < 1 second
- **Warning**: 1-2 seconds
- **Critical**: > 2 seconds

### Memory Usage

- **Target**: < 50MB
- **Monitoring**: Real-time memory tracking
- **Optimization**: Automatic cleanup suggestions

## 🤝 Contributing

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `run_zsh_tests`
5. Submit a pull request

### Code Style

- Use consistent indentation (2 spaces)
- Add comments for complex logic
- Follow shell scripting best practices
- Include error handling

### Testing

All changes must pass the test suite:

```bash
run_zsh_tests
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📋 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a complete history of changes and version information.

## 🙏 Acknowledgments

- [Oh My Posh](https://ohmyposh.dev/) - Prompt engine
- [ZSH Community](https://zsh.sourceforge.io/) - Shell framework
- [FZF](https://github.com/junegunn/fzf) - Fuzzy finder
- [Zoxide](https://github.com/ajeetdsouza/zoxide) - Smart cd replacement
- [Eza](https://github.com/eza-community/eza) - Modern ls replacement

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/zsh-config/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/zsh-config/discussions)
- **Documentation**: [Wiki](https://github.com/yourusername/zsh-config/wiki)
- **Performance Guide**: [PERFORMANCE_GUIDE.md](PERFORMANCE_GUIDE.md)

---

**Made with ❤️ for developers who care about their shell experience**

**Version 1.0.0** - A complete, modular, and performance-optimized ZSH configuration system. 