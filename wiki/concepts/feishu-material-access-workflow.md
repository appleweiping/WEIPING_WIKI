---
title: Feishu Material Access Workflow
type: concept
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - feishu
  - lark
  - agent-workflow
  - browser-automation
  - local-tooling
source_pages:
  - 2026-05-17-larksuite-cli-feishu-bridge
  - 2026-05-17-feishu-form-fill-session
---

# Feishu Material Access Workflow

## Purpose

This workflow records how Codex should connect Feishu/Lark materials to the local knowledge and agent system without treating Feishu as a disconnected browser island.

The core rule is API first, browser second:

1. Use [[lark-cli]] and the relevant `lark-*` skill when the task can be done through official Feishu/Lark APIs.
2. Use [[chrome-automation]] through [[feishu-bridge]] when the task is a logged-in web page, a shared form, a live browser session, or an interaction that the API path cannot cover.
3. Keep private Feishu content out of the public wiki unless the user explicitly asks to preserve it.

## Installed Local System

- EXTRACTED: The official Lark CLI runtime is installed on the D-drive at `.wiki-tmp/tools/lark-cli/v1.0.32/bin/lark-cli.exe`.
- EXTRACTED: The project-local skill router is installed at `.codex/skills/feishu-bridge/`.
- EXTRACTED: Official `lark-*` skills are installed under `.codex/skills/` for Docs, Wiki, Drive, Base, Sheets, IM, Calendar, Contact, Slides, Markdown, OpenAPI exploration, and skill making.
- EXTRACTED: Browser fallback uses the D-drive `agent-browser` runtime installed for [[chrome-automation]].

## Routing Rules

Use API access when the user asks to:

- read or summarize a Feishu Doc/Docx;
- search Drive;
- read a Wiki space or node;
- read/write Base records or table schemas;
- operate Sheets;
- create or fetch test documents;
- inspect Feishu resources by token or URL when CLI support exists.

Use browser automation when the user asks to:

- open a public/shared Feishu form link;
- fill a Feishu Base form;
- work with a logged-in page that depends on the user's browser session;
- inspect visible form fields, buttons, and confirmation dialogs;
- handle workflows where `lark-cli` cannot express the operation cleanly.

## Form-Fill Rules

- Confirm before final submission unless the user has clearly said to submit.
- Treat one-time-submit dialogs as a second confirmation boundary; if the user already explicitly authorized submission, proceed and record the final visible result.
- Verify after every important action with page text, snapshots, and, when possible, network request history.
- Do not assume visible dropdown text is a selected value. Feishu forms can show candidate lists and selected chips in the same DOM subtree.
- For stubborn Feishu select controls, use a real-browser sequence:
  - click the field;
  - inspect `snapshot -i`;
  - if necessary, click a real row by screen coordinates;
  - close open dropdowns with `Escape` before pressing the final submit button;
  - handle the "current form can only be submitted once" confirmation dialog explicitly.

## Privacy Boundary

- Do not record names, phone numbers, WeChat IDs, private application content, or personal free-text answers in public wiki pages.
- Public wiki notes may record neutral operational facts: tool paths, commands, workflow discoveries, smoke-test results, and whether a submission succeeded.
- If a Feishu source itself is sensitive, record only minimal metadata and the intended operational lesson.

## Counterpoints And Gaps

- AMBIGUOUS: API access depends on the configured Feishu/Lark app scopes. Future tasks may require additional incremental OAuth scopes before they can run.
- AMBIGUOUS: Browser automation depends on current page structure and login state, so form-filling recipes should be verified on the live page rather than copied blindly.
- INFERRED: For highly sensitive Feishu materials, the safer route is to answer from the live page/session and avoid writing source contents into the public wiki.

## Operational Lessons From 2026-05-17

- EXTRACTED: OAuth and API smoke tests made the API path usable for Drive, Wiki, Docs, and Base reads/writes under user-approved test resources.
- EXTRACTED: A real Feishu shared Base form was filled and submitted successfully through browser automation.
- INFERRED: The useful durable lesson is not the submitted personal data; it is the combined workflow: `feishu-bridge` routes, `lark-cli` handles structured resources, and `chrome-automation` handles live web forms.
- INFERRED: Future Feishu tasks should not be toyified. If a required runtime, OAuth scope, browser profile, or live test is missing, install/configure the narrow dependency on D-drive and run a real smoke test rather than documenting an unverified collection of files.

## Related Pages

- [[feishu-bridge]]
- [[lark-cli]]
- [[chrome-automation]]
- [[agent-skill-installation-workflow]]
- [[2026-05-17-feishu-form-fill-session]]
