---
title: 工作区 D -\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：设计/实现 AI-assisted audit 管线...
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

# 工作区 D:\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：设计/实现 AI-assisted audit 管线...

## Metadata

- Stable ID: `codex-user-prompt:5cd68ebeac91ce41`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-07T14:41:39.468Z`
- Semantic hash: `5cd68ebeac91ce41976e27bd71bded60413b3e12246ec842b48594441991829b`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
工作区 D:\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：设计/实现 AI-assisted audit 管线。职责范围：新增/修改 donebench/scripts/ai_audit.py、donebench/cli.py 中相关命令、annotation/ 或 reports/audit 相关文件、tests 中对应测试。目标：读取 annotation/human_audit_queue.jsonl 或 data/tasks，调用配置模型（可 fallback/mock），输出 JSONL 审计意见、risk labels、需要人工 adjudication 的条目。不要改任务生成器。最后报告改动文件、运行方式、验证。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
