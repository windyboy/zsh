# Environment Variables Configuration Guide

## Overview

This project uses a simplified environment variable configuration approach. Core environment variables are managed directly in configuration scripts, while only user-specific environment variables use template-based configuration.

## File Structure

```
env/
├── templates/                    # Environment variable template files
│   └── environment.env.template # User environment configuration template
├── local/                       # User actual configuration files (copied from templates)
│   └── environment.env          # User actual environment configuration
├── init-env.sh                  # Initialization script
├── migrate-env.sh               # Migration script
├── README.md                    # This documentation file
└── .gitignore                   # Git ignore file
```

## Configuration Categories

### 1. Core Environment Variables (set directly in zshenv)
- XDG base directory configuration
- ZSH path configuration
- History settings
- Terminal configuration
- Basic tool configuration

### 2. Plugin Environment Variables (managed in modules/plugins.zsh)
- ZSH autosuggestion configuration
- Other plugin-related configurations
- `ZSH_ENABLE_PLUGINS`: Whether to load all plugins (1/0)
- `ZSH_ENABLE_OPTIONAL_PLUGINS`: Whether to load optional plugins (like fzf-tab)

### 3. Theme Environment Variables (managed in themes/prompt.zsh)
- Oh My Posh configuration
- Other theme-related configurations

### 4. User Environment Variables (template-managed)
- Development tool installation paths
- Package manager mirror configurations
- Personal custom configurations

## Usage

### 1. Initialize Configuration

When using for the first time, you need to create actual configuration files from templates:

```bash
# Navigate to environment configuration directory
cd ~/.config/zsh/env

# Run initialization script
./init-env.sh
```

### 2. Customize Configuration

Edit the local configuration file and modify the corresponding values according to your actual environment:

```bash
# Edit user environment configuration
${EDITOR:-code} local/environment.env
```

### 3. Enable Configuration

Configuration files are loaded automatically without additional operations. The system loads in the following order:

1. `zshenv` - Core environment variables
2. `env/local/environment.env` - User environment configuration (if exists)
3. `modules/` - Feature modules (including plugin and theme configurations)

**Important Note:** If an old `env/development.zsh` file exists, the system will prioritize loading it instead of `environment.env`. It's recommended to use the migration script to handle old configurations.

## Configuration Description

### environment.env - User Environment Configuration
Contains environment variables for various development tools such as Go, Rust, Flutter, Android SDK, etc.

Main configuration items:
- **Development Tool Paths**: GOPATH, GOROOT, ANDROID_HOME, etc.
- **Package Manager Mirrors**: Homebrew, Flutter, Rust mirror sources, etc.
- **Custom Configurations**: Personal workspace directories, project paths, etc.

## Important Notes

1. **Do not modify template files** - Template files are for version control, do not modify them directly
2. **Local files can be modified** - Files in the `local/` directory can be freely modified
3. **Backup important configurations** - It's recommended to regularly backup the `local/` directory
4. **Comment descriptions** - Each environment variable has detailed comments, please read carefully
5. **Old configuration files** - If `env/development.zsh` or `env/local.zsh` exists, it's recommended to migrate to the new system

## Troubleshooting

### Configuration Not Taking Effect

**Problem:** After editing `environment.env` and reloading configuration, changes don't take effect.

**Possible Causes:**
1. Old `env/development.zsh` file exists, system prioritizes loading it
2. Configuration file syntax error
3. File permission issues

**Solutions:**
```bash
# 1. Check if old configuration file exists
ls -la ~/.config/zsh/env/development.zsh

# 2. If exists, use migration script to handle
cd ~/.config/zsh/env
./migrate-env.sh

# 3. Or manually delete old file (already backed up)
rm ~/.config/zsh/env/development.zsh

# 4. Reload configuration
source ~/.config/zsh/zshrc

# 5. Verify environment variables
echo "GOPATH: $GOPATH"
echo "ANDROID_HOME: $ANDROID_HOME"
```

### Environment Variable Conflicts
```bash
# View current environment variables
env | grep -E "(GOPATH|ANDROID_HOME|BUN_INSTALL)"

# Check configuration file syntax
zsh -n ~/.config/zsh/env/local/environment.env
```

### Syntax Errors
```bash
# Check zshenv syntax
zsh -n ~/.config/zsh/zshenv

# Check module file syntax
zsh -n ~/.config/zsh/modules/plugins.zsh
zsh -n ~/.config/zsh/themes/prompt.zsh
```

## Migration Guide

### Migrate from Old Configuration

If you previously used `env/development.zsh` or `env/local.zsh`:

```bash
# 1. Run migration script
cd ~/.config/zsh/env
./migrate-env.sh

# 2. Check migration results
cat local/environment.env

# 3. Adjust configuration as needed
${EDITOR:-code} local/environment.env

# 4. Test configuration
source ~/.config/zsh/zshenv
```

## Update Templates

When template files are updated, you can manually merge changes:

```bash
# View template updates
diff templates/environment.env.template local/environment.env

# Manually merge changes to local configuration
```

## Contributing

Welcome to submit Issues and Pull Requests to improve template files! 