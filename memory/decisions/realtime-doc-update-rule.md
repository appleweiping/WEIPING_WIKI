---
title: "硬规则：实时更新文档和 memory"
type: decision
created: 2026-05-21T23:45:00+08:00
updated: 2026-05-21T23:45:00+08:00
agent: claude
tags: [documentation, memory, hard-rule, permanent, all-agents, critical]
related: [memory-write-policy.md, auto-update-docs.md]
---

## 规则

每完成一个阶段、一个 step、一次错误排除、一次贡献，都必须**立即**更新到：
1. 共享 memory (`D:\research\Vipin's Knowledgebase\memory\`) 中的相关文件
2. 项目自身的关键文档（PROJECT_MEMORY.md, PHASE_HANDOFF.md, README 等）

## 触发条件

- 完成一个实验阶段 → 更新项目状态 + memory fact
- 完成一个代码 step → 更新 PHASE_HANDOFF + 相关 doc
- 排除一个错误/bug → 记录到 memory lesson 或项目 doc
- 做出一个贡献（新功能、新发现、新决策）→ 更新所有相关文档

## 不允许

- 攒着不写，等"全部做完"再更新
- 只更新一处而忽略另一处（memory 和项目 doc 必须同步）
- 认为"太小不值得记"——任何有意义的进展都要记

## 为什么

用户多次发现 agent 做了工作但没记录，导致：
- 下一个 session 的 agent 从零开始
- 被过时信息误导做错误决策
- 重复踩已经解决过的坑

这是硬规则，不是建议。违反此规则等于工作没做。
