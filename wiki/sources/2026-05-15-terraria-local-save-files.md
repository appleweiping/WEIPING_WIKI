---
title: Terraria Local Save Files
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - source
  - local-files
  - game-archive
  - terraria
source_files:
  - C:/Users/admin/Documents/My Games/Terraria
  - D:/Terraria_doc/Terraria_saves
  - D:/Terraria_doc/inventory/terraria-file-analysis.md
  - D:/Terraria_doc/inventory/terraria-file-inventory.csv
source_pages:
  - terraria-save-archive
  - local-project-roots
---

# Terraria Local Save Files

## Provenance

- Source: user request in chat on 2026-05-15 to search for Terraria save-related local files, ingest the finding into the wiki, then back up and analyze them.
- Inspection mode: local filesystem search of standard Terraria save locations plus a D-drive filename scan attempt.
- Primary live source found: `C:/Users/admin/Documents/My Games/Terraria`.
- Backup destination created: `D:/Terraria_doc/Terraria_saves`.
- Local inventory files created:
  - `D:/Terraria_doc/inventory/terraria-file-analysis.md`
  - `D:/Terraria_doc/inventory/terraria-file-inventory.csv`

## Discovery Result

- EXTRACTED: The standard Windows Terraria save directory exists at `C:/Users/admin/Documents/My Games/Terraria`.
- EXTRACTED: No Terraria save directory was found at `D:/Terraria`, `D:/泰拉瑞亚`, or `D:/Terraria_doc` before the backup directory was created.
- EXTRACTED: A broader recursive scan of `D:/` for Terraria/tModLoader/save extensions timed out after 120 seconds and did not return an additional completed result in that run.
- EXTRACTED: The found save set contains 193 Terraria-related files totaling 173,405,180 bytes, about 165.37 MB.
- EXTRACTED: The source tree has two main save subdirectories:
  - `Players`: 121 files, including player saves, player backups, and per-player map cache files.
  - `Worlds`: 72 files, including world saves and world backups.

## File Type Summary

- EXTRACTED: 54 `.plr` files are player/character saves. They preserve character inventory, equipment, money, health/mana, and character-level progression.
- EXTRACTED: 44 `.wld` files are world saves. They preserve world terrain, buildings, chests, NPC housing, farms, world state, and all-item/resource maps.
- EXTRACTED: 48 `.map` files are per-player explored-map cache files under `Players/<character>/`. They are useful for restoring map visibility but are less critical than `.plr` and `.wld`.
- EXTRACTED: 47 `.bak` files are backups, including 19 player backups, 27 world backups, and 1 generic backup-like file.

## Backup And Analysis Artifacts

- EXTRACTED: The backup copied 193 files to `D:/Terraria_doc/Terraria_saves`.
- EXTRACTED: The copied backup has the same count and total size as the discovered source set: 193 files and 173,405,180 bytes.
- EXTRACTED: The CSV inventory records relative path, file name, inferred kind, size, modified time, source path, backup path, SHA-256 hash, and a short per-file analysis note.
- EXTRACTED: The Markdown inventory records the same analysis in a human-readable table, with a recent-files section and full inventory section.

## Organization Guidance

- INFERRED: Treat `.plr` and `.wld` as the core files to keep even when pruning aggressively.
- INFERRED: Keep `.bak` files until a clean restore has been verified; they are cheap insurance against corrupted or overwritten saves.
- INFERRED: `.map` files can be kept with their corresponding player folders, but they are secondary if the goal is only to preserve characters and worlds.
- INFERRED: Names indicating all-item maps, workshops, equipment shops, farms, buildings, challenge maps, or class-specific characters can be used as first-pass sorting categories.

## Safety And Public Boundary

- This wiki page records only routing, counts, file types, and backup locations.
- Do not copy the binary game-save files into `wiki/`.
- Keep detailed per-file sorting work in `D:/Terraria_doc/inventory/` unless the user explicitly wants a public-facing summary.
- If future sorting exposes personal names or private notes embedded in filenames, keep those details out of public wiki summaries unless needed.

## Related Pages

- [[terraria-save-archive]]
- [[local-project-roots]]
