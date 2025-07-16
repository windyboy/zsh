# 完整参考手册

## 🔧 系统管理

```bash
status          # 系统状态
reload          # 重新加载配置
validate        # 验证配置
errors          # 查看错误
help            # 查看帮助
```

## ⚡ 性能相关

```bash
perf            # 性能分析
optimize        # 性能优化
quick_perf_check # 快速性能检查
zsh_perf_analyze # 详细性能分析
zsh_perf_dashboard # 性能仪表板
```

## 🎨 主题管理

```bash
posh_themes     # 查看主题
posh_theme <主题名> # 切换主题
posh_theme_list # 列出所有主题
posh_theme_install # 安装主题
```

## 🛠️ 实用工具

### 文件操作
```bash
mkcd <目录>     # 创建目录并进入
up [层数]       # 向上跳转目录
dirsize [目录]  # 显示目录大小
findlarge [大小] [路径] # 查找大文件
trash <文件>    # 安全删除文件
backup <文件>   # 创建备份
extract <文件>  # 解压文件
```

### 网络工具
```bash
serve [端口] [目录] # 启动HTTP服务器
myip            # 查看外网IP
```

### 开发工具
```bash
newproject <名称> [类型] # 创建新项目
gcm <消息>      # 快速Git提交
```

### 系统信息
```bash
sysinfo         # 系统信息
diskusage       # 磁盘使用
memusage        # 内存使用
```

## 🔌 插件管理

```bash
plugins         # 插件状态
check_conflicts # 检查冲突
completion_status # 补全状态
rebuild_completion # 重建补全缓存
keybindings     # 显示按键绑定
check_keybindings # 检查按键冲突
```

## ⚙️ 配置管理

```bash
config <文件>   # 编辑配置文件
backup_config   # 备份配置
restore_config <目录> # 恢复配置
```

### 可编辑的配置文件
- `zshrc` - 主配置文件
- `core` - 核心模块
- `plugins` - 插件模块
- `completion` - 补全模块
- `aliases` - 别名模块
- `keybindings` - 按键绑定模块
- `utils` - 工具模块

## 🐛 调试命令

```bash
debug           # 调试信息
debug_config    # 配置调试
debug_functions # 函数调试
enter_recovery_mode  # 进入恢复模式
exit_recovery_mode   # 退出恢复模式
```

## 🧹 维护命令

```bash
clean_cache     # 清理缓存
report_errors   # 查看错误日志
clear_error_log # 清除错误日志
```

## 🔧 环境变量

### 核心变量
```bash
export ZSH_CONFIG_DIR="$HOME/.config/zsh"
export ZSH_CACHE_DIR="$HOME/.cache/zsh"
export ZSH_DATA_DIR="$HOME/.local/share/zsh"
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
- `~/.cache/zsh/system.log` - 系统日志

### 数据文件
- `~/.local/share/zsh/history` - 命令历史

## 🚨 故障排除

### 启动慢
```bash
# 检查启动时间
time zsh -c "source ~/.zshrc; exit"

# 性能分析
perf
optimize

# 检查瓶颈
zsh_perf_analyze
```

**解决方案**:
- 禁用重插件：编辑 `modules/plugins.zsh`
- 优化补全缓存：`rebuild_completion`
- 禁用自动更新：`export ZINIT_AUTO_UPDATE=0`

### 配置错误
```bash
# 验证配置
validate
errors

# 检查系统状态
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
check_conflicts

# 重新加载插件
reload
```

**解决方案**:
- 检查插件冲突：`check_conflicts`
- 重新加载插件：`reload`
- 禁用问题插件：编辑 `modules/plugins.zsh`

### 内存使用高
```bash
# 检查内存使用
ps -o rss= -p $$

# 检查函数数量
declare -F | wc -l
```

**解决方案**:
- 减少函数数量：编辑模块移除不必要函数
- 优化历史：限制历史大小
- 使用懒加载：编辑插件配置

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
# 版本: 4.0
# =============================================================================

# 环境设置
export NEW_MODULE_ENABLED="${NEW_MODULE_ENABLED:-1}"

# 核心函数
new_module_function() {
    # 函数实现
    echo "新模块函数被调用"
}

# 工具函数
_new_module_helper() {
    # 辅助函数实现
}

# 初始化
if [[ "$NEW_MODULE_ENABLED" == "1" ]]; then
    # 模块初始化代码
fi
```

### 测试
```bash
# 运行所有测试
./test.sh

# 运行特定测试
./test.sh --module core
```

### 贡献流程
```bash
# 创建功能分支
git checkout -b feature/new-feature

# 提交更改
git commit -m "添加新功能"

# 推送分支
git push origin feature/new-feature
```

## 📊 性能监控

### 快速检查
```bash
# 启动时间
time zsh -c "source ~/.zshrc; exit"

# 内存使用
ps -o rss= -p $$

# 函数数量
declare -F | wc -l

# 钩子性能
add-zsh-hook -L precmd
```

### 目标性能
- **启动时间**: < 0.5秒
- **内存使用**: < 50MB
- **函数数量**: < 500
- **钩子数量**: < 3个

## 📚 更多信息

- **项目概览**: `README.md`
- **版本历史**: `CHANGELOG.md`

---

**提示**: 使用 `help` 命令查看完整帮助信息 