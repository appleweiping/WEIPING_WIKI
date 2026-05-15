---
title: "minbpe"
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
  - https://github.com/karpathy/minbpe
---

# minbpe

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/minbpe
- Discovery source: https://github.com/karpathy/minbpe
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `0be8f093000a07d5385b32a3272fca8b2d12e3062156b531977dc81b95a347fa`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

minbpe Minimal, clean code for the (byte-level) Byte Pair Encoding (BPE) algorithm commonly used in LLM tokenization. The BPE algorithm is "byte-level" because it runs on UTF-8 encoded strings. This algorithm was popularized for LLMs by the $1 and the associated GPT-2 $1 from OpenAI. $1 is cited as the original reference for the use of BPE in NLP applications. Today, all modern LLMs (e.g. GPT, Llama, Mistral) use this algorithm to train their tokenizers. There are two Tokenizers in this repository, both of which can perform the 3 primary functions of a Tokenizer: 1) train the tokenizer vocabulary and merges on a...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/minbpe`
- Default branch: `master`
- HEAD: `1acefe89412b20245db5a22d2a02001e547dc602`
- Stars at crawl: 10482
- Forks at crawl: 1046
- File count: 16
- README path: `README.md`
- License path: `LICENSE`
- Created: 2024-02-16T16:18:15Z
- Updated: 2026-05-15T16:21:17Z
- Pushed: 2024-07-01T14:20:22Z

### Top-Level Structure

- `[root]`: 7
- `minbpe`: 5
- `tests`: 3
- `assets`: 1

### File Extension Profile

- `.py`: 8
- `.md`: 3
- `.txt`: 2
- `.gitignore`: 1
- `.png`: 1
- `[none]`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitignore`
- `assets/tiktokenizer.png`
- `exercise.md`
- `lecture.md`
- `LICENSE`
- `minbpe/__init__.py`
- `minbpe/base.py`
- `minbpe/basic.py`
- `minbpe/gpt4.py`
- `minbpe/regex.py`
- `README.md`
- `requirements.txt`
- `tests/__init__.py`
- `tests/taylorswift.txt`
- `tests/test_tokenizer.py`
- `train.py`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
