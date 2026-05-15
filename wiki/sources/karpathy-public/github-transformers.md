---
title: "transformers"
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
  - https://github.com/karpathy/transformers
---

# transformers

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/transformers
- Discovery source: https://github.com/karpathy/transformers
- License: `Apache-2.0`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `9dab02138e8e1053c71f775d2f82d11edd2d7bd39f829f2c68ba6a56d4bcf0ee`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

English 简体中文 繁體中文 한국어 State-of-the-art Machine Learning for JAX, PyTorch and TensorFlow 🤗 Transformers provides thousands of pretrained models to perform tasks on different modalities such as text, vision, and audio. These models can be applied on: 📝 Text, for tasks like text classification, information extraction, question answering, summarization, translation, text generation, in over 100 languages. 🖼️ Images, for tasks like image classification, object detection, and segmentation. 🗣️ Audio, for tasks like speech recognition and audio classification. Transformer models can also perform tasks on several moda...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/transformers`
- Default branch: `main`
- HEAD: `b03be78a4bc3223695ed4f738375148acd487007`
- Stars at crawl: 216
- Forks at crawl: 43
- File count: 2321
- README path: `README.md`
- License path: `LICENSE`
- Created: 2022-06-24T20:53:24Z
- Updated: 2026-05-14T21:26:52Z
- Pushed: 2022-06-27T18:49:38Z

### Top-Level Structure

- `src`: 873
- `tests`: 573
- `examples`: 478
- `docs`: 257
- `templates`: 32
- `utils`: 27
- `.github`: 23
- `[root]`: 20
- `scripts`: 20
- `docker`: 14
- `.circleci`: 2
- `model_cards`: 1

### File Extension Profile

- `.py`: 1712
- `.mdx`: 245
- `.md`: 103
- `.txt`: 72
- `.sh`: 54
- `.json`: 39
- `.yml`: 24
- `[none]`: 16
- `.h`: 5
- `.model`: 5
- `.png`: 5
- `.source`: 5

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.circleci/config.yml`
- `.circleci/TROUBLESHOOT.md`
- `.coveragerc`
- `.gitattributes`
- `.github/conda/build.sh`
- `.github/conda/meta.yaml`
- `.github/ISSUE_TEMPLATE/bug-report.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/ISSUE_TEMPLATE/feature-request.yml`
- `.github/ISSUE_TEMPLATE/migration.yml`
- `.github/ISSUE_TEMPLATE/new-model-addition.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/workflows/add-model-like.yml`
- `.github/workflows/build_documentation.yml`
- `.github/workflows/build_pr_documentation.yml`
- `.github/workflows/build-docker-images.yml`
- `.github/workflows/delete_doc_comment.yml`
- `.github/workflows/doctests.yml`
- `.github/workflows/model-templates.yml`
- `.github/workflows/release-conda.yml`
- `.github/workflows/self-nightly-scheduled.yml`
- `.github/workflows/self-push.yml`
- `.github/workflows/self-push-caller.yml`
- `.github/workflows/self-scheduled.yml`
- `.github/workflows/stale.yml`
- `.github/workflows/TROUBLESHOOT.md`
- `.github/workflows/update_metdata.yml`
- `.gitignore`
- `CITATION.cff`
- `CODE_OF_CONDUCT.md`
- `conftest.py`
- `CONTRIBUTING.md`
- `docker/transformers-all-latest-gpu/Dockerfile`
- `docker/transformers-cpu/Dockerfile`
- `docker/transformers-doc-builder/Dockerfile`
- `docker/transformers-gpu/Dockerfile`
- `docker/transformers-pytorch-cpu/Dockerfile`
- `docker/transformers-pytorch-deepspeed-latest-gpu/Dockerfile`
- `docker/transformers-pytorch-deepspeed-nightly-gpu/Dockerfile`
- `docker/transformers-pytorch-gpu/Dockerfile`
- `docker/transformers-pytorch-tpu/bert-base-cased.jsonnet`
- `docker/transformers-pytorch-tpu/dataset.yaml`
- `docker/transformers-pytorch-tpu/docker-entrypoint.sh`
- `docker/transformers-pytorch-tpu/Dockerfile`
- `docker/transformers-tensorflow-cpu/Dockerfile`
- `docker/transformers-tensorflow-gpu/Dockerfile`
- `docs/README.md`
- `docs/source/_config.py`
- `docs/source/en/_config.py`
- `docs/source/en/_toctree.yml`
- `docs/source/en/accelerate.mdx`
- `docs/source/en/add_new_model.mdx`
- `docs/source/en/add_new_pipeline.mdx`
- `docs/source/en/autoclass_tutorial.mdx`
- `docs/source/en/benchmarks.mdx`
- `docs/source/en/bertology.mdx`
- `docs/source/en/big_models.mdx`
- `docs/source/en/community.mdx`
- `docs/source/en/contributing.md`
- `docs/source/en/converting_tensorflow_models.mdx`
- `docs/source/en/create_a_model.mdx`
- `docs/source/en/custom_models.mdx`
- `docs/source/en/debugging.mdx`
- `docs/source/en/fast_tokenizers.mdx`
- `docs/source/en/glossary.mdx`
- `docs/source/en/index.mdx`
- `docs/source/en/installation.mdx`
- `docs/source/en/internal/file_utils.mdx`
- `docs/source/en/internal/generation_utils.mdx`
- `docs/source/en/internal/modeling_utils.mdx`
- `docs/source/en/internal/pipelines_utils.mdx`
- `docs/source/en/internal/tokenization_utils.mdx`
- `docs/source/en/internal/trainer_utils.mdx`
- `docs/source/en/main_classes/callback.mdx`
- `docs/source/en/main_classes/configuration.mdx`
- `docs/source/en/main_classes/data_collator.mdx`
- `docs/source/en/main_classes/deepspeed.mdx`
- `docs/source/en/main_classes/feature_extractor.mdx`
- `docs/source/en/main_classes/keras_callbacks.mdx`
- `docs/source/en/main_classes/logging.mdx`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
