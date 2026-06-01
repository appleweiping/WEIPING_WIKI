param(
    [int]$StaleDays = 45,
    [int]$MaxItems = 40
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$wikiRoot = Join-Path $repoRoot "wiki"
$cutoff = (Get-Date).AddDays(-1 * $StaleDays)

function Get-FrontmatterValue($text, $key) {
    $pattern = "(?m)^$([regex]::Escape($key)):\s*(.+?)\s*$"
    $match = [regex]::Match($text, $pattern)
    if ($match.Success) {
        return $match.Groups[1].Value.Trim().Trim('"').Trim("'")
    }
    return $null
}

function New-PageInfo($file) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $relative = $file.FullName.Substring($wikiRoot.Length + 1).Replace("\", "/")
    $updatedRaw = Get-FrontmatterValue $text "updated"
    $type = Get-FrontmatterValue $text "type"
    $updated = [datetime]::MinValue
    if ($updatedRaw) {
        $parsed = [datetime]::TryParse($updatedRaw, [ref]$updated)
        if (-not $parsed) {
            $updated = $null
        }
    } else {
        $updated = $null
    }
    [pscustomobject]@{
        Path = $relative
        Type = $type
        UpdatedRaw = $updatedRaw
        Updated = $updated
        LastWriteTime = $file.LastWriteTime
        HasCounterpoints = ($text -match '(?im)^##\s+Counterpoints')
        MentionsLocalPath = ($text -match '(?i)([A-Z]:/|[A-Z]:\\)')
        MentionsAgentHub = ($text -match '(?i)Agent Hub')
    }
}

$pages = Get-ChildItem -LiteralPath $wikiRoot -Recurse -Filter "*.md" -File |
    Where-Object { $_.FullName -notmatch '\\_templates\\' } |
    ForEach-Object { New-PageInfo $_ }

$missingUpdated = $pages |
    Where-Object { -not $_.UpdatedRaw -and $_.Path -notin @("index.md", "log.md") } |
    Sort-Object Path |
    Select-Object -First $MaxItems

$stale = $pages |
    Where-Object { $_.Updated -and $_.Updated -lt $cutoff } |
    Sort-Object Updated, Path |
    Select-Object -First $MaxItems

$localPathPages = $pages |
    Where-Object { $_.MentionsLocalPath } |
    Sort-Object Path |
    Select-Object -First $MaxItems

$agentHubPages = $pages |
    Where-Object { $_.MentionsAgentHub } |
    Sort-Object Path |
    Select-Object -First $MaxItems

$missingCounterpoints = $pages |
    Where-Object { $_.Type -in @("analysis", "comparison", "concept", "entity", "query", "synthesis", "topic") -and -not $_.HasCounterpoints } |
    Sort-Object Path |
    Select-Object -First $MaxItems

Write-Output "# Wiki Maintenance Audit"
Write-Output ""
Write-Output ("Generated: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz"))
Write-Output ("Stale cutoff: pages with `updated` before {0}" -f $cutoff.ToString("yyyy-MM-dd"))
Write-Output ""
Write-Output "This report is advisory. It identifies refresh candidates; it does not edit files."
Write-Output ""
Write-Output "## Summary"
Write-Output ""
Write-Output ("- Pages scanned: {0}" -f $pages.Count)
Write-Output ("- Missing `updated`: {0}" -f ($pages | Where-Object { -not $_.UpdatedRaw -and $_.Path -notin @("index.md", "log.md") }).Count)
Write-Output ("- Stale by frontmatter date: {0}" -f ($pages | Where-Object { $_.Updated -and $_.Updated -lt $cutoff }).Count)
Write-Output ("- Pages mentioning local paths: {0}" -f ($pages | Where-Object { $_.MentionsLocalPath }).Count)
Write-Output ("- Pages mentioning Agent Hub: {0}" -f ($pages | Where-Object { $_.MentionsAgentHub }).Count)
Write-Output ("- Typed pages missing Counterpoints section: {0}" -f ($pages | Where-Object { $_.Type -in @("analysis", "comparison", "concept", "entity", "query", "synthesis", "topic") -and -not $_.HasCounterpoints }).Count)

function Write-Table($title, $items, $columns) {
    Write-Output ""
    Write-Output "## $title"
    Write-Output ""
    if (-not $items -or $items.Count -eq 0) {
        Write-Output "No candidates."
        return
    }
    Write-Output ($columns.Header -join " | ")
    Write-Output (($columns.Header | ForEach-Object { "---" }) -join " | ")
    foreach ($item in $items) {
        $row = foreach ($expr in $columns.Expr) {
            $value = & $expr $item
            if ($null -eq $value) { "" } else { ([string]$value) -replace '\|', '\|' }
        }
        Write-Output ($row -join " | ")
    }
}

Write-Table "Missing Updated Frontmatter" $missingUpdated @{
    Header = @("Path", "Type", "Last write")
    Expr = @(
        { param($x) $x.Path },
        { param($x) $x.Type },
        { param($x) $x.LastWriteTime.ToString("yyyy-MM-dd") }
    )
}

Write-Table "Stale Pages" $stale @{
    Header = @("Path", "Type", "Updated")
    Expr = @(
        { param($x) $x.Path },
        { param($x) $x.Type },
        { param($x) if ($x.Updated) { $x.Updated.ToString("yyyy-MM-dd") } else { "" } }
    )
}

Write-Table "Local Path Pages" $localPathPages @{
    Header = @("Path", "Type", "Updated")
    Expr = @(
        { param($x) $x.Path },
        { param($x) $x.Type },
        { param($x) $x.UpdatedRaw }
    )
}

Write-Table "Agent Hub Mentions" $agentHubPages @{
    Header = @("Path", "Type", "Updated")
    Expr = @(
        { param($x) $x.Path },
        { param($x) $x.Type },
        { param($x) $x.UpdatedRaw }
    )
}

Write-Table "Missing Counterpoints" $missingCounterpoints @{
    Header = @("Path", "Type", "Updated")
    Expr = @(
        { param($x) $x.Path },
        { param($x) $x.Type },
        { param($x) $x.UpdatedRaw }
    )
}
