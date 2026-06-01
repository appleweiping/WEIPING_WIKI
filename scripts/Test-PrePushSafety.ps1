param(
    [string]$Path = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)),
    [switch]$SkipHistory,
    [switch]$ScanUntracked
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path -LiteralPath $Path).Path
$secretPattern = 'sk-proj-[A-Za-z0-9_-]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{32,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----'
$allowedPlaceholders = @(
    "ghp_your_github_token",
    "ghp_your_new_github_token",
    "github_pat_your_github_token",
    "github_pat_your_new_github_token"
)
$blockedPathPattern = '(^|/)(\.env|secrets?)(/|$)|^(logs?|cache|sessions?|state|runtime|runtimes|node_modules|npm-cache|uv-cache|uv-venv|browser-profiles|model-cache)(/|$)|\.(sqlite|sqlite-shm|sqlite-wal|db|log|pem|p12|pfx)$|(^|/).*\.(local|secret|secrets)(\.cmd|\.ps1|\.json|\.toml|\.env|$)'

function Convert-ToRepoPath([string]$filePath) {
    $full = [System.IO.Path]::GetFullPath((Join-Path $root $filePath))
    $relative = [System.IO.Path]::GetRelativePath($root, $full)
    return ($relative -replace '\\', '/')
}

function Invoke-GitLines([string[]]$arguments) {
    $output = & git -C $root -c core.quotePath=false @arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "git $($arguments -join ' ') failed in $root"
    }
    return @($output)
}

Invoke-GitLines @("rev-parse", "--is-inside-work-tree") *> $null

$files = New-Object System.Collections.Generic.HashSet[string]
foreach ($line in (Invoke-GitLines @("ls-files"))) {
    if ($line) { [void]$files.Add(($line -replace '\\', '/')) }
}
foreach ($line in (Invoke-GitLines @("diff", "--cached", "--name-only"))) {
    if ($line) { [void]$files.Add(($line -replace '\\', '/')) }
}
if ($ScanUntracked) {
    foreach ($line in (Invoke-GitLines @("ls-files", "--others", "--exclude-standard"))) {
        if ($line) { [void]$files.Add(($line -replace '\\', '/')) }
    }
}

$failures = New-Object System.Collections.Generic.List[string]

foreach ($relative in $files) {
    if ($relative -match $blockedPathPattern) {
        $failures.Add("Blocked tracked/staged path: $relative")
        continue
    }

    $full = Join-Path $root ($relative -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    try {
        $exists = Test-Path -LiteralPath $full -PathType Leaf
    } catch {
        continue
    }
    if (-not $exists) {
        continue
    }
    $item = Get-Item -LiteralPath $full
    if ($item.Length -gt 5MB) {
        continue
    }
    try {
        $text = Get-Content -LiteralPath $full -Raw -ErrorAction Stop
    } catch {
        continue
    }
    if ($null -eq $text) {
        continue
    }
    foreach ($match in [regex]::Matches($text, $secretPattern)) {
        $value = $match.Value
        if ($allowedPlaceholders -contains $value) {
            continue
        }
        if ($value -match '^sk-x{8,}$') {
            continue
        }
        $redacted = if ($value.Length -gt 12) {
            $value.Substring(0, 8) + "..." + $value.Substring($value.Length - 4)
        } else {
            "[redacted]"
        }
        $failures.Add("Secret-like value in $relative`: $redacted")
    }
}

foreach ($relative in $files) {
    if ($relative -match '(^|/)\.git(/|$)') {
        $failures.Add("Tracked/staged nested .git path: $relative")
    }
}

foreach ($line in (Invoke-GitLines @("status", "--porcelain=v1", "--untracked-files=normal"))) {
    if ($line -notmatch '^\?\? ') { continue }
    $relative = ($line.Substring(3) -replace '\\', '/').TrimEnd('/')
    $candidate = Join-Path $root ($relative -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    if ((Test-Path -LiteralPath $candidate -PathType Container) -and (Test-Path -LiteralPath (Join-Path $candidate ".git"))) {
        $failures.Add("Nested .git directory is not ignored: $relative")
    }
}

if (-not $SkipHistory) {
    $historyHits = @(& git -C $root log -p --all -G $secretPattern -- . 2>$null)
    foreach ($line in $historyHits) {
        foreach ($match in [regex]::Matches($line, $secretPattern)) {
            $value = $match.Value
            if ($allowedPlaceholders -contains $value) {
                continue
            }
            if ($value -match '^sk-x{8,}$') {
                continue
            }
            $redacted = if ($value.Length -gt 12) {
                $value.Substring(0, 8) + "..." + $value.Substring($value.Length - 4)
            } else {
                "[redacted]"
            }
            $failures.Add("Secret-like value in git history: $redacted")
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | Select-Object -First 80
    throw "Pre-push safety gate failed in $root"
}

Write-Host "Pre-push safety gate passed: $root" -ForegroundColor Green
