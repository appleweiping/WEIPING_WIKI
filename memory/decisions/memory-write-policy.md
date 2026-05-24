---
title: "Memory Write Policy — 何时写入、谁来写、写什么"
type: decision
created: 2026-05-21T20:00:00+08:00
updated: 2026-05-22T22:00:00+08:00
agent: claude
tags: [memory, policy, all-agents, permanent, critical]
related: [agent-roles-and-skills.md, research-hard-rules.md]
---

## 存储分层规则（2026-05-22 更新）

**不再双写。每类信息只存一个地方，各层有明确分工。**

| 信息类型 | 存储位置 | 原因 |
|---------|---------|------|
| fact / decision / preference / workflow | **Vipin's Knowledgebase markdown** (`D:\research\...\memory\`) | 人类可读、git 追踪、IDE 可浏览 |
| lesson（经验教训、踩坑） | **agentmemory MCP** (lesson_save) | 自动衰减/强化机制有意义 |
| signal / action / lease | **agentmemory MCP** | 纯运行时跨 agent 协调 |
| CC 专属偏好/反馈 | **CC auto-memory** (`C:\Users\admin\.claude\projects\...\memory\`) | 仅 CC 需要 |
| agentmemory 摘要指针 | **agentmemory MCP** (memory_save, 简短摘要 + 指向 markdown 路径) | 让其他 agent 能搜到，然后去读 markdown |

### 关键规则

1. **fact/decision 不再写入 agentmemory 全文** — 只写一行摘要 + markdown 文件路径作为指针
2. **lesson 不再写 markdown** — 只存 agentmemory，靠 confidence 衰减自动管理生命周期
3. **已有的 agentmemory 数据不删除** — 自然衰减即可
4. **已有的 markdown 文件不删除** — 保持现状，后续按新规则写入

## 核心原则

**不依赖 agent 判断"是否重要"。用事件触发 + 结构化审计代替模糊的"如果重要就写"。**

## 强制写入事件（任何 agent 遇到以下事件必须写 memory）

### 科研项目

| 事件 | 写入位置 | 内容 |
|------|---------|------|
| ARIS 步骤完成 | `facts/<project>-status.md` | 更新项目状态、当前步骤、下一步 |
| 用户做出重要决策 | `decisions/<topic>.md` | 决策内容、原因、影响范围 |
| 发现 bug 或踩坑 | `lessons/<slug>.md` | 问题、根因、解决方案 |
| 用户表达偏好/规则 | `preferences/<slug>.md` | 规则、原因、适用范围 |
| 项目状态发生变化 | `facts/<project>-status.md` | 更新状态 |
| 收到其他 agent 的重要消息 | 对应类别 | 提取关键信息写入 |
| Session 结束（显著 session） | `sessions/YYYY-MM-DD_<slug>.md` | 做了什么、结论、下一步 |

### 软件开发

| 事件 | 写入位置 | 内容 |
|------|---------|------|
| PR merge / deploy / feature 完成 | `sessions/YYYY-MM-DD_<feature>.md` | 做了什么、关键决策、遗留问题 |
| Bug 修复完成 | `lessons/<bug-slug>.md` | 根因、修复方案、预防策略 |
| 架构/技术决策 | `decisions/<topic>.md` | 选了什么、考虑过的替代方案、为什么 |
| 项目初始化 / 重大重构 | `facts/<project>-status.md` | 技术栈、架构、关键约束 |
| 新依赖/工具引入 | `decisions/<tool-choice>.md` | 选了什么、为什么、替代方案 |
| 性能优化完成 | `lessons/<optimization>.md` | 瓶颈、方案、效果数据 |

## 不需要写入的情况

- 简单问答（"这个函数怎么用"）
- 纯执行任务（"格式化这个文件"）
- 信息已经在代码/git 里（不重复记录代码变更）
- 临时调试过程（除非发现了值得记录的 lesson）

## 自动分类规则（agent 全自动执行，不需要用户确认）

Agent 写入 memory 时，按以下规则自动选择目录和文件名：

### 目录选择

| 内容特征 | 目录 |
|---------|------|
| 选择了 A 而不是 B，有 trade-off | `decisions/` |
| 当前状态、进度、配置 | `facts/` |
| 出了问题、踩了坑、修了 bug | `lessons/` |
| 用户说"以后都要..."、"不要..." | `preferences/` |
| 可复用的步骤、流程、方法 | `workflows/` |
| 今天做了什么（session 总结） | `sessions/` |

### 文件名生成

格式：`lowercase-kebab-case.md`

规则：
- 从内容中提取核心主题（2-4 个词）
- 项目相关的加项目前缀：`pony-ccrp-v2-decision.md`
- Session 文件加日期前缀：`2026-05-21_memory-system-overhaul.md`
- 如果同名文件已存在，更新而不是创建新文件

### 自动执行流程

1. 检测到触发事件
2. 确定内容类别 → 选择目录
3. 生成文件名（检查是否已存在同主题文件）
4. 写入文件（完整 YAML frontmatter + 内容）
5. 运行 `python scripts/rebuild-memory-index.py` 更新索引

整个过程不需要问用户。Agent 直接做。

## 每次任务完成后的强制记录（所有 agent）

**每个 agent 完成一个 prompt/任务后，必须把相关贡献、结论、所作所为写入对应文件。** 不需要用户提醒。这是自动行为。

### 写入位置（两处都要更新）：

**1. 共享 memory（跨 agent 可见）：**
- 完成了什么 → 更新对应 `facts/` 文件（项目状态）
- 做了什么决策 → 写 `decisions/`
- 发现了什么 → 写 `lessons/`
- Session 有重要产出 → 写 `sessions/`

**2. 项目自身的重要文件（项目内可见）：**
- 更新项目的 `AGENTS.md` 或 `docs/` 里的进度文档
- 更新项目的 experiment tracker / milestone 文件
- 更新项目的 `CHANGELOG.md` 或 `log.md`（如果有）
- 确保项目目录内的人能看到最新进展，不只是 memory 里有

**触发时机（硬规则）：** 完成一个阶段、一个 step、一次错误排除、一次贡献，都必须同时更新 memory + 项目文档。不是"做完所有事再统一更新"，而是每一步都更新。

**不写 = 违规。** 下一个 agent 开 session 时如果发现状态文件没更新，说明上一个 agent 没遵守规则。

## Session 结束审计（close-day 模式）

每个显著 session 结束时，agent 应该：
1. 回顾本次 session 做了什么
2. 检查是否有未写入的决策/发现/状态变更
3. 写入遗漏的 memory
4. 更新 INDEX.md

CC 的 Stop hook 会提醒执行这一步。

## Memory 生命周期

| 阶段 | 说明 |
|------|------|
| **创建** | 事件触发 → agent 写入对应目录 |
| **访问** | Session 开始时读 INDEX.md，按需读具体文件 |
| **更新** | 事实变化时原地更新（git 保留历史） |
| **归档** | 项目完成后，将 facts 移到 sessions/ 作为历史记录 |

## 质量保证

- 每个 memory 文件必须有完整 YAML frontmatter
- 标题必须具体（不允许"杂项笔记"这种模糊标题）
- 写完后运行 `python scripts/rebuild-memory-index.py` 更新索引
- 定期（每周）检查是否有过时的 facts 需要更新
