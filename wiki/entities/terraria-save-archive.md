---
title: Terraria Save Archive
type: entity
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - entity
  - local-files
  - game-archive
  - terraria
source_pages:
  - 2026-05-15-terraria-local-save-files
source_files:
  - C:/Users/admin/Documents/My Games/Terraria
  - D:/Terraria_doc
---

# Terraria Save Archive

## Role In The Wiki

This page is the routing note for Vipin's local Terraria saves and their D-drive backup.

## Current Locations

- EXTRACTED: Original save root: `C:/Users/admin/Documents/My Games/Terraria`.
- EXTRACTED: Backup root: `D:/Terraria_doc/Terraria_saves`.
- EXTRACTED: Inventory and analysis files:
  - `D:/Terraria_doc/inventory/terraria-file-analysis.md`
  - `D:/Terraria_doc/inventory/terraria-file-inventory.csv`

## Current Inventory Snapshot

- EXTRACTED: 193 Terraria-related files were detected and copied.
- EXTRACTED: Total copied size is about 165.37 MB.
- EXTRACTED: The archive contains:
  - 54 player character saves (`.plr`)
  - 44 world saves (`.wld`)
  - 48 per-player world map cache files (`.map`)
  - 47 backup files (`.bak`, including `.plr.bak` and `.wld.bak`)

## Sorting Heuristics

- INFERRED: Highest priority for preservation: `.plr`, `.wld`, then `.bak`, then `.map`.
- INFERRED: Good top-level organization categories are `Players`, `Worlds`, `Backups`, `MapCache`, `AllItemMaps`, `Farms`, `Buildings`, and `ClassCharacters`.
- INFERRED: The generated CSV is the best working surface for later cleanup because it includes hashes and a short note for each file.

## Restore Notes

- EXTRACTED: Terraria's usual Windows save location is under `Documents/My Games/Terraria`.
- INFERRED: To restore a character, copy the desired `.plr` file into `Players`.
- INFERRED: To restore a world, copy the desired `.wld` file into `Worlds`.
- INFERRED: To restore from a backup file, copy the backup and remove the trailing `.bak` after deciding which version should become active.

## Related Pages

- [[2026-05-15-terraria-local-save-files]]
- [[local-project-roots]]
