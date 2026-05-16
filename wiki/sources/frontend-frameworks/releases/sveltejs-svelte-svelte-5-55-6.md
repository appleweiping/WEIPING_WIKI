---
title: "sveltejs/svelte svelte@5.55.6"
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - compiler-runtime
  - frontend-frameworks
  - release
  - svelte
source_pages:
  - https://github.com/sveltejs/svelte/releases/tag/svelte%405.55.6
---

# sveltejs/svelte svelte@5.55.6

## Source

- Source kind: `github-release`
- Canonical URL: https://github.com/sveltejs/svelte/releases/tag/svelte%405.55.6
- Repository: [[sources/frontend-frameworks/sveltejs-svelte|sveltejs/svelte]]
- Framework: [[entities/frontend-frameworks/svelte|Svelte]]
- Published: 2026-05-14T18:04:38Z
- Prerelease: `False`
- Author: `github-actions[bot]`
- Body hash: `8e21683b40eb99234dd5bd850afe5d20e9384f37c8a6cacafe172650d6d3bbcb`
- Semantic hash: `78a860eb92cfcbb35a310dc7c2f21e44eb88fef036dffe8f7bc2b5bc91f5946c`

## Release Ideas

- fix: leave stale promises to wait for a later resolution, instead of rejecting ([#18180](https://github.com/sveltejs/svelte/pull/18180))
- fix: keep dependencies of `$state.eager/pending` ([#18218](https://github.com/sveltejs/svelte/pull/18218))
- fix: reapply context after transforming error during SSR ([#18099](https://github.com/sveltejs/svelte/pull/18099))
- fix: don't rebase just-created batches ([#18117](https://github.com/sveltejs/svelte/pull/18117))
- chore: allow `null` for `pending` in typings ([#18201](https://github.com/sveltejs/svelte/pull/18201))

## Summary

Patch Changes - fix: leave stale promises to wait for a later resolution, instead of rejecting ($1) - fix: keep dependencies of $state.eager/pending ($1) - fix: reapply context after transforming error during SSR ($1) - fix: don't rebase just-created batches ($1) - chore: allow null for pending in typings ($1) - fix: flush eager effects in production ($1) - fix: rethrow error of failed iterable after calling return() ($1) - fix: account for proxified instance when updating bind:this ($1) - fix: ensure scheduled bat...

## Public Handling Notes

- EXTRACTED: This page records release metadata and a concise idea summary.
- INFERRED: The full release body is not mirrored publicly; use the canonical GitHub URL for complete text.
