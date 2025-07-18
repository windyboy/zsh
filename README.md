# ZSH Configuration v4.2

高性能、模块化的ZSH配置系统，专为个人工作环境优化。经过两阶段优化，代码精简73%，启动性能显著提升。

## ✨ 特性

- **极速启动** - 优化的启动时间，减少模块依赖
- **简洁架构** - 代码精简73%，从2204行优化到604行
- **核心功能** - 聚焦最常用功能，删除边缘化特性
- **智能模块** - 模块化设计，按需加载
- **一致体验** - 统一的命令命名和输出格式
- **开箱即用** - 预配置常用插件和工具

## 📋 系统要求

### 必需依赖
- **ZSH**: 5.8或更高版本
- **Git**: 用于插件管理

### 可选依赖（推荐安装）
- **fzf**: 模糊文件查找
- **zoxide**: 智能目录导航
- **eza**: 增强版ls命令
- **oh-my-posh**: 主题系统
- **curl/wget**: 网络工具

## 🚀 快速开始

### 方法一：自动安装（推荐）

使用我们提供的自动安装脚本：

```bash
# 1. 克隆仓库
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh
cd ~/.config/zsh

# 2. 安装依赖工具
./install-deps.sh

# 3. 安装ZSH配置
./install.sh

# 4. 重启终端或执行
exec zsh
```

### 方法二：手动安装

#### 1. 安装依赖工具

#### macOS (使用Homebrew)
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
exec zsh
```

#### 3. 验证安装
```bash
status    # 检查状态
version   # 查看版本
plugins   # 检查插件状态
```

## 🛠️ 常用命令

### 系统管理
```bash
status          # 系统状态
reload          # 重新加载配置
validate        # 验证配置
version         # 查看版本
```

### 开发工具
```bash
g               # Git快捷操作
ni              # npm install
py              # python3
serve           # 启动HTTP服务器
```

### 文件操作
```bash
mkcd <目录>     # 创建目录并进入
up [层数]       # 向上跳转目录
trash <文件>    # 安全删除文件
extract <文件>  # 解压文件
```

## 📦 包含功能

- **语法高亮** - 代码语法高亮
- **自动补全** - 智能命令补全
- **历史搜索** - 强大的历史搜索
- **Git集成** - Git状态显示
- **FZF集成** - 模糊文件查找

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
├── zshenv                    # 核心环境配置
├── env/
│   ├── development.zsh       # 开发工具配置（可选）
│   ├── local.zsh.example     # 本地配置模板
│   └── local.zsh            # 本地自定义配置（可选）
└── modules/                  # 功能模块
```

### 自定义配置
```bash
config zshrc    # 编辑主配置
config core     # 编辑核心模块
config plugins  # 编辑插件模块
config aliases  # 编辑别名模块
config env      # 编辑环境配置
```

### 本地配置
```bash
# 创建本地配置文件
cp ~/.config/zsh/env/local.zsh.example ~/.config/zsh/env/local.zsh

# 编辑本地配置
${EDITOR:-code} ~/.config/zsh/env/local.zsh
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

**版本**: 4.2.0  
**最后更新**: 2024-12-19  
**许可证**: MIT 