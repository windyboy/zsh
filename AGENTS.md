# Agent Guidelines for ZSH Configuration Repository

## Build/Lint/Test Commands

### Testing (Run Single Test)
- **All tests**: `./test.sh all`
- **Single test type**: `./test.sh unit|integration|performance|plugins|validation|conflicts|security`
- **Test help**: `./test.sh --help` for usage information

### Validation & Health Checks
- **Project health**: `./check-project.sh` (full validation suite)
- **Quick health**: `./check-project.sh --skip-syntax --skip-security`
- **Status check**: `./status.sh` (system status and diagnostics)
- **Syntax validation**: `zsh -n <file>` (individual file syntax check)
- **ShellCheck**: Run on scripts (automated in CI)

### CI/CD Pipeline
- **Linting**: ShellCheck via GitHub Actions (`.github/workflows/test.yml`)
- **Security**: TruffleHog secret scanning (GitHub Actions)
- **Testing**: Ubuntu & macOS matrix testing (GitHub Actions)
- **Performance**: Startup time benchmarks (< 5s in CI)
- **Documentation**: README, CHANGELOG, REFERENCE validation

### Development Commands
- **Install dependencies**: `./install-deps.sh`
- **Install plugins**: `./install-plugins.sh install`
- **Install themes**: `./install-themes.sh install`
- **Quick install**: `./quick-install.sh` (one-command setup)
- **Update system**: `./update.sh` (update all components)
- **Release process**: `./release.sh` (version tagging)

## Architecture & Codebase Structure

### Directory Layout
- **`modules/`** - Core configuration modules (`.zsh` files)
  - `lib/validation.zsh` - Shared validation utilities
  - `core.zsh` - Base environment, directories, history
  - `aliases.zsh` - Command aliases
  - `plugins.zsh` - Plugin management via zinit
  - `completion.zsh` - ZSH completion system setup
  - `keybindings.zsh` - Vi/Emacs key bindings
  - `utils.zsh` - Utility functions (mkcd, trash, extract)
  - `path.zsh` - PATH management and cleanup
  - `colors.zsh` - Color definitions for output
  - `navigation.zsh` - Directory navigation helpers
- **`themes/`** - Oh My Posh theme management
  - `prompt.zsh` - Prompt configuration
  - `theme-preference` - Theme selection file
- **`plugins/`** - Plugin registry files
  - `core.list` - Essential plugins
  - `optional.list` - Optional plugins
- **`scripts/`** - Installation and utility scripts
  - `lib/logging.sh` - Shared logging functions
- **`completions/`** - ZSH completion definitions
- **`env/`** - Environment variable management
  - `templates/environment.env.template` - Environment template
- **`.github/workflows/`** - CI/CD pipeline definitions
  - `test.yml` - Main test workflow

### Configuration Files
- **`zshrc`** - Main configuration entry point
- **`zshenv`** - Environment setup (sourced before zshrc)
- **`.zsh-install.conf.example`** - Installation configuration template
- **`.check-project.conf.example`** - Health check configuration template
- **`plugins.conf.example`** - Plugin configuration template

## Code Style Guidelines

### File Structure
- **Shebang**: `#!/usr/bin/env zsh` for .zsh files, `#!/usr/bin/env bash` for .sh files
- **Header comments**: Descriptive headers with file purpose, version, and description
- **Modular organization**: Separate concerns into dedicated modules in `modules/` directory
- **Configuration files**: External config support via `.conf` files with `.example` templates
- **Function organization**: Group related functions with section comments
- **Error handling**: Functions should return appropriate exit codes (0 for success, non-zero for failure)

### Naming Conventions
- **Functions**: snake_case (e.g., `safe_source`, `core_init_dirs`, `validation_run`)
- **Variables**: UPPER_CASE for globals, lower_case for locals, prefix with `__` for internal
- **Files**: kebab-case for scripts, snake_case for modules, .zsh for ZSH, .sh for bash
- **Aliases**: Short, memorable names (e.g., `ll`, `la`, `gst`)
- **Arrays**: Use descriptive plural names (e.g., `config_files`, `plugin_dirs`)
- **Integer variables**: Declare with `typeset -gi` for global integers

