# Oh My Posh Theme Configuration Guide

This guide explains how to configure Oh My Posh themes in your modular zsh configuration.

## 🚀 Quick Setup

### 1. Install Oh My Posh

**macOS (using Homebrew):**
```bash
brew install oh-my-posh
```

**Linux:**
```bash
# Download and install
curl -s https://ohmyposh.dev/install.sh | bash -s
```

**Windows:**
```powershell
winget install JanDeDobbeleer.OhMyPosh
```

### 2. Install Official Themes

```bash
# Install all official themes
oh-my-posh theme install

# Or install specific themes
oh-my-posh theme install agnoster
oh-my-posh theme install atomic
oh-my-posh theme install catppuccin
```

### 3. Switch Themes

Your zsh configuration is already set up to use Oh My Posh! To switch themes:

```bash
# List available themes
posh_themes

# Switch to a specific theme
posh_theme agnoster
posh_theme atomic
posh_theme catppuccin
posh_theme dracula
posh_theme gruvbox
posh_theme jandedobbeleer
posh_theme m365princess
posh_theme paradox
posh_theme robbyrussell
posh_theme star
posh_theme tokyonight

# Reload your shell to apply changes
source ~/.zshrc
```

## 🎨 Popular Official Themes

### Classic Themes
- **agnoster** - Classic powerline style (default)
- **robbyrussell** - Oh My Zsh style
- **paradox** - Clean and modern

### Color Scheme Themes
- **catppuccin** - Catppuccin color palette
- **dracula** - Dracula color scheme
- **gruvbox** - Gruvbox colors
- **tokyonight** - Tokyo Night theme

### Modern Themes
- **atomic** - Modern atomic design
- **blueish** - Blue color scheme
- **jandedobbeleer** - Author's personal theme
- **m365princess** - Princess theme
- **star** - Star-themed design

## 🔧 Available Commands

### Theme Management
```bash
posh_themes          # List installed themes
posh_theme_list      # List all available themes
posh_theme_install   # Install official themes
posh_theme <name>    # Switch to a theme
```

### Manual Theme Switching
You can also manually edit `~/.config/zsh/themes/prompt.zsh` and change the theme line:

```bash
# Change this line in the file:
eval "$(oh-my-posh init zsh --config ~/.poshthemes/agnoster.omp.json)"

# To any other theme, for example:
eval "$(oh-my-posh init zsh --config ~/.poshthemes/catppuccin.omp.json)"
```

## 📁 File Structure

```
~/.config/zsh/
├── themes/
│   └── prompt.zsh          # Oh My Posh configuration
└── zshrc                   # Main config (loads prompt.zsh)

~/.poshthemes/              # Official themes directory
├── agnoster.omp.json
├── atomic.omp.json
├── catppuccin.omp.json
└── ... (other themes)
```

## 🎯 Current Configuration

Your configuration automatically:
- ✅ Checks if Oh My Posh is installed
- ✅ Uses the `agnoster` theme by default
- ✅ Falls back to a custom prompt if Oh My Posh is not available
- ✅ Provides easy theme switching commands
- ✅ Maintains compatibility with your modular zsh setup
- ✅ Optimized git status checks (only runs in git repositories)
- ✅ Performance-optimized prompt rendering

## 🔄 Reloading Configuration

After changing themes, reload your configuration:

```bash
# Method 1: Reload zshrc
source ~/.zshrc

# Method 2: Use the built-in reload function
zsh-reload

# Method 3: Start a new shell
exec zsh
```

## 🐛 Troubleshooting

### Oh My Posh Not Found
```bash
# Check if installed
which oh-my-posh

# Reinstall if needed
brew install oh-my-posh  # macOS
```

### Themes Not Available
```bash
# Install themes
posh_theme_install

# Or manually
oh-my-posh theme install
```

### Theme Not Applying
```bash
# Check theme file exists
ls ~/.poshthemes/agnoster.omp.json

# Reload configuration
source ~/.zshrc
```

### Performance Issues
```bash
# Check Oh My Posh performance
oh-my-posh debug

# Use a simpler theme if needed
posh_theme robbyrussell

# Check hook performance
add-zsh-hook -L precmd

# Optimize if needed
optimize_zsh_performance
```

## 📚 Additional Resources

- [Oh My Posh Official Documentation](https://ohmyposh.dev/)
- [Theme Gallery](https://ohmyposh.dev/docs/themes)
- [Theme Schema Reference](https://ohmyposh.dev/docs/configuration/overview)
- [Community Themes](https://github.com/JanDeDobbeleer/oh-my-posh/tree/main/themes)

## 🎉 Enjoy Your New Prompt!

Your zsh configuration now supports beautiful Oh My Posh themes while maintaining the modular architecture and performance optimizations of your existing setup. 