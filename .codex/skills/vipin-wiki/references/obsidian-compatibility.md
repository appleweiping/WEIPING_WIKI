# Obsidian Compatibility

Use this reference when improving `vipinknowledge` with Obsidian-style local-first knowledge features.

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
- CLI reports for backlinks, outgoing links, tags, properties, tasks, and feature parity.
- Markdown templates for daily notes and web clips.
- Generated dashboard pages that remain valid wiki pages and pass lint.

## Commands

```powershell
python scripts/wiki.py obsidian report --json
python scripts/wiki.py obsidian export --json
python scripts/wiki.py obsidian backlinks vipinknowledge-maintenance-system --json
python scripts/wiki.py obsidian outgoing index --json
python scripts/wiki.py obsidian tags --json
python scripts/wiki.py obsidian properties --json
python scripts/wiki.py obsidian tasks --status open --json
python scripts/wiki.py obsidian daily --date 2026-06-01 --json
```

After `obsidian export`, run catalog, lint, health, `git diff --check`, and pre-push safety before committing.
