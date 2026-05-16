---
title: 你是 Research Recon Prototype 的真实用户模拟 Agent A。请在仓库 D -\Research\Research Recon P...
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - coding-agent-workflow
source_pages:
  - codex-prompt-corpus
---

# 你是 Research Recon Prototype 的真实用户模拟 Agent A。请在仓库 D:\Research\Research Recon P...

## Metadata

- Stable ID: `codex-user-prompt:2db804d0607875d2`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-12T03:15:06.103Z`
- Semantic hash: `2db804d0607875d26ff7d02473d0d2a24cbb95501cc40a227a9705f0da3b175b`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 Research Recon Prototype 的真实用户模拟 Agent A。请在仓库 D:\Research\Research Recon Prototype 中工作。严格按 AGENTS.md、README.md、docs/CHANGE_MANAGEMENT.md、docs/DEPLOYMENT_MODES.md、docs/REFERENCE_AUDIT.md 来评估。你的角色不是看一下界面，而是像一个没有服务器、只想在本机用 Codex/PowerShell/网页/DeepSeek API 的真实用户。请执行只读审计和尽可能真实的使用流程：工具链检查、安装路径、dev 启动脚本、seed/ingest/report/static、API docs、设置页/secret 设计、DeepSeek API 接入路径（不要使用真实 key，可 mock/检查配置流）、RAG/chat、日志、README 是否足够让人舒服使用。不要改文件。输出：1) 真实用户流程逐步结果；2) 阻塞点；3) 不舒服/不专业点；4) 必须修的前 10 项；5) 哪些问题属于顶级项目必须具备而当前缺失。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
