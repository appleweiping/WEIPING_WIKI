---
title: "2026-05-22 基础设施审计与修复"
type: session
created: 2026-05-22T16:20:00+08:00
updated: 2026-05-22T16:20:00+08:00
agent: claude
tags: [infrastructure, agent-hub, agentmemory, PATH, bugfix, session]
related: [d-drive-rule.md, mandatory-step-update.md, agent-roles-and-skills.md]
---

# 2026-05-22 基础设施审计与修复

## 完成的工作

### 1. Agent Hub Daemon 修复 (D:\devtools\agent-hub\daemon.mjs)

**Bug 1 — 消息无限重复调度**
- 原因: 调度完成后从未标记消息为 read，同一条消息被调度 7 次跨 4 天
- 修复: 新增 `markRead(agent, msgId)` 函数，所有终止路径（成功/失败/fallback）都调用

**Bug 2 — 调度结果不持久化**
- 原因: 结果只存在 hub mailbox JSON，其他 agent 看不到
- 修复: 新增 `writeToSharedMemory()` 写 markdown + `syncToAgentMemory()` 写 agentmemory SQLite（双写）

### 2. 自启动清理

- 删除 `pixelcat.cmd` 自启（agent-hub 的 `ensurePixelCat()` 按需拉起，避免重复进程）
- 保留: agent-hub-daemon, key-rotator, AgentMemory-Backup

### 3. PATH 全局化

- `D:\devtools` 加入 User PATH
- 现在任意终端可直接输入: `claude`, `cc`, `codex`, `opencode`, `openhands`, `aris`, `deepseek`

### 4. 各 Agent 接入 agentmemory

| Agent | 改动 |
|-------|------|
| OpenCode | `C:\Users\admin\.config\opencode\opencode.json` 加 mcp.agentmemory |
| DeepSeek CLI | `D:\devtools\deepseek-cli\config.toml` 加 [mcp_servers.agentmemory] |
| CC 家族 | 已通过 MCP stdio 连接 |
| Codex | 已通过 plugin 系统连接 |

### 5. agentmemory 数据初始化

导入 6 条核心记忆: 角色分工、科研硬规则、D盘规则、项目状态、环境规则、强制更新规则

## 当前状态

- Agent Hub: PID 28052, 端口 9800, 正常运行
- Key Rotator: 端口 9100, 正常
- PixelCat: 端口 8990, 正常
- agentmemory: stdio MCP, 数据在 C:\Users\admin\.agentmemory\data\
- 所有 agent 开机即用，无需手动操作
