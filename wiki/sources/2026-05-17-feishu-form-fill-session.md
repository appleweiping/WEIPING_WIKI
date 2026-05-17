---
title: 2026-05-17 Feishu Form Fill Session
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - feishu
  - lark
  - browser-automation
  - agent-workflow
source_pages:
  - 2026-05-17-larksuite-cli-feishu-bridge
---

# 2026-05-17 Feishu Form Fill Session

## Provenance

- Source: current chat session in which the user asked Codex to inspect and fill a Feishu shared Base form.
- URL class: Feishu/Lark shared Base form.
- Tool route: [[feishu-bridge]] -> [[chrome-automation]] using the D-drive `agent-browser` runtime.
- Privacy note: The public wiki records only neutral workflow and verification details. It intentionally omits the user's personal identifiers and free-text form answers.

## What Happened

- EXTRACTED: The user supplied a Feishu shared Base form link associated with a community intake form for an AI Agent practice group.
- EXTRACTED: The user provided form answers in chat and explicitly authorized final submission after reviewing that the form was filled.
- EXTRACTED: Codex used `agent-browser` with a persistent D-drive Chrome profile and CDP session to inspect, fill, and submit the form.
- EXTRACTED: The final visible result after the second confirmation was `提交成功` and `你已达提交次数上限`.

## Tools And Local State

- EXTRACTED: Browser runtime path used: `.wiki-tmp/tools/agent-browser/bin/agent-browser-win32-x64.exe`.
- EXTRACTED: CDP session used: `feishu-form-inspect`.
- EXTRACTED: CDP port used during the session: `9226`.
- EXTRACTED: The browser profile was project-local under `.wiki-tmp/tools/feishu-browser-fill-profile`.

## Field Handling Lessons

- EXTRACTED: Feishu Base form dropdowns are not ordinary HTML selects.
- EXTRACTED: The accessibility tree may show candidate options and selected chips together, so `innerText` alone can be misleading.
- EXTRACTED: Some fields looked filled while still failing required-field validation.
- EXTRACTED: The successful method for the stubborn single-select field was to scroll the field into view, reopen the full option list, inspect the list-item coordinates, and click the exact visible option row.
- EXTRACTED: Before final submission, open dropdowns needed to be closed so the final submit button could receive the click.
- EXTRACTED: The form presented a final modal stating that the form could only be submitted once; the user had already explicitly said to submit, so Codex clicked the modal's submit button.

## Verification

- EXTRACTED: First submission attempt exposed real validation failures, which were corrected instead of being ignored.
- EXTRACTED: The second-stage confirmation dialog appeared after required fields were satisfied.
- EXTRACTED: Final page text contained `提交成功`.
- EXTRACTED: Final page text contained `你已达提交次数上限`, consistent with a one-time form submission having been accepted.

## Durable Takeaways

- INFERRED: For Feishu shared forms, browser automation should combine snapshots, DOM inspection, coordinate clicks, and visible success text checks.
- INFERRED: Future agents should preserve the safety pattern: fill first, confirm with the user before irreversible submit, then handle one-time confirmation if already authorized.
- INFERRED: This real-world form submission upgrades [[feishu-bridge]] from a theoretical browser fallback into a verified live Feishu form workflow.

## Related Pages

- [[feishu-material-access-workflow]]
- [[feishu-bridge]]
- [[chrome-automation]]
- [[lark-cli]]
