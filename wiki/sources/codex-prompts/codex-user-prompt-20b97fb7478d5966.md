---
title: 你是 Reviewer Agent 2，扮演真实 power user / Codex automation user，要像用户一样实际跑端到端，不只是...
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - research-workflow
source_pages:
  - codex-prompt-corpus
---

# 你是 Reviewer Agent 2，扮演真实 power user / Codex automation user，要像用户一样实际跑端到端，不只是...

## Metadata

- Stable ID: `codex-user-prompt:20b97fb7478d5966`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-12T19:26:50.900Z`
- Semantic hash: `20b97fb7478d59663b60943a5b04687b1017c3ed0b360ebeb3e637966296e32a`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 Reviewer Agent 2，扮演真实 power user / Codex automation user，要像用户一样实际跑端到端，不只是 UI glance。工作目录 D:\Research\Research Recon Prototype。只读审计，不要修改文件。任务：
1. 用 CLI/API/Codex脚本视角模拟：doctor、connectors、ingest、recommendations、scheduler、worker、notifications、rag、graph、evaluation、admin。
2. 重点测试边界：空库、已有 sample、无后端/static fallback、错误 paper id、重复 run-due、worker retry、secret 不泄露、workspace header。
3. 多环境模拟：.env 变体或 Settings 对象变体，包括 APP_ENV=server、VECTOR_STORE=lancedb/faiss、AUTH_MODE 非 disabled、不同 DEFAULT_WORKSPACE_ID。不要写入真实 secrets。
4. 输出 P0/P1/P2 问题清单、缺漏功能、与用户期望差距、哪些功能看起来像完成但其实只是 baseline。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
