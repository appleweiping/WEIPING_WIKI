---
title: "char-rnn"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - education
  - karpathy
  - neural-networks
source_pages:
  - https://github.com/karpathy/char-rnn
---

# char-rnn

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/char-rnn
- Discovery source: https://github.com/karpathy/char-rnn
- License: `NOASSERTION`
- Distribution policy: `public-summary-local-archive-only`
- Public mirror status: `summary-only`
- Content hash: `045b065bcbe7340eb1836fd5f2528400892d087d532b1f8fe6601fff0dca0f84`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Neural network fundamentals
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

char-rnn This code implements multi-layer Recurrent Neural Network (RNN, LSTM, and GRU) for training/sampling from character-level language models. In other words the model takes one text file as input and trains a Recurrent Neural Network that learns to predict the next character in a sequence. The RNN can then be used to generate text character by character that will look like the original training data. The context of this code base is described in detail in my $1. If you are new to Torch/Lua/Neural Nets, it might be helpful to know that this code is really just a slightly more fancy version of this $1 that I...

## What This Teaches

- How core neural network ideas can be rebuilt from first principles.
- Useful for grounding later LLM work in gradients, activations, optimization, and model internals.

## Why It Matters

This is high-priority for Vipin because it supports durable first-principles understanding instead of shallow API use.

## Repository Snapshot

- Full name: `karpathy/char-rnn`
- Default branch: `master`
- HEAD: `6f9487a6fe5b420b7ca9afb0d7c078e37c1d1b4e`
- Stars at crawl: 12034
- Forks at crawl: 2628
- File count: 14
- README path: `Readme.md`
- License path: ``
- Created: 2015-05-21T17:25:24Z
- Updated: 2026-05-15T08:18:38Z
- Pushed: 2023-10-24T17:15:27Z

### Top-Level Structure

- `[root]`: 6
- `util`: 4
- `model`: 3
- `data`: 1

### File Extension Profile

- `.lua`: 11
- `.gitignore`: 1
- `.md`: 1
- `.txt`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitignore`
- `convert_gpu_cpu_checkpoint.lua`
- `data/tinyshakespeare/input.txt`
- `inspect_checkpoint.lua`
- `model/GRU.lua`
- `model/LSTM.lua`
- `model/RNN.lua`
- `Readme.md`
- `sample.lua`
- `train.lua`
- `util/CharSplitLMMinibatchLoader.lua`
- `util/misc.lua`
- `util/model_utils.lua`
- `util/OneHot.lua`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
