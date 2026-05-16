---
title: Song Page Capture Rule
type: concept
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - music
  - personal-preferences
  - wiki-workflow
source_pages:
  - chat
---

# Song Page Capture Rule

## Rule

- EXTRACTED: For every liked song, create a dedicated song page instead of only listing it inside a general preference page.
- EXTRACTED: The song page should have a stable click target from the music preference hub.
- EXTRACTED: When a legitimate public source exists, include an embedded player or direct player link so the original song can be heard from the page.
- EXTRACTED: The page should feel like a high-end interactive entry when practical, using dedicated HTML or rich wiki/site output rather than a bare list item.
- EXTRACTED: Preserve versions: original, covers, preferred channel versions, live versions, and uncertain candidates should be separated but linked on the same song page.

## Minimum Song Page Fields

- stable title and alternative titles
- artist or channel
- preferred version
- original version
- playable URL or embed source
- why Vipin likes it, if known
- source confidence and unresolved metadata gaps

## Agent Notes

- Do not invent YouTube, streaming, or artist metadata when the user only gives a fuzzy memory.
- Search or ask for a link when the playable source is ambiguous.
- If a media lookup or page-generation tool is missing, install the narrowest needed dependency into the D: drive project-local temporary area and continue; do not make a degraded non-playable song page solely because the tool was missing.
- Prefer official uploads for the original song and clearly label fan covers or channel versions.
- Avoid copying lyrics into public wiki pages unless the quoted fragment is short and necessary.

## Counterpoints And Gaps

- AMBIGUOUS: Dedicated interactive HTML song pages need a site-side implementation path; this rule currently defines the desired content model and navigation target.
- AMBIGUOUS: Some songs may not have a legal embeddable player source, so a direct official player link may be safer than an embed.

## Related

- [[personal-music-preferences]]
