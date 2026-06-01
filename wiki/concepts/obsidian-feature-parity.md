---
title: Obsidian Feature Parity
type: concept
status: active
created: 2026-06-01
updated: 2026-06-01
tags:
  - obsidian
  - interoperability
  - knowledge-system
  - maintenance
source_pages:
  - vipinknowledge-maintenance-system
---

# Obsidian Feature Parity

## Purpose

EXTRACTED: `vipinknowledge` should borrow Obsidian's strongest local-first knowledge-system ideas without depending on Obsidian's proprietary core application.

The repository now has an Obsidian-compatible layer:

- `.obsidian/` vault settings for opening this repo directly in Obsidian.
- `wiki/bases/*.base` views for database-like page slices.
- `wiki/canvases/vipinknowledge-map.canvas` as a JSON Canvas visual route map.
- `wiki/obsidian-dashboard.md` as a generated bookmarks, tags, properties, and task dashboard.
- `wiki/_templates/daily.md` and `wiki/_templates/web-clip.md` for daily note and web-clip capture workflows.
- `python scripts/wiki.py obsidian ...` for CLI parity with backlinks, outgoing links, tags, properties, tasks, daily notes, export, and report.

## Feature Mapping

| Obsidian feature | VipinKnowledge adaptation |
| --- | --- |
| Backlinks / outgoing links | `wiki/catalog.json` plus `python scripts/wiki.py obsidian backlinks/outgoing` |
| Graph view | Existing graph tooling plus generated JSON Canvas map |
| Bases | Generated `.base` files over Markdown frontmatter |
| Properties view | `obsidian properties` frontmatter schema report |
| Tags view | `obsidian tags` counts and page lists |
| Tasks | `obsidian tasks` checkbox scan |
| Daily notes | `obsidian daily` plus `wiki/_templates/daily.md` |
| Templates | Existing wiki templates plus daily and web-clip templates |
| Bookmarks | Generated `wiki/obsidian-dashboard.md` |
| Canvas | JSON Canvas file under `wiki/canvases/` |
| Web Clipper | `wiki/_templates/web-clip.md` plus existing URL/source ingest skills |
| Sync / Publish | Git commit/push, GitHub, and Quartz publishing |

## Usage

```powershell
python scripts/wiki.py obsidian report --json
python scripts/wiki.py obsidian export --json
python scripts/wiki.py catalog
python scripts/wiki.py lint
```

Then open `D:\Research\vipin's knowledgebase` as an Obsidian vault. The generated dashboard is [[obsidian-dashboard]], and the generated base index is [[bases/README]].

## Sources

- [Obsidian Help: Core plugins](https://obsidian.md/help/plugins)
- [Obsidian Help: Bases](https://obsidian.md/help/bases)
- [Obsidian Help: Properties](https://obsidian.md/help/properties)
- [Obsidian Help: Web Clipper](https://obsidian.md/help/web-clipper)
- [Obsidian Help: CLI](https://obsidian.md/help/cli)
- [JSON Canvas Spec](https://jsoncanvas.org/spec/1.0/)
- [Obsidian GitHub organization](https://github.com/obsidianmd)

## Counterpoints And Gaps

- Obsidian's core app is not open source. This project adapts documented behavior and open formats rather than copying proprietary implementation.
- The local layer is CLI and file-format oriented; it does not recreate Obsidian's full interactive desktop UI.
- `.base` syntax may evolve with Obsidian versions, so future maintenance should validate generated base files after major Obsidian updates.
