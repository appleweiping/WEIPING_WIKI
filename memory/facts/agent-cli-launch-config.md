---
title: "Agent CLI 启动方式与配置位置"
type: fact
created: 2026-05-21T09:33:00+08:00
updated: 2026-05-21T18:00:00+08:00
agent: claude
tags: [agent-cli, launch, config, infrastructure]
related: [d-drive-rule.md]
---

## 所有 Agent 启动入口 (统一在 D:\devtools\)

| Agent | 启动命令 | 模型 |
|-------|---------|------|
| Claude Code (Opus) | `D:\devtools\cc.cmd` | Claude Opus 4.7 via PixelCat (127.0.0.1:8990) |
| OpenCode (像素猫) | `D:\devtools\opencode.cmd` | Claude Opus 4.7 via PixelCat |
| Codex (GPT-5.5) | `D:\devtools\codex.cmd` | GPT-5.5 via 127.0.0.1:9100 |
| DeepSeek CLI (鲸鱼) | `D:\devtools\deepseek.cmd` | DeepSeek V4 via api.deepseek.com |
| OpenHands | `D:\devtools\openhands.cmd` | Python agent framework |

## 配置位置 (实体全在 D:\devtools\)

| Agent | 实际配置路径 | C:盘 junction |
|-------|------------|--------------|
| Claude Code | D:\devtools\claude\ | C:\Users\admin\.claude → D:\devtools\claude |
| Codex | D:\devtools\codex\home\ | C:\Users\admin\.codex → D:\devtools\codex\home |
| OpenCode | D:\devtools\opencode\config\ | (直接读 D:) |
| DeepSeek | D:\devtools\deepseek-cli\ | (直接读 D:) |
| OpenHands | D:\devtools\openhands\home\ | C:\Users\admin\.openhands → D:\devtools\openhands\home |

## 共享记忆

所有 agent 通过读写 `D:\research\Vipin's Knowledgebase\memory\` 目录下的 markdown 文件共享记忆。无需任何服务器。

## 基础设施 (开机自启)

- PixelCat (port 8990): Claude 家族 API 代理
- Agent Hub Daemon (port 9800): Agent 间实时通信
