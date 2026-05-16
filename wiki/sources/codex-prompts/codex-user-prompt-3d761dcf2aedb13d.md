---
title: 你是 DoneBench 的实现助手。请只读分析以下文件并给出最小实现方案，不要改文件：donebench/scripts/advanced_stats....
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

# 你是 DoneBench 的实现助手。请只读分析以下文件并给出最小实现方案，不要改文件：donebench/scripts/advanced_stats....

## Metadata

- Stable ID: `codex-user-prompt:3d761dcf2aedb13d`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-09T23:40:34.676Z`
- Semantic hash: `3d761dcf2aedb13de2f6cabb6bd0f145b074ed899d63c63e497f220b5f6286b4`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 DoneBench 的实现助手。请只读分析以下文件并给出最小实现方案，不要改文件：donebench/scripts/advanced_stats.py, donebench/scripts/failure_mining.py, donebench/scripts/near_miss_breakdown.py, donebench/scripts/paper_refresh.py, donebench/scripts/experiment_pipeline.py, donebench/cli.py. 目标是生成 M6.1 诊断输出：四象限表、自我违反 taxonomy、near-miss × success 诊断表，输出到 reports/full_runs/runs/topconf_deepseek_toolplan_full/diagnostics/，并刷新 paper/tables。请返回：1) 哪个现有脚本最适合扩展；2) 需要哪些输入文件；3) 建议输出文件名；4) 最小新增代码路径。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
