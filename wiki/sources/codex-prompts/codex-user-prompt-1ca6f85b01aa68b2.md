---
title: 追加 reviewer 发现，请纳入你的后端实作范围：
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

# 追加 reviewer 发现，请纳入你的后端实作范围：

## Metadata

- Stable ID: `codex-user-prompt:1ca6f85b01aa68b2`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-12T19:38:05.585Z`
- Semantic hash: `1ca6f85b01aa68b27dad0d52bded3dccec4c1262598606fe58234e813f60b145`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
追加 reviewer 发现，请纳入你的后端实作范围：
P0: AUTH_MODE=token 目前不保护 mutating API。请实现后端 auth dependency：当 settings.auth_mode != disabled 时，所有 mutating routes（POST/PATCH/PUT/DELETE，允许 /health/runtime/connectors/readiness 读操作）需要 Authorization header，否则 401。不要在 frontend 存 secrets；用 simple bearer presence baseline 即可，文档标明不是完整 RBAC。
P1: scheduler/report artifact id 碰撞；CLI rag ask 对 bad paper id 要非零/报错；ingest source invalid 不要静默 fallback arxiv；/evaluation/run RAG 全 0 命中不应 overall_status ok，可用 warning/degraded；readiness notifications.delivery_enabled 语义改成 false 或 provider_delivery_enabled false，避免和 preview 冲突。
继续保持后端/CLI/tests/docs 写入范围，不碰 frontend dashboard。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
