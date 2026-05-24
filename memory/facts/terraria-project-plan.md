---
title: "My Terraria 项目计划 (Codex 制定)"
type: fact
created: 2026-05-21T22:10:00+08:00
updated: 2026-05-21T19:05:00+01:00
agent: codex
tags: [terraria, game, codex-lead, plan]
related: [all-projects-status.md]
---

## Codex Action Plan (2026-05-21)

### 1. Build flagship original: "My Terraria Vault" (all-item archive world)
- Complete item coverage by category
- Labeled chests, themed rooms, test chambers
- External metadata file with provenance

### 2. Import 6 high-quality external saves
- Categories: all-item, adventure map ×2, arena, builder, challenge
- Full provenance for each (source, author, license, hash)
- Respect redistribution rights

### 3. Upgrade TerrariaAgent Framework
- Save manifest schema (JSON)
- Automated validation (hashing, duplicate detection, provenance check)
- Quality scoring rubric (100-point scale, 85+ for originals)
- Catalog generation (CATALOG.md + catalog.json) — DONE in v2.1

## Status
- Assigned to: Codex (GPT-5.5) + DeepSeek
- CC does not participate in daily development
- Runs in parallel with research projects

## 2026-05-21 Update — Framework v2.1

- Repository: `D:\Terraria_doc` / `https://github.com/appleweiping/my-terraria`
- Commit pushed: `3822364 Add Terraria archive catalog v2.1`
- Added `tools/build_catalog.py`, a dependency-free catalog/version-matrix generator.
- Generated `inventory/CATALOG.md` and `inventory/catalog.json`.
- Added `tests/test_build_catalog.py`; validation passed with `python -m unittest tests.test_build_catalog` and `python tools/build_catalog.py --check`.
- Reconstructed Starter Academy docs: `README.md`, `design.md`, `acceptance-checklist.md`.
- No `.wld`, `.plr`, `.map`, or `.bak` save binaries were modified.

## Next Terraria Steps

- Add GitHub Actions / CI for `python tools/build_catalog.py --check`.
- Add per-save load-test or metadata readback validation.
- Generate visual documentation/map renders for catalog display.
- Continue importing license-compatible maps only; private/unclear third-party binaries stay local-only.
