---
title: 2026-05-17 HTML PPT Skill And Deck Session
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - chat-session
  - html-ppt
  - codex-skill
source_files:
  - D:/Research/vipin's knowledgebase/.codex/skills/frontend-slides/SKILL.md
  - D:/Research/vipin's knowledgebase/skill/llm4ppt(html)/frontend-slides/
  - D:/Research/vipin's knowledgebase/skill/llm4ppt(html)/beautiful-html-templates/
  - D:/ppt/life-did-not-spare-you/template.html
  - D:/ppt/beauty-love/template.html
source_pages:
  - html-ppt-agent-workflow
---

# 2026-05-17 HTML PPT Skill And Deck Session

This source note preserves the reusable facts from the chat session in which Codex installed and tested an HTML PPT workflow.

## Provenance

- Origin: chat session plus local filesystem operations.
- User intent: install a D-drive HTML PPT skill/template setup, modify the skill to call template projects, and test the workflow on two decks.
- Public-safety note: one deck used a local image pack. This page records minimal neutral metadata about that pack and does not describe sensitive visual details.

## Skill And Template Setup

- EXTRACTED: The user asked to download two GitHub repositories:
  - `zarazhangrui/frontend-slides`
  - `zarazhangrui/beautiful-html-templates`
- EXTRACTED: The repositories were downloaded under `skill/llm4ppt(html)/` in this D-drive repository workspace rather than under the C drive.
- EXTRACTED: The `frontend-slides` skill was installed project-locally at `.codex/skills/frontend-slides/`.
- EXTRACTED: The user requested avoiding C-drive installation when possible because the C drive was crowded.
- EXTRACTED: The local skill was modified so its deck-generation flow reads and uses the local `beautiful-html-templates` library by default.

## Skill Modification

The local `frontend-slides` skill was updated to:

- EXTRACTED: mention the `beautiful-html-templates` library in the skill description.
- EXTRACTED: add a `Local Template Library` section pointing to `skill/llm4ppt(html)/beautiful-html-templates`.
- EXTRACTED: make Phase 2 style discovery template-backed by default when the local template library exists.
- EXTRACTED: make Phase 3 generation clone/copy and adapt a chosen template while preserving that template's design system.
- EXTRACTED: retain the original built-in preset flow as fallback when the local template library is unavailable or a custom non-template deck is explicitly requested.

## Test Deck 1: Life Did Not Spare You

- EXTRACTED: Output folder: `D:/ppt/life-did-not-spare-you/`.
- EXTRACTED: Main deck file: `D:/ppt/life-did-not-spare-you/template.html`.
- EXTRACTED: Runtime copied into the output folder: `deck-stage.js`.
- EXTRACTED: The deck used the `Soft Editorial` template as its design basis.
- EXTRACTED: The user's Chinese short-video script was adapted into a 12-slide storyboard-style HTML PPT.
- EXTRACTED: Validation found 12 slides, correct title visibility, and no console errors under local HTTP preview.
- INFERRED: `Soft Editorial` matched the brief because the source copy requested a healing, reflective, daily-life tone.

## Test Deck 2: Beauty-Love

- EXTRACTED: Output folder: `D:/ppt/beauty-love/`.
- EXTRACTED: Main deck file: `D:/ppt/beauty-love/template.html`.
- EXTRACTED: Source archive path supplied by the user: `D:/ppt/beauty-love/source.zip`.
- EXTRACTED: The archive contained 26 image files, and the finished deck referenced all 26 image filenames at least once.
- EXTRACTED: A temporary/public-safe contact sheet HTML was created at `D:/ppt/beauty-love/contact-sheet.html` for local verification.
- EXTRACTED: The deck used the `Pink Script - After Hours` template as its design basis.
- EXTRACTED: The user's Beauty-Love project-plan copy was adapted into a 16-slide HTML PPT.
- EXTRACTED: Validation found 16 slides, 27 image tags, visible cover text, and no console errors under local HTTP preview.
- INFERRED: `Pink Script - After Hours` matched the Beauty-Love brief because it supports a feminine, expressive, magazine-like, luxe content-brand presentation.

## Local Preview And Validation

- EXTRACTED: Direct `file://` loading was blocked by the in-app browser security policy.
- EXTRACTED: A local HTTP server rooted at `D:/ppt` was used for validation.
- EXTRACTED: Preview URLs used:
  - `http://127.0.0.1:8765/life-did-not-spare-you/template.html`
  - `http://127.0.0.1:8765/beauty-love/template.html`
  - `http://127.0.0.1:8765/beauty-love/contact-sheet.html`

## Durable Takeaways

- INFERRED: Keeping the skill and template library on D drive works for this repository-local workflow and avoids large C-drive installs.
- INFERRED: A template-backed HTML PPT workflow produces better visual consistency than fully ad hoc HTML generation.
- INFERRED: Asset-heavy decks should include an explicit file-use check so every user-supplied image is either used or deliberately rejected.
