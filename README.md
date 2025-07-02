# ZSH Modular Configuration with Oh My Posh

A professional-grade, modular ZSH configuration system with Oh My Posh integration, designed for developers who demand performance, reliability, and extensibility.

## 🚀 Features

- **Modular Architecture**: Clean separation of concerns with dedicated modules
- **Performance Optimized**: Sub-second startup times with intelligent caching
- **Error Handling**: Comprehensive error recovery and logging
- **Testing Framework**: Built-in testing and validation
- **Plugin Management**: Zinit-based plugin system with lazy loading
- **Oh My Posh Integration**: Beautiful, informative prompts
- **XDG Compliance**: Proper file organization following standards

## 📁 Project Structure

```
~/.config/zsh/
├── zshrc                 # Main configuration file
├── zshenv                # Environment variables
├── modules/              # Modular configuration
│   ├── core.zsh         # Core ZSH settings
│   ├── plugins.zsh      # Plugin management
│   ├── completion.zsh   # Completion system
│   ├── functions.zsh    # Custom functions
│   ├── aliases.zsh      # Aliases
│   ├── keybindings.zsh  # Key bindings
│   ├── performance.zsh  # Performance monitoring
│   └── error_handling.zsh # Error handling
├── themes/
│   └── prompt.zsh       # Oh My Posh configuration
├── tests/
│   └── test_framework.zsh # Testing framework
├── completions/         # Custom completions
├── cache/              # Cache files
└── data/               # Data files
```

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

## 🔧 Modules

### Core Module (`modules/core.zsh`)

Essential ZSH settings and options:

- History configuration
- Directory navigation
- Globbing options
- Correction settings
- Global aliases

### Plugin Module (`modules/plugins.zsh`)

Plugin management using Zinit:

- **FZF**: Fuzzy finder
- **Fast Syntax Highlighting**: Syntax highlighting
- **Zsh Autosuggestions**: Command suggestions
- **Zsh Completions**: Additional completions
- **FZF Tab**: FZF-powered completion
- **Zeno**: Snippet manager
- **Zoxide**: Smart directory navigation
- **Eza**: Modern ls replacement
- **Forgit**: Git workflow enhancement

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
- Performance metrics
- Optimization suggestions
- Performance dashboard

### Error Handling Module (`modules/error_handling.zsh`)

Robust error handling and recovery:

- Error logging
- Recovery strategies
- Safe execution
- Emergency recovery mode

## 🧪 Testing

### Run Tests

```bash
# Full test suite
run_zsh_tests

# Quick test
quick_test
```

### Test Categories

- Core configuration validation
- Plugin system verification
- Completion system testing
- Performance analysis
- Custom function validation

## 📊 Performance

### Monitoring

```bash
# Performance dashboard
zsh_perf_dashboard

# Detailed analysis
zsh_perf_analyze

# Quick check
quick_perf_check
```

### Optimization

```bash
# Optimize performance
optimize_zsh_performance
```

### Performance Targets

- **Startup Time**: < 1 second
- **Memory Usage**: < 50MB
- **Function Count**: < 500
- **PATH Entries**: < 20

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

## 🔍 Troubleshooting

### Common Issues

#### Slow Startup

```bash
# Check startup time
zsh_perf_analyze

# Optimize performance
optimize_zsh_performance

# Disable startup check temporarily
export ZSH_DISABLE_STARTUP_CHECK=1
```

#### Plugin Issues

```bash
# Check plugin installation
ls -la ~/.local/share/zsh/zinit/zinit.git/

# Reinstall Zinit
rm -rf ~/.local/share/zsh/zinit
./install.sh
```

#### Completion Problems

```bash
# Rebuild completion cache
rm ~/.cache/zsh/zcompdump*
source ~/.zshrc
```

### Error Recovery

```bash
# Enter recovery mode
enter_recovery_mode

# Check error log
report_errors

# Clear error log
clear_error_log
```

### Debug Mode

```bash
# Enable debug mode
export ZSH_DEBUG=1

# Enable profiling
export ZSH_PROF=1
exec zsh
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

## 🙏 Acknowledgments

- [Zinit](https://github.com/zdharma-continuum/zinit) - Plugin manager
- [Oh My Posh](https://ohmyposh.dev/) - Prompt engine
- [ZSH Community](https://zsh.sourceforge.io/) - Shell framework

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/zsh-config/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/zsh-config/discussions)
- **Documentation**: [Wiki](https://github.com/yourusername/zsh-config/wiki)

---

**Made with ❤️ for developers who care about their shell experience** 