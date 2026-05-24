---
title: "硬规则：本地主开发 + 服务器只跑实验"
type: decision
created: 2026-05-21T23:55:00+08:00
updated: 2026-05-21T23:55:00+08:00
agent: claude
tags: [workflow, server, local, hard-rule, permanent, all-agents, critical]
related: [realtime-doc-update-rule.md, research-hard-rules.md]
---

## 规则

- **本地（Windows）是主开发环境**：所有代码编辑、文档更新、git commit/push 都在本地完成
- **服务器只作为实验场所**：只做 git pull → 跑 GPU 实验 → 产出 logs/metrics/artifacts
- **GitHub 更新从本地提交**：不从服务器 push

## 工作流

```
本地：编辑代码/文档 → commit → push to GitHub
服务器：git pull → 跑实验 → 产出结果
用户：把服务器 log/metrics 贴回来
本地：分析结果 → 更新文档 → commit → push
```

## 不允许

- 在服务器上改代码然后 push
- 在服务器上 commit
- 把服务器当开发环境用
