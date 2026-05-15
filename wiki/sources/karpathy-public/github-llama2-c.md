---
title: "llama2.c"
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
  - https://github.com/karpathy/llama2.c
---

# llama2.c

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/llama2.c
- Discovery source: https://github.com/karpathy/llama2.c
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `efc5d59dc4245b93ee7f1578d4a4c35c5e42da0a251632d97209a2e4fe506251`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

llama2.c Have you ever wanted to inference a baby $1 model in pure C? No? Well, now you can! Train the Llama 2 LLM architecture in PyTorch then inference it with one simple 700-line C file ($1). You might think that you need many billion parameter LLMs to do anything useful, but in fact very small LLMs can have surprisingly strong performance if you make the domain narrow enough (ref: $1 paper). This repo is a "fullstack" train + inference solution for Llama 2 LLM, with focus on minimalism and simplicity. As the architecture is identical, you can also load and inference Meta's Llama 2 models. However, the current...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/llama2.c`
- Default branch: `master`
- HEAD: `350e04fe35433e6d2941dce5a1f53308f87058eb`
- Stars at crawl: 19506
- Forks at crawl: 2548
- File count: 25
- README path: `README.md`
- License path: `LICENSE`
- Created: 2023-07-23T05:15:06Z
- Updated: 2026-05-15T18:28:04Z
- Pushed: 2024-08-06T09:44:40Z

### Top-Level Structure

- `[root]`: 21
- `doc`: 2
- `.github`: 1
- `assets`: 1

### File Extension Profile

- `.py`: 8
- `.c`: 4
- `.md`: 3
- `[none]`: 2
- `.bat`: 1
- `.bin`: 1
- `.h`: 1
- `.ipynb`: 1
- `.jpg`: 1
- `.model`: 1
- `.txt`: 1
- `.yml`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.github/workflows/build.yml`
- `assets/llama_cute.jpg`
- `build_msvc.bat`
- `configurator.py`
- `doc/stories260K.md`
- `doc/train_llama_tokenizer.md`
- `export.py`
- `LICENSE`
- `Makefile`
- `model.py`
- `README.md`
- `requirements.txt`
- `run.c`
- `run.ipynb`
- `runq.c`
- `sample.py`
- `test.c`
- `test_all.py`
- `tinystories.py`
- `tokenizer.bin`
- `tokenizer.model`
- `tokenizer.py`
- `train.py`
- `win.c`
- `win.h`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
