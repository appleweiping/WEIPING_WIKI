---
title: VS Code Black Screen Repair Runbook
type: query
status: active
created: 2026-05-18
updated: 2026-05-18
tags:
  - query
  - vscode
  - troubleshooting
  - windows
  - local-tools
source_pages:
  - chat
source_files:
  - C:/Users/admin/AppData/Roaming/Code/User/argv.json
---

# VS Code Black Screen Repair Runbook

## Question

How should future agents diagnose and repair the local Microsoft VS Code black-screen issue seen on 2026-05-17 / 2026-05-18?

## Short Answer

The durable fix was an in-place reinstall of Microsoft VS Code plus a safer renderer configuration in `C:/Users/admin/AppData/Roaming/Code/User/argv.json`.

Final visible result:

- EXTRACTED: `Code.exe` showed a normal `Release Notes: 1.120.0 - Visual Studio Code` window.
- EXTRACTED: `code.cmd --status` reported `gpu_compositing: enabled`.
- EXTRACTED: `code.cmd --status` showed active Intel Iris Xe Graphics rather than SwiftShader software rendering.

## Symptom

- EXTRACTED: The user reported that VS Code opened as a dark/black window with no usable workbench content.
- EXTRACTED: The visible window frame and menu existed, but the main editor/workbench region did not render normally.
- INFERRED: This was not simply a workspace with no file open; VS Code had a real rendering/workbench startup problem.

## Important Correction

Do not confuse Microsoft VS Code and Cursor.

- EXTRACTED: The problematic app requested by the user was Microsoft VS Code, launched from `C:/Users/admin/AppData/Local/Programs/Microsoft VS Code/Code.exe`.
- EXTRACTED: During the repair attempt, Codex briefly misread a screenshot that showed `Cursor` in the title bar and started applying similar cache fixes to Cursor.
- EXTRACTED: That Cursor change was reversed in the same session:
  - the created `C:/Users/admin/AppData/Roaming/Cursor/User/argv.json` was removed
  - moved Cursor cache and workspace-state folders were restored from `C:/Users/admin/AppData/Roaming/Cursor/_black-screen-backup-20260517-233305`
- Durable rule: when the user says VS Code, first verify the process path is `Microsoft VS Code/Code.exe`; do not repair Cursor unless the user explicitly names Cursor.

## Diagnosis Timeline

### 1. Confirm Process And Install Path

Useful command:

```powershell
Get-Process Code -ErrorAction SilentlyContinue |
  Select-Object Id,ProcessName,Path,StartTime,MainWindowTitle,MainWindowHandle |
  Format-Table -AutoSize
```

What it contributed:

- EXTRACTED: Confirmed multiple `Code` processes.
- EXTRACTED: Confirmed the executable path was `C:/Users/admin/AppData/Local/Programs/Microsoft VS Code/Code.exe`.
- EXTRACTED: Confirmed a main window handle eventually existed, so the app was launching but the content was not rendering.

### 2. Check VS Code Renderer Config

Useful file:

```text
C:/Users/admin/AppData/Roaming/Code/User/argv.json
```

Initial finding:

```json
{
  "disable-hardware-acceleration": true
}
```

What it contributed:

- EXTRACTED: VS Code was explicitly forcing hardware acceleration off.
- INFERRED: This pushed VS Code toward software rendering / SwiftShader, which can be safer on some GPU failures but can also produce blank/black Electron windows on some Windows builds and drivers.

### 3. Clear VS Code Rendering Caches

The cache/state cleanup moved VS Code directories to timestamped backup folders instead of deleting them.

Backups created:

```text
C:/Users/admin/AppData/Roaming/Code/_black-screen-cache-backup-20260517-231900
C:/Users/admin/AppData/Roaming/Code/_black-screen-state-backup-20260517-233049
```

Moved cache folders included:

```text
GPUCache
DawnGraphiteCache
DawnWebGPUCache
Cache
Code Cache
CachedData
blob_storage
Session Storage
Service Worker
Local Storage
WebStorage
Network
```

Moved state folders included:

```text
User/workspaceStorage
User/History
Workspaces
Backups
```

What it contributed:

