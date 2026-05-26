---
title: "科研项目核心执行规则"
type: decision
created: 2026-05-25
updated: 2026-05-25
agent: opus
tags: [research, rules, ARIS, permanent, all-agents]
related: [research-hard-rules.md, proteinshift-status.md, memory-write-policy.md]
---

# 科研项目核心执行规则 (永久生效)

用户于 2026-05-25 确认，适用于所有科研项目，所有 agent 必须遵守。

## 方法与质量

1. **禁止 toy 化** — 所有实验、baseline、方法必须完整版本，不得简化
2. **Opus 先想后做** — 遇到复杂问题先规划思路再动手，不冲动
3. **Codex 5.5/GPT 作为 reviewer** — 代码和方案需经 review
4. **8 个 official baseline** — 必须用官方代码，禁止 proxy 实现
5. **自研方法必须创新** — 禁止缝合，必须有新理论贡献

## 流程与规范

6. **严格 ARIS 流程** — research-refine → experiment-plan → experiment-bridge → experiments → paper-write
7. **每次改动必须三同步**: commit+push GitHub + 更新 agentmemory + 更新项目重要文档
8. **GitHub 推送前检查隐私** — API key, token, credentials 不得泄露
9. **Todo list 永不遗忘** — 新 prompt 只能在已有 todolist 基础上增加任务，不得覆盖或遗忘

## 监控与持久化

10. **异常即时汇报** — API key 不可用、服务器空间不足等问题立即告知用户
11. **长期监控** — 每 2 小时检查实验进度，直到论文写作完成
12. **持久化** — 电脑关机/重连后，后续 agent 必须能从文档中接手实验
13. **适用范围** — 以上规则适用于所有科研项目，永久执行
