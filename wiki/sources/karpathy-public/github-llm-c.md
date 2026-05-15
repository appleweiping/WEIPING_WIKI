---
title: "llm.c"
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
  - https://github.com/karpathy/llm.c
---

# llm.c

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/llm.c
- Discovery source: https://github.com/karpathy/llm.c
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `6c746994efbccac748d16aab0bccebf90e31b1272b80aa063f900dce4b84b34c`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

llm.c LLMs in simple, pure C/CUDA with no need for 245MB of PyTorch or 107MB of cPython. Current focus is on pretraining, in particular reproducing the $1 and $1 miniseries, along with a parallel PyTorch reference implementation in $1. You'll recognize this file as a slightly tweaked $1, an earlier project of mine. Currently, llm.c is a bit faster than PyTorch Nightly (by about 7%). In addition to the bleeding edge mainline code in $1, we have a simple reference CPU fp32 implementation in ~1,000 lines of clean code in one file $1. I'd like this repo to only maintain C and CUDA code. Ports to other languages or re...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/llm.c`
- Default branch: `master`
- HEAD: `f1e2ace651495b74ae22d45d1723443fd00ecd3a`
- Stars at crawl: 29911
- Forks at crawl: 3588
- File count: 102
- README path: `README.md`
- License path: `LICENSE`
- Created: 2024-04-08T16:58:11Z
- Updated: 2026-05-15T17:54:14Z
- Pushed: 2025-06-26T17:03:40Z

### Top-Level Structure

- `dev`: 48
- `llmc`: 23
- `[root]`: 15
- `scripts`: 10
- `.github`: 3
- `doc`: 3

### File Extension Profile

- `.cu`: 28
- `.h`: 14
- `.py`: 14
- `.sh`: 11
- `.cuh`: 10
- `.c`: 6
- `.md`: 6
- `[none]`: 4
- `.yml`: 3
- `.sbatch`: 2
- `.cpp`: 1
- `.gitignore`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.github/workflows/ci.yml`
- `.github/workflows/ci_gpu.yml`
- `.github/workflows/ci_tests.yml`
- `.gitignore`
- `dev/cpu/matmul_forward.c`
- `dev/cuda/adamw.cu`
- `dev/cuda/attention_backward.cu`
- `dev/cuda/attention_forward.cu`
- `dev/cuda/benchmark_on_modal.py`
- `dev/cuda/classifier_fused.cu`
- `dev/cuda/common.h`
- `dev/cuda/crossentropy_forward.cu`
- `dev/cuda/crossentropy_softmax_backward.cu`
- `dev/cuda/encoder_backward.cu`
- `dev/cuda/encoder_forward.cu`
- `dev/cuda/fused_residual_forward.cu`
- `dev/cuda/gelu_backward.cu`
- `dev/cuda/gelu_forward.cu`
- `dev/cuda/global_norm.cu`
- `dev/cuda/layernorm_backward.cu`
- `dev/cuda/layernorm_forward.cu`
- `dev/cuda/Makefile`
- `dev/cuda/matmul_backward.cu`
- `dev/cuda/matmul_backward_bias.cu`
- `dev/cuda/matmul_forward.cu`
- `dev/cuda/nccl_all_reduce.cu`
- `dev/cuda/permute.cu`
- `dev/cuda/README.md`
- `dev/cuda/residual_forward.cu`
- `dev/cuda/softmax_forward.cu`
- `dev/cuda/trimat_forward.cu`
- `dev/data/data_common.py`
- `dev/data/edu_fineweb.sh`
- `dev/data/fineweb.py`
- `dev/data/fineweb.sh`
- `dev/data/hellaswag.py`
- `dev/data/mmlu.py`
- `dev/data/README.md`
- `dev/data/tinyshakespeare.py`
- `dev/data/tinystories.py`
- `dev/download_starter_pack.sh`
- `dev/eval/export_hf.py`
- `dev/eval/README.md`
- `dev/eval/run_eval.sh`
- `dev/eval/summarize_eval.py`
- `dev/loss_checker_ci.py`
- `dev/test/device_file_io.cu`
- `dev/test/Makefile`
- `dev/test/test_dataloader.c`
- `dev/test/test_outlier_detector.c`
- `dev/unistd.h`
- `dev/vislog.ipynb`
- `doc/layernorm/layernorm.c`
- `doc/layernorm/layernorm.md`
- `doc/layernorm/layernorm.py`
- `LICENSE`
- `llmc/adamw.cuh`
- `llmc/attention.cuh`
- `llmc/cublas_common.h`
- `llmc/cuda_common.h`
- `llmc/cuda_utils.cuh`
- `llmc/cudnn_att.cpp`
- `llmc/cudnn_att.h`
- `llmc/dataloader.h`
- `llmc/encoder.cuh`
- `llmc/fused_classifier.cuh`
- `llmc/gelu.cuh`
- `llmc/global_norm.cuh`
- `llmc/layernorm.cuh`
- `llmc/logger.h`
- `llmc/matmul.cuh`
- `llmc/mfu.h`
- `llmc/outlier_detector.h`
- `llmc/rand.h`
- `llmc/sampler.h`
- `llmc/schedulers.h`
- `llmc/tokenizer.h`
- `llmc/utils.h`
- `llmc/zero.cuh`
- `Makefile`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
