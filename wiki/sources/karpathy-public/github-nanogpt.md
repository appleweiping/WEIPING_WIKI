---
title: "nanoGPT"
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
  - https://github.com/karpathy/nanoGPT
---

# nanoGPT

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/nanoGPT
- Discovery source: https://github.com/karpathy/nanoGPT
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `2f170dfcb46470a93f72b8f85dbca39d8f68c50f35139fbc4d0dccc078bbbd73`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

nanoGPT !$1 --- Update Nov 2025 nanoGPT has a new and improved cousin called $1. It is very likely you meant to use/find nanochat instead. nanoGPT (this repo) is now very old and deprecated but I will leave it up for posterity. --- The simplest, fastest repository for training/finetuning medium-sized GPTs. It is a rewrite of $1 that prioritizes teeth over education. Still under active development, but currently the file train.py reproduces GPT-2 (124M) on OpenWebText, running on a single 8XA100 40GB node in about 4 days of training. The code itself is plain and readable: train.py is a ~300-line boilerplate traini...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/nanoGPT`
- Default branch: `master`
- HEAD: `3adf61e154c3fe3fca428ad6bc3818b27a3b8291`
- Stars at crawl: 58127
- Forks at crawl: 9986
- File count: 26
- README path: `README.md`
- License path: `LICENSE`
- Created: 2022-12-28T00:51:12Z
- Updated: 2026-05-15T21:37:40Z
- Pushed: 2025-11-12T19:52:34Z

### Top-Level Structure

- `[root]`: 11
- `config`: 7
- `data`: 6
- `assets`: 2

### File Extension Profile

- `.py`: 15
- `.md`: 4
- `.ipynb`: 2
- `.gitattributes`: 1
- `.gitignore`: 1
- `.jpg`: 1
- `.png`: 1
- `[none]`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitattributes`
- `.gitignore`
- `assets/gpt2_124M_loss.png`
- `assets/nanogpt.jpg`
- `bench.py`
- `config/eval_gpt2.py`
- `config/eval_gpt2_large.py`
- `config/eval_gpt2_medium.py`
- `config/eval_gpt2_xl.py`
- `config/finetune_shakespeare.py`
- `config/train_gpt2.py`
- `config/train_shakespeare_char.py`
- `configurator.py`
- `data/openwebtext/prepare.py`
- `data/openwebtext/readme.md`
- `data/shakespeare/prepare.py`
- `data/shakespeare/readme.md`
- `data/shakespeare_char/prepare.py`
- `data/shakespeare_char/readme.md`
- `LICENSE`
- `model.py`
- `README.md`
- `sample.py`
- `scaling_laws.ipynb`
- `train.py`
- `transformer_sizing.ipynb`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
