---
title: "minGPT"
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
  - https://github.com/karpathy/minGPT
---

# minGPT

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/minGPT
- Discovery source: https://github.com/karpathy/minGPT
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `4c8ee83f891fdacf055541a7d011ccb175b3eb57f2d79d34f42693a3ef36f55a`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

minGPT !$1 A PyTorch re-implementation of $1, both training and inference. minGPT tries to be small, clean, interpretable and educational, as most of the currently available GPT model implementations can a bit sprawling. GPT is not a complicated model and this implementation is appropriately about 300 lines of code (see $1). All that's going on is that a sequence of indices feeds into a $1, and a probability distribution over the next index in the sequence comes out. The majority of the complexity is just being clever with batching (both across examples and over sequence length) for efficiency. note (Jan 2023) :...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/minGPT`
- Default branch: `master`
- HEAD: `37baab71b9abea1b76ab957409a1cc2fbfba8a26`
- Stars at crawl: 24376
- Forks at crawl: 3249
- File count: 18
- README path: `README.md`
- License path: `LICENSE`
- Created: 2020-08-17T07:08:48Z
- Updated: 2026-05-15T19:37:16Z
- Pushed: 2024-08-15T04:09:40Z

### Top-Level Structure

- `[root]`: 7
- `mingpt`: 5
- `projects`: 5
- `tests`: 1

### File Extension Profile

- `.py`: 9
- `.md`: 4
- `.ipynb`: 2
- `.gitignore`: 1
- `.jpg`: 1
- `[none]`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitignore`
- `demo.ipynb`
- `generate.ipynb`
- `LICENSE`
- `mingpt.jpg`
- `mingpt/__init__.py`
- `mingpt/bpe.py`
- `mingpt/model.py`
- `mingpt/trainer.py`
- `mingpt/utils.py`
- `projects/adder/adder.py`
- `projects/adder/readme.md`
- `projects/chargpt/chargpt.py`
- `projects/chargpt/readme.md`
- `projects/readme.md`
- `README.md`
- `setup.py`
- `tests/test_huggingface_import.py`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
