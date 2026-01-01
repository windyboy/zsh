# Agent Guidelines for ZSH Configuration Repository

## Build/Lint/Test Commands

### Testing (Run Single Test)
- **All tests**: `./test.sh all`
- **Single test type**: `./test.sh unit|integration|performance|plugins|validation|conflicts|security`

### Validation & Health Checks
- **Project health**: `./check-project.sh`
- **Configuration**: `./validate.sh`
- **Status**: `./status.sh`
- **Syntax**: `zsh -n <file>`

### CI/CD
- **Linting**: ShellCheck (GitHub Actions)
- **Security**: TruffleHog (GitHub Actions)
- **Testing**: Ubuntu & macOS (GitHub Actions)

## Architecture & Codebase Structure

### Directory Layout
- **`modules/`** - Core configuration modules (core.zsh, aliases.zsh, plugins.zsh, completion.zsh, keybindings.zsh, path.zsh, utils.zsh, colors.zsh, navigation.zsh, lib/)
- **`themes/`** - Oh My Posh theme management
- **`plugins/`** - Plugin registry files (core.list, optional.list)
- **`scripts/`** - Installation and utility scripts
- **`completions/`** - ZSH completion definitions
- **`env/`** - Environment variable management

### Core Modules
- **core.zsh** - Base environment, directories, history
- **plugins.zsh** - Plugin management via zinit
- **completion.zsh** - ZSH completion system setup
- **aliases.zsh** - Command aliases
- **keybindings.zsh** - Vi/Emacs key bindings
- **utils.zsh** - Utility functions (mkcd, trash, extract)
- **path.zsh** - PATH management and cleanup
- **colors.zsh** - Color definitions for output
- **navigation.zsh** - Directory navigation helpers

## Code Style Guidelines

### File Structure
- **Shebang**: `#!/usr/bin/env zsh` for .zsh files
- **Header comments**: Descriptive headers with file purpose
- **Modular organization**: Separate modules in `modules/` directory
- **Configuration files**: External config support via `.conf` files

### Naming Conventions
- **Functions**: snake_case (e.g., `safe_source`, `core_init_dirs`)
- **Variables**: UPPER_CASE for globals, lower_case for locals
- **Files**: kebab-case for scripts, snake_case for modules
- **Aliases**: Short, memorable names

### Code Style
- **Error handling**: Use `safe_source()` function for file loading
- **Security**: umask 022, safe file operations (rm/cp/mv with -i)
- **Permissions**: Files should be 644 or 600, never world-writable
- **Validation**: Use shared validation helpers from `modules/lib/validation.zsh`
- **Color output**: Use color functions (color_red, color_green, etc.)
- **Comments**: No inline comments unless explaining complex logic
- **Imports**: Source dependencies at top of files

### Shell Options
- **Core options**: `AUTO_PARAM_KEYS`, `INTERACTIVE_COMMENTS`
- **Safety options**: `NO_CLOBBER`, `RM_STAR_WAIT`, `PIPE_FAIL`
- **Disabled options**: `BEEP`, `CASE_GLOB`, `FLOW_CONTROL`

### Best Practices
- **Modular design**: Keep functions focused and reusable
- **Error handling**: Comprehensive error checking and fallback behavior
- **Performance**: Optimize for fast startup (< 500ms cold start)
- **Compatibility**: Support multiple platforms (macOS, Linux, WSL)
- **Documentation**: Update README and REFERENCE.md for changes</content>
<parameter name="filePath">/home/windy/.config/zsh/AGENTS.md