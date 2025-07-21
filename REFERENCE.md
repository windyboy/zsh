# 完整参考手册

## 🔧 系统管理

```bash
status          # 系统状态
reload          # 重新加载配置
validate        # 验证配置
version         # 查看版本
```

## 🛠️ 实用工具

### 文件操作
```bash
mkcd <目录>     # 创建目录并进入
up [层数]       # 向上跳转目录
trash <文件>    # 安全删除文件
extract <文件>  # 解压文件
```

### PATH管理
```bash
show_path       # 显示当前PATH状态
cleanup_path    # 清理无效和重复路径
reload_path     # 重新加载PATH配置
add_path <路径> # 添加路径到PATH
remove_path <路径> # 从PATH移除路径
path-status     # PATH状态别名
path-clean      # PATH清理别名
path-reload     # PATH重载别名
```

### 网络工具
```bash
serve [端口] [目录] # 启动HTTP服务器
myip            # 查看外网IP
```

### 开发工具
```bash
g               # Git快捷操作
ni              # npm install
py              # python3
```

## 🔌 插件管理

```bash
plugins         # 插件状态
```

## ⚙️ 配置管理

```bash
config <文件>   # 编辑配置文件
```

### 可编辑的配置文件
- `zshrc` - 主配置文件
- `core` - 核心模块
- `plugins` - 插件模块
- `completion` - 补全模块
- `aliases` - 别名模块
- `keybindings` - 按键绑定模块
- `utils` - 工具模块

## 🔧 环境变量

### 核心变量
```bash
export ZSH_CONFIG_DIR="$HOME/.config/zsh"
export ZSH_CACHE_DIR="$HOME/.cache/zsh"
export ZSH_DATA_DIR="$HOME/.local/share/zsh"
```

### PATH管理变量
```bash
export PATH_MANAGEMENT_ENABLED=1    # 启用PATH管理
export PATH_DEBUG=0                 # PATH调试模式
export PATH_AUTO_CLEANUP=1          # 自动清理无效路径
```

### 调试变量
```bash
export ZSH_DEBUG=1    # 启用调试模式
export ZSH_VERBOSE=1  # 启用详细输出
export ZSH_QUIET=1    # 静默模式
```

## 📁 重要文件

### 配置文件
- `~/.config/zsh/zshrc` - 主配置
- `~/.config/zsh/zshenv` - 环境变量
- `~/.config/zsh/modules/` - 模块目录

### 缓存文件
- `~/.cache/zsh/zcompdump` - 补全缓存

### 数据文件
- `~/.local/share/zsh/history` - 命令历史

## 🚨 故障排除

### 启动慢
```bash
# 检查启动时间
time zsh -c "source ~/.zshrc; exit"

# 检查状态
status
```

**解决方案**:
- 禁用重插件：编辑 `modules/plugins.zsh`
- 优化补全缓存：`rm ~/.cache/zsh/zcompdump*`
- 检查模块加载：`validate`

### 配置错误
```bash
# 验证配置
validate
status
```

**解决方案**:
- 检查文件权限：`ls -la ~/.config/zsh/`
- 重新安装配置：备份后重新克隆仓库
- 检查核心文件：验证 `zshrc` 和模块文件存在

### 插件问题
```bash
# 检查插件状态
plugins

# 重新加载插件
reload
```

**解决方案**:
- 重新加载插件：`reload`
- 禁用问题插件：编辑 `modules/plugins.zsh`

### 命令执行慢
```bash
# 检查钩子性能
add-zsh-hook -L precmd

# 测试命令执行
time ls -la
```

**解决方案**:
- 减少钩子数量：检查 `precmd` 钩子
- 优化PATH：`typeset -U path`
- 检查插件性能：监控插件加载时间

## 🔧 开发指南

### 开发环境
```bash
# 启用调试模式
export ZSH_DEBUG=1
export ZSH_VERBOSE=1
exec zsh
```

### 模块开发
```bash
# 创建新模块
touch modules/new_module.zsh
```

### 模块模板
```bash
#!/usr/bin/env zsh
# =============================================================================
# 新模块 - 描述
# 版本: 4.2
# =============================================================================

# 环境设置
export NEW_MODULE_ENABLED="${NEW_MODULE_ENABLED:-1}"

# 核心函数
new_module_function() {
    # 函数实现
    echo "新模块函数被调用"
}
```

## 📊 当前状态

### 模块统计
- **总行数**: 604行
- **模块数量**: 6个核心模块
- **版本**: 4.2.0

### 核心模块
- `core.zsh` (94行) - 核心环境设置
- `aliases.zsh` (95行) - 别名和快捷命令
- `plugins.zsh` (95行) - 插件管理
- `completion.zsh` (119行) - 自动补全
- `keybindings.zsh` (116行) - 按键绑定
- `utils.zsh` (85行) - 实用工具

---

**最后更新**: 2024-12-19  
**状态**: 生产就绪 ✅ 