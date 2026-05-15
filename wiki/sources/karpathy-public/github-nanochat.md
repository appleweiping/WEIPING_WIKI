---
title: "nanochat"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - inference
  - karpathy
  - llm
  - training
source_pages:
  - https://github.com/karpathy/nanochat
---

# nanochat

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/nanochat
- Discovery source: https://github.com/karpathy/nanochat
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `8af3544b26ed787f1f0a3c2dec602e7b606331727f2f03b2377984c79555a817`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

nanochat !$1 !$1 nanochat is the simplest experimental harness for training LLMs. It is designed to run on a single GPU node, the code is minimal/hackable, and it covers all major LLM stages including tokenization, pretraining, finetuning, evaluation, inference, and a chat UI. For example, you can train your own GPT-2 capability LLM (which cost ~$43,000 to train in 2019) for only $48 (~2 hours of 8XH100 GPU node) and then talk to it in a familiar ChatGPT-like web UI. On a spot instance, the total cost can be closer to ~$15. More generally, nanochat is configured out of the box to train an entire miniseries of com...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/nanochat`
- Default branch: `master`
- HEAD: `dc54a1a3077cab11d68fac4c5d1cd5c51f5d8c7a`
- Stars at crawl: 53492
- Forks at crawl: 7192
- File count: 56
- README path: `README.md`
- License path: `LICENSE`
- Created: 2025-10-13T13:46:35Z
- Updated: 2026-05-15T21:47:22Z
- Pushed: 2026-05-05T03:17:23Z

### Top-Level Structure

- `nanochat`: 17
- `dev`: 9
- `scripts`: 9
- `tasks`: 8
- `[root]`: 6
- `runs`: 4
- `tests`: 2
- `.claude`: 1

### File Extension Profile

- `.py`: 36
- `.md`: 4
- `.sh`: 4
- `.html`: 2
- `.ipynb`: 2
- `.png`: 2
- `.gitignore`: 1
- `.lock`: 1
- `.python-version`: 1
- `.svg`: 1
- `.toml`: 1
- `[none]`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.claude/skills/read-arxiv-paper/SKILL.md`
- `.gitignore`
- `.python-version`
- `dev/estimate_gpt3_core.ipynb`
- `dev/gen_synthetic_data.py`
- `dev/generate_logo.html`
- `dev/LEADERBOARD.md`
- `dev/LOG.md`
- `dev/nanochat.png`
- `dev/repackage_data_reference.py`
- `dev/scaling_analysis.ipynb`
- `dev/scaling_laws_jan26.png`
- `LICENSE`
- `nanochat/__init__.py`
- `nanochat/checkpoint_manager.py`
- `nanochat/common.py`
- `nanochat/core_eval.py`
- `nanochat/dataloader.py`
- `nanochat/dataset.py`
- `nanochat/engine.py`
- `nanochat/execution.py`
- `nanochat/flash_attention.py`
- `nanochat/fp8.py`
- `nanochat/gpt.py`
- `nanochat/logo.svg`
- `nanochat/loss_eval.py`
- `nanochat/optim.py`
- `nanochat/report.py`
- `nanochat/tokenizer.py`
- `nanochat/ui.html`
- `pyproject.toml`
- `README.md`
- `runs/miniseries.sh`
- `runs/runcpu.sh`
- `runs/scaling_laws.sh`
- `runs/speedrun.sh`
- `scripts/base_eval.py`
- `scripts/base_train.py`
- `scripts/chat_cli.py`
- `scripts/chat_eval.py`
- `scripts/chat_rl.py`
- `scripts/chat_sft.py`
- `scripts/chat_web.py`
- `scripts/tok_eval.py`
- `scripts/tok_train.py`
- `tasks/arc.py`
- `tasks/common.py`
- `tasks/customjson.py`
- `tasks/gsm8k.py`
- `tasks/humaneval.py`
- `tasks/mmlu.py`
- `tasks/smoltalk.py`
- `tasks/spellingbee.py`
- `tests/test_attention_fallback.py`
- `tests/test_engine.py`
- `uv.lock`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
