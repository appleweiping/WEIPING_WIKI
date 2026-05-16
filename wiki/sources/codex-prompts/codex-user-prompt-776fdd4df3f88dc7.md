---
title: 工作区：D -\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark M...
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

# 工作区：D:\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark M...

## Metadata

- Stable ID: `codex-user-prompt:776fdd4df3f88dc7`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-07T10:13:45.007Z`
- Semantic hash: `776fdd4df3f88dc75d6a255f04be9fbd38ed14cae85993f28efa35af36fa39d1`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
工作区：D:\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark MVP，已有 pyproject、donebench 包、data/tasks 100个生成任务、CLI、tests。任务：扩展 API-backed 模型实验框架，直接编辑你的 fork 中文件。职责范围只包括 donebench/agents/llm_adapters.py、donebench/agents/*.py、configs/models.yaml、configs/experiments.yaml、donebench/scripts/run_experiments.py 中的模型/runner相关改动。目标：支持 OpenAI-compatible、Anthropic、Gemini、OpenRouter、Ollama/vLLM 风格的配置占位；没有 key 时 graceful skip/blocker；有 key 时 runner 可选择模型矩阵。不要改数据生成/paper。最后列出改动文件和如何运行。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
