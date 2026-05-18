---
title: Tencent Doc - Plants vs. Zombies Fusion Edition Mobile And PC
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - tencent-docs
  - pvz-fusion
  - game-mod
source_pages:
  - https://docs.qq.com/doc/DSk9tUnNKTGdFVFBJ
---

# Tencent Doc - Plants vs. Zombies Fusion Edition Mobile And PC

## Source

- Canonical URL: https://docs.qq.com/doc/DSk9tUnNKTGdFVFBJ
- Title: 关于植物大战僵尸融合版（手机加PC端）
- Platform: Tencent Docs
- Pad type: `doc`
- Pad ID: `JOmRsJLgETPI`
- Creator / owner display name: 知秋
- Created: 2026-05-12 17:04:29 +02:00
- Last modified: 2026-05-14 13:30:13 +02:00

## Access And Capture Status

- EXTRACTED: The document title and metadata are publicly visible from the Tencent Docs page shell.
- EXTRACTED: Browser rendering shows the message `此文档已设置权限，请登录后使用。`
- EXTRACTED: The page metadata reports `canRead=true`, `canSearch=true`, `canCopy=false`, `canExport=false`, and `isAuth=false`.
- EXTRACTED: After the user opened the authorized browser view, the document body became visible but normal copy still returned only document shell text.
- EXTRACTED: The current body extraction is from authorized visual capture/screenshots, not from a clean text export.
- AMBIGUOUS: The exact target URLs behind the Tencent Docs links were not extracted in this pass.

## What This Source Is About

This is a Tencent Docs page about 植物大战僵尸融合版 / Plants vs. Zombies Fusion Edition for mobile plus PC. It functions as a small download/link hub plus a PC-side MOD installation walkthrough.

## Current Usable Facts

- It is a guide or information document, not a sheet.
- It is meant to cover both phone and PC versions.
- It is permission-gated for unauthenticated browser access.
- Copy and export permissions are disabled in the public metadata, so this pass used authorized visual capture rather than direct export.

## Visible Link Headings

The authorized view showed these link labels. Target URLs still need direct link extraction or export:

- `不想麻烦想玩手机版点我`
- `手机端看这个视频结尾跟着操作行`
- `视频知秋同款PC端点我`
- `电脑端同款不想安装 MOD 点我`
- `游戏本体点我PC端点我`
- `手机端游戏本体点我`
- `植物MOD 高级版本MOD植物插件点我`

## PC MOD Tutorial Extract

EXTRACTED from the authorized visual capture:

- The tutorial first asks the user to identify two locations:
  - the downloaded game folder
  - the MOD folder/location to place add-ons
- The example game folder path shown is under `E:\quake\植物大战僵尸融合版3.6.1`.
- The example game root contains folders/files including:
  - `BepInEx`
  - `dotnet`
  - `PlantsVsZombiesRH_Data`
  - `.doorstop_version`
  - `baselib.dll`
  - `changelog`
  - `doorstop_config`
  - `GameAssembly.dll`
  - `MaterialDesignColors.dll`
  - `MaterialDesignThemes.Wpf.dll`
  - `Microsoft.Xaml.Behaviors.dll`
  - `Modified-Plus.dll`
  - `Newtonsoft.Json.dll`
  - `PlantsVsZombiesRH`
  - `PvZRHModified`
  - `UnityCrashHandler64`
  - `UnityPlayer.dll`
  - `UniverseLib.IL2CPP.dll`
  - `winhttp.dll`
- The document stresses that the author's example folder is a personally modified/tested copy, so the user's downloaded folder may look different and have fewer items.
- The tutorial says to open `BepInEx`; inside it, open `plugins`.
- The `BepInEx\plugins` folder is described as the location where MOD files are stored. The document warns not to place MODs randomly or the game may fail to run.
- Existing `.dll` files in the author's `plugins` folder are treated as built-in/current MOD files.
- The document says the left side of the comparison is the game body/root and the right side is MOD/modifier-related content.
- For adding plant MODs:
  - open the plant file folder described as `二.二创植物`
  - open the version folder shown as `3.6（兼容3.6.1）`
  - the plant packages are shown as `.zip` files
  - example package names include `AstralGodCabbage-究极星神卷心菜`, `BarleyNuts-寒伤苔坚果`, `BathFireKomatsu-究极浴火小松炉`, and several `BigSuper...Gatling` packages
  - the instruction is to decompress/extract the chosen plant package and open it

## Interpretation

- INFERRED: This is a practical end-user guide for choosing between mobile, vanilla PC, PC without installing MODs, and PC with advanced plant MOD plugins.
- INFERRED: PC MOD installation depends on a BepInEx-style Unity mod loader layout, with `BepInEx\plugins` as the main plugin destination.
- INFERRED: The document assumes the user already has the game folder and a separate archive/folder of plant MOD packages.

## Follow-Up Capture Plan

1. Extract the hidden target URLs behind the visible link labels.
2. If Tencent Docs export is available to the user, use the exported `.docx`, `.pdf`, or copied text to replace screenshot-derived text with cleaner source text.
3. If download files are obtained, record version, size, checksum, provenance, and whether each file is game body, mobile package, PC package, or MOD plugin archive.
4. Check executable/archive safety before running or redistributing anything.

## Related Pages

- [[pvz-fusion-edition]]

## Counterpoints And Gaps

- Screenshot-derived extraction can miss small labels and cannot reliably capture the exact hyperlink destinations.
- The document may contain download links or unofficial game-mod files; those should be treated as external software sources and checked for provenance, version, and safety before use.
