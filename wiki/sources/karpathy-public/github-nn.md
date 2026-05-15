---
title: "nn"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - karpathy
  - multimodal
  - vision
source_pages:
  - https://github.com/karpathy/nn
---

# nn

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/nn
- Discovery source: https://github.com/karpathy/nn
- License: `NOASSERTION`
- Distribution policy: `public-summary-local-archive-only`
- Public mirror status: `summary-only`
- Content hash: `220ddcf630a4ffbe09119e27d27b6351d9c4b4b5f290ca543fe3ac730d825f13`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Vision / multimodal / captioning
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

$1](https://travis-ci.org/torch/nn) Neural Network Package This package provides an easy and modular way to build and train simple or complex neural networks using $1: Modules are the bricks used to build neural networks. Each are themselves neural networks, but can be combined with other networks using containers to create complex neural networks: $1: abstract class inherited by all modules; $1: container classes like $1, $1 and $1; $1: non-linear functions like $1 and $1; $1: like $1, $1, $1 and $1; $1: layers for manipulating table s like $1, $1 and $1; $1: $1, $1 and $1 convolutions; Criterions compute a grad...

## What This Teaches

- How earlier vision and captioning systems connect representation learning with language outputs.
- Useful historical context for multimodal LLM research and evaluation.

## Why It Matters

This matters as part of Karpathy's broader pattern: compress hard technical systems into readable, inspectable, working artifacts.

## Repository Snapshot

- Full name: `karpathy/nn`
- Default branch: `master`
- HEAD: `3de925cff92921aafa2bf4a93fcd5395c6322862`
- Stars at crawl: 37
- Forks at crawl: 7
- File count: 196
- README path: `README.md`
- License path: ``
- Created: 2015-05-05T21:33:51Z
- Updated: 2026-04-26T08:03:12Z
- Pushed: 2016-02-05T14:58:20Z

### Top-Level Structure

- `[root]`: 125
- `generic`: 39
- `doc`: 31
- `rocks`: 1

### File Extension Profile

- `.lua`: 118
- `.c`: 40
- `.png`: 19
- `.md`: 12
- `.jpg`: 2
- `.txt`: 2
- `.luacheckrc`: 1
- `.rockspec`: 1
- `.yml`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.luacheckrc`
- `.travis.yml`
- `Abs.lua`
- `AbsCriterion.lua`
- `Add.lua`
- `AddConstant.lua`
- `BatchNormalization.lua`
- `BCECriterion.lua`
- `CAddTable.lua`
- `CDivTable.lua`
- `ClassNLLCriterion.lua`
- `CMakeLists.txt`
- `CMul.lua`
- `CMulTable.lua`
- `Concat.lua`
- `ConcatTable.lua`
- `Container.lua`
- `CONTRIBUTING.md`
- `Copy.lua`
- `COPYRIGHT.txt`
- `CosineDistance.lua`
- `CosineEmbeddingCriterion.lua`
- `Criterion.lua`
- `CriterionTable.lua`
- `CrossEntropyCriterion.lua`
- `CSubTable.lua`
- `DepthConcat.lua`
- `DistKLDivCriterion.lua`
- `doc/containers.md`
- `doc/convolution.md`
- `doc/criterion.md`
- `doc/image/abs.png`
- `doc/image/exp.png`
- `doc/image/hshrink.png`
- `doc/image/htanh.png`
- `doc/image/lena.jpg`
- `doc/image/lenap.jpg`
- `doc/image/logsigmoid.png`
- `doc/image/logsoftmax.png`
- `doc/image/power.png`
- `doc/image/prelu.png`
- `doc/image/relu.png`
- `doc/image/sigmmoid.png`
- `doc/image/sigmoid.png`
- `doc/image/softmax.png`
- `doc/image/softmin.png`
- `doc/image/softplus.png`
- `doc/image/softsign.png`
- `doc/image/sqrt.png`
- `doc/image/square.png`
- `doc/image/sshrink.png`
- `doc/image/tanh.png`
- `doc/module.md`
- `doc/overview.md`
- `doc/simple.md`
- `doc/table.md`
- `doc/testing.md`
- `doc/training.md`
- `doc/transfer.md`
- `DotProduct.lua`
- `Dropout.lua`
- `ErrorMessages.lua`
- `Euclidean.lua`
- `Exp.lua`
- `FlattenTable.lua`
- `generic/Abs.c`
- `generic/AbsCriterion.c`
- `generic/DistKLDivCriterion.c`
- `generic/HardShrink.c`
- `generic/HardTanh.c`
- `generic/L1Cost.c`
- `generic/LogSigmoid.c`
- `generic/LogSoftMax.c`
- `generic/MarginCriterion.c`
- `generic/Max.c`
- `generic/Min.c`
- `generic/MSECriterion.c`
- `generic/MultiLabelMarginCriterion.c`
- `generic/MultiMarginCriterion.c`
- `generic/PReLU.c`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
