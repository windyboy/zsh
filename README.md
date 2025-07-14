# ZSH Configuration - Unified Module System

A comprehensive, modular ZSH configuration system designed for performance, security, and maintainability.

## 🚀 Features

### Core System
- **Unified Module System**: Centralized module management with dependency resolution
- **Performance Monitoring**: Real-time performance tracking and optimization
- **Security Framework**: Comprehensive security auditing and validation
- **Error Handling**: Robust error recovery and logging system
- **XDG Compliance**: Follows XDG Base Directory Specification

### Module Architecture
- **Core Module**: Foundation settings and module system
- **Error Handling**: Safe operations and error recovery
- **Security**: Security auditing and validation
- **Performance**: Performance monitoring and optimization
- **Plugins**: Zinit-based plugin management
- **Completion**: Advanced completion system
- **Aliases**: Comprehensive alias management
- **Functions**: Utility function collection
- **Keybindings**: Custom keybinding system

### Advanced Features
- **Module Manager**: Centralized module loading with dependencies
- **System Status**: Comprehensive system diagnostics
- **Performance Analysis**: Detailed performance metrics
- **Security Auditing**: Security validation and monitoring
- **Configuration Validation**: Automated configuration checking

## 📦 Installation

### Prerequisites
- ZSH 5.8 or higher
- Git
- Basic Unix tools (curl, wget, etc.)

### Quick Install
```bash
# Clone the repository
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh

# Create symlinks
ln -sf ~/.config/zsh/zshrc ~/.zshrc
ln -sf ~/.config/zsh/zshenv ~/.zshenv

# Restart your shell
exec zsh
```

### Manual Installation
```bash
# Create configuration directories
mkdir -p ~/.config/zsh ~/.cache/zsh ~/.local/share/zsh

# Copy configuration files
cp -r zsh/ ~/.config/zsh/

# Set up environment
echo 'export ZSH_CONFIG_DIR="$HOME/.config/zsh"' >> ~/.zshenv
echo 'source ~/.config/zsh/zshrc' >> ~/.zshrc
```

## 🏗️ Module System

### Module Dependencies
```
core (foundation)
├── error_handling
├── security
├── performance
├── plugins
│   └── completion
├── aliases
├── functions
└── keybindings
```

### Module Loading Order
1. **Core**: Foundation settings and module system
2. **Error Handling**: Safe operations and error recovery
3. **Security**: Security auditing and validation
4. **Performance**: Performance monitoring and optimization
5. **Plugins**: Zinit-based plugin management
6. **Completion**: Advanced completion system
7. **Aliases**: Comprehensive alias management
8. **Functions**: Utility function collection
9. **Keybindings**: Custom keybinding system

## 🛠️ Usage

### Basic Commands
```bash
# System status
system_status          # Comprehensive system check
quick_status          # Quick system check
module_status         # Module status check

# Configuration management
zsh-check            # Validate configuration
zsh-reload           # Reload configuration
validate_configuration # Detailed validation

# Performance
zsh-perf             # Performance analysis
zsh-perf-dash        # Performance dashboard
zsh-perf-opt         # Performance optimization

# Security
security-audit       # Security audit
check-suspicious     # Check suspicious files
validate-security    # Security validation

# Module management
modules-list         # List all modules
modules-check        # Check module dependencies
modules-validate     # Validate module system
```

### Module Management
```bash
# List modules
list_all_modules

# Get module status
get_module_status <module>

# Reload module
reload_module <module>

# Monitor module performance
monitor_module_performance <module>

# Validate module security
validate_module_security <module>
```

### Performance Optimization
```bash
# Run performance analysis
zsh_perf_analyze

# Optimize performance
optimize_zsh_performance

# Quick performance check
quick_perf_check

# Performance dashboard
zsh_perf_dashboard
```

## 🔧 Configuration

### Environment Variables
```bash
export ZSH_CONFIG_DIR="$HOME/.config/zsh"
export ZSH_CACHE_DIR="$HOME/.cache/zsh"
export ZSH_DATA_DIR="$HOME/.local/share/zsh"
export ZSH_VERBOSE=1          # Enable verbose output
export ZSH_WELCOME=1          # Show welcome message
export ZSH_QUIET=1            # Suppress output
```

