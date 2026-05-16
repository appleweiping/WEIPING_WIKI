---
title: "remix-run/remix test@0.3.0"
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - app-framework
  - frontend-frameworks
  - release
  - remix-react-router
source_pages:
  - https://github.com/remix-run/remix/releases/tag/test%400.3.0
---

# remix-run/remix test@0.3.0

## Source

- Source kind: `github-release`
- Canonical URL: https://github.com/remix-run/remix/releases/tag/test%400.3.0
- Repository: [[sources/frontend-frameworks/remix-run-remix|remix-run/remix]]
- Framework: [[entities/frontend-frameworks/remix-react-router|Remix / React Router]]
- Published: 2026-04-30T19:14:07Z
- Prerelease: `False`
- Author: `github-actions[bot]`
- Body hash: `1866b4a3f1c516ec5e7232ab1672a4996b67a2e3bbdbd3592b9d52e7fd2f8bf8`
- Semantic hash: `39faa26de5082c87581dae208e82488d51362c7c5cd0eb8f6ff25016c1eb3937`

## Release Ideas

- Add `FakeTimers#advanceAsync(ms)` to `t.useFakeTimers()`. Like `advance`, it walks pending timers in time order and fires them, but yields to microtasks between each firing so promise continuations (and any timers they s...
- Accept arrays for `glob.{test,browser,e2e,exclude}`, `project`, `type`, and `coverage.{include,exclude}` config fields
- `type`'s default is now `["server", "browser", "e2e"]` instead of `"server,browser,e2e"`.
- Load Playwright only when browser or E2E tests run, allowing test help and server-only test runs without Playwright installed. Browser and E2E test runs now report a clearer error when Playwright is missing.
- Run server and E2E test files in forked child processes by default, add `pool: 'threads'`/`--pool threads` to preserve the previous worker-thread behavior, and clean up leaked test worker resources after results are repo...

## Summary

Minor Changes - Add FakeTimers advanceAsync(ms) to t.useFakeTimers() . Like advance , it walks pending timers in time order and fires them, but yields to microtasks between each firing so promise continuations (and any timers they schedule) can settle before the next firing is processed. Use it when a fake-timer-driven callback awaits work that itself depends on the fake clock. - Accept arrays for glob.{test,browser,e2e,exclude} , project , type , and coverage.{include,exclude} config fields - The matching CLI flag...

## Public Handling Notes

- EXTRACTED: This page records release metadata and a concise idea summary.
- INFERRED: The full release body is not mirrored publicly; use the canonical GitHub URL for complete text.

## Navigation

- [[frontend-frameworks-public]]
- [[frontend-framework-reuse-map]]
