# AiDE 项目状态 2026-05-23

**仓库**: https://github.com/appleweiping/AiDE-dev  
**本地**: D:\devtools\aide  
**最新 commit**: dd2737e (2026-05-23)  
**Tags**: aide, desktop-agent, tauri, react-native, chinese-llm, coding-agent

---

## 今日完成工作（2026-05-23）

### 1. README 全面重写（commit eefe7b1 → 7027232）
- 英文 README.md（709 行）+ 中文 README.zh-CN.md
- 新增日语 README.ja.md + 韩语 README.ko.md
- 全平台下载链接表格（Windows x64/arm64, macOS Intel/Apple Silicon, Linux x64/arm64, CLI npm）
- 4 个 README 顶部语言切换器互相链接

### 2. Phase 4 功能实现（commit 2b72434）
对标 CC/Codex/Gemini 的竞品功能差距全部补齐：
- AIDE.md/CLAUDE.md/AGENTS.md 项目上下文加载（git root→cwd 层级，32KB 预算）
- Prompt 缓存（cache_control markers + cache_stats 事件）
- Plan Mode 工具限制（写工具在 plan 阶段被 registry 拦截）
- Session 分叉（fork() + parentId 追踪）
- 29 事件生命周期 Hooks 系统（session/agent/tool/file/shell/git/MCP/approval/plan）
- SubAgent 共享上下文（SharedContext）+ SendMessage 跨 agent 通信
- 90% 上下文自动压缩（按模型识别窗口大小）
- 全局 Slash 命令注册表（10 个内置命令）
- Docker 沙箱执行（DockerSandbox + sandboxed bash 工具）
- LSP 集成（LspClient + hover/definition/references 工具）
- Playwright 浏览器自动化（6 个工具）
- nut-js 桌面控制（5 个工具：截图/点击/输入/按键/滚动）
- 语音 TTS（系统/edge-tts/自定义 API）
- Skills 库（8 个内置 + 项目/全局 skill 文件）
- OpenTelemetry 可观测性（spans/metrics/OTLP 导出）
- A2A 协议服务器（port 3748，agent 发现卡 + 任务 API）

### 3. 后台守护进程 + 手机远程控制（commit 2a6cdff）
- packages/core/src/daemon.ts: 持久化 WebSocket daemon（port 7432）
  - 关闭 Tauri 窗口后 Node.js 核心继续运行（息屏持续工作）
  - PID 文件 ~/.aide/daemon.pid，日志 ~/.aide/daemon.log
  - 内置 ntfy.sh 推送通知
- packages/relay/: 轻量 WebSocket 中继服务器（port 7433）
  - token 隔离房间，24h TTL，自托管
- Tauri lib.rs: CloseRequested → 最小化到托盘（不退出）

### 4. 手机 App 完整重写 + 桌面端 JA/KO i18n（commit 14809d2）
手机端从玩具升级到功能完整（对标 Codex 移动端）：
- 5 个 tab：Chat / Sessions / Files / Git / Connect
- 流式内容 + 推理链分开显示
- ToolCallCard（可展开：args/output/diff/截图）
- DiffViewer（+/- 颜色高亮）
- 模型切换底部 sheet
- FilesScreen（面包屑导航，文件图标）
- GitScreen（分支/staged/unstaged/提交历史）
- 4 语言 i18n（EN/ZH/JA/KO），自动检测设备语言
- 指数退避重连，心跳 20s，离线消息队列
- 内置 Expo push notifications
- 桌面端新增 ja.json + ko.json（287 个 key 全翻译）

### 5. Bug 修复（commits 36754f6 + dd2737e）
安全修复：
- bash.ts: ENV_ALLOWLIST 白名单过滤子进程环境变量（防 API key 泄露）
- file-edit/file-write: path-guard.ts 防路径遍历（写操作限制在 workingDirectory）
- approval.ts: powershell 加入命令分类器，扩展安全工具列表

Bug 修复：
- ws 包未声明依赖 → daemon 启动即崩溃
- daemon 使用共享 toolRegistry 单例 → 并发 session 共享工具状态
- relay 重连循环在 stop() 后继续
- ping 方法未处理 → 每 20s 报错
- mobile store 空数组响应路由错误
- approval.ts respond() remember 标志被静默忽略
- compaction.ts 朴素截断 → LLM 真实摘要（失败回退）
- cli/repl.ts 完整重写，接入 slash command registry

---

## 当前架构

```
packages/
  core/        — 63 个 TS 文件，Agent 引擎
  shared/      — 共享类型
  desktop/     — Tauri v2 + React 桌面应用
  cli/         — 命令行界面
  vscode/      — VS Code 扩展
  mobile/      — React Native/Expo 手机 App
  relay/       — WebSocket 中继服务器
```

## 待修复（已知问题）
- API key 存 localStorage（需 Tauri keychain API）
- ipc-server session 持久化竞态条件（需队列/锁）
- 硬编码上下文窗口大小（需 provider API 查询或用户配置）
