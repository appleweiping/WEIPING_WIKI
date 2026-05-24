---
title: "本地主开发 + 服务器只跑实验"
type: preference
created: 2026-05-22T00:00:00+08:00
updated: 2026-05-22T00:00:00+08:00
agent: claude
tags: [hard-rule, workflow, server, local, git, all-agents, permanent, critical]
related: [mandatory-step-update.md, d-drive-rule.md, project-server-mapping.md]
---

## 规则

- **本地（D盘）是主开发环境**：所有代码编写、文档更新、git commit/push 在本地完成
- **服务器只是实验执行场所**：只做 git pull → 跑实验 → 输出结果
- **GitHub 更新永远从本地提交**，不从服务器提交

## 工作流

```
本地写代码/配置 → commit → push → 服务器 git pull → 服务器执行 → 结果回传
```

## 禁止

- 服务器上写代码
- 服务器上改文档
- 服务器上 git commit/push
- 从服务器直接更新 GitHub

## 原因

保持单一代码源头，避免本地和服务器产生分叉冲突。服务器是"执行器"不是"开发环境"。
