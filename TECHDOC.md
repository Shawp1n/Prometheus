# Prometheus 技术文档

## 1. 技术背景
Prometheus 是为了解决多环境下的 Claude API 配置管理问题而开发的。在使用 Claude code 等工具时，经常需要在不同的 API Key 和 Base URL 之间切换。手动修改环境变量繁琐且容易出错，因此需要一个轻量级的工具来自动化此过程。

## 2. 实现方法
项目采用 **Windows Batch Script (.bat)** 编写，以保持最大的兼容性和便携性（无需安装额外运行时）。

### 核心机制
- **自修改数据存储**：脚本利用 `type` 和 `findstr` 命令读取自身内容，并将数据以 `::DATA|Key|Value` 或 `::SHORTCUT|Alias|Command` 的形式追加到文件末尾。这使得脚本成为一个独立的单文件应用。
- **环境变量控制**：
    - **全局模式**：使用 `setx` 命令修改 Windows 用户级环境变量，实现持久化配置。
    - **隔离模式**：通过 `wt` (Windows Terminal) 启动新的 CMD 进程，并在启动参数中直接注入环境变量 (`cmd /k "set ..."`). 这样新窗口拥有独立的配置，互不干扰。
    - **配置保留**：脚本不再主动修改或重置 `%USERPROFILE%\.claude\settings.json`，确保现有的 MCP (Model Context Protocol) 配置和权限设置不受影响。
- **快捷指令注入**：利用 `doskey` 命令别名机制。
    -   在启动隔离终端时，脚本会读取用户定义的快捷指令，动态构建 `doskey alias=command` 序列。
    -   支持使用 `$T` 作为命令分隔符，实现多命令串联（如 `cd path $T command`）。
    -   **动态加载**：每次进入 Shortcut 菜单都会强制重载数据，确保删除操作后的列表即时更新。

## 3. 技术架构
单文件架构 (`Prometheus.bat`)：

```mermaid
graph TD
    A[启动脚本] --> B{初始化 & 加载数据}
    B --> C[主菜单 GUI]
    C --> D[Profile 管理]
    C --> E[Shortcut 管理]
    C --> F[全局环境设置]
    C --> G[启动隔离终端]
    
    D --> D1[新建/编辑/删除]
    D1 --> H[自身文件 IO]
    
    E --> E1[新建/删除 Shortcut]
    E1 --> H
    
    F --> I[System Environment (setx)]
    
    G --> J[Windows Terminal (wt.exe)]
    J --> K[注入 Env & Doskey]
```

## 4. 功能目录
1.  **Profile Management**: 增删改查 API 配置 (Name, Key, URL)。
2.  **Global Environment**: 一键应用配置到系统环境。
3.  **Isolated Terminal**: 启动带有特定配置和快捷指令的独立终端窗口。
4.  **Shortcut System**: 管理 `doskey` 别名，自动注入到隔离终端。
5.  **Backup/Restore**: 导出配置到文本文件，支持从文件恢复。
6.  **Connectivity Test**: 使用 `curl` 验证 API 连接。

## 5. 后续开发方向
-   [ ] **PowerShell 重构**: 考虑到 Batch 的局限性，未来计划迁移到 PowerShell 版本，以支持更复杂的 UI 和更强的数据处理能力。
-   [ ] **加密存储**: 目前 API Key 明文存储，需引入简单的加密混淆机制。
-   [ ] **TUI 框架**: 引入更完善的终端 UI 库（如果是 PS 版本）。
