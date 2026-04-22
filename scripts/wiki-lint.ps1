param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$wikiPath = Join-Path $rootPath "wiki"
$indexPath = Join-Path $wikiPath "index.md"
$privatePath = Join-Path $rootPath "wiki-private"
$catalogPath = Join-Path $wikiPath "catalog.json"

if (-not (Test-Path $wikiPath)) {
    throw "wiki directory not found: $wikiPath"
}

$pages = Get-ChildItem -LiteralPath $wikiPath -Recurse -File -Filter *.md |
    Where-Object { $_.FullName -notlike "*\_templates\*" }
$lintExcludeNames = @("home", "overview", "index", "log", "queries-home", "synthesis-home", "timelines-home", "topics-home", "comparisons-home", "knowledge-graph", "README")

$nameToPath = @{}
foreach ($page in $pages) {
    $nameToPath[[System.IO.Path]::GetFileNameWithoutExtension($page.Name)] = $page.FullName
}

$inbound = @{}
$brokenLinks = New-Object System.Collections.Generic.List[string]
$privateLeaks = New-Object System.Collections.Generic.List[string]
$missingCounterpoints = New-Object System.Collections.Generic.List[string]
$missingAttribution = New-Object System.Collections.Generic.List[string]

function Get-PageType {
    param(
        [System.IO.FileInfo]$Page,
        [string]$Content
    )

    $match = [regex]::Match($Content, '(?ms)^---\s+.*?^type:\s*([A-Za-z0-9_-]+)\s*$.*?^---\s*')
    if ($match.Success) {
        return $match.Groups[1].Value.Trim().ToLowerInvariant()
    }

    switch ($Page.Directory.Name.ToLowerInvariant()) {
        "entities" { return "entity" }
        "concepts" { return "concept" }
        "topics" { return "topic" }
        "sources" { return "source" }
        "analyses" { return "analysis" }
        "comparisons" { return "comparison" }
        "queries" { return "query" }
        "synthesis" { return "synthesis" }
        "sessions" { return "synthesis" }
        "timelines" { return "timeline" }
        default { return "overview" }
    }
}

foreach ($page in $pages) {
    $content = Get-Content $page.FullName -Raw
    $pageType = Get-PageType -Page $page -Content $content
    $pageName = [System.IO.Path]::GetFileNameWithoutExtension($page.Name)

    if ($content -match 'raw/private-' -or $content -match 'wiki-private/') {
        $privateLeaks.Add($page.FullName)
    }

    if ($pageType -in @("concept", "topic", "comparison", "analysis", "synthesis") -and $pageName -notin $lintExcludeNames) {
        $hasCounterpoints = $content -match '(?im)^##\s+Counterpoints and Gaps\s*$'
        if (-not $hasCounterpoints) {
            $missingCounterpoints.Add($page.FullName)
        }
    }

    if ($pageType -in @("concept", "topic", "comparison", "analysis", "query", "synthesis") -and $pageName -notin $lintExcludeNames) {
        $hasFrontmatterSources = $content -match '(?im)^source_pages:\s*$' -or
            $content -match '(?im)^source_files:\s*$' -or
            $content -match '(?im)^source_pages:\s+\S' -or
            $content -match '(?im)^source_files:\s+\S'
        $hasSourceSection = $content -match '(?im)^##\s+Sources\s*$'
        $hasSourceLinks = $content -match '\[\[20\d{2}-\d{2}-\d{2}-'
        if (-not ($hasFrontmatterSources -or $hasSourceSection -or $hasSourceLinks)) {
            $missingAttribution.Add($page.FullName)
        }
    }

    $matches = [regex]::Matches($content, '\[\[([^\]]+)\]\]')
    foreach ($match in $matches) {
        $target = ($match.Groups[1].Value.Trim() -split '\|')[0].Trim()
        if ([string]::IsNullOrWhiteSpace($target)) { continue }

        if ($nameToPath.ContainsKey($target)) {
            if (-not $inbound.ContainsKey($target)) {
                $inbound[$target] = 0
            }
            $inbound[$target]++
        } else {
            $brokenLinks.Add("$($page.FullName) -> [[${target}]]")
        }
    }
}

$orphanPages = foreach ($page in $pages) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($page.Name)
    if ($name -in $lintExcludeNames) { continue }
    if (-not $inbound.ContainsKey($name)) {
        $page.FullName
    }
}

$indexContent = if (Test-Path $indexPath) { Get-Content $indexPath -Raw } else { "" }
$missingFromIndex = foreach ($page in $pages) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($page.Name)
    if ($name -in @("index", "knowledge-graph", "README")) { continue }
    if ($indexContent -notmatch [regex]::Escape("[[$name]]")) {
        $page.FullName
    }
}

$catalogStatus = if (-not (Test-Path $catalogPath)) {
    "Missing"
} else {
    $catalogTime = (Get-Item $catalogPath).LastWriteTimeUtc
    $latestPageTime = ($pages | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1).LastWriteTimeUtc
    if ($latestPageTime -gt $catalogTime) { "Stale" } else { "Fresh" }
}

Write-Output "# Wiki Lint"
Write-Output ""
Write-Output "## Broken Links"
if ($brokenLinks.Count -eq 0) {
    Write-Output "- None"
} else {
    $brokenLinks | Sort-Object -Unique | ForEach-Object { Write-Output "- $_" }
}

Write-Output ""
Write-Output "## Orphan Pages"
if (-not $orphanPages) {
    Write-Output "- None"
} else {
    $orphanPages | Sort-Object -Unique | ForEach-Object { Write-Output "- $_" }
}

Write-Output ""
Write-Output "## Missing From Index"
if (-not $missingFromIndex) {
    Write-Output "- None"
} else {
    $missingFromIndex | Sort-Object -Unique | ForEach-Object { Write-Output "- $_" }
}

Write-Output ""
Write-Output "## Missing Counterpoints Sections"
if ($missingCounterpoints.Count -eq 0) {
    Write-Output "- None"
} else {
    $missingCounterpoints | Sort-Object -Unique | ForEach-Object { Write-Output "- $_" }
}

Write-Output ""
Write-Output "## Missing Source Attribution"
if ($missingAttribution.Count -eq 0) {
    Write-Output "- None"
} else {
    $missingAttribution | Sort-Object -Unique | ForEach-Object { Write-Output "- $_" }
}

Write-Output ""
Write-Output "## Public / Private Boundary Leaks"
if ($privateLeaks.Count -eq 0) {
    Write-Output "- None"
} else {
    $privateLeaks | Sort-Object -Unique | ForEach-Object { Write-Output "- $_" }
}

Write-Output ""
Write-Output "## Private Wiki Presence"
if (Test-Path $privatePath) {
    Write-Output "- Private wiki directory present."
} else {
    Write-Output "- Private wiki directory missing."
}

Write-Output ""
Write-Output "## Catalog Status"
Write-Output "- $catalogStatus"
