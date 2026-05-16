---
title: 现在开始实作，写入范围限定在后端/CLI/tests/docs，避免碰 frontend dashboard 以免和主 agent 冲突。你不是一个人在代...
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

# 现在开始实作，写入范围限定在后端/CLI/tests/docs，避免碰 frontend dashboard 以免和主 agent 冲突。你不是一个人在代...

## Metadata

- Stable ID: `codex-user-prompt:0dbde13815f47abb`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-12T19:35:43.159Z`
- Semantic hash: `0dbde13815f47abb3e366c2901c0552d90d6ece8313a0df4a3324f9a3e4401c8`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
现在开始实作，写入范围限定在后端/CLI/tests/docs，避免碰 frontend dashboard 以免和主 agent 冲突。你不是一个人在代码库里，不要 revert 他人改动。请实现以下高确定性修复：
1. 抽出共享 ingest profiles helper，API /ingest/profiles 和 CLI ingest --profile 都使用同一事实来源；CLI --profile 要应用 query/max_results/sources 默认值，并允许显式参数覆盖。
2. 统一 BibTeX export/citation key：API 和 CLI export 都使用 library/bibtex.py 的 canonical 函数，不再重复实现。
3. 抽出 connector health extraction 和 library saved views helper，API 和 CLI doctor 复用，减少漂移。
4. RAG vector/document lifecycle：删除 paper 时清理 local vector index 中对应 paper/document chunks，或添加清理 helper；补测试。
5. 更新相关 API/CLI tests 和 docs，运行后端检查。
请直接修改文件并在最终回复列出修改路径、验证命令和任何未完成事项。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
