---
title: "withastro/astro astro@6.3.2"
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - astro
  - frontend-frameworks
  - release
  - site-framework
source_pages:
  - https://github.com/withastro/astro/releases/tag/astro%406.3.2
---

# withastro/astro astro@6.3.2

## Source

- Source kind: `github-release`
- Canonical URL: https://github.com/withastro/astro/releases/tag/astro%406.3.2
- Repository: [[sources/frontend-frameworks/withastro-astro|withastro/astro]]
- Framework: [[entities/frontend-frameworks/astro|Astro]]
- Published: 2026-05-13T17:47:18Z
- Prerelease: `False`
- Author: `astrobot-houston`
- Body hash: `b5591feee6c6fdfcb4a255942f5828418651c65b7d15791da7cf5bb4de5242f2`
- Semantic hash: `0c2abbf3cd0f889687ad66462b758cedee7a934a89c795660690851af78ec2e9`

## Release Ideas

- [#16675](https://github.com/withastro/astro/pull/16675) [`11d4592`](https://github.com/withastro/astro/commit/11d4592e9498e900b433ba94abed9cd615a9350b) Thanks [@ascorbic](https://github.com/ascorbic)! - Fixes a regressio...
- [#16691](https://github.com/withastro/astro/pull/16691) [`0f0a4ce`](https://github.com/withastro/astro/commit/0f0a4ce1b28a6d6ec1658c7f59e0e68408935135) Thanks [@matthewp](https://github.com/matthewp)! - Fixes `HTMLElemen...
- [#16562](https://github.com/withastro/astro/pull/16562) [`07529ec`](https://github.com/withastro/astro/commit/07529eccdaef8727a375475e6d04071b770114a1) Thanks [@matthewp](https://github.com/matthewp)! - Fixes non-prerend...
- [#16638](https://github.com/withastro/astro/pull/16638) [`272185b`](https://github.com/withastro/astro/commit/272185bcccf6a4adcd7575f319bf91f2e5306c6d) Thanks [@ematipico](https://github.com/ematipico)! - Fixes a bug whe...
- [#16544](https://github.com/withastro/astro/pull/16544) [`d365c97`](https://github.com/withastro/astro/commit/d365c975ba2d88fc1dbdfe698df2bf9e2eafadce) Thanks [@matthewp](https://github.com/matthewp)! - Tightens `isRemot...

## Summary

Patch Changes - $1 $1 Thanks $1! - Fixes a regression where Astro.cache was undefined when experimental.cache was not configured. The previous documented behavior is for Astro.cache to always be defined as a no-op shim: cache.set() warns once, cache.invalidate() throws and cache.enabled can be used to gate. This allows library and user code can call cache methods without conditional checks. The cache provider registration was being gated at the call site on experimental.cache being configured, which meant the disab...

## Public Handling Notes

- EXTRACTED: This page records release metadata and a concise idea summary.
- INFERRED: The full release body is not mirrored publicly; use the canonical GitHub URL for complete text.

## Navigation

- [[frontend-frameworks-public]]
- [[frontend-framework-reuse-map]]
