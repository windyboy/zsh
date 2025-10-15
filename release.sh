#!/usr/bin/env bash
# =============================================================================
# Release Script for ZSH Configuration
# Automated version tagging and release process
# =============================================================================
# shellcheck disable=SC2162

set -euo pipefail

# Shared logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/lib/logging.sh"

# Configuration
CURRENT_VERSION="${ZSH_VERSION:-5.3.0}"
RELEASE_DATE=$(date +%Y-%m-%d)

# Load version from git if available
if command -v git >/dev/null 2>&1 && [[ -d ".git" ]]; then
    GIT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
    if [[ -n "$GIT_VERSION" ]]; then
        CURRENT_VERSION="$GIT_VERSION"
    fi
fi

# Check if running in git repository
check_git_repo() {
    if [[ ! -d ".git" ]]; then
        error "Not a git repository. Please run this script from the project root."
        exit 1
    fi
}

# Check if git is clean
check_git_status() {
    if [[ -n "$(git status --porcelain)" ]]; then
        warning "Git working directory is not clean."
        echo "Uncommitted changes:"
        git status --short
        read -p "Continue anyway? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Run pre-release checks
run_pre_release_checks() {
    log "Running pre-release checks..."
    
    # Check project health
    if ! ./check-project.sh >/dev/null 2>&1; then
        error "Project health check failed"
        exit 1
    fi
    
    # Run tests
    if ! ./test.sh all >/dev/null 2>&1; then
        error "Test suite failed"
        exit 1
    fi
    
    # Check for critical files
    local critical_files=(
        "README.md"
        "install.sh"
        "status.sh"
        "test.sh"
        "update.sh"
        "quick-install.sh"
        "check-project.sh"
        "zshrc"
        "zshenv"
        "LICENSE"
    )
    
    for file in "${critical_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Critical file missing: $file"
            exit 1
        fi
    done
    
    success "Pre-release checks passed"
}

# Update version in files
update_version() {
    local new_version="$1"
    log "Updating version to $new_version..."
    
    # Portable sed in-place replacement function
    portable_sed() {
        local pattern="$1"
        local file="$2"
        local temp_file="${file}.tmp.$$"
        
        if sed "$pattern" "$file" > "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$file"
            return 0
        else
            rm -f "$temp_file"
            return 1
        fi
    }
    
    # Update README.md
    if [[ -f "README.md" ]]; then
        portable_sed "s/ZSH Configuration v[0-9]\+\.[0-9]\+\.[0-9]\+/ZSH Configuration v$new_version/g" README.md
    fi
    
    # Update install.sh if it has version
    if [[ -f "install.sh" ]]; then
        portable_sed "s/Version: [0-9]\+\.[0-9]\+\.[0-9]\+/Version: $new_version/g" install.sh 2>/dev/null || true
        portable_sed "s/VERSION=\"[0-9]\+\.[0-9]\+\.[0-9]\+\"/VERSION=\"$new_version\"/g" install.sh 2>/dev/null || true
    fi
    
    # Update other scripts if they have version
    for script in *.sh; do
        if [[ -f "$script" ]]; then
            portable_sed "s/Version: [0-9]\+\.[0-9]\+\.[0-9]\+/Version: $new_version/g" "$script" 2>/dev/null || true
            portable_sed "s/VERSION=\"[0-9]\+\.[0-9]\+\.[0-9]\+\"/VERSION=\"$new_version\"/g" "$script" 2>/dev/null || true
        fi
    done
    
    # Update zshrc
    if [[ -f "zshrc" ]]; then
        portable_sed "s/Version: [0-9]\+\.[0-9]\+\.[0-9]\+/Version: $new_version/g" zshrc 2>/dev/null || true
    fi
    
    success "Version updated in files"
}

# Create release notes
create_release_notes() {
    local new_version="$1"
    local release_notes_file="RELEASE_NOTES_${new_version}.md"
    
    log "Creating release notes..."
    
    cat > "$release_notes_file" << EOF
# Release Notes - v${new_version}

**Release Date**: ${RELEASE_DATE}

## 🎉 Major Release

This is a major release with significant improvements and new features.

## ✨ New Features

### 🔄 Automated Update System
- **update.sh** - Complete update automation for all components
- **Backup Management** - Automatic backup creation and cleanup
- **Component Updates** - zinit, oh-my-posh, themes, and tools
- **Interactive Mode** - User-friendly update prompts

### 🚀 Quick Installation
- **quick-install.sh** - One-command installation script
- **Cross-platform Support** - macOS, Linux, WSL compatibility
- **Automatic Setup** - ZSH installation and configuration
- **Verification** - Complete installation validation

### 🧪 Comprehensive Testing
- **test.sh** - Enhanced test suite with multiple categories
- **check-project.sh** - Project health validation
- **CI/CD Pipeline** - GitHub Actions integration
- **Security Scanning** - Vulnerability detection

### 🛡️ Security & Quality
- **Error Handling** - Robust error checking in all scripts
- **Security Validation** - Automated security scanning
- **Code Quality** - ShellCheck integration
- **Documentation** - Professional documentation structure

## 🔧 Improvements

### Installation Process
- Enhanced error handling and validation
- Interactive configuration options
- Automatic dependency detection
- Cross-platform compatibility

### Configuration Management
- Modular architecture improvements
- Better environment variable handling
- Template-based configuration
- Custom configuration support

### Performance Optimization
- Faster startup times
- Reduced memory usage
- Optimized plugin loading
- Intelligent caching

## 🐛 Bug Fixes

- Fixed CI/CD pipeline issues
- Resolved plugin conflict detection
- Improved error reporting
- Enhanced compatibility

## 📚 Documentation

- Complete README rewrite
- Professional documentation structure
- Installation guides
- Troubleshooting documentation

## 🔄 Migration Guide

### From v4.x.x
1. Backup your current configuration
2. Run the new installation script
3. Review and update custom configurations
4. Test the new features

### From v3.x.x
1. Complete reinstallation recommended
2. Review new configuration structure
3. Update custom scripts and aliases
4. Test all functionality

## 📦 Installation

### Quick Install
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/yourusername/zsh-config/main/quick-install.sh | bash
\`\`\`

### Manual Install
\`\`\`bash
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh
cd ~/.config/zsh
./install.sh --interactive
\`\`\`

## 🧪 Testing

After installation, run the test suite:

\`\`\`bash
./test.sh all
./check-project.sh
\`\`\`

## 🔄 Updates

Use the new update system:

\`\`\`bash
./update.sh --interactive
\`\`\`

## 📞 Support

- GitHub Issues: [Report bugs](https://github.com/yourusername/zsh-config/issues)
- GitHub Discussions: [Ask questions](https://github.com/yourusername/zsh-config/discussions)
- Documentation: [Complete guides](docs/)

---

**Thank you for using ZSH Configuration!**

EOF
    
    success "Release notes created: $release_notes_file"
}

# Create git tag
create_git_tag() {
    local new_version="$1"
    local tag_message
    tag_message="Release v$new_version - $(date +%Y-%m-%d)"
    
    log "Creating git tag v$new_version..."
    
    if git tag -l "v$new_version" | grep -q "v$new_version"; then
        warning "Tag v$new_version already exists"
        read -p "Delete existing tag? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git tag -d "v$new_version"
        else
            error "Cannot create duplicate tag"
            exit 1
        fi
    fi
    
    git tag -a "v$new_version" -m "$tag_message"
    success "Git tag created: v$new_version"
}

# Push to remote
push_to_remote() {
    local new_version="$1"
    
    log "Pushing to remote repository..."
    
    # Push commits
    if ! git push origin main; then
        error "Failed to push commits"
        exit 1
    fi
    
    # Push tag
    if ! git push origin "v$new_version"; then
        error "Failed to push tag"
        exit 1
    fi
    
    success "Successfully pushed to remote"
}

# Show release summary
show_release_summary() {
    local new_version="$1"
    
    echo
    success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    success "🎉 Release v$new_version Complete!"
    success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "  📋 Release Summary:"
    echo "    • Version: v$new_version"
    echo "    • Date: $RELEASE_DATE"
    echo "    • Tag: v$new_version"
    echo "    • Branch: main"
    echo
    echo "  📁 Files Updated:"
    echo "    • README.md"
    echo "    • Scripts (version numbers)"
    echo "    • Release notes: RELEASE_NOTES_${new_version}.md"
    echo
    echo "  🧪 Quality Checks:"
    echo "    • Project health validation"
    echo "    • Test suite execution"
    echo "    • Critical file verification"
    echo
    echo "  📤 Remote Push:"
    echo "    • Commits pushed to main"
    echo "    • Tag pushed to remote"
    echo
    echo "  📚 Next Steps:"
    echo "    1. Create GitHub release from tag"
    echo "    2. Update documentation links"
    echo "    3. Announce to community"
    echo "    4. Monitor for issues"
    echo
}

# Parse command line arguments
parse_arguments() {
    new_version=""
    skip_checks=0
    skip_push=0
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --version|-v)
                new_version="$2"
                shift 2
                ;;
            --skip-checks|-s)
                skip_checks=1
                shift
                ;;
            --skip-push|-p)
                skip_push=1
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo
                echo "Release script for ZSH Configuration"
                echo
                echo "Options:"
                echo "  -v, --version VERSION    Specify new version (e.g., 5.0.1)"
                echo "  -s, --skip-checks        Skip pre-release checks"
                echo "  -p, --skip-push          Skip pushing to remote"
                echo "  -h, --help               Show this help message"
                echo
                echo "Examples:"
                echo "  $0 --version 5.0.1       # Release v5.0.1"
                echo "  $0 --version 5.1.0 -s    # Release v5.1.0, skip checks"
                echo "  $0 --version 5.0.2 -p    # Release v5.0.2, skip push"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$new_version" ]]; then
        echo "Current version: $CURRENT_VERSION"
        read -p "Enter new version: " new_version
        if [[ -z "$new_version" ]]; then
            error "Version is required"
            exit 1
        fi
    fi
}

# Main function
main() {
    printf '%b╔══════════════════════════════════════════════════════════════╗%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    printf '%b║                🚀 ZSH Configuration Release                  ║%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    printf '%b╚══════════════════════════════════════════════════════════════╝%b\n' "$LOG_COLOR_BLUE" "$LOG_COLOR_RESET"
    echo
    
    # Parse arguments (sets new_version, skip_checks, skip_push)
    parse_arguments "$@"
    
    # Validate version format
    if [[ ! "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Invalid version format. Use semantic versioning (e.g., 5.0.1)"
        exit 1
    fi
    
    # Check git repository
    check_git_repo
    
    # Check git status
    check_git_status
    
    # Run pre-release checks
    if [[ $skip_checks -eq 0 ]]; then
        run_pre_release_checks
    else
        warning "Skipping pre-release checks"
    fi
    
    # Update version in files
    update_version "$new_version"
    
    # Create release notes
    create_release_notes "$new_version"
    
    # Commit changes
    log "Committing changes..."
    git add .
    git commit -m "Release v$new_version - $(date +%Y-%m-%d)"
    
    # Create git tag
    create_git_tag "$new_version"
    
    # Push to remote
    if [[ $skip_push -eq 0 ]]; then
        push_to_remote "$new_version"
    else
        warning "Skipping push to remote"
    fi
    
    # Show summary
    show_release_summary "$new_version"
}

# Run main function
main "$@" 
