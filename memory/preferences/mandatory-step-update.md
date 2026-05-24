---
title: "强制更新规则 — 每步完成必须同步 memory + 项目文档"
type: preference
created: 2026-05-21T23:45:00+08:00
updated: 2026-05-21T23:45:00+08:00
agent: claude
tags: [hard-rule, memory, documentation, all-agents, permanent, critical]
related: [auto-update-docs.md, memory-write-policy.md]
---

## 规则

每完成一个阶段、一个 step、一次错误排除、一次贡献，**必须同时更新**：

1. **Memory**（shared memory `D:\research\Vipin's Knowledgebase\memory\` + local memory）
2. **项目文档**（README、CLAUDE.md、CONTEXT.md、codex_project_memory、phase plan 等关键文件）

## 触发条件

以下任何一种情况发生后，立即执行更新：
- 完成一个实验/实现阶段
- 完成一个具体 step（如"gate训练完成"、"observation跑完"）
- 排除一个错误/bug
- 产出一个贡献（新代码、新文档、新结论）
- 状态变更（如"pending → completed"、"blocked → resolved"）

## 执行方式

- 不需要问用户"要不要更新"——直接做
- 如果有 git 仓库，更新后 commit 并 push
- 两边内容保持一致（memory 记结论和状态，项目文档记详细内容）

## 违反后果

如果只更新一边：
- 只更新 memory 不更新项目文档 → 其他 agent 进项目看不到最新状态
- 只更新项目文档不更新 memory → 跨 session 信息丢失

两边必须同步。这是硬规则，不是建议。
