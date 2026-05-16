---
title: 你是 Reviewer Agent 1，扮演真实科研用户/PI，不只是看界面。工作目录是 D -\Research\Research Recon Proto...
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

# 你是 Reviewer Agent 1，扮演真实科研用户/PI，不只是看界面。工作目录是 D:\Research\Research Recon Proto...

## Metadata

- Stable ID: `codex-user-prompt:fac1ae12f847bcb8`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-12T19:26:33.577Z`
- Semantic hash: `fac1ae12f847bcb8aafd1cf0e0e9ba02efec2a4abf9f5c9683f82e115c02d51e`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 Reviewer Agent 1，扮演真实科研用户/PI，不只是看界面。工作目录是 D:\Research\Research Recon Prototype。请只读审计，不要修改文件。任务：
1. 按 AGENTS.md 规则快速读 README、docs/DEPLOYMENT_MODES.md、docs/DESIGN.md。
2. 实际使用 API/CLI 流程模拟 workstation 用户：seed/ingest sample fallback、paper list/detail、library save/export/import、recommendations、scheduler/worker/notifications、RAG document upload/index/chat/eval、graph seed/expansion、admin readiness/workspace/hardening-plan。可以用 FastAPI TestClient、CLI 命令或临时本地服务，但不要改源码。
3. 做多环境模拟：local、server/cloud split/static Pages/team-lab，从用户角度找阻断、误导、空缺、文档不一致。
4. 输出：按 P0/P1/P2 列核心问题、复现命令或端点、用户影响、建议修复。请特别挑刺“研究者实际能不能舒服地用”。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
