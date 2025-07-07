# 🧭 ZSH Navigation Guide

## **File & Directory Navigation**

### **FZF Tab Completion** (Primary Method)
- **How to use**: Press `TAB` when typing a command
- **What happens**: Opens a fuzzy search interface
- **Navigation**: 
  - Type to filter results
  - Use arrow keys or `Ctrl+N/P` to navigate
  - Press `Enter` to select
  - Press `Esc` to cancel

### **FZF File Finder**
- **Key binding**: `Ctrl+T`
- **What it does**: Fuzzy find files from current directory
- **Navigation**: Same as above

### **FZF Directory Finder**
- **Key binding**: `Ctrl+G`
- **What it does**: Fuzzy find and change to directories
- **Navigation**: Same as above

### **FZF History Search**
- **Key binding**: `Ctrl+R`
- **What it does**: Search through command history
- **Navigation**: Same as above

## **Completion Menu Navigation**

### **Arrow Keys**
- `↑/↓` - Navigate up/down
- `←/→` - Navigate left/right (for grouped completions)

### **Vim-Style Navigation**
- `h/j/k/l` - Navigate in Vim style
- `h/l` - Left/Right
- `j/k` - Down/Up

### **Accept/Reject**
- `Enter` - Accept current selection
- `Tab` - Accept current selection
- `Space` - Accept current selection
- `Esc` - Cancel/Exit menu

## **Smart Directory Navigation**

### **Zoxide** (if installed)
- **Command**: `z <directory_name>`
- **What it does**: Smart directory jumping
- **Example**: `z config` → jumps to `~/.config`

### **Enhanced Directory Listing**
- **Command**: `ls`, `ll`, `la`, `lt`
- **What it does**: Enhanced directory listings with icons
- **Requires**: `eza` command

## **Quick Navigation Shortcuts**

### **Directory Jumps**
- `Alt+P` - Jump to Projects directory
- `Alt+H` - Jump to Home directory
- `Alt+R` - Jump to Root directory

### **File Operations**
- `Ctrl+T` - File finder
- `Ctrl+G` - Directory finder
- `Ctrl+H` - History search

## **Tips & Tricks**

1. **Fuzzy Search**: Just type part of the filename you want
2. **Case Insensitive**: FZF searches are case-insensitive
3. **Preview**: File contents are shown in the preview window
4. **Multiple Selection**: Use `Tab` to select multiple files in FZF
5. **Quick Access**: Use `z` for frequently visited directories

## **Troubleshooting**

If navigation doesn't work:
1. Make sure you're in `zsh` shell
2. Run: `source ~/.zshrc`
3. Check if FZF is installed: `which fzf`
4. Check plugin status: `check_plugins`

## **Customization**

You can customize the navigation by editing:
- `modules/plugins.zsh` - Plugin configuration
- `modules/keybindings.zsh` - Key bindings
- `modules/completion.zsh` - Completion styles 