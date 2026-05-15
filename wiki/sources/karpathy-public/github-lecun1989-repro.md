---
title: "lecun1989-repro"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - education
  - karpathy
  - neural-networks
source_pages:
  - https://github.com/karpathy/lecun1989-repro
---

# lecun1989-repro

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/lecun1989-repro
- Discovery source: https://github.com/karpathy/lecun1989-repro
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `4706f25dba3667bb604a0dce5fde117d008f341a591cc9c1c332bac569f76982`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Neural network fundamentals
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

lecun1989-repro !$1 This code tries to reproduce the 1989 Yann LeCun et al. paper: $1. To my knowledge this is the earliest real-world application of a neural net trained with backpropagation (now 33 years ago). run Since we don't have the exact dataset that was used in the paper, we take MNIST and randomly pick examples from it to generate an approximation of the dataset, which contains only 7291 training and 2007 testing digits, only of size 16x16 pixels (standard MNIST is 28x28). Now we can attempt to reproduce the paper. The original network trained for 3 days, but my (Apple Silicon M1) MacBook Air 33 years l...

## What This Teaches

- How core neural network ideas can be rebuilt from first principles.
- Useful for grounding later LLM work in gradients, activations, optimization, and model internals.

## Why It Matters

This is high-priority for Vipin because it supports durable first-principles understanding instead of shallow API use.

## Repository Snapshot

- Full name: `karpathy/lecun1989-repro`
- Default branch: `master`
- HEAD: `8553f52c8d0a51a4bbbabf98e005cef28a22a36b`
- Stars at crawl: 760
- Forks at crawl: 86
- File count: 7
- README path: `README.md`
- License path: `LICENSE`
- Created: 2022-03-10T22:15:51Z
- Updated: 2026-05-11T17:13:01Z
- Pushed: 2024-02-03T23:42:16Z

### Top-Level Structure

- `[root]`: 7

### File Extension Profile

- `.py`: 3
- `.ipynb`: 1
- `.md`: 1
- `.png`: 1
- `[none]`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `lecun1989.png`
- `LICENSE`
- `modern.py`
- `prepro.py`
- `README.md`
- `repro.py`
- `vis.ipynb`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
