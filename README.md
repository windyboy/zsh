# ZSH Configuration v4.2.2

High-performance, modular ZSH configuration system optimized for personal work environments. Features beautiful English interface, comprehensive status monitoring, and intelligent scoring system.

## ✨ Features

- **🚀 Lightning Fast** - Optimized startup time with minimal module dependencies
- **🎨 Beautiful Interface** - Complete English localization with color-coded output
- **📊 Smart Monitoring** - Comprehensive status checking with intelligent scoring
- **🔧 Modular Design** - Clean, maintainable module architecture
- **⚡ Performance Optimized** - Streamlined codebase with 73% reduction
- **🎯 Personal Experience** - Focused on essential functionality
- **📈 Progress Tracking** - Visual progress indicators and detailed metrics
- **🔌 Plugin Management** - Categorized plugin status with health monitoring

## 📋 System Requirements

### Required Dependencies
- **ZSH**: Version 5.8 or higher
- **Git**: For plugin management

### Optional Dependencies (Recommended)
- **fzf**: Fuzzy file finder
- **zoxide**: Smart directory navigation
- **eza**: Enhanced ls command
- **oh-my-posh**: Theme system
- **curl/wget**: Network tools

## 🚀 Quick Start

### Method 1: Automatic Installation (Recommended)

Use our provided automatic installation script:

```bash
# 1. Clone repository
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh
cd ~/.config/zsh

# 2. Install dependency tools
./install-deps.sh

# 3. Install Oh My Posh themes (optional)
./install-themes.sh --all

# 4. Install ZSH configuration
./install.sh

# 5. Restart terminal or execute
exec zsh
```

**Note**: The installation script automatically sets `ZDOTDIR="$HOME/.config/zsh"` to ensure ZSH loads configuration from the correct directory.
```

### Method 2: Manual Installation

#### 1. Install Dependency Tools

#### macOS (using Homebrew)
```bash
# 安装必需工具
brew install zsh git

# 安装推荐工具
brew install fzf zoxide eza oh-my-posh curl

# 验证ZSH版本
zsh --version  # 应显示5.8或更高版本
```

#### Ubuntu/Debian
```bash
# 安装必需工具
sudo apt update
sudo apt install zsh git

# 安装推荐工具
sudo apt install fzf curl wget

# 安装zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# 安装eza (下载二进制文件)
# 1. 下载并解压eza
curl -L -o eza.tar.gz https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz
tar -xzf eza.tar.gz

# 2. 安装到系统路径
sudo mv eza /usr/local/bin/
rm eza.tar.gz

# 安装oh-my-posh
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
```

#### CentOS/RHEL/Fedora
```bash
# 安装必需工具
sudo dnf install zsh git  # Fedora
# 或 sudo yum install zsh git  # CentOS/RHEL

# 安装推荐工具
sudo dnf install fzf curl wget  # Fedora
# 或 sudo yum install fzf curl wget  # CentOS/RHEL

# 安装zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# 安装eza (下载二进制文件)
# 1. 下载并解压eza
curl -L -o eza.tar.gz https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz
tar -xzf eza.tar.gz

# 2. 安装到系统路径
sudo mv eza /usr/local/bin/
rm eza.tar.gz

# 安装oh-my-posh
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
```

#### Windows (WSL)
```bash
# 在WSL中按照Ubuntu/Debian的步骤安装
```

#### 2. 安装ZSH配置
```bash
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh
ln -sf ~/.config/zsh/zshrc ~/.zshrc
ln -sf ~/.config/zsh/zshenv ~/.zshenv

# 设置ZDOTDIR (可选，但推荐)
echo 'export ZDOTDIR="$HOME/.config/zsh"' >> ~/.profile