### Plugin Configuration
```bash
# Enable enhanced plugins
export ZSH_ENHANCED_PLUGINS=1

# Plugin categories
export ZSH_CORE_PLUGINS=1     # Core plugins
export ZSH_ENHANCED_PLUGINS=1 # Enhanced plugins
```

## 📊 Performance

### Startup Time
- **Target**: < 1 second
- **Optimized**: ~0.5 seconds
- **Monitoring**: Real-time startup tracking

### Memory Usage
- **Target**: < 50MB
- **Optimized**: ~30MB
- **Monitoring**: Memory usage tracking

### Function Count
- **Target**: < 500 functions
- **Optimized**: ~300 functions
- **Monitoring**: Function count tracking

## 🔒 Security

### Security Features
- **File Permissions**: Secure file permissions
- **Path Validation**: PATH security checking
- **Dangerous Pattern Detection**: Security pattern scanning
- **Audit Logging**: Comprehensive security logging
- **Recovery Mode**: Emergency recovery system

### Security Commands
```bash
# Security audit
security_audit

# Check suspicious files
check_suspicious_files

# Secure file deletion
secure_rm <file>

# Security validation
validate_security_config

# Security monitoring
monitor_security
```

## 🐛 Troubleshooting

### Common Issues

#### Slow Startup
```bash
# Check performance
zsh-perf

# Optimize performance
zsh-perf-opt

# Check for bottlenecks
_identify_bottlenecks
```

#### Module Loading Issues
```bash
# Check module status
module_status

# Validate modules
validate_module_files

# Check dependencies
validate_module_dependencies
```

#### Configuration Errors
```bash
# Validate configuration
validate_configuration

# Check system status
system_status

# Quick check
quick_status
```

### Debug Mode
```bash
# Enable debug mode
export ZSH_DEBUG=1
exec zsh

# Enable profiling
export ZSH_PROF=1
exec zsh
```

### Recovery Mode
```bash
# Enter recovery mode
enter_recovery_mode

# Exit recovery mode
exit_recovery_mode
```

## 📝 Logging

### Log Files
- **Error Log**: `~/.cache/zsh/error.log`
- **Performance Log**: `~/.cache/zsh/performance.log`
- **Security Log**: `~/.cache/zsh/security.log`
- **Module Log**: `~/.cache/zsh/module_manager.log`
- **Status Log**: `~/.cache/zsh/system_status.log`

### Log Commands
```bash
# View error log
report_errors

# Clear error log
clear_error_log

# Module error summary
module_error_summary

# Security monitoring
monitor_security
```

## 🤝 Contributing

### Development Setup
```bash
# Clone repository
git clone https://github.com/yourusername/zsh-config.git

# Create development environment
cd zsh-config
./setup_dev.sh

# Run tests
./run_tests.sh
```

### Code Style
- Follow ZSH best practices
- Use consistent naming conventions
- Add comprehensive comments
- Include error handling
- Write unit tests

### Module Development
```bash
# Create new module
touch modules/new_module.zsh

# Add module to dependencies
# Edit module_manager.zsh

# Test module
./test_module.sh new_module
```

## 📚 Documentation

### Module Documentation
- **Core**: Foundation and module system
- **Error Handling**: Safe operations and recovery
- **Security**: Security auditing and validation
- **Performance**: Performance monitoring and optimization
- **Plugins**: Zinit-based plugin management
- **Completion**: Advanced completion system
- **Aliases**: Comprehensive alias management
- **Functions**: Utility function collection
- **Keybindings**: Custom keybinding system

### API Reference
- **Module Manager**: Centralized module management
- **System Status**: Comprehensive diagnostics
- **Performance Analysis**: Performance metrics
- **Security Auditing**: Security validation
- **Configuration Validation**: Automated checking

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Zinit**: Plugin manager
- **ZSH Community**: Inspiration and best practices
- **XDG**: Base Directory Specification
- **Contributors**: All contributors to this project

## 📞 Support

### Getting Help
- **Documentation**: Check this README
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Wiki**: Project Wiki

### Reporting Issues
1. Check existing issues
2. Use issue templates
3. Include system information
4. Provide error logs
5. Describe steps to reproduce

---

**Version**: 3.0  
**Last Updated**: 2024  
**Maintainer**: Your Name  
**License**: MIT 