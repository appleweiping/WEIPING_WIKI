param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$wikiPath = Join-Path $rootPath "wiki"
$indexPath = Join-Path $wikiPath "index.md"
$privatePath = Join-Path $rootPath "wiki-private"

if (-not (Test-Path $wikiPath)) {
    throw "wiki directory not found: $wikiPath"
}

$pages = Get-ChildItem -LiteralPath $wikiPath -Recurse -File -Filter *.md |
    Where-Object { $_.FullName -notlike "*\_templates\*" }

$nameToPath = @{}
foreach ($page in $pages) {
    $nameToPath[[System.IO.Path]::GetFileNameWithoutExtension($page.Name)] = $page.FullName
}

$inbound = @{}
$brokenLinks = New-Object System.Collections.Generic.List[string]
$privateLeaks = New-Object System.Collections.Generic.List[string]

foreach ($page in $pages) {
    $content = Get-Content $page.FullName -Raw

    if ($content -match 'raw/private-' -or $content -match 'wiki-private/') {
        $privateLeaks.Add($page.FullName)
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
    if ($name -in @("home", "index", "log")) { continue }
    if (-not $inbound.ContainsKey($name)) {
        $page.FullName
    }
}

$indexContent = if (Test-Path $indexPath) { Get-Content $indexPath -Raw } else { "" }
$missingFromIndex = foreach ($page in $pages) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($page.Name)
    if ($name -in @("index")) { continue }
    if ($indexContent -notmatch [regex]::Escape("[[$name]]")) {
        $page.FullName
    }
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