exec zsh
```

#### 3. 验证安装
```bash
status    # 检查状态
version   # 查看版本
plugins   # 检查插件状态
```

## 🛠️ 常用命令

### System Management
```bash
status          # System status
reload          # Reload configuration
validate        # Validate configuration
version         # View version
```

### Status Monitoring
```bash
./status.sh     # Comprehensive status check with beautiful output
test.sh         # Plugin conflict detection and testing
```

The status script provides:
- **📊 Real-time metrics** - Functions, aliases, memory usage, history
- **🎯 Performance scoring** - Intelligent rating system (0-100)
- **🔌 Plugin health** - Categorized plugin status with detailed breakdown
- **📈 Progress tracking** - Visual progress indicators for module loading
- **🎨 Beautiful interface** - Color-coded output with professional formatting

### 开发工具
```bash
g               # Git快捷操作
ni              # npm install
py              # python3
serve           # 启动HTTP服务器
```

### 文件解压
```bash
extract <文件>  # 智能解压，支持多种格式
# 支持格式: tar.gz, tar.bz2, tar.xz, zip, rar, 7z, cab, iso 等
```

### 文件操作
```bash
mkcd <目录>     # 创建目录并进入
up [层数]       # 向上跳转目录
trash <文件>    # 安全删除文件
extract <文件>  # 智能解压文件 (支持多种格式)
```

## 📦 包含功能

- **语法高亮** - 代码语法高亮
- **自动补全** - 智能命令补全
- **历史搜索** - 强大的历史搜索
- **Git集成** - Git状态显示
- **FZF集成** - 模糊文件查找
- **智能解压** - 支持多种压缩格式的智能解压工具

## ⚡ 性能表现

- **代码行数**: 精简73%（2204行 → 604行）
- **核心模块**: 6个模块，总计604行
- **启动优化**: 减少模块依赖，提升启动速度
- **维护性**: 简化配置逻辑，降低学习成本

## 🔧 配置

### 环境变量
```bash
export ZSH_CONFIG_DIR="$HOME/.config/zsh"
export ZSH_CACHE_DIR="$HOME/.cache/zsh"
export ZSH_DATA_DIR="$HOME/.local/share/zsh"
```

### 环境配置结构
```
~/.config/zsh/
├── zshenv                    # 核心环境配置加载器
├── env/
│   ├── templates/
│   │   └── environment.env.template # 用户环境配置模板
│   ├── local/
│   │   └── environment.env          # 用户实际环境配置
│   ├── init-env.sh                  # 环境变量初始化脚本
│   ├── migrate-env.sh               # 环境变量迁移脚本
│   ├── README.md                    # 环境变量配置说明
│   └── .gitignore                   # Git忽略文件
└── modules/                          # 功能模块
```

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

```bash
# 1. 检查是否存在旧配置文件
ls -la ~/.config/zsh/env/development.zsh

# 2. 如果存在，使用迁移脚本处理
cd ~/.config/zsh/env
./migrate-env.sh

# 3. 重新加载配置
source ~/.config/zsh/zshrc

# 4. 验证环境变量
echo "GOPATH: $GOPATH"
echo "ANDROID_HOME: $ANDROID_HOME"
```

详细说明请参考：[环境变量配置指南](env/README.md)

## 🎨 Oh My Posh 主题管理

### 主题安装
```bash
# 方法1: 自动安装所有主题 (推荐)
./install-themes.sh --all

# 方法2: 安装指定主题
./install-themes.sh agnoster powerlevel10k_modern paradox

# 方法3: 查看所有可用主题
./install-themes.sh --list

# 方法4: 通过依赖安装脚本 (安装少量常用主题)
./install-deps.sh
```

### 主题使用
```bash
# 使用特定主题
oh-my-posh init zsh --config ~/.poshthemes/agnoster.omp.json

# 在.zshrc中设置默认主题
echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/agnoster.omp.json)"' >> ~/.zshrc

# 预览主题
oh-my-posh print primary --config ~/.poshthemes/agnoster.omp.json
```

### 常用主题
- `agnoster` - 经典Powerline风格
- `powerlevel10k` - 功能丰富的现代主题
- `paradox` - 简洁优雅的主题
- `atomic` - 现代原子风格
- `agnosterplus` - 增强版agnoster主题

### 浏览所有主题
```bash
# 查看所有可用主题
./install-themes.sh --list

