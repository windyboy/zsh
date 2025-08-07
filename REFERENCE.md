# Complete Reference Manual

## 🔧 System Management

```bash
status          # System status
reload          # Reload configuration
validate        # Validate configuration
version         # View version
```

## 🧪 Testing and Validation

### Automated Testing
```bash
./test.sh              # Run complete test suite
./test.sh unit         # Run unit tests only
./test.sh integration  # Run integration tests only
./test.sh performance  # Run performance tests only
./test.sh plugins      # Run plugin conflict tests only
./test.sh security     # Run security tests only
```

### Configuration Validation
```bash
validate                # Basic configuration validation
validate --verbose      # Detailed validation information
validate --fix          # Auto-fix common issues
validate --report       # Generate detailed validation report
```

## 📊 Performance Monitoring

```bash
perf                    # Display basic performance metrics
perf --monitor          # Start continuous performance monitoring
perf --profile          # Generate detailed performance analysis report
perf --optimize         # Display optimization suggestions
perf --history          # Display performance history
```

### Performance Metrics
- **Functions**: Number of functions (recommended <200)
- **Aliases**: Number of aliases (recommended <100)
- **Memory**: Memory usage (recommended <10MB)
- **Startup**: Startup time (recommended <2s)
- **Score**: Performance score (0-100)

## 🛠️ Utility Tools

### File Operations
```bash
mkcd <directory>     # Create directory and enter
up [levels]          # Navigate up directories
trash <file>         # Safely delete files
extract <file>       # Smart file extraction (supports multiple formats)
```

### PATH Management
```bash
show_path       # Display current PATH status
cleanup_path    # Clean invalid and duplicate paths
reload_path     # Reload PATH configuration
add_path <path> # Add path to PATH
remove_path <path> # Remove path from PATH
path-status     # PATH status alias
path-clean      # PATH cleanup alias
path-reload     # PATH reload alias
```

### Network Tools
```bash
serve [port] [directory] # Start HTTP server
myip            # View external IP
```

### Development Tools
```bash
g               # Git quick operations
ni              # npm install
py              # python3
```

### File Extraction
```bash
extract <file>  # Smart extraction, supports multiple formats
# Supported formats: tar.gz, tar.bz2, tar.xz, zip, rar, 7z, cab, iso, etc.
```

## 🔌 Plugin Management

```bash
plugins         # Plugin status
```

## ⚙️ Configuration Management

```bash
config <file>   # Edit configuration file
```

### Editable Configuration Files
- `zshrc` - Main configuration file
- `core` - Core module
- `plugins` - Plugin module
- `completion` - Completion module
- `aliases` - Alias module
- `keybindings` - Key binding module
- `utils` - Utility module

## 🔧 Environment Variables

### Core Variables
```bash
export ZSH_CONFIG_DIR="$HOME/.config/zsh"
export ZSH_CACHE_DIR="$HOME/.cache/zsh"
export ZSH_DATA_DIR="$HOME/.local/share/zsh"
```

### PATH Management Variables
```bash
export PATH_MANAGEMENT_ENABLED=1    # Enable PATH management
export PATH_DEBUG=0                 # PATH debug mode
export PATH_AUTO_CLEANUP=1          # Auto-cleanup invalid paths
```

### Debug Variables
```bash
export ZSH_DEBUG=1    # Enable debug mode
export ZSH_VERBOSE=1  # Enable verbose output
export ZSH_QUIET=1    # Silent mode
```

## 📁 Important Files

### Configuration Files
- `~/.config/zsh/zshrc` - Main configuration
- `~/.config/zsh/zshenv` - Environment variables
- `~/.config/zsh/modules/` - Module directory

### Cache Files
- `~/.cache/zsh/zcompdump` - Completion cache

### Data Files
- `~/.local/share/zsh/history` - Command history

## 🚨 Troubleshooting

### Slow Startup
```bash
# Check startup time
time zsh -c "source ~/.zshrc; exit"

# Check status
status
```

**Solutions**:
- Disable heavy plugins: Edit `modules/plugins.zsh`
- Optimize completion cache: `rm ~/.cache/zsh/zcompdump*`
- Check module loading: `validate`

### Configuration Errors
```bash
# Validate configuration
validate
status
```

**Solutions**:
- Check file permissions: `ls -la ~/.config/zsh/`
- Reinstall configuration: Backup and re-clone repository
- Check core files: Verify `zshrc` and module files exist

### Plugin Issues
```bash
# Check plugin status
plugins

# Reload plugins
reload
```

**Solutions**:
- Reload plugins: `reload`
- Disable problematic plugins: Edit `modules/plugins.zsh`

### Slow Command Execution
```bash
# Check hook performance
add-zsh-hook -L precmd

# Test command execution
time ls -la
```

**Solutions**:
- Reduce hook count: Check `precmd` hooks
- Optimize PATH: `typeset -U path`
- Check plugin performance: Monitor plugin loading time

## 🔧 Development Guide

### Development Environment
```bash
# Enable debug mode
export ZSH_DEBUG=1
export ZSH_VERBOSE=1
exec zsh
```

### Module Development
```bash
# Create new module
touch modules/new_module.zsh
```

### Module Template
```bash
#!/usr/bin/env zsh
# =============================================================================
# New Module - Description
# Version: 4.2
# =============================================================================

# Environment setup
export NEW_MODULE_ENABLED="${NEW_MODULE_ENABLED:-1}"

# Core functions
new_module_function() {
    # Function implementation
    echo "New module function called"
}
```

## 📊 Current Status

### Module Statistics
- **Total Lines**: 604 lines
- **Module Count**: 6 core modules
- **Version**: 4.2.3

### Core Modules
- `core.zsh` (94 lines) - Core environment setup
- `aliases.zsh` (95 lines) - Aliases and shortcuts
- `plugins.zsh` (95 lines) - Plugin management
- `completion.zsh` (119 lines) - Auto-completion
- `keybindings.zsh` (116 lines) - Key bindings
- `utils.zsh` (85 lines) - Utility tools

---

**Last Updated**: 2024-12-19  
**Status**: Production Ready ✅ 