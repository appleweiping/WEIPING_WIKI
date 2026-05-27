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
- **实验必须在服务器运行，禁止在本地电脑跑实验**：本地没有 GPU，也不应该占用本地资源跑耗时任务

## 工作流

```
本地写代码/配置 → commit → push → SSH到服务器 → git pull → 服务器执行实验 → 结果 scp 回本地
```

## 禁止

- 服务器上写代码
- 服务器上改文档
- 服务器上 git commit/push
- 从服务器直接更新 GitHub
- **在本地电脑运行实验脚本**（python train/eval/experiment 等耗时任务）
- 在本地跑任何需要 GPU 的任务

## 原因

1. 保持单一代码源头，避免本地和服务器产生分叉冲突。服务器是"执行器"不是"开发环境"。
2. 本地电脑没有实验级 GPU，跑实验会卡死机器且结果不可靠。所有实验（训练、评估、大规模推理）必须 SSH 到服务器执行。