# 安装所有主题
./install-themes.sh --all

# 安装特定主题
./install-themes.sh <theme_name1> <theme_name2>
```

### 自定义主题
```bash
# 创建自定义主题
cp ~/.poshthemes/agnoster.omp.json ~/.poshthemes/my-theme.omp.json

# 编辑自定义主题
${EDITOR:-code} ~/.poshthemes/my-theme.omp.json

# 使用自定义主题
oh-my-posh init zsh --config ~/.poshthemes/my-theme.omp.json
```

## 🐛 故障排除

### 依赖安装问题

**eza安装失败？**
```bash
# 方法1: 使用包管理器 (推荐)
# macOS: brew install eza
# Ubuntu: sudo apt install eza

# 方法2: 手动下载二进制文件
# 1. 确定你的系统架构
uname -m  # x86_64 或 aarch64

# 2. 下载对应版本
# x86_64 Linux:
curl -L -o eza.tar.gz https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz
# aarch64 Linux:
curl -L -o eza.tar.gz https://github.com/eza-community/eza/releases/latest/download/eza_aarch64-unknown-linux-gnu.tar.gz
# macOS:
curl -L -o eza.tar.gz https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-apple-darwin.tar.gz

# 3. 解压并安装
tar -xzf eza.tar.gz
sudo mv eza /usr/local/bin/
rm eza.tar.gz
```

**oh-my-posh安装失败？**
```bash
# 方法1: 手动下载二进制文件 (推荐)
# Linux x86_64:
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

# Linux aarch64:
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-arm64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

# 方法2: 使用包管理器
# macOS: brew install oh-my-posh
# Ubuntu: sudo apt install oh-my-posh

# 方法3: 使用官方安装脚本
curl -sS https://ohmyposh.dev/install.sh | bash

# 安装主题 (安装oh-my-posh后执行)
./install-themes.sh --all
```

**zoxide安装失败？**
```bash
# 手动安装zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# 或者使用包管理器
# macOS: brew install zoxide
# Ubuntu: sudo apt install zoxide
```

**ZSH版本过低？**
```bash
# 检查当前版本
zsh --version

# 升级ZSH
# macOS: brew upgrade zsh
# Ubuntu: sudo apt update && sudo apt upgrade zsh
# CentOS: sudo yum update zsh
```

### 配置问题

**启动慢？**
```bash
status          # 检查状态
```

**配置错误？**
```bash
validate        # 验证配置
```

**插件问题？**
```bash
plugins         # 检查插件状态
```

### 调试模式
```bash
export ZSH_DEBUG=1  # 启用调试模式
exec zsh
```

## 📚 更多信息

- **完整命令参考**: `REFERENCE.md`
- **版本历史**: `CHANGELOG.md`

## 🔧 依赖工具说明

### 必需工具
- **ZSH 5.8+**: 核心shell环境，提供强大的脚本和交互功能
- **Git**: 用于插件管理和版本控制

### 可选工具（推荐安装）
- **fzf**: 模糊查找工具，提供强大的文件搜索和命令历史搜索
- **zoxide**: 智能目录导航，比cd更快更智能
- **eza**: 现代化的ls替代品，支持图标和更好的显示效果
- **oh-my-posh**: 强大的主题系统，提供美观的提示符
- **curl/wget**: 网络工具，用于下载和网络请求

### 工具安装优先级
1. **高优先级**: fzf, zoxide (显著提升日常使用体验)
2. **中优先级**: eza (美化文件列表显示)
3. **低优先级**: oh-my-posh (主题美化，可选)

### 系统兼容性
- **macOS**: 所有工具都支持，推荐使用Homebrew安装
- **Linux**: 支持主流发行版，部分工具可能需要手动安装
- **Windows**: 建议使用WSL，按照Linux方式安装

## 🤝 贡献

欢迎提交Issue和Pull Request！

---

**版本**: 4.2.2  
**最后更新**: 2025-07-25  
**许可证**: MIT 