# Obsidian Compatibility

Use this reference when improving `WEIPING_WIKI` with Obsidian-style local-first knowledge features. `vipinknowledge` remains a historical alias for older vault artifacts and slugs.

## Evidence Boundary

Obsidian's core desktop app is proprietary, but it documents its feature model publicly and maintains open pieces such as JSON Canvas, Web Clipper, API typings, and sample plugins. Do not claim that the core app is open source.

Primary evidence:

- Official core plugins page: backlinks, Bases, bookmarks, Canvas, daily notes, graph, properties, search, tags, templates, and more.
- Official Bases docs: database-like table/list/card/map views over local Markdown properties.
- Official Properties docs: YAML frontmatter with typed text, list, number, checkbox, date, date-time, and tags values.
- JSON Canvas spec: `.canvas` files with `nodes` and `edges`.
- Official Web Clipper docs: local capture, highlights, templates, variables, filters, and open-source extension code.

## Local Adaptation

Do not try to clone the proprietary UI. Implement durable plain-text equivalents:

- `.obsidian/` settings so the repo can be opened as a real Obsidian vault.
- `.base` files for common wiki views.
- `.canvas` files for visual maps.
- CLI reports for backlinks, outgoing links, search, quick switcher, command palette, file explorer, outline, preview, footnotes, tags, properties, tasks, word count, random note, external links, format conversion issues, and feature parity.
- Markdown templates for daily notes and web clips.
- Timestamped inbox notes and page-to-slides export for transferable Obsidian creation flows.
- Generated dashboard, command, Bases, Canvas, and workspace pages that remain valid wiki pages and pass lint.

## Commands

```powershell
python scripts/wiki.py obsidian report --json
python scripts/wiki.py obsidian export --json
python scripts/wiki.py obsidian commands --json
python scripts/wiki.py obsidian quick "whole computer" --json
python scripts/wiki.py obsidian backlinks weiping-wiki-maintenance-system --json
python scripts/wiki.py obsidian outgoing index --json
python scripts/wiki.py obsidian outline obsidian-feature-parity --json
python scripts/wiki.py obsidian preview obsidian-feature-parity --json
python scripts/wiki.py obsidian tags --json
python scripts/wiki.py obsidian properties --json
python scripts/wiki.py obsidian tasks --status open --json
python scripts/wiki.py obsidian word-count --top 20 --json
python scripts/wiki.py obsidian footnotes --json
python scripts/wiki.py obsidian external-links --page obsidian-feature-parity --json
python scripts/wiki.py obsidian format-report --json
python scripts/wiki.py obsidian daily --date 2026-06-01 --json
python scripts/wiki.py obsidian unique --title "Inbox thought" --json
python scripts/wiki.py obsidian slides obsidian-feature-parity --json
```

After `obsidian export`, run catalog, lint, health, `git diff --check`, and pre-push safety before committing.
