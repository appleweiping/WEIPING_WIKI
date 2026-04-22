param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$wikiPath = Join-Path $rootPath "wiki"
$privateWikiPath = Join-Path $rootPath "wiki-private"
$rawPath = Join-Path $rootPath "raw"
$catalogPath = Join-Path $wikiPath "catalog.json"
$readerContextPath = Join-Path $rootPath "reader-context.md"
$contributionsPath = Join-Path $rootPath "CONTRIBUTIONS.md"

function Get-MarkdownCount {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return 0 }
    return (Get-ChildItem -LiteralPath $Path -Recurse -File -Filter *.md).Count
}

function Get-LatestLogHeading {
    param([string]$LogPath)
    if (-not (Test-Path $LogPath)) { return $null }
    return Get-Content $LogPath | Where-Object { $_ -match '^## ' } | Select-Object -Last 3
}

$publicMarkdown = Get-MarkdownCount -Path $wikiPath
$privateMarkdown = Get-MarkdownCount -Path $privateWikiPath
$publicSourcePages = Get-MarkdownCount -Path (Join-Path $wikiPath "sources")
$publicConceptPages = Get-MarkdownCount -Path (Join-Path $wikiPath "concepts")
$publicEntityPages = Get-MarkdownCount -Path (Join-Path $wikiPath "entities")
$publicAnalysisPages = Get-MarkdownCount -Path (Join-Path $wikiPath "analyses")
$publicTopicPages = Get-MarkdownCount -Path (Join-Path $wikiPath "topics")
$publicComparisonPages = Get-MarkdownCount -Path (Join-Path $wikiPath "comparisons")
$publicQueryPages = Get-MarkdownCount -Path (Join-Path $wikiPath "queries")
$publicSynthesisPages = Get-MarkdownCount -Path (Join-Path $wikiPath "synthesis")

$privateImageCount = if (Test-Path (Join-Path $rawPath "private-images")) {
    (Get-ChildItem -LiteralPath (Join-Path $rawPath "private-images") -File | Where-Object { $_.Name -ne "README.md" }).Count
} else { 0 }

$privateVideoCount = if (Test-Path (Join-Path $rawPath "private-videos")) {
    (Get-ChildItem -LiteralPath (Join-Path $rawPath "private-videos") -File | Where-Object { $_.Name -ne "README.md" }).Count
} else { 0 }

$catalogStatus = if (-not (Test-Path $catalogPath)) {
    "missing"
} else {
    $catalogTime = (Get-Item $catalogPath).LastWriteTimeUtc
    $latestWikiTime = (Get-ChildItem -LiteralPath $wikiPath -Recurse -File | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1).LastWriteTimeUtc
    if ($latestWikiTime -gt $catalogTime) { "stale" } else { "fresh" }
}

Write-Output "# Wiki Status"
Write-Output ""
Write-Output "- Root: $rootPath"
Write-Output "- Public markdown pages: $publicMarkdown"
Write-Output "- Private markdown pages: $privateMarkdown"
Write-Output "- Public source pages: $publicSourcePages"
Write-Output "- Public concept pages: $publicConceptPages"
Write-Output "- Public entity pages: $publicEntityPages"
Write-Output "- Public analysis pages: $publicAnalysisPages"
Write-Output "- Public topic pages: $publicTopicPages"
Write-Output "- Public comparison pages: $publicComparisonPages"
Write-Output "- Public query pages: $publicQueryPages"
Write-Output "- Public synthesis pages: $publicSynthesisPages"
Write-Output "- Private images: $privateImageCount"
Write-Output "- Private videos: $privateVideoCount"
Write-Output "- Reader context present: $(Test-Path $readerContextPath)"
Write-Output "- Contributions ledger present: $(Test-Path $contributionsPath)"
Write-Output "- Catalog status: $catalogStatus"
Write-Output ""
Write-Output "## Recent Public Log Entries"

$recentPublic = Get-LatestLogHeading -LogPath (Join-Path $wikiPath "log.md")
if ($recentPublic) {
    $recentPublic | ForEach-Object { Write-Output "- $_" }
} else {
    Write-Output "- No public log entries found."
}

Write-Output ""
Write-Output "## Recent Private Log Entries"

$recentPrivate = Get-LatestLogHeading -LogPath (Join-Path $privateWikiPath "log.md")
if ($recentPrivate) {
    $recentPrivate | ForEach-Object { Write-Output "- $_" }
} else {
    Write-Output "- No private log entries found."
}