### Code Style
- **Error handling**: Use `safe_source()` function for file loading with fallback
- **Security**: umask 022, safe file operations (rm/cp/mv with -i), no world-writable files
- **Permissions**: Files should be 644 or 600, scripts should be 755
- **Validation**: Use shared validation helpers from `modules/lib/validation.zsh`
- **Color output**: Use color functions (color_red, color_green, etc.) with fallback
- **Comments**: No inline comments unless explaining complex logic; use section headers
- **Imports**: Source dependencies at top of files; check for circular dependencies
- **Portability**: Avoid hardcoded paths; use `$HOME`, `$ZSH_CONFIG_DIR`, etc.
- **Platform detection**: Use `[[ "$OSTYPE" == *"darwin"* ]]` for macOS, `[[ "$OSTYPE" == *"linux"* ]]` for Linux

### Shell Options (Set in core.zsh)
- **Core options**: `AUTO_PARAM_KEYS`, `INTERACTIVE_COMMENTS`, `EXTENDED_GLOB`
- **Safety options**: `NO_CLOBBER`, `RM_STAR_WAIT`, `PIPE_FAIL`, `NO_BG_NICE`
- **Disabled options**: `BEEP`, `CASE_GLOB`, `FLOW_CONTROL`, `HUP`
- **Completion options**: `AUTO_LIST`, `AUTO_MENU`, `AUTO_PARAM_SLASH`, `COMPLETE_IN_WORD`
- **History options**: `SHARE_HISTORY`, `EXTENDED_HISTORY`, `HIST_IGNORE_DUPS`

### Function Design Patterns
- **Input validation**: Check arguments at function start
- **Error messages**: Use color-coded output with clear descriptions
- **Return values**: Return 0 for success, non-zero for failure
- **Local variables**: Declare locals with `local` keyword
- **Array handling**: Use `"${array[@]}"` for proper expansion
- **Command substitution**: Use `$(command)` not backticks
- **Conditional execution**: Use `[[ ... ]]` for tests, `(( ... ))` for arithmetic

### Best Practices
- **Modular design**: Keep functions focused and reusable (single responsibility)
- **Error handling**: Comprehensive error checking and fallback behavior
- **Performance**: Optimize for fast startup (< 500ms cold start, < 5s in CI)
- **Compatibility**: Support multiple platforms (macOS, Linux, WSL)
- **Documentation**: Update README, REFERENCE.md, and CHANGELOG.md for changes
- **Testing**: Write tests for new functionality in `test.sh`
- **Security**: Never hardcode secrets; use environment variables or config files
- **Portability**: Use POSIX-compatible constructs when possible
- **Memory usage**: Keep memory footprint low (< 50MB typical)

### Testing Guidelines
- **Unit tests**: Test individual functions and modules
- **Integration tests**: Test module interactions and configuration loading
- **Performance tests**: Measure startup time and memory usage
- **Plugin tests**: Verify plugin manager functionality
- **Validation tests**: Check configuration integrity
- **Conflict tests**: Detect duplicate aliases/functions
- **Security tests**: Verify file permissions and security practices

### Git & Version Control
- **Commit messages**: Use conventional commits format
- **Branching**: `main` for stable, `develop` for development
- **Tags**: Semantic versioning (v1.2.3)
- **Changelog**: Keep CHANGELOG.md updated with all changes
- **Releases**: Use `release.sh` for consistent release process

### Agent-Specific Guidelines
- **Before editing**: Run `./check-project.sh` to ensure clean state
- **After editing**: Run `./test.sh all` to verify changes don't break functionality
- **New features**: Add corresponding tests in `test.sh`
- **Configuration changes**: Update example config files if needed
- **Documentation**: Update REFERENCE.md for new configuration options
- **Performance**: Verify startup time doesn't regress
- **Security**: Never introduce hardcoded secrets or insecure patterns</content>
<parameter name="filePath">/home/windy/.config/zsh/AGENTS.md