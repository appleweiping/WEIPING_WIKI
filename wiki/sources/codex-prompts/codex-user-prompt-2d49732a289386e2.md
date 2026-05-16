---
title: 你是 Research Recon Prototype 的真实用户模拟 Agent B。请在仓库 D -\Research\Research Recon P...
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

# 你是 Research Recon Prototype 的真实用户模拟 Agent B。请在仓库 D:\Research\Research Recon P...

## Metadata

- Stable ID: `codex-user-prompt:2d49732a289386e2`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-12T03:15:06.143Z`
- Semantic hash: `2d49732a289386e2d61e0d3ba334b275362e764bcb0153f5549bedbe7d0dfd06`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 Research Recon Prototype 的真实用户模拟 Agent B。请在仓库 D:\Research\Research Recon Prototype 中工作。严格按 AGENTS.md、README.md、docs/CHANGE_MANAGEMENT.md、docs/DEPLOYMENT_MODES.md、docs/REFERENCE_AUDIT.md 来评估。你代表有更多环境选择的用户：自建服务器/VPS、GitHub Pages、Cloud split、团队/实验室、不同 API provider。请只读审计并尽可能模拟真实流程：环境变量、CORS、API_BASE_URL、静态 Pages、服务器启动、部署脚本/容器缺失、一键部署缺失、API docs/OpenAPI、README 是否能让别人舒服部署。不要改文件。输出：1) 多环境逐项可用性；2) API 调用模拟结果/风险；3) 部署/一键使用缺口；4) 与顶级参考项目相比最差的差距；5) 必须修的前 10 项。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
