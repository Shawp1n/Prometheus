# Prometheus

Prometheus 是一个用于管理 Anthropic Claude API 配置（API Key 和 Base URL）的 Windows 批处理工具。它允许你在多个 API 配置之间快速切换，或者启动带有特定配置的隔离终端环境。

## 功能特性

-   **多配置文件管理**：保存多个 API Key 和 URL 组合。
-   **全局环境切换**：一键设置系统级环境变量（`ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL` 等），立即生效（需重启终端）。
-   **隔离环境启动**：**[新功能]** 在 **Windows Terminal** 中启动一个新的选项卡 (Tab)，仅在该选项卡内应用选定的 API 配置，不影响全局环境变量。便于多环境并存管理。
-   **配置导入/导出**：方便备份和迁移配置。
-   **连接测试**：内置 `curl` 测试功能，验证 API 连接性和权限。
-   **MCP 支持**：不再重置 Claude 配置文件，完美支持本地 MCP 工具链。
-   **直观 UI**：颜色编码的界面，清晰显示当前激活的全局配置。

## 使用方法

1.  双击运行 `Prometheus.bat`。
2.  使用菜单命令进行操作：
    -   `[N]`: 新建配置 (New Profile)
    -   `[E]`: 编辑配置 (Edit Profile)
    -   `[D]`: 删除配置 (Delete Profile)
    -   `[G]`: **设置全局环境 (Set Global Env)** - *设置系统级环境变量*
    -   `[Input ID]`: **启动隔离终端 (Launch Terminal)** - *在 Windows Terminal 新标签页中启动*
    -   `[S]`: **快捷指令 (Shortcuts)**
        -   管理常用的启动命令 (如: `myproject` -> `cd ...`)
        -   支持多命令串联：使用 `$T` 连接 (如: `cd path $T claude`)
    -   `[T]`: 测试连接 (Test Connection)
    -   `[B]`: 备份/恢复 (Backup/Restore)

## 环境变量

当应用配置为全局时，Prometheus 会设置以下用户级环境变量：

-   `ANTHROPIC_AUTH_TOKEN`: 你的 API Key
-   `ANTHROPIC_BASE_URL`: 你的 API 代理地址
-   `ANTHROPIC_DEFAULT_HAIKU_MODEL`: （可选）配置的 Haiku 模型映射
-   `ANTHROPIC_DEFAULT_SONNET_MODEL`: （可选）配置的 Sonnet 模型映射
-   `ANTHROPIC_DEFAULT_OPUS_MODEL`: （可选）配置的 Opus 模型映射
-   `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`: 设为 1
-   `API_TIMEOUT_MS`: 设为 600000 (10分钟)

当直接输入 **ID** 启动隔离终端时，这些变量仅在新的命令行窗口中临时设置。

## 安全免责声明 (Security Disclaimer)⚠️

本工具为纯 Batch 脚本编写的**本地辅助工具**，使用时请务必注意以下安全风险：

1.  **敏感信息存储**：
    *   本工具使用「自修改」机制保存数据。你的 API Key 和 URL 会以**明文形式**直接写入 `Prometheus.bat` 文件本身的末尾。
    *   **切勿**将包含你真实 API Key 的 `Prometheus.bat` 文件上传到 GitHub 或分享给他人，否则会导致密钥泄露。
2.  **代码修改风险**：
    *   本脚本包含修改系统环境变量 (`setx`) 和修改自身文件内容的操作。部分杀毒软件可能会误报为风险行为。
    *   脚本代码完全开源，建议在使用前阅读源码，确保无恶意注入。
3.  **免责条款**：
    *   本工具按“原样”提供，不提供任何形式的明示或暗示担保。
    *   作者不对因使用本工具（包括但不限于密钥泄露、配置丢失、系统设置异常）造成的任何直接或间接损失负责。
    *   **请仅在受信任的个人电脑上使用。**
