---
title: Obsidian Feature Parity
type: concept
status: active
created: 2026-06-01
updated: 2026-06-04
tags:
  - obsidian
  - interoperability
  - knowledge-system
  - maintenance
source_pages:
  - weiping-wiki-maintenance-system
---

# Obsidian Feature Parity

## Purpose

EXTRACTED: `WEIPING_WIKI` should borrow Obsidian's strongest local-first knowledge-system ideas without depending on Obsidian's proprietary core application.

The repository now has an Obsidian-compatible layer:

- `.obsidian/` vault settings for opening this repo directly in Obsidian.
- `wiki/bases/*.base` views for database-like page slices.
- `wiki/canvases/vipinknowledge-map.canvas` as a historical-name JSON Canvas visual route map.
- `wiki/obsidian-dashboard.md` as a generated bookmarks, core-plugin coverage, tags, properties, and task dashboard.
- `wiki/commands/obsidian-compatible-commands.md` as a generated command-palette page.
- `wiki/slides/README.md` plus `obsidian slides` for note-derived slide decks.
- `wiki/_templates/daily.md` and `wiki/_templates/web-clip.md` for daily note and web-clip capture workflows.
- `python scripts/wiki.py obsidian ...` for CLI parity with backlinks, outgoing links, search, quick switcher, commands, file explorer, outline, page preview, footnotes, tags, properties, tasks, daily notes, unique notes, random notes, word count, external links, format audit, slides, export, and report.

## Feature Mapping

| Obsidian feature | WEIPING_WIKI adaptation |
| --- | --- |
| Audio recorder | Not cloned; media evidence belongs in `raw/attachments` and recording UI is app/hardware-specific |
| Backlinks / outgoing links | `wiki/catalog.json` plus `python scripts/wiki.py obsidian backlinks/outgoing` |
| Bases | Generated `.base` files over Markdown frontmatter |
| Bookmarks | Generated `wiki/obsidian-dashboard.md` and `.obsidian/bookmarks.json` |
| Canvas | JSON Canvas file under `wiki/canvases/` |
| Command palette / slash commands | `obsidian commands` plus `wiki/commands/obsidian-compatible-commands.md` |
| Daily notes | `obsidian daily` plus `wiki/_templates/daily.md` |
| File explorer | `obsidian files` folder and recent-file report |
| File recovery | Git history, scoped commits, pre-push safety, and generated maintenance artifacts |
| Footnotes view | `obsidian footnotes` |
| Format converter | `obsidian format-report` conversion-risk audit |
| Graph view | Existing graph tooling plus generated JSON Canvas map |
| Note composer | Safety-gated; agents perform merge/split edits with lint/catalog validation rather than blind note surgery |
| Outline | `obsidian outline <page>` |
| Page preview | `obsidian preview <page>` |
| Properties view | `obsidian properties` frontmatter schema report |
| Publish | Quartz publishing layer |
| Quick switcher | `obsidian quick <query>` |
| Random note | `obsidian random` |
| Search | `python scripts/wiki.py search` and `obsidian search` |
| Slides | `obsidian slides <page>` |
| Sync | Git commit/push and GitHub remote |
| Tags view | `obsidian tags` counts and page lists |
| Tasks | `obsidian tasks` checkbox scan |
| Templates | Existing wiki templates plus daily and web-clip templates |
| Unique note creator | `obsidian unique --title ...` |
| Web viewer | `obsidian external-links`; browsing stays in the browser/app layer |
| Web Clipper | `wiki/_templates/web-clip.md` plus existing URL/source ingest skills |
| Word count | `obsidian word-count` |
| Workspaces | `.obsidian/workspaces.json`, dashboard, canvas, and Bases |

## Usage

```powershell
python scripts/wiki.py obsidian report --json
python scripts/wiki.py obsidian export --json
python scripts/wiki.py obsidian commands --json
python scripts/wiki.py obsidian quick "whole computer" --json
python scripts/wiki.py obsidian outline obsidian-feature-parity --json
python scripts/wiki.py obsidian word-count --top 20 --json
python scripts/wiki.py catalog
python scripts/wiki.py lint
```

Then open `D:\Research\vipin's knowledgebase` as an Obsidian vault. The generated dashboard is [[obsidian-dashboard]], the generated base index is [[bases/README]], and the generated command index is [[obsidian-compatible-commands]].

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
