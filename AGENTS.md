# Agent Guidelines for ZSH Configuration Repository

## Build/Lint/Test Commands

### Testing
- **All tests**: `./test.sh all`
- **Unit tests**: `./test.sh unit`
- **Integration tests**: `./test.sh integration`
- **Performance tests**: `./test.sh performance`
- **Plugin tests**: `./test.sh plugins`
- **Validation tests**: `./test.sh validation`
- **Conflict tests**: `./test.sh conflicts`
- **Security tests**: `./test.sh security`

### Validation & Health Checks
- **Project health check**: `./check-project.sh`
- **Configuration validation**: `./validate.sh`
- **Status check**: `./status.sh`
- **Syntax validation**: `zsh -n <file>`

### CI/CD
- **Linting**: ShellCheck (via GitHub Actions)
- **Security scanning**: TruffleHog (via GitHub Actions)
- **Cross-platform testing**: Ubuntu & macOS (via GitHub Actions)

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