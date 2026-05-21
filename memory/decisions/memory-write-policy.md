---
title: "Memory Write Policy — 何时写入、谁来写、写什么"
type: decision
created: 2026-05-21T20:00:00+08:00
updated: 2026-05-21T20:00:00+08:00
agent: claude
tags: [memory, policy, all-agents, permanent, critical]
related: [agent-roles-and-skills.md, research-hard-rules.md]
---

## 核心原则

**不依赖 agent 判断"是否重要"。用事件触发 + 结构化审计代替模糊的"如果重要就写"。**

## 强制写入事件（任何 agent 遇到以下事件必须写 memory）

| 事件 | 写入位置 | 内容 |
|------|---------|------|
| ARIS 步骤完成 | `facts/<project>-status.md` | 更新项目状态、当前步骤、下一步 |
| 用户做出重要决策 | `decisions/<topic>.md` | 决策内容、原因、影响范围 |
| 发现 bug 或踩坑 | `lessons/<slug>.md` | 问题、根因、解决方案 |
| 用户表达偏好/规则 | `preferences/<slug>.md` | 规则、原因、适用范围 |
| 项目状态发生变化 | `facts/<project>-status.md` | 更新状态 |
| 收到其他 agent 的重要消息 | 对应类别 | 提取关键信息写入 |
| Session 结束（显著 session） | `sessions/YYYY-MM-DD_<slug>.md` | 做了什么、结论、下一步 |

## 不需要写入的情况

- 简单问答（"这个函数怎么用"）
- 纯执行任务（"格式化这个文件"）
- 信息已经在代码/git 里（不重复记录代码变更）
- 临时调试过程（除非发现了值得记录的 lesson）

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
