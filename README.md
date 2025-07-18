# ZSH Configuration v4.2

高性能、模块化的ZSH配置系统，专为个人工作环境优化。经过两阶段优化，代码精简73%，启动性能显著提升。

## ✨ 特性

- **极速启动** - 优化的启动时间，减少模块依赖
- **简洁架构** - 代码精简73%，从2204行优化到604行
- **核心功能** - 聚焦最常用功能，删除边缘化特性
- **智能模块** - 模块化设计，按需加载
- **一致体验** - 统一的命令命名和输出格式
- **开箱即用** - 预配置常用插件和工具

## 🚀 快速开始

### 安装
```bash
git clone https://github.com/yourusername/zsh-config.git ~/.config/zsh
ln -sf ~/.config/zsh/zshrc ~/.zshrc
ln -sf ~/.config/zsh/zshenv ~/.zshenv
exec zsh
```

### 验证
```bash
status    # 检查状态
version   # 查看版本
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

### 自定义配置
```bash
config zshrc    # 编辑主配置
config core     # 编辑核心模块
config plugins  # 编辑插件模块
config aliases  # 编辑别名模块
```

## 🐛 故障排除

### 常见问题

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

## 🤝 贡献

欢迎提交Issue和Pull Request！

---

**版本**: 4.2.0  
**最后更新**: 2024-12-19  
**许可证**: MIT 