- EXTRACTED: It removed stale Chromium/Electron GPU and web cache state.
- EXTRACTED: It removed stale workbench/window restoration state.
- INFERRED: This was necessary but not sufficient; the VS Code window still had a black/empty workbench before the final reinstall/config fix.

### 4. Use Clean-Profile Tests

Useful command pattern:

```powershell
$testDir = Join-Path $env:TEMP 'vscode-clean-profile-test'
Start-Process -FilePath "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" `
  -ArgumentList @('--user-data-dir', $testDir, '--disable-extensions', '--disable-gpu', '--new-window')
```

What it contributed:

- EXTRACTED: A clean profile could create a `Visual Studio Code` main window.
- INFERRED: The app binary was at least launchable.
- INFERRED: Because the content still appeared black in follow-up checks, the issue was not just one corrupted workspace folder or one user setting.

### 5. Inspect Logs And Status

Useful commands:

```powershell
Get-ChildItem "$env:APPDATA\Code\logs" -Recurse -Filter *.log |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 12 FullName,Length,LastWriteTime

& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" --status
```

Key findings:

- EXTRACTED: Main logs showed normal storage initialization and no obvious renderer crash.
- EXTRACTED: Earlier logs repeatedly warned that MCP migration failed to parse `settings.json`, but byte-level validation showed `settings.json` was valid UTF-8 JSON at the time of inspection.
- EXTRACTED: `code.cmd --status` in the broken rendering path showed SwiftShader software rendering:
  - `GPU0: Google Inc. ANGLE ... SwiftShader`
  - `gpu_compositing: disabled_software`
  - `webgl: unavailable_software`
- INFERRED: The more important failure signal was the software rendering path, not the earlier MCP migration warning.

### 6. Switch Back To Hardware Rendering

Final `argv.json` after repair:

```json
{
  "disable-hardware-acceleration": false,
  "disable-features": "CalculateNativeWinOcclusion",
  "force-device-scale-factor": 1
}
```

What each line contributes:

- `"disable-hardware-acceleration": false`
  - avoids forcing SwiftShader/software rendering
  - allows VS Code to use the Intel GPU path
- `"disable-features": "CalculateNativeWinOcclusion"`
  - disables a Chromium/Windows optimization that can mis-detect covered windows and produce blank/black rendering symptoms
- `"force-device-scale-factor": 1`
  - removes display-scaling weirdness from the diagnosis path

Validation after this change:

```text
GPU0: Intel(R) Iris(R) Xe Graphics ... *ACTIVE*
gpu_compositing: enabled
```

### 7. Repair The VS Code Installation

Winget checks:

```powershell
winget list --id Microsoft.VisualStudioCode --exact
winget upgrade --id Microsoft.VisualStudioCode --exact
```

Findings:

- EXTRACTED: VS Code was installed as `Microsoft Visual Studio Code (User)`.
- EXTRACTED: Installed version was `1.120.0`.
- EXTRACTED: No newer winget upgrade was available.
- EXTRACTED: `winget repair` failed due to winget/source issues:
  - `0x80071130 : Fast Cache data not found`
  - later `找不到匹配的版本: 1.120.0`

Effective fallback:

```powershell
$installer = Join-Path $env:TEMP 'VSCodeUserSetup-x64-stable.exe'
Invoke-WebRequest `
  -Uri 'https://update.code.visualstudio.com/latest/win32-x64-user/stable' `
  -OutFile $installer `
  -UseBasicParsing

Start-Process -FilePath $installer `
  -ArgumentList @('/VERYSILENT','/NORESTART','/MERGETASKS=!runcode') `
  -Wait
```

What it contributed:

- EXTRACTED: Reinstalled VS Code user edition in place.
- EXTRACTED: Preserved user settings and extensions under `AppData/Roaming/Code` and `.vscode/extensions`.
- EXTRACTED: Repaired the installed `Code.exe/resources` layer without deleting the user profile.

### 8. Final Verification

Useful commands:

```powershell
Start-Process -FilePath "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" `
  -ArgumentList @('--new-window', "$env:TEMP\vscode-after-reinstall-test.txt")

& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" --status

Get-Process Code -ErrorAction SilentlyContinue |
  Where-Object { $_.MainWindowHandle -ne 0 } |
  Select-Object Id,MainWindowTitle,Path
