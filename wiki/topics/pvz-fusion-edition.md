---
title: Plants vs. Zombies Fusion Edition
type: topic
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - topic
  - pvz-fusion
  - game-mod
source_pages:
  - 2026-05-16-qq-doc-pvz-fusion-mobile-pc
---

# Plants vs. Zombies Fusion Edition

This topic tracks 植物大战僵尸融合版 / Plants vs. Zombies Fusion Edition materials for phone and PC setup.

## Current Source Set

- [[2026-05-16-qq-doc-pvz-fusion-mobile-pc]] - Tencent Docs page titled `关于植物大战僵尸融合版（手机加PC端）`; metadata plus authorized visual capture of the PC MOD tutorial.

## Known State

- EXTRACTED: The available source is a Tencent Docs document about both mobile and PC versions.
- EXTRACTED: The unauthenticated browser view says the document has permissions enabled and asks the user to log in.
- EXTRACTED: The user opened an authorized browser view; normal copy remained restricted, but visual capture exposed the link labels and PC MOD tutorial.
- EXTRACTED: Public metadata exposes title, owner display name, create time, modify time, and permission flags.
- EXTRACTED: PC MOD installation is centered on the game root and the `BepInEx\plugins` folder.
- AMBIGUOUS: Actual hyperlink target URLs are not yet extracted.
- UNVERIFIED: Download file provenance, checksums, and compatibility notes are not yet independently verified.

## Link Labels Seen

- `不想麻烦想玩手机版点我`
- `手机端看这个视频结尾跟着操作行`
- `视频知秋同款PC端点我`
- `电脑端同款不想安装 MOD 点我`
- `游戏本体点我PC端点我`
- `手机端游戏本体点我`
- `植物MOD 高级版本MOD植物插件点我`

## PC MOD Setup Summary

- Locate the downloaded game folder and the MOD folder/source.
- Example game root: `E:\quake\植物大战僵尸融合版3.6.1`.
- The author's example root includes BepInEx, dotnet, game data, Unity runtime DLLs, and existing mod-related DLLs.
- User folders may differ from the author's because the author's copy already has added/tested content.
- Open `BepInEx`, then open `plugins`; this is the MOD storage location.
- Do not scatter MOD files into random folders, because wrong placement may prevent the game from running.
- For plant MODs, open the `二.二创植物` folder, then `3.6（兼容3.6.1）`.
- Plant MOD packages are shown as `.zip` archives. Choose a plant package, decompress it, open the decompressed folder, and use the contained plugin file(s) according to the `BepInEx\plugins` target rule.
- Example plant package labels visible in the screenshot include `AstralGodCabbage-究极星神卷心菜`, `BarleyNuts-寒伤苔坚果`, and `BathFireKomatsu-究极浴火小松炉`.

## Ingest Rules

- Do not invent installation steps or package links from the title alone.
- If future ingest receives a user-exported file or logged-in page capture, separate phone and PC instructions explicitly.
- Treat downloaded executables, APKs, archives, and patches as software supply-chain items: record source URL, version/date, checksums when available, and whether the file is official, community, mirrored, or unknown.
- Keep public wiki notes to metadata, summaries, and provenance unless redistribution rights for any file or full text are clear.

## Desired Structured Fields

Still needed:

- version or release date
- Android/mobile download source
- PC download source
- exact hyperlink destinations
- exact archive contents after download/extraction
- save/config location, if mentioned elsewhere
- compatibility notes
- known issues
- safety/provenance notes

## Related

- [[2026-05-16-qq-doc-pvz-fusion-mobile-pc]]

## Counterpoints And Gaps

- Current instructions are screenshot-derived and should be replaced by clean exported text if export becomes available.
- Exact target URLs behind the Tencent Docs links are not yet captured.
