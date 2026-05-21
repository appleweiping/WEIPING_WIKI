---
title: "D盘规则 — 所有 Agent 配置和数据必须在 D:\devtools"
type: preference
created: 2026-05-21T18:00:00+08:00
updated: 2026-05-21T18:00:00+08:00
agent: claude
tags: [d-drive, infrastructure, permanent, all-agents]
related: [agent-cli-launch-config.md]
---

## 规则

所有 agent 的配置文件、数据目录、skill 文件的实体必须存放在 `D:\devtools\`。C: 盘只允许存放指向 D: 的 junction/symlink。

## 适用范围

所有 agent: Claude Code, Codex, OpenCode, DeepSeek, OpenHands。

## 当前状态

| Agent | D: 实体 | C: junction |
|-------|---------|-------------|
| Claude Code | D:\devtools\claude\ | C:\Users\admin\.claude → D:\devtools\claude |
| Codex | D:\devtools\codex\home\ | C:\Users\admin\.codex → D:\devtools\codex\home |
| OpenHands | D:\devtools\openhands\home\ | C:\Users\admin\.openhands → D:\devtools\openhands\home |
| OpenCode | D:\devtools\opencode\ | (直接读 D:, 无需 junction) |
| DeepSeek | D:\devtools\deepseek-cli\ | (直接读 D:, 无需 junction) |

## Why

- C: 盘是系统盘，空间有限
- D: 盘是数据盘，方便备份和管理
- 统一位置减少混乱，所有 agent 都知道去哪里找配置
- 不影响任何实际使用（做项目、科研、配置、skill 都正常）

## How to apply

- 新装 agent 时，先在 D:\devtools\ 创建目录，再用 junction 指向
- 发现有 agent 把数据写到 C: 时，立即迁移到 D: 并创建 junction
- CLI 启动脚本统一放在 D:\devtools\*.cmd
