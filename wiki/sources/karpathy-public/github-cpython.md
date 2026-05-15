---
title: "cpython"
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
  - https://github.com/karpathy/cpython
---

# cpython

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/cpython
- Discovery source: https://github.com/karpathy/cpython
- License: `NOASSERTION`
- Distribution policy: `public-summary-local-archive-only`
- Public mirror status: `summary-only`
- Content hash: `04a66db51f1883d97084ca98bc479aec2ddc24d9e6b56b13df5feda67284f786`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

This is Python version 3.15.0 alpha 2 ===================================== .. image:: https://github.com/python/cpython/actions/workflows/build.yml/badge.svg?branch=main&event=push :alt: CPython build status on GitHub Actions :target: https://github.com/python/cpython/actions .. image:: https://dev.azure.com/python/cpython/ apis/build/status/Azure%20Pipelines%20CI?branchName=main :alt: CPython build status on Azure DevOps :target: https://dev.azure.com/python/cpython/ build/latest?definitionId=4&branchName=main .. image:: https://img.shields.io/badge/discourse-join chat-brightgreen.svg :alt: Python Discourse cha...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/cpython`
- Default branch: `main`
- HEAD: `09d6bf20b67f4d3001afac9d20886a6e9cbcc94f`
- Stars at crawl: 70
- Forks at crawl: 7
- File count: 5456
- README path: `README.rst`
- License path: `LICENSE`
- Created: 2025-12-09T18:04:49Z
- Updated: 2026-05-15T07:04:18Z
- Pushed: 2025-12-19T06:13:32Z

### Top-Level Structure

- `Lib`: 2483
- `Doc`: 628
- `Modules`: 622
- `Tools`: 419
- `Include`: 288
- `Misc`: 251
- `Objects`: 140
- `PCbuild`: 138
- `Python`: 130
- `PC`: 91
- `Mac`: 73
- `Apple`: 41

### File Extension Profile

- `.py`: 2194
- `.rst`: 763
- `.h`: 630
- `.c`: 479
- `.txt`: 158
- `.dectest`: 143
- `.xml`: 119
- `[none]`: 91
- `.toml`: 77
- `.vcxproj`: 56
- `.filters`: 52
- `.wxs`: 52

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.azure-pipelines/ci.yml`
- `.azure-pipelines/prebuild-checks.yml`
- `.azure-pipelines/windows-layout-steps.yml`
- `.azure-pipelines/windows-steps.yml`
- `.coveragerc`
- `.devcontainer/devcontainer.json`
- `.devcontainer/wasi/devcontainer.json`
- `.editorconfig`
- `.gitattributes`
- `.github/actionlint.yaml`
- `.github/CODEOWNERS`
- `.github/CONTRIBUTING.rst`
- `.github/dependabot.yml`
- `.github/ISSUE_TEMPLATE/bug.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/ISSUE_TEMPLATE/crash.yml`
- `.github/ISSUE_TEMPLATE/documentation.md`
- `.github/ISSUE_TEMPLATE/feature.yml`
- `.github/problem-matchers/gcc.json`
- `.github/problem-matchers/msvc.json`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/SECURITY.md`
- `.github/workflows/add-issue-header.yml`
- `.github/workflows/build.yml`
- `.github/workflows/documentation-links.yml`
- `.github/workflows/jit.yml`
- `.github/workflows/lint.yml`
- `.github/workflows/mypy.yml`
- `.github/workflows/new-bugs-announce-notifier.yml`
- `.github/workflows/posix-deps-apt.sh`
- `.github/workflows/regen-abidump.sh`
- `.github/workflows/require-pr-label.yml`
- `.github/workflows/reusable-context.yml`
- `.github/workflows/reusable-docs.yml`
- `.github/workflows/reusable-macos.yml`
- `.github/workflows/reusable-san.yml`
- `.github/workflows/reusable-ubuntu.yml`
- `.github/workflows/reusable-wasi.yml`
- `.github/workflows/reusable-windows.yml`
- `.github/workflows/reusable-windows-msi.yml`
- `.github/workflows/stale.yml`
- `.github/workflows/tail-call.yml`
- `.github/workflows/verify-ensurepip-wheels.yml`
- `.github/zizmor.yml`
- `.gitignore`
- `.mailmap`
- `.pre-commit-config.yaml`
- `.readthedocs.yml`
- `.ruff.toml`
- `.well-known/funding-manifest-urls`
- `aclocal.m4`
- `Android/android.py`
- `Android/android-env.sh`
- `Android/README.md`
- `Android/testbed/.gitignore`
- `Android/testbed/.idea/inspectionProfiles/Project_Default.xml`
- `Android/testbed/app/.gitignore`
- `Android/testbed/app/build.gradle.kts`
- `Android/testbed/app/src/androidTest/java/org/python/testbed/PythonSuite.kt`
- `Android/testbed/app/src/main/AndroidManifest.xml`
- `Android/testbed/app/src/main/c/CMakeLists.txt`
- `Android/testbed/app/src/main/c/main_activity.c`
- `Android/testbed/app/src/main/java/org/python/testbed/MainActivity.kt`
- `Android/testbed/app/src/main/res/drawable-xxhdpi/ic_launcher.png`
- `Android/testbed/app/src/main/res/layout/activity_main.xml`
- `Android/testbed/app/src/main/res/values/strings.xml`
- `Android/testbed/build.gradle.kts`
- `Android/testbed/gradle.properties`
- `Android/testbed/gradle/wrapper/gradle-wrapper.properties`
- `Android/testbed/settings.gradle.kts`
- `Apple/.ruff.toml`
- `Apple/__main__.py`
- `Apple/iOS/README.md`
- `Apple/iOS/Resources/bin/arm64-apple-ios-ar`
- `Apple/iOS/Resources/bin/arm64-apple-ios-clang`
- `Apple/iOS/Resources/bin/arm64-apple-ios-clang++`
- `Apple/iOS/Resources/bin/arm64-apple-ios-cpp`
- `Apple/iOS/Resources/bin/arm64-apple-ios-simulator-ar`
- `Apple/iOS/Resources/bin/arm64-apple-ios-simulator-clang`
- `Apple/iOS/Resources/bin/arm64-apple-ios-simulator-clang++`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
