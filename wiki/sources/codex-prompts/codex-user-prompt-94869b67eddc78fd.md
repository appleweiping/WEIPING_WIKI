---
title: 做这些：跑 GPT-5.5 targeted audit，处理 ai_adjudication_queue_nonempty。
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

# 做这些：跑 GPT-5.5 targeted audit，处理 ai_adjudication_queue_nonempty。

## Metadata

- Stable ID: `codex-user-prompt:94869b67eddc78fd`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-08T22:52:40.098Z`
- Semantic hash: `94869b67eddc78fda9b7713ce1f0c76e575c6f20cb70a27d4378b9ec76a38682`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
做这些：跑 GPT-5.5 targeted audit，处理 ai_adjudication_queue_nonempty。

具体顺序：


读这两个文件：


reports/agent_handoff.md

reports/audit_gpt55_targeted_tasks.md


用 GPT-5.5 审那 46 个 targeted tasks，输出到：


text


reports/audit_gpt55_targeted/


把 GPT-5.5 audit 和现有 DeepSeek merged audit 合并到：

text


reports/audit_deepseek_gpt55_merged/


重新跑：

powershell


C:\Users\admin\AppData\Local\Programs\Python\Python312\python.exe -m donebench.cli audit-gate reports/full_runs/runs/topconf_deepseek_toolplan_full/audit_gate.json --annotation annotation/human_audit_queue.jsonl --ai-audit reports/audit_deepseek_gpt55_merged/ai_audit_opinions.jsonl


如果 GPT-5.5 能把 AI adjudication 队列清掉，
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
