---
title: 只读探索任务，不要修改文件。请把当前 analog-agent 与外部参考（AnalogGym、AnalogCoder、AnalogGenie、AICir...
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

# 只读探索任务，不要修改文件。请把当前 analog-agent 与外部参考（AnalogGym、AnalogCoder、AnalogGenie、AICir...

## Metadata

- Stable ID: `codex-user-prompt:39cf3e1ec375383a`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-11T15:33:17.294Z`
- Semantic hash: `39cf3e1ec375383a862aecd7019a879de228a36bad96a38839fd401cac2e0af1`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
只读探索任务，不要修改文件。请把当前 analog-agent 与外部参考（AnalogGym、AnalogCoder、AnalogGenie、AICircuit、OpenFASOC/ALIGN、ChipNeMo、VerilogEval、RTLFixer、HaVen、I-JEPA/V-JEPA 2/TD-MPC2/DreamerV3）对比，扮演一个顶会审稿人：列出本项目最容易被质疑的 5-8 个问题，哪些地方会被认为是 toy / stitching / lack of novelty / lack of rigorous evaluation，并给出每个问题如果要让项目站得住，最低需要补的证据或架构改动。输出中文，短而狠，优先结论。不要修改任何文件。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
