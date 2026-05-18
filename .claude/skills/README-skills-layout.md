---
name: skills-directory-layout
description: |
  说明全局 .claude/skills 的 junction 链接结构，以及 D 盘上 skill 文件夹的组织方式。
  未来 agent 在查找 skill、安装新 skill、或理解为什么有多个 skill 目录时参考此文件。
metadata:
  type: reference
---

# Skills 目录结构说明

## 全局 Junction

`C:\Users\admin\.claude\skills\` 是一个 NTFS junction，指向：

```
D:\Research\vipin's knowledgebase\.claude\skills\
```

C 盘不存实际文件，只有链接。所有 skill 的增删改都在 D 盘操作。

## D 盘 Skill 相关目录

| 路径 | 用途 |
|------|------|
| `D:\Skill\` | 本地 skill 仓库收藏（git clone 的原始 repo） |
| `D:\Research\vipin's knowledgebase\.claude\skills\` | Claude Code 全局加载的 skill（通过 junction） |
| `D:\Research\vipin's knowledgebase\.codex\skills\` | Codex agent 用的 skill 目录 |

## 当前已安装的 Claude skills

- `lidang-perspective` — 立党思维框架 skill（女娲流程蒸馏）
- `mattpocock-skills` — Matt Pocock 的工程 skill 集合（/tdd, /grill-me, /diagnose 等）

## 操作规则

- 新增 skill → 放到 `D:\Research\vipin's knowledgebase\.claude\skills\` 下，junction 会自动让全局可见
- 不要在 C 盘 `.claude\skills\` 下直接创建文件（它是 junction，写入会落到 D 盘，但语义上应该去 D 盘操作）
- `D:\Skill\` 是素材库/归档，不会被 Claude Code 自动加载
- mattpocock skills 的使用需要先在项目里跑一次 `/setup-matt-pocock-skills`

## 为什么有三个文件夹

历史原因：
1. `.claude/skills/` — Claude Code 的 skill 加载路径
2. `.codex/skills/` — OpenAI Codex 的 skill 加载路径
3. `D:\Skill\` — 用户自己的 git repo 收藏夹

如果只用 Claude Code，关注 `.claude/skills/` 即可。

## Agent Hub MCP Server

位置：`D:\devtools\agent-hub\`

多 Agent 实时协作总线（MCP server + HTTP daemon）。

- MCP server: `agent-hub.mjs`（16 tools，每个 agent spawn 自己的实例）
- HTTP daemon: `daemon.mjs`（端口 9800，自动 dispatch + 容错重试 + pipeline 引擎 + 绩效追踪）
- Claude Code MCP 注册：`C:\Users\admin\.claude\mcp.json`
- Codex MCP 注册：`C:\Users\admin\.codex\config.toml` → `[mcp_servers.agent_hub]`
- 共享状态：`D:\devtools\agent-hub\state\`
- 绩效数据：`D:\devtools\agent-hub\state\metrics.json`
- 开机自启动：`shell:startup` 里有 `pixelcat.cmd` 和 `agent-hub-daemon.cmd`

详细文档见 `D:\devtools\agent-hub\README.md` 和项目根目录的 `CLAUDE.md`。
