param(
    [string]$Path = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath $Path).Path
$gitDir = (& git -C $root rev-parse --git-dir).Trim()
if ($LASTEXITCODE -ne 0 -or -not $gitDir) {
    throw "Not a git repository: $root"
}
if (-not [System.IO.Path]::IsPathRooted($gitDir)) {
    $gitDir = Join-Path $root $gitDir
}

$hookDir = Join-Path $gitDir "hooks"
New-Item -ItemType Directory -Force -Path $hookDir | Out-Null

$gate = (Join-Path $root "scripts/Test-PrePushSafety.ps1") -replace '\\', '/'
$hook = @"
#!/bin/sh
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$gate"
"@

$hookPath = Join-Path $hookDir "pre-push"
[System.IO.File]::WriteAllText($hookPath, $hook + "`n", [System.Text.UTF8Encoding]::new($false))
Write-Host "Installed pre-push hook: $hookPath" -ForegroundColor Green
