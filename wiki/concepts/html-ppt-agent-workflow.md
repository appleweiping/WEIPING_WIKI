---
title: HTML PPT Agent Workflow
type: concept
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - html-ppt
  - codex-skill
  - presentation
  - workflow
source_pages:
  - 2026-05-17-html-ppt-skill-and-deck-session
---

# HTML PPT Agent Workflow

This page records the maintained workflow for using Codex to build presentation decks as HTML PPTs.

## Current Local Setup

- EXTRACTED: The local `frontend-slides` skill is installed under the project-local D-drive path `.codex/skills/frontend-slides/`.
- EXTRACTED: The upstream `frontend-slides` repository was also kept under `skill/llm4ppt(html)/frontend-slides/`.
- EXTRACTED: The `beautiful-html-templates` library was kept under `skill/llm4ppt(html)/beautiful-html-templates/`.
- EXTRACTED: The local `frontend-slides` skill was modified so new deck-generation work defaults to the `beautiful-html-templates` library when that local path exists.

## Template-Backed Generation Rule

For HTML PPT tasks, the agent should:

1. Read the local `frontend-slides` skill.
2. Read `beautiful-html-templates/AGENTS.md` and `index.json`.
3. Match the user's occasion and mood to candidate templates.
4. Use a chosen template as a design system rather than inventing a deck from scratch.
5. Preserve the chosen template's fonts, palette, layout grammar, decorative vocabulary, and navigation runtime.
6. Replace placeholder content with the user's real content.
7. Extend missing slide layouts inside the chosen template's style instead of mixing templates.
8. Verify the finished HTML through a local HTTP preview when browser security blocks `file://` loading.

## Output Convention

- EXTRACTED: User-facing PPT outputs are placed under `D:/ppt/`.
- EXTRACTED: Deck folders use stable slugs such as `life-did-not-spare-you/` and `beauty-love/`.
- INFERRED: Future deck tasks should keep the deck HTML, copied runtime file, local assets, and optional contact sheets in the same output folder so the folder can be moved or deployed together.

## Verification Notes

- EXTRACTED: `file://` preview can be blocked by the in-app browser security policy.
- EXTRACTED: A local HTTP server rooted at `D:/ppt` was used for validation, with URLs under `http://127.0.0.1:8765/`.
- EXTRACTED: Browser checks should verify slide count, image count when assets are required, visible first/last slide text, and console errors.

## Safety Boundary

- Public wiki pages should record deck names, workflow facts, and high-level asset handling.
- Do not publicly describe sensitive visual details from local image packs unless the user explicitly asks and the details are necessary.
- Record private or intimate source material only with minimal neutral metadata when preserving it in the public wiki.

## Counterpoints and Gaps

- AMBIGUOUS: The current setup is project-local and D-drive specific; future machines may need a different skill discovery path.
- AMBIGUOUS: The skill asks for preview-first template selection, but time-sensitive deck tasks may reasonably skip that step when the user gives a strong style direction.
- UNVERIFIED: No PDF export workflow was validated for these two decks yet.
