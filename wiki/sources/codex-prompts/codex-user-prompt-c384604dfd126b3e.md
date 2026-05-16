---
title: 工作区：D -\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark M...
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

# 工作区：D:\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark M...

## Metadata

- Stable ID: `codex-user-prompt:c384604dfd126b3e`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-07T10:13:45.493Z`
- Semantic hash: `c384604dfd126b3e11343a41c5d1f7a7db460ad833733c83353b0797c0a8175e`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
工作区：D:\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark MVP，已有 pyproject、donebench 包、data/tasks 100个生成任务、CLI、tests。任务：扩展任务生成与数据审计框架，直接编辑你的 fork 中文件。职责范围只包括 donebench/scripts/generate_seed_tasks.py、donebench/scripts/audit_tasks.py、data/schemas/*.json、reports/decisions.md 中与数据生成相关的段落。目标：让生成器支持每个 domain 多种 task pattern、difficulty 分布、mutation taxonomy、task stats 输出；保持 100 task validation 可过。不要改 runner/agents/paper。最后列出改动文件和如何运行。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
