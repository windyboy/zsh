# ZSH Configuration Project - QWEN Context

## Project Overview

This is a comprehensive, high-performance ZSH configuration system with modular architecture, automated testing, and professional CI/CD pipeline. The project provides a complete shell environment with themes, plugins, and utilities designed for developers.

**Project Type**: ZSH Shell Configuration Framework  
**Version**: 5.3.1  
**Architecture**: Modular, cross-platform compatible  

## Key Features

- **Lightning-fast startup** with optimized modules and intelligent caching
- **Modular design** with clean separation of concerns
- **Comprehensive testing** framework with unit, integration, and performance tests
- **Automatic plugin management** with zinit as the plugin manager
- **Beautiful UI** with Oh My Posh theme system and color-coded output
- **Cross-platform support** (macOS, Linux, WSL)
- **Security scanning** and vulnerability detection
- **Performance monitoring** with real-time metrics

## Directory Structure

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
│   ├── colors.zsh       # Color definitions
│   └── lib/             # Shared libraries
├── themes/               # Theme collection
│   ├── prompt.zsh       # Oh My Posh integration
│   └── theme-preference # Current theme preference
├── completions/          # Completion scripts
├── env/                  # Environment management
├── scripts/              # Utility scripts
├── plugins/              # Plugin registry files
│   ├── core.list        # Core plugins
│   └── optional.list    # Optional plugins
├── install.sh            # Main installation script
├── status.sh             # System status checker
├── test.sh               # Test suite
├── check-project.sh      # Project health checker
├── install-deps.sh       # Dependency installer
├── install-plugins.sh    # Plugin installer
├── install-themes.sh     # Theme installer
├── quick-install.sh      # One-command installer
└── update.sh             # Update script
```

## Building and Running

### Installation Methods

1. **Quick Install** (Recommended):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/windyboy/zsh/main/quick-install.sh | bash
   ```

2. **Manual Installation**:
   ```bash
   git clone https://github.com/windyboy/zsh.git ~/.config/zsh
   cd ~/.config/zsh
   ./install-deps.sh
   ./install.sh --interactive
   exec zsh
   ```

3. **Interactive Installation**:
   ```bash
   ./install.sh --interactive
   ```

### Core Commands

- `status` - Comprehensive system status
- `reload` - Reload configuration
- `validate` - Validate configuration
- `version` - Show version information
- `perf` - Performance metrics
- `plugins` - List installed plugins
- `plugins_update` - Update all plugins
- `plugins_clean` - Clean unused plugins

### Configuration Management

The `config` command provides a unified interface for all configuration management:

```bash
config zshrc      # Edit main configuration file
config zshenv     # Edit environment variables
config core       # Edit core module
config plugins    # Edit plugins module
config aliases    # Edit aliases module
config completion # Edit completion module
config keybindings # Edit keybindings module
config utils      # Edit utils module
config env        # Edit user environment variables
```

## Development Conventions

### Module Structure

Each module follows a consistent structure:
- Header with description and version
- Color output tools loading
- Security settings
- Core functionality
- Error handling
- Common functions

### Plugin Management

- Core plugins are defined in `plugins/core.list`
- Optional plugins are defined in `plugins/optional.list`
- Uses zinit as the plugin manager
- Automatic plugin installation when missing
- Lazy loading for performance

### Theme System

- Uses Oh My Posh for theme management
- Themes stored in `~/.poshthemes/`
- Theme preference saved in `themes/theme-preference`
- Interactive theme selector with `change_theme` or `ct`

### Testing Framework

The project includes a comprehensive test suite:
- Unit tests for basic functionality
- Integration tests for system components
- Performance tests for startup time and memory usage
- Plugin tests for plugin manager functionality
- Security tests for potential vulnerabilities
- Validation checks for configuration integrity

Run tests with:
```bash
./test.sh all           # Run all tests
./test.sh unit          # Run unit tests
./test.sh performance   # Run performance tests
./test.sh plugins       # Run plugin tests
```

### Performance Metrics

- **Cold Start**: < 500ms
- **Warm Start**: < 200ms
- **Module Load**: < 100ms
- **Base Load**: < 5MB memory
- **Full Load**: < 10MB memory
- **Peak Usage**: < 15MB memory

### Environment Variables

- `ZSH_CONFIG_DIR` - Configuration directory (default: `~/.config/zsh`)
- `ZSH_CACHE_DIR` - Cache directory (default: `~/.cache/zsh`)
- `ZSH_DATA_DIR` - Data directory (default: `~/.local/share/zsh`)
- `ZSH_ENABLE_PLUGINS` - Enable/disable plugin loading (default: 0, set to 1 in `env/local/environment.env`)
- `ZSH_DEBUG` - Enable debug mode (default: 0)

## Key Scripts and Their Functions

- `install.sh` - Main installation with dependency checking and configuration setup
- `status.sh` - Beautiful status output with progress indicators and metrics
- `test.sh` - Comprehensive test suite with multiple test categories
- `check-project.sh` - Project health validation with security and syntax checks
- `install-deps.sh` - System dependency installation
- `install-plugins.sh` - Plugin registry management
- `install-themes.sh` - Oh My Posh theme installation
- `quick-install.sh` - One-command installation script

## Troubleshooting

### Common Issues

1. **Slow startup**: Check with `perf --startup` to identify slow modules
2. **Plugin conflicts**: Run `check_plugin_conflicts` to detect issues
3. **Configuration errors**: Use `validate` to check for problems
4. **Theme issues**: Use `posh_themes` to list available themes

### Debugging

Enable debug mode:
```bash
export ZSH_DEBUG=1
source ~/.config/zsh/zshrc
```

Run verbose validation:
```bash
validate --verbose
```

Check detailed status:
```bash
./status.sh --verbose
```

## Security Features

- Safe file operations with extra protections for `rm`
- Secure umask settings (022)
- No command and argument spelling correction to avoid prompts
- Security scanning in CI/CD pipeline
- Validation of theme files to prevent malicious content
- File permission checks

## Performance Optimizations

- Lazy loading of heavy tools (NVM, bun)
- Asynchronous syntax highlighting
- Optimized completion system
- Efficient PATH management
- Plugin loading optimizations
- Memory usage monitoring