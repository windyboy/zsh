# 环境变量配置指南

## 概述

本项目采用简化的环境变量配置方式，核心环境变量在配置脚本中直接管理，只有用户特定的环境变量使用模板化配置。

## 文件结构

```
env/
├── templates/                    # 环境变量模板文件
│   └── environment.env.template # 用户环境配置模板
├── local/                       # 用户实际配置文件（从模板复制）
│   └── environment.env          # 用户实际环境配置
├── init-env.sh                  # 初始化脚本
├── migrate-env.sh               # 迁移脚本
├── README.md                    # 本说明文件
└── .gitignore                   # Git忽略文件
```

## 配置分类

### 1. 核心环境变量（在zshenv中直接设置）
- XDG基础目录配置
- ZSH路径配置
- 历史记录设置
- 终端配置
- 基础工具配置

### 2. 插件环境变量（在modules/plugins.zsh中管理）
- ZSH自动建议配置
- 其他插件相关配置

### 3. 主题环境变量（在themes/prompt.zsh中管理）
- Oh My Posh配置
- 其他主题相关配置

### 4. 用户环境变量（模板化管理）
- 开发工具安装路径
- 包管理器镜像配置
- 个人自定义配置

## 使用方法

### 1. 初始化配置

首次使用时，需要从模板创建实际配置文件：

```bash
# 进入环境配置目录
cd ~/.config/zsh/env

# 运行初始化脚本
./init-env.sh
```

### 2. 自定义配置

编辑本地配置文件，根据你的实际环境修改相应的值：

```bash
# 编辑用户环境配置
${EDITOR:-code} local/environment.env
```

### 3. 启用配置

配置文件会自动加载，无需额外操作。系统会按以下顺序加载：

1. `zshenv` - 核心环境变量
2. `env/local/environment.env` - 用户环境配置（可选）
3. `modules/` - 功能模块（包含插件和主题配置）

## 配置说明

### environment.env - 用户环境配置
包含各种开发工具的环境变量，如Go、Rust、Flutter、Android SDK等。

主要配置项：
- **开发工具路径**: GOPATH、GOROOT、ANDROID_HOME等
- **包管理器镜像**: Homebrew、Flutter、Rust等镜像源
- **自定义配置**: 个人工作目录、项目路径等

## 注意事项

1. **模板文件不要修改** - 模板文件用于版本控制，不要直接修改
2. **本地文件可以修改** - `local/` 目录下的文件可以自由修改
3. **备份重要配置** - 建议定期备份 `local/` 目录
4. **注释说明** - 每个环境变量都有详细注释，请仔细阅读

## 故障排除

### 配置不生效
```bash
# 重新加载配置
source ~/.config/zsh/zshrc

# 检查文件权限
ls -la ~/.config/zsh/env/local/
```

### 环境变量冲突
```bash
# 查看当前环境变量
env | grep -E "(GOPATH|ANDROID_HOME|BUN_INSTALL)"

# 检查配置文件语法
zsh -n ~/.config/zsh/env/local/environment.env
```

## 更新模板

当模板文件更新时，可以手动合并更改：

```bash
# 查看模板更新
diff templates/environment.env.template local/environment.env

# 手动合并更改到本地配置
```

## 贡献

欢迎提交Issue和Pull Request来改进模板文件！ 