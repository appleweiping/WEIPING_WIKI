---
title: 你是 audit 工作流梳理 agent。只读梳理 audit gate / AI audit / human audit 工作流现状。请重点阅读 don...
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

# 你是 audit 工作流梳理 agent。只读梳理 audit gate / AI audit / human audit 工作流现状。请重点阅读 don...

## Metadata

- Stable ID: `codex-user-prompt:b5307a63b3c9f880`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-08T22:40:22.189Z`
- Semantic hash: `b5307a63b3c9f880905acaa449df04ea76a9303960818b72bb7340984ef76a02`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 audit 工作流梳理 agent。只读梳理 audit gate / AI audit / human audit 工作流现状。请重点阅读 donebench/scripts/audit_gate.py、ai_audit.py、annotation_agreement.py、human_audit_queue.py、annotation/annotation_guide.md、annotation/human_audit_queue.jsonl、reports/audit*、reports/full_runs/runs/topconf_deepseek_toolplan_full/audit_gate.json 和 pipeline_manifest.json。输出：1) 当前 blockers 的精确定义；2) 已有 DeepSeek merged AI audit 是否能解除 trusted coverage；3) GPT-5.5 targeted audit 应该审哪些任务、产物放哪；4) human audit 最小过关路径；5) 后续 Codex 的执行边界。不要修改文件。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
