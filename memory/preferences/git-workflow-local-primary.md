---
title: "科研项目 Git 工作流 — 本地为主，服务器只跑实验"
type: preference
created: 2026-05-22T03:30:00+08:00
updated: 2026-05-22T03:30:00+08:00
agent: claude
tags: [git, workflow, server, permanent, all-agents, critical]
related: [project-server-mapping.md, experiment-fairness.md]
---

## 规则

- **本地是主仓库**，所有 commit 和 push 从本地发起
- **服务器只是实验场所** — 跑推理、跑训练、产出结果，不做 commit/push
- **GitHub 更新用本地提交**，不从服务器直接 push

## 工作流

1. 本地写代码/修改 → commit → push to GitHub
2. 服务器 `git pull` 拉取最新代码
3. 服务器跑实验，产出结果到 `results/` 或 `outputs/`
4. 把服务器产出（结果文件、日志）scp 回本地或记录到文档
5. 本地更新文档/memory → commit → push

## 例外

如果紧急需要在服务器上改代码（比如修 bug 才能跑通实验），可以临时在服务器改，但：
- 改完后必须把改动同步回本地
- 最终 push 仍然从本地发起
- 不要让服务器和本地长期分叉

## 项目路径对应

| 项目 | 本地路径 | 服务器路径 |
|------|---------|-----------|
| Pony/Uncertainty | D:\research\Uncertainty | ~/projects/pony-rec-rescue-shadow-v6/ |
| TGL-Rec | D:\research\TGL-Rec | 未部署 |
| TRUCE-Rec | D:\research\TRUCE-Rec | ~/projects/uncertainty-llm4rec/ |