```

Final observed output:

- EXTRACTED: Window title became `Release Notes: 1.120.0 - Visual Studio Code`.
- EXTRACTED: `Code.exe` path remained `C:/Users/admin/AppData/Local/Programs/Microsoft VS Code/Code.exe`.
- EXTRACTED: `gpu_compositing` was `enabled`.
- EXTRACTED: active GPU was Intel Iris Xe Graphics.

## Next-Time Fast Path

Use this order if VS Code opens black again:

1. Confirm it is VS Code, not Cursor:

```powershell
Get-Process Code,Cursor -ErrorAction SilentlyContinue |
  Select-Object ProcessName,Path,MainWindowTitle,MainWindowHandle
```

2. Stop VS Code:

```powershell
Get-Process Code -ErrorAction SilentlyContinue | Stop-Process -Force
```

3. Set `C:/Users/admin/AppData/Roaming/Code/User/argv.json` to:

```json
{
  "disable-hardware-acceleration": false,
  "disable-features": "CalculateNativeWinOcclusion",
  "force-device-scale-factor": 1
}
```

4. Move VS Code rendering cache folders to a timestamped backup:

```powershell
$codeRoot = Join-Path $env:APPDATA 'Code'
$backupRoot = Join-Path $codeRoot ("_black-screen-cache-backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

@(
  'GPUCache',
  'DawnGraphiteCache',
  'DawnWebGPUCache',
  'Cache',
  'Code Cache',
  'CachedData',
  'blob_storage',
  'Session Storage',
  'Service Worker',
  'Local Storage',
  'WebStorage',
  'Network'
) | ForEach-Object {
  $src = Join-Path $codeRoot $_
  if (Test-Path -LiteralPath $src) {
    Move-Item -LiteralPath $src -Destination (Join-Path $backupRoot $_) -Force
  }
}
```

5. If it is still black, run the official user installer in place:

```powershell
$installer = Join-Path $env:TEMP 'VSCodeUserSetup-x64-stable.exe'
Invoke-WebRequest `
  -Uri 'https://update.code.visualstudio.com/latest/win32-x64-user/stable' `
  -OutFile $installer `
  -UseBasicParsing

Start-Process -FilePath $installer `
  -ArgumentList @('/VERYSILENT','/NORESTART','/MERGETASKS=!runcode') `
  -Wait
```

6. Verify:

```powershell
& "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" --status |
  Select-String -Pattern 'GPU0|gpu_compositing|window \['
```

Good signs:

- `GPU0` is Intel or another real GPU, not only SwiftShader.
- `gpu_compositing: enabled`.
- `window [1]` has a real title such as `Release Notes` or an opened file.

## Backups Created During This Repair

VS Code:

```text
C:/Users/admin/AppData/Roaming/Code/_black-screen-cache-backup-20260517-231900
C:/Users/admin/AppData/Roaming/Code/_black-screen-state-backup-20260517-233049
C:/Users/admin/AppData/Roaming/Code-user-config-backup-before-reinstall-20260517-235042
```

Cursor temporary backup, restored during the same session:

```text
C:/Users/admin/AppData/Roaming/Cursor/_black-screen-backup-20260517-233305
```

## Safety Notes

- Do not publish full `settings.json` contents. It may include terminal environment variables, local tokens, paths, or service endpoints.
- Do not delete cache/state directories first; move them to a timestamped backup so recovery is possible.
- Do not touch Cursor when the target is VS Code, even though both are VS Code-family Electron editors.
- Prefer user-level reinstall over destructive cleanup. Reinstall `Code.exe/resources` while preserving `AppData/Roaming/Code/User` and `.vscode/extensions`.

## Counterpoints And Gaps

- AMBIGUOUS: The exact root cause was not proven. The strongest signals were stale rendering/cache state, forced software rendering, and possible VS Code installation/resource corruption.
- AMBIGUOUS: Earlier MCP migration warnings about `settings.json` appeared in logs, but later validation showed the file was valid JSON; those warnings may have been stale or from a previous malformed state.
- UNVERIFIED: Whether `CalculateNativeWinOcclusion` alone would have fixed the issue without reinstall was not isolated.
- UNVERIFIED: Whether a newer Intel graphics driver would prevent recurrence was not checked.

## Related

- [[queries-home]]
- [[index]]
- [[log]]
