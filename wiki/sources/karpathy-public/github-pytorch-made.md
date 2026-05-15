---
title: "pytorch-made"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - karpathy
  - minimal-implementation
source_pages:
  - https://github.com/karpathy/pytorch-made
---

# pytorch-made

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/pytorch-made
- Discovery source: https://github.com/karpathy/pytorch-made
- License: `NOASSERTION`
- Distribution policy: `public-summary-local-archive-only`
- Public mirror status: `summary-only`
- Content hash: `0af21560306c2b48912821868ef067eccbfa79fbdb5c7c65f42479ee8bffad49`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Minimal implementations
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

pytorch-made This code is an implementation of $1 by Germain et al., 2015. The core idea is that you can turn an auto-encoder into an autoregressive density model just by appropriately masking the connections in the MLP, ordering the input dimensions in some way and making sure that all outputs only depend on inputs earlier in the list. Like other autoregressive models (char-rnn, pixel cnns, etc), evaluating the likelihood is very cheap (a single forward pass), but sampling is linear in the number of dimensions. !$1 The authors of the paper also published code $1, but it's a bit wordy, sprawling and in Theano. He...

## What This Teaches

- How a complex idea can be compressed into a minimal but working implementation.
- Useful as a reference style for serious small systems rather than decorative demos.

## Why It Matters

This matters as part of Karpathy's broader pattern: compress hard technical systems into readable, inspectable, working artifacts.

## Repository Snapshot

- Full name: `karpathy/pytorch-made`
- Default branch: `master`
- HEAD: `81886ccc8270cdf3a2b32cbbca5c7feab422f907`
- Stars at crawl: 593
- Forks at crawl: 93
- File count: 4
- README path: `README.md`
- License path: ``
- Created: 2018-04-22T22:23:49Z
- Updated: 2026-04-02T23:17:26Z
- Pushed: 2018-12-08T16:36:26Z

### Top-Level Structure

- `[root]`: 4

### File Extension Profile

- `.py`: 2
- `.md`: 1
- `.png`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `made.png`
- `made.py`
- `README.md`
- `run.py`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
