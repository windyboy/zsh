# 🚀 ZSH Configuration v5.3.1

> **High-performance, modular ZSH configuration system** with comprehensive testing, automated updates, and professional CI/CD pipeline.

[![CI/CD](https://github.com/windyboy/zsh/workflows/Test%20ZSH%20Configuration/badge.svg)](https://github.com/windyboy/zsh/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![ZSH Version](https://img.shields.io/badge/zsh-5.8+-green.svg)](https://www.zsh.org/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL-blue.svg)]()

## ✨ Features

| Category | Features |
|----------|----------|
| **🚀 Performance** | Lightning-fast startup, optimized modules, intelligent caching |
| **⭐ Script Quality** | All scripts upgraded with enhanced configuration and maintainability |
| **🎨 Interface** | Beautiful UI, color-coded output, progress indicators |
| **📊 Monitoring** | Real-time status, performance metrics, health scoring |
| **🔧 Architecture** | Modular design, clean separation, maintainable code |
| **🔄 Automation** | Auto-updates, CI/CD pipeline, comprehensive testing |
| **🛡️ Security** | Security scanning, vulnerability detection, safe defaults |
| **📚 Documentation** | Complete guides, examples, troubleshooting |

## 📋 Table of Contents

- [System Requirements](#-system-requirements)
- [Quick Start](#-quick-start)
- [Installation Methods](#-installation-methods)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Testing & Validation](#-testing--validation)
- [Updates & Maintenance](#-updates--maintenance)
- [Development](#-development)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [Changelog](#-changelog)

## 🔧 System Requirements

### Required Dependencies
- **ZSH**: Version 5.8 or higher
- **Git**: For plugin management and updates

### Optional Dependencies (Recommended)
- **fzf**: Fuzzy file finder
- **zoxide**: Smart directory navigation  
- **eza**: Enhanced ls command
- **oh-my-posh**: Theme system
- **curl/wget**: Network tools

## 🚀 Quick Start

### One-Command Installation

> **💡 New in v5.3.0**: Enhanced theme installation system with automatic validation and essential theme installation!

```bash
# Quick install with automatic setup
curl -fsSL https://raw.githubusercontent.com/windyboy/zsh/main/quick-install.sh | bash
```

### Manual Installation

```bash
# 1. Clone repository
git clone https://github.com/windyboy/zsh.git ~/.config/zsh
cd ~/.config/zsh

# 2. Install dependencies
./install-deps.sh

# 3. Run installation
./install.sh --interactive

# 4. Restart terminal
exec zsh
```

## 📦 Installation Methods

### Method 1: Quick Install Script

The `quick-install.sh` script provides a complete one-command installation:

```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/windyboy/zsh/main/quick-install.sh | bash

# Or clone and run locally
git clone https://github.com/windyboy/zsh.git
cd zsh
./quick-install.sh
```

**Features:**
- ✅ Automatic ZSH installation
- ✅ Cross-platform support (macOS, Linux, WSL)
- ✅ Interactive configuration
- ✅ Default shell setup
- ✅ Complete verification

### Method 2: Interactive Installation

```bash
# Clone repository
git clone https://github.com/windyboy/zsh.git ~/.config/zsh
cd ~/.config/zsh

# Interactive installation
./install.sh --interactive
```

**Features:**
- 🎯 Custom editor selection
- 🎨 Theme installation
- 🔌 Plugin recommendations
- ⚙️ Environment configuration

### Method 3: Manual Setup

```bash
# 1. Install dependencies
./install-deps.sh

# 2. Install themes (optional)
./install-themes.sh --all

# 3. Install configuration
./install.sh

# 4. Verify installation
./status.sh
```

## ⚙️ Configuration

### Directory Structure

```
~/.config/zsh/
├── zshrc                 # Main configuration
├── zshenv                # Environment variables
├── modules/              # Configuration modules
│   ├── core.zsh         # Core functionality
│   ├── aliases.zsh      # Aliases
│   ├── completion.zsh   # Completion system
│   ├── keybindings.zsh  # Key bindings
│   ├── path.zsh         # PATH management
│   ├── plugins.zsh      # Plugin management
│   ├── utils.zsh        # Utility functions
│   └── colors.zsh       # Color definitions
├── themes/               # Theme collection
├── custom/               # Custom configurations
├── completions/          # Completion scripts
└── env/                  # Environment management
```

### Environment Variables

```bash
# Core configuration
export ZDOTDIR="$HOME/.config/zsh"
export ZSH_CONFIG_DIR="$HOME/.config/zsh"
export ZSH_CACHE_DIR="$HOME/.cache/zsh"
export ZSH_DATA_DIR="$HOME/.local/share/zsh"

# Editor preferences
export EDITOR="code"
export VISUAL="code"

# Development tools
export PATH="$HOME/.local/bin:$PATH"
```

### Custom Configuration

The `config` command provides easy access to all configuration files:

```bash
# Quick configuration commands
config zshrc    # Edit main configuration
config core     # Edit core module
config plugins  # Edit plugin module
config aliases  # Edit aliases module
config env      # Edit environment configuration
```

#### Example `local.zsh`
```bash
# Personal aliases
alias ll='ls -la'
alias la='ls -A'

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Environment variables
export MY_CUSTOM_VAR="value"
```

### Environment Variable Configuration

This project uses a simplified environment variable configuration approach:

- **Core Environment Variables**: Set directly in `zshenv` (XDG paths, ZSH paths, history, etc.)
- **Plugin Environment Variables**: Managed in `modules/plugins.zsh` (ZSH autosuggestion config, etc.)
  - `ZSH_ENABLE_PLUGINS` controls whether to load all plugins
  - `ZSH_ENABLE_OPTIONAL_PLUGINS` controls optional plugins (like fzf-tab)
- **Theme Environment Variables**: Managed in `themes/prompt.zsh` (Oh My Posh config, etc.)
- **User Environment Variables**: Template-based management (development tool paths, package manager mirrors, etc.)

#### Initialize Configuration (First Use)
```bash
# Use the unified config command
config env-init
```

#### Migrate Old Configuration (If Existing)
```bash
# Use the unified config command
config env-migrate
```

#### Edit Configuration
```bash
# Use the unified config command
config env
```

#### Configuration Notes
- **Template File**: `env/templates/environment.env.template` - Do not modify directly
- **Local Configuration**: `env/local/environment.env` - Can be freely modified
- **Auto-loading**: Configuration files are automatically loaded, no additional steps required

## 🎯 Usage

### Core Commands

```bash
# System management
status          # Comprehensive system status
reload          # Reload configuration
validate        # Validate configuration
version         # Show version information

# Plugin management
plugins         # List installed plugins
plugins_update  # Update all plugins
plugins_clean   # Clean unused plugins

# Performance
perf            # Performance metrics
perf --modules  # Per-module performance breakdown
perf --memory   # Memory usage analysis
perf --startup  # Startup time analysis
perf --monitor  # Continuous monitoring
perf --optimize # Optimization suggestions
```

### Unified Configuration Interface

The `config` command provides a unified interface for all configuration management:

```bash
# Configuration Files
config zshrc      # Edit main configuration file
config zshenv     # Edit environment variables
config core       # Edit core module
config plugins    # Edit plugins module
config aliases    # Edit aliases module
config completion # Edit completion module
config keybindings # Edit keybindings module
config utils      # Edit utils module

# Environment Configuration
config env        # Edit user environment variables (recommended)
config env-template # View environment template file
config env-init   # Initialize environment configuration
config env-migrate # Migrate old environment configuration

# System Management
config status     # Show system status
config reload     # Reload configuration
config validate   # Validate configuration
config test       # Run test suite
```

### Status Monitoring

```bash
# Quick status check
./status.sh

# Detailed status with metrics
./status.sh --verbose

# Export status report
./status.sh --export report.json
```

**Status Features:**
- 📊 Real-time performance metrics
- 🎯 Intelligent scoring system (0-100)
- 🔌 Plugin health monitoring
- 📈 Visual progress indicators
- 🎨 Beautiful color-coded output

## 🛠 Helper Commands

Here are some commonly used commands for managing custom configurations:

### Installation and Dependency Management

```bash
# Manual dependency installation
./install-deps.sh

# Install themes
./install-themes.sh

# Install configuration (interactive mode)
./install.sh --interactive

# Quick installation (non-interactive)
./quick-install.sh
```

### Configuration Management

```bash
# Unified configuration interface
config status     # Check current status
config reload     # Reload configuration
config validate   # Validate configuration
config test       # Run test suite

# Direct script access (alternative)
./status.sh       # Check current status
./backup/         # Backup configuration
./backup/restore.sh # Restore configuration

# Enhanced script options (v5.3.0+)
./check-project.sh --config custom.conf  # Use custom configuration
./install-plugins.sh list                # List available plugins
./quick-install.sh                      # Configurable installation
```

### Testing and Validation

```bash
# Unified testing interface
config test       # Run complete test suite
config validate   # Validate configuration

# Direct script access (alternative)
./test.sh unit    # Run unit tests
./test.sh performance # Run performance tests
./test.sh all     # Run complete test suite
./check-project.sh # Project health check
```

### Updates and Maintenance

```bash
# Update configuration
./update.sh

# Check for updates
./update.sh --check

# Force update
./update.sh --force
```

### Enhanced Plugin Management

The configuration now includes automatic plugin installation and enhanced error handling:

```bash
# Plugin management with automatic installation
plugins         # List installed plugins
plugins_update  # Update all plugins
plugins_clean   # Clean unused plugins

# Automatic plugin installation
# Plugins are automatically installed when loading fails
# Detailed status reporting shows installation progress
```

**Important Notes:**
- Ensure `zsh`, `git` and other dependencies are installed before running any scripts
- It's recommended to backup before modifying configuration: `cp -r ~/.config/zsh ~/.config/zsh.backup`
- If you encounter issues, check logs: `./status.sh --verbose`
- Plugins are automatically installed when missing, reducing manual setup

## 🧪 Testing & Validation

### Comprehensive Test Suite

```bash
# Run all tests
./test.sh all

# Run specific test categories
./test.sh unit         # Unit tests
./test.sh integration  # Integration tests
./test.sh performance  # Performance tests
./test.sh plugins      # Plugin conflict tests
./test.sh security     # Security tests
```

### Project Health Check

```bash
# Complete project validation
./check-project.sh

# Check specific aspects
./check-project.sh --help

# Use custom configuration
./check-project.sh --config custom.conf

# Skip specific checks
./check-project.sh --skip-syntax --skip-security
```

**Health Check Features:**
- 📁 File structure validation
- 🔐 Script permissions check
- 🔍 Syntax validation (configurable)
- ⚙️ Configuration validation
- 🧩 Module validation
- 📚 Documentation check
- 🔒 Security scan (configurable)
- ⚡ Performance check
- 🎛️ **NEW**: External configuration file support
- 🚫 **NEW**: Selective check skipping

### CI/CD Pipeline

The project includes a complete GitHub Actions workflow:

- ✅ **Automated Testing** - Runs on every push/PR
- ✅ **Cross-platform Support** - Ubuntu, macOS, Windows
- ✅ **Security Scanning** - Vulnerability detection
- ✅ **Code Quality** - ShellCheck integration
- ✅ **Performance Testing** - Startup time validation

## 🔄 Updates & Maintenance

### Automatic Updates

```bash
# Update all components
./update.sh

# Interactive update with prompts
./update.sh --interactive

# Update without backup
./update.sh --skip-backup

# Force update
./update.sh --force
```

**Update Features:**
- 🔄 zinit plugin manager updates
- 🎨 oh-my-posh theme engine updates
- 🛠️ Optional tools updates (fzf, zoxide, eza)
- 🎭 Theme collection updates
- 💾 Automatic backup creation
- 🧹 Old backup cleanup

### Manual Updates

```bash
# Update repository
git pull origin main

# Update plugins
zinit update

# Update oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s

# Update optional tools
brew upgrade fzf zoxide eza  # macOS
sudo apt update && sudo apt upgrade fzf zoxide eza  # Ubuntu
```

## 🛠️ Development

### Project Structure

```
zsh/
├── .github/workflows/    # CI/CD pipelines
├── modules/              # Configuration modules
├── themes/               # Theme collection
├── scripts/              # Utility scripts
├── docs/                 # Documentation
└── tests/                # Test suites
```

### Development Commands

```bash
# Run tests
./test.sh all

# Check project health
./check-project.sh

# Validate configuration
./validate.sh

# Performance profiling
./perf.sh --profile
```

### Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request

**Development Guidelines:**
- ✅ Follow shell scripting best practices
- ✅ Add comprehensive tests
- ✅ Update documentation
- ✅ Maintain backward compatibility
- ✅ Use semantic versioning

## 🔧 Troubleshooting

### Common Issues

#### Installation Problems

```bash
# Check ZSH version
zsh --version

# Verify installation
./status.sh

# Check configuration
./test.sh unit
```

#### Performance Issues

```bash
# Profile startup time
./perf.sh --profile

# Check for slow plugins
./test.sh performance

# Performance optimization (integrated into core system)
perf --optimize    # Show optimization recommendations
perf --profile     # Generate performance profile
perf --monitor     # Continuous performance monitoring
perf --modules     # Show per-module performance metrics
perf --memory      # Display module memory impact
perf --startup     # Analyze startup time per module
```

#### Plugin Conflicts

```bash
# Detect conflicts
./test.sh plugins

# Clean plugins
plugins_clean

# Update plugins
plugins_update
```

### Debug Mode

```bash
# Enable debug logging
export ZSH_DEBUG=1
source ~/.config/zsh/zshrc

# Verbose validation
./validate.sh --verbose

# Detailed status
./status.sh --debug
```

### Getting Help

1. **Check Documentation** - README.md, REFERENCE.md
2. **Run Diagnostics** - `./status.sh --verbose`
3. **Review Logs** - Check `~/.cache/zsh/` for logs
4. **Search Issues** - GitHub Issues page
5. **Ask Community** - GitHub Discussions

## 📚 Documentation

### Core Documentation

- **[README.md](README.md)** - This file, complete guide
- **[REFERENCE.md](REFERENCE.md)** - Configuration reference
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[LICENSE](LICENSE)** - MIT License

### Additional Resources

- **Installation Guide** - Detailed installation instructions
- **Configuration Guide** - Advanced configuration options
- **Troubleshooting** - Common issues and solutions
- **Development Guide** - Contributing guidelines

## ⚙️ Configuration Files

### Script Configuration (v5.3.0+)

All major scripts now support external configuration files for customization:

```bash
# Plugin configuration
cp plugins.conf.example plugins.conf
# Edit plugins.conf to customize plugin selection

# Project health check configuration
cp .check-project.conf.example .check-project.conf
# Edit .check-project.conf to customize validation rules

# Installation configuration
cp .zsh-install.conf.example ~/.zsh-install.conf
# Edit ~/.zsh-install.conf to customize installation options
```

**Available Configuration Files:**
- **`plugins.conf`** - Plugin selection and management options
- **`.check-project.conf`** - Health check thresholds and exclusions
- **`.zsh-install.conf`** - Installation preferences and repository settings

### Configuration Examples

```bash
# Customize plugin installation
export ZSH_PLUGINS="fzf,zoxide,eza"
./install-plugins.sh install

# Custom repository for quick-install
export ZSH_REPO_URL="https://github.com/yourusername/zsh-config.git"
./quick-install.sh

# Skip specific health checks
./check-project.sh --skip-syntax --skip-security
```

---

## 🎯 Performance Metrics

### Startup Time
- **Cold Start**: < 500ms
- **Warm Start**: < 200ms
- **Module Load**: < 100ms

### Memory Usage
- **Base Load**: < 5MB
- **Full Load**: < 10MB
- **Peak Usage**: < 15MB

### Plugin Count
- **Essential**: 5-10 plugins
- **Recommended**: 10-20 plugins
- **Maximum**: < 30 plugins

## ⭐ Script Quality Metrics

### Code Quality Improvements (v5.3.1+)
- **Unused Variables**: 100% eliminated
- **Code Duplication**: Significantly reduced
- **Error Handling**: Enhanced throughout all scripts
- **Configuration**: External configuration file support
- **Maintainability**: Improved modular structure
- **Prompt System**: 55% code reduction with improved performance

### Script Improvements
- **check-project.sh**: Enhanced CLI options, configuration files, improved security
- **install-deps.sh**: Eliminated duplication, shared functions, better error handling
- **install-plugins.sh**: External configuration, plugin listing, customization
- **quick-install.sh**: Configurable URLs, configuration files, enhanced error handling
- **release.sh**: Automatic version detection, git integration, improved management
- **status.sh**: Already excellent performance and user experience
- **test.sh**: Already excellent testing framework
- **themes/prompt.zsh**: Simplified from 280 to 125 lines, improved performance and maintainability

## 🔄 Version History

### v5.3.1 (Current)
- 🧹 **Prompt System Simplification** - Streamlined `themes/prompt.zsh` from 280 to 125 lines (55% reduction)
- ⚡ **Enhanced Performance** - Optimized prompt rendering and cleanup operations
- 🔧 **Code Quality** - Removed redundant loops, simplified validation logic
- 🎯 **Better Maintainability** - Clean, readable code with improved error handling
- 📊 **Technical Improvements** - Dynamic path resolution, streamlined theme management

### v5.3.0
- ⭐ **Script Quality Upgrade** - Comprehensive improvements to all scripts for better maintainability and user experience
- ⚙️ **Configuration Files** - External configuration support for all major scripts
- 🔧 **Code Quality** - Eliminated duplication, removed unused variables, improved maintainability
- 🎛️ **Enhanced Options** - New CLI options and configuration capabilities
- 📁 **New Templates** - Configuration file examples and templates

### v5.2.0
- 🚀 Complete rewrite with modular architecture
- 📊 Comprehensive testing framework
- 🔄 Automated update system
- 🛡️ Security scanning and validation
- 📚 Professional documentation
- 🔧 CI/CD pipeline integration

### v4.x.x
- Performance optimizations
- Plugin management improvements
- Theme system enhancements

### v3.x.x
- Initial modular design
- Basic testing framework
- Status monitoring system

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **zinit** - Fast plugin manager
- **oh-my-posh** - Beautiful prompt themes
- **fzf** - Fuzzy finder
- **zoxide** - Smart directory navigation
- **eza** - Enhanced ls command

## 📞 Support

- **GitHub Issues**: [Report bugs](https://github.com/windyboy/zsh/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/windyboy/zsh/discussions)
- **Documentation**: Complete guides in this repository

---

<div align="center">

**Made with ❤️ for the ZSH community**

[![Stars](https://img.shields.io/github/stars/windyboy/zsh?style=social)](https://github.com/windyboy/zsh)
[![Forks](https://img.shields.io/github/forks/windyboy/zsh?style=social)](https://github.com/windyboy/zsh)

</div>
