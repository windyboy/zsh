# 🚀 ZSH Configuration v5.0.0

> **High-performance, modular ZSH configuration system** with comprehensive testing, automated updates, and professional CI/CD pipeline.

[![CI/CD](https://github.com/yourusername/zsh-config/workflows/Test%20ZSH%20Configuration/badge.svg)](https://github.com/yourusername/zsh-config/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![ZSH Version](https://img.shields.io/badge/zsh-5.8+-green.svg)](https://www.zsh.org/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL-blue.svg)]()

## ✨ Features

| Category | Features |
|----------|----------|
| **🚀 Performance** | Lightning-fast startup, optimized modules, intelligent caching |
| **🎨 Interface** | Beautiful English UI, color-coded output, progress indicators |
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
<<<<<<< HEAD
- **ZSH**: Version 5.8 or higher
- **Git**: For plugin management and updates
=======
- **ZSH**: Version 5.8 or higher (the configuration checks this on startup)
- **Git**: For plugin management
>>>>>>> ac16eed89bb6d528f3565da520287a46f6fd429e

### Optional Dependencies (Recommended)
- **fzf**: Fuzzy file finder
- **zoxide**: Smart directory navigation  
- **eza**: Enhanced ls command
- **oh-my-posh**: Theme system
- **curl/wget**: Network tools

## 🚀 Quick Start

### One-Command Installation (Recommended)

```bash
# Quick install with automatic setup
curl -fsSL https://raw.githubusercontent.com/yourusername/zsh-config/main/quick-install.sh | bash
```

### Manual Installation

```bash
# 1. Clone repository
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh
cd ~/.config/zsh

# 2. Run installation
./install.sh --interactive

# 3. Restart terminal
exec zsh
```

## 📦 Installation Methods

### Method 1: Quick Install Script

The `quick-install.sh` script provides a complete one-command installation:

```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/yourusername/zsh-config/main/quick-install.sh | bash

# Or clone and run locally
git clone https://github.com/yourusername/zsh-config.git
cd zsh-config
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
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh
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

<<<<<<< HEAD
Create `~/.config/zsh/custom/local.zsh` for personal settings:
=======
### 自定义配置
```bash
config zshrc    # 编辑主配置
config core     # 编辑核心模块
config plugins  # 编辑插件模块
config aliases  # 编辑别名模块
config env      # 编辑环境配置
```

### 环境变量配置

本项目采用简化的环境变量配置方式：
- **核心环境变量**：在 `zshenv` 中直接设置（XDG路径、ZSH路径、历史记录等）
- **插件环境变量**：在 `modules/plugins.zsh` 中管理（ZSH自动建议配置等）
- `ZSH_ENABLE_PLUGINS` 控制是否加载所有插件
- `ZSH_ENABLE_OPTIONAL_PLUGINS` 控制可选插件（如 fzf-tab）
- **主题环境变量**：在 `themes/prompt.zsh` 中管理（Oh My Posh配置等）
- **用户环境变量**：使用模板化管理（开发工具路径、包管理器镜像等）

#### 初始化配置（首次使用）
```bash
# 进入环境配置目录
cd ~/.config/zsh/env

# 运行初始化脚本
./init-env.sh
```

#### 迁移旧配置（如果已有配置）
```bash
# 进入环境配置目录
cd ~/.config/zsh/env

# 运行迁移脚本
./migrate-env.sh
```

#### 编辑配置
```bash
# 编辑用户环境配置
${EDITOR:-code} ~/.config/zsh/env/local/environment.env
```

#### 配置说明
- **模板文件**：`env/templates/environment.env.template` - 不要直接修改
- **本地配置**：`env/local/environment.env` - 可以自由修改
- **自动加载**：配置文件会自动加载，无需额外操作

#### 故障排除
如果配置更改后没有生效，可能的原因和解决方案：
>>>>>>> ac16eed89bb6d528f3565da520287a46f6fd429e

```bash
# Personal aliases
alias ll='ls -la'
alias la='ls -A'

# Custom functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Environment variables
export MY_CUSTOM_VAR="value"
```

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
perf --monitor  # Continuous monitoring
perf --optimize # Optimization suggestions
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
```

**Health Check Features:**
- 📁 File structure validation
- 🔐 Script permissions check
- 🔍 Syntax validation
- ⚙️ Configuration validation
- 🧩 Module validation
- 📚 Documentation check
- 🔒 Security scan
- ⚡ Performance check

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
zsh-config/
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

# Optimize configuration
./optimize.sh
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

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation
- **[Configuration Guide](docs/CONFIGURATION.md)** - Advanced configuration
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues
- **[Development Guide](docs/DEVELOPMENT.md)** - Contributing guidelines

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

## 🔄 Version History

### v5.0.0 (Current)
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

- **GitHub Issues**: [Report bugs](https://github.com/yourusername/zsh-config/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/yourusername/zsh-config/discussions)
- **Documentation**: [Complete guides](docs/)

---

<div align="center">

**Made with ❤️ for the ZSH community**

[![Stars](https://img.shields.io/github/stars/yourusername/zsh-config?style=social)](https://github.com/yourusername/zsh-config)
[![Forks](https://img.shields.io/github/forks/yourusername/zsh-config?style=social)](https://github.com/yourusername/zsh-config)

</div> 