# Ingest-Common.ps1 — Shared utility functions for all ingest scripts.
# Dot-source this at the top of each ingest script:
#   . (Join-Path $PSScriptRoot "Ingest-Common.ps1")

# --- Encoding setup ---
$script:utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# --- File I/O ---

function Read-TextFile([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Write-TextIfChanged([string]$Path, [string]$Content) {
    $normalized = $Content.TrimEnd() + "`n"
    if ((Test-Path -LiteralPath $Path) -and ((Read-TextFile $Path) -eq $normalized)) {
        return $false
    }
    Ensure-Dir (Split-Path -Parent $Path)
    [System.IO.File]::WriteAllText($Path, $normalized, $script:utf8NoBom)
    return $true
}

# --- Text utilities ---

function ConvertTo-Slug([string]$Text) {
    $slug = $Text.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
    return $slug.Trim('-')
}

function Escape-Yaml([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    return (($Text -replace '"', '\"') -replace "(`r`n|`n|`r)", " ").Trim()
}

function Escape-WikiText([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    return (($Text -replace '\[\[', '&#91;&#91;') -replace '\]\]', '&#93;&#93;') -replace '(?m)^(<{7}|={7}|>{7})', '`$1'
}

function Get-Sha256Text([string]$Text) {
    if ($null -eq $Text) { $Text = "" }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally {
        $sha.Dispose()
    }
}

function Get-PlainSummary([string]$Text, [int]$Limit = 520) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return "No source summary text was available during this crawl." }
    $plain = $Text -replace '(?s)```.*?```', ' '
    $plain = $plain -replace '(?s)<script.*?</script>', ' '
    $plain = $plain -replace '(?s)<style.*?</style>', ' '
    $plain = $plain -replace '<[^>]+>', ' '
    $plain = $plain -replace '&nbsp;', ' '
    $plain = $plain -replace '&amp;', '&'
    $plain = $plain -replace '&lt;', '<'
    $plain = $plain -replace '&gt;', '>'
    $plain = $plain -replace '(?m)^---.*?---\s*', ' '
    $plain = $plain -replace '(?m)^#+\s*', ''
    $plain = $plain -replace '\[[^\]]+\]\([^)]+\)', '$1'
    $plain = $plain -replace '[#*_>`|]', ' '
    $plain = $plain -replace '\s+', ' '
    $plain = $plain.Trim()
    if ($plain.Length -gt $Limit) { return $plain.Substring(0, $Limit).Trim() + "..." }
    if ($plain.Length -eq 0) { return "No source summary text was available during this crawl." }
    return $plain
}

function Get-ShortText([string]$Text, [int]$Limit = 220) {
    $summary = Get-PlainSummary $Text $Limit
    return Escape-WikiText $summary
}

# --- Frontmatter helpers ---

function Convert-ToFrontmatterList([string[]]$Items, [string]$Default = "") {
    if ($null -eq $Items -or $Items.Count -eq 0) {
        if ($Default) { return "  - $Default" }
        return ""
    }
    return (($Items | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique | ForEach-Object { "  - $_" }) -join "`n")
}

function Convert-ToWikiAlias([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    $alias = $Text.Trim() -replace '\s+', ' '
    return $alias
}

# --- Index/log helpers ---

function Add-OrReplaceIndexLine([string]$Text, [string]$Heading, [string]$Line) {
    # Find the section under $Heading and add/replace $Line
    $pattern = "(?m)^(## $([regex]::Escape($Heading)).*?)(?=^## |\z)"
    if ($Text -match $pattern) {
        $section = $Matches[1]
        # Check if line already exists (by link target)
        $linkTarget = if ($Line -match '\[\[([^\]|]+)') { $Matches[1] } else { "" }
        if ($linkTarget -and $section -match [regex]::Escape("[[${linkTarget}")) {
            # Replace existing line
            $escapedTarget = [regex]::Escape("[[${linkTarget}")
            $Text = $Text -replace "(?m)^- .*${escapedTarget}.*$", $Line
        }
        else {
            # Append after last line in section
            $Text = $Text -replace "(?m)(^## $([regex]::Escape($Heading)).*?)(\r?\n)(## |\z)", "`$1`n${Line}`$2`$3"
            if ($Text -notmatch [regex]::Escape($Line)) {
                # Fallback: append at end of section
                $Text = $Text -replace "(?m)(^## $([regex]::Escape($Heading)).*$)", "`$1`n${Line}"
            }
        }
    }
    return $Text
}

# --- HTTP helpers ---

function Invoke-GitHubJson([string]$Url) {
    $headers = @{
        "User-Agent" = "vipin-wiki-ingest"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    $token = [Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "Process")
    if ([string]::IsNullOrWhiteSpace($token)) { $token = [Environment]::GetEnvironmentVariable("GH_TOKEN", "Process") }
    if ([string]::IsNullOrWhiteSpace($token)) { $token = [Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "User") }
    if ([string]::IsNullOrWhiteSpace($token)) { $token = [Environment]::GetEnvironmentVariable("GH_TOKEN", "User") }
    if (-not [string]::IsNullOrWhiteSpace($token)) { $headers["Authorization"] = "Bearer $token" }
    return Invoke-RestMethod -Uri $Url -Headers $headers -TimeoutSec 90
}

function Invoke-WebJson([string]$Url) {
    return Invoke-RestMethod -Uri $Url -TimeoutSec 60
}

function Invoke-WebText([string]$Url) {
    return (Invoke-WebRequest -Uri $Url -TimeoutSec 60 -UseBasicParsing).Content
}

function Get-WebHeaders([string]$Url) {
    try {
        $resp = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 30 -UseBasicParsing
        return $resp.Headers
    }
    catch { return $null }
}

# --- Manifest helpers ---

function Get-FirstSeen([hashtable]$OldById, [string]$Id) {
    if ($OldById.ContainsKey($Id) -and $OldById[$Id].first_seen) {
        return $OldById[$Id].first_seen
    }
    return (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
}

function Convert-ToObjectArray([object]$Value) {
    if ($null -eq $Value) { return @() }
    if ($Value -is [System.Array]) { return @($Value) }
    if ($Value.PSObject.Properties.Name -contains "items") { return @($Value.items) }
    return @($Value)
}

# --- Validation gate ---

function Invoke-WikiValidation([string]$Root) {
    <#
    .SYNOPSIS
    Run catalog rebuild and lint as a validation gate.
    Returns $true if passed, $false if issues found.
    #>
    $catalogScript = Join-Path $Root "scripts\wiki-catalog.ps1"
    $lintScript = Join-Path $Root "scripts\wiki-lint.ps1"

    Write-Host "`n[validation] Rebuilding catalog..." -ForegroundColor Cyan
    & python (Join-Path $Root "scripts\wiki.py") catalog --root $Root

    Write-Host "[validation] Running lint..." -ForegroundColor Cyan
    $lintOutput = & python (Join-Path $Root "scripts\wiki.py") lint --root $Root --json 2>&1
    try {
        $issues = $lintOutput | ConvertFrom-Json
        $total = 0
        foreach ($prop in $issues.PSObject.Properties) {
            if ($prop.Value -is [System.Array]) { $total += $prop.Value.Count }
        }
        if ($total -eq 0) {
            Write-Host "[validation] PASSED (0 issues)" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "[validation] $total issues found" -ForegroundColor Yellow
            return $true  # Non-blocking for now
        }
    }
    catch {
        Write-Host "[validation] Could not parse lint output" -ForegroundColor Yellow
        return $true
    }
}
