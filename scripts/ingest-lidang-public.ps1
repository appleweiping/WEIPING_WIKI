param(
    [ValidateSet("Light", "Digest")]
    [string]$Mode = "Digest",
    [string]$Root = ".",
    [switch]$DryRun,
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"


. (Join-Path $PSScriptRoot "Ingest-Common.ps1")

$rootPath = (Resolve-Path $Root).Path
$today = (Get-Date).ToString("yyyy-MM-dd")
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm")
$runStamp = (Get-Date).ToString("o")
$calendar = [System.Globalization.CultureInfo]::InvariantCulture.Calendar
$weekNumber = $calendar.GetWeekOfYear((Get-Date), [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Monday)
$weekId = "{0}-w{1:D2}" -f (Get-Date).Year, $weekNumber
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$youtubeFeedUrl = "https://www.youtube.com/feeds/videos.xml?channel_id=UC4gzU_8MxRDiQrSFOiT79tQ"
$youtubeChannelUrl = "https://www.youtube.com/@lidangzzz"
$xCanonicalUrl = "https://x.com/lidangzzz"
$xMirrorUrls = @(
    "https://twstalker.com/lidangzzz",
    "https://rattibha.com/lidangzzz",
    "https://twicopy.com/lidangzzz/"
)

function Convert-ToRepoRelativePath([string]$Path) {
    $rootFull = [System.IO.Path]::GetFullPath($rootPath)
    if (-not $rootFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $rootFull = $rootFull + [System.IO.Path]::DirectorySeparatorChar
    }
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    $rootUri = New-Object System.Uri($rootFull)
    $pathUri = New-Object System.Uri($pathFull)
    $relative = $rootUri.MakeRelativeUri($pathUri).ToString()
    return [System.Uri]::UnescapeDataString($relative) -replace '\\', '/'
}

function Invoke-WebUtf8([string]$Url) {
    $client = New-Object System.Net.WebClient
    try {
        $client.Headers.Set("User-Agent", "Mozilla/5.0 vipin-wiki-lidang-ingest")
        $bytes = $client.DownloadData($Url)
        return [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    finally {
        $client.Dispose()
    }
}

function Get-ErrorSummary($ErrorRecord) {
    $response = $ErrorRecord.Exception.Response
    if ($null -ne $response -and $response.StatusCode) {
        return "HTTP $([int]$response.StatusCode) $($response.StatusCode)"
    }
    $message = [string]$ErrorRecord.Exception.Message
    $message = $message -replace '[^\x20-\x7E]', '?'
    $message = $message -replace '"', "'"
    $message = $message -replace '\\', '/'
    if ($message.Length -gt 180) { return $message.Substring(0, 180) }
    return $message
}

function Get-OldValue([hashtable]$OldById, [string]$Id, [string]$Name, [object]$Default) {
    if ($OldById.ContainsKey($Id) -and $null -ne $OldById[$Id].PSObject.Properties[$Name] -and $null -ne $OldById[$Id].$Name -and "$($OldById[$Id].$Name)" -ne "") {
        return $OldById[$Id].$Name
    }
    return $Default
}

function Get-OldHash([hashtable]$OldById, [string]$Id) {
    if ($OldById.ContainsKey($Id)) {
        if ($OldById[$Id].semantic_hash) { return $OldById[$Id].semantic_hash }
        if ($OldById[$Id].content_hash) { return $OldById[$Id].content_hash }
    }
    return ""
}

function Get-LastSeen([hashtable]$OldById, [string]$Id, [string]$SemanticHash) {
    $oldHash = Get-OldHash $OldById $Id
    if ($OldById.ContainsKey($Id) -and $oldHash -eq $SemanticHash) {
        return Get-OldValue $OldById $Id "last_seen" $today
    }
    return $today
}

function Get-LastChanged([hashtable]$OldById, [string]$Id, [string]$SemanticHash) {
    $oldHash = Get-OldHash $OldById $Id
    if ($OldById.ContainsKey($Id) -and $oldHash -eq $SemanticHash) {
        return Get-OldValue $OldById $Id "last_changed" $today
    }
    return $today
}

function Get-CapturedAt([hashtable]$OldById, [string]$Id, [string]$SemanticHash) {
    $oldHash = Get-OldHash $OldById $Id
    if ($OldById.ContainsKey($Id) -and $oldHash -eq $SemanticHash) {
        return Get-OldValue $OldById $Id "captured_at" $runStamp
    }
    return $runStamp
}

function Save-HtmlSnapshot([string]$Url, [string]$Content) {
    $slug = ConvertTo-Slug $Url
    $dayDir = Join-Path $script:htmlDir $today
    $absolutePath = Join-Path $dayDir "$slug.html"
    if (Test-Path -LiteralPath $absolutePath) {
        $stored = Read-TextFile $absolutePath
        $hash = Get-Sha256Text $stored
    }
    else {
        $hash = Get-Sha256Text $Content
        if (-not $DryRun) {
            Ensure-Dir $dayDir
            [System.IO.File]::WriteAllText($absolutePath, $Content, $utf8NoBom)
        }
    }
    $relative = Convert-ToRepoRelativePath $absolutePath
    return [pscustomobject]@{
        path = $relative
        hash = $hash
    }
}

function Get-StatusIdsFromHtml([string]$Content) {
    $matches = [regex]::Matches($Content, '(?:https?://(?:x|twitter)\.com)?/lidangzzz/status/(\d+)')
    return @($matches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
}

function Invoke-WebProbe([string]$Url) {
    try {
        $content = Invoke-WebUtf8 $Url
        $title = [regex]::Match($content, "<title>(.*?)</title>", [System.Text.RegularExpressions.RegexOptions]::Singleline).Groups[1].Value
        $statusIds = Get-StatusIdsFromHtml $content
        $snapshot = Save-HtmlSnapshot $Url $content
        $semanticPayload = [pscustomobject]@{
            url = $Url
            ok = $true
            status = 200
            title = $title
            status_ids = $statusIds
        } | ConvertTo-Json -Depth 8 -Compress
        return [pscustomobject]@{
            url = $Url
            ok = $true
            status = 200
            length = $content.Length
            title = $title
            status_ids = @($statusIds)
            status_links = @($statusIds | ForEach-Object { "https://x.com/lidangzzz/status/$_" })
            raw_html_path = $snapshot.path
            raw_html_hash = $snapshot.hash
            semantic_hash = Get-Sha256Text $semanticPayload
            error = ""
            crawl_status = if ($statusIds.Count -gt 0) { "ok-status-links-found" } else { "ok-no-status-links-found" }
            backfill_status = if ($statusIds.Count -gt 0) { "status-links-seen" } else { "no-status-links-found" }
        }
    }
    catch {
        return [pscustomobject]@{
            url = $Url
            ok = $false
            status = "ERR"
            length = 0
            title = ""
            status_ids = @()
            status_links = @()
            raw_html_path = ""
            raw_html_hash = ""
            semantic_hash = Get-Sha256Text ("error`n" + $Url)
            error = Get-ErrorSummary $_
            crawl_status = "error"
            backfill_status = "unreachable-or-blocked"
        }
    }
}

function Get-CategoryInfo([string]$Text) {
    $p = $Text.ToLowerInvariant()
    if ($p -match 'ai|agent|coding|codex|manus|spec|llm') { return @{ Category = "AI coding / agent workflows"; Tags = @("lidang", "ai-coding", "agents") } }
    if ($p -match 'cs|georgia tech|omscs|master|career|job|doctor|math|phd') { return @{ Category = "Career / CS learning path"; Tags = @("lidang", "career", "cs-learning") } }
    if ($p -match 'visa|immigration|identity|abroad|doctor|canada|america|us ') { return @{ Category = "Immigration / identity / institutional entry"; Tags = @("lidang", "immigration", "identity") } }
    if ($p -match 'startup|delaware|stripe|company|corp|fundraising|legal') { return @{ Category = "Startup / Delaware / company tooling"; Tags = @("lidang", "startup", "delaware") } }
    if ($p -match 'github|open source|compiler|interpreter|lean|repo|tool') { return @{ Category = "Open-source engineering / toolchains"; Tags = @("lidang", "open-source", "tooling") } }
    if ($p -match 'university|education|school|course|math|phd|degree|master') { return @{ Category = "Education / discipline choice / CS learning"; Tags = @("lidang", "education", "cs-learning") } }
    if ($p -match 'house|real estate|economy|market|price|society|luxury') { return @{ Category = "Economy / real estate / social observation"; Tags = @("lidang", "economy", "social-observation") } }
    if ($p -match 'institution|governance|rule|law|policy|collapse') { return @{ Category = "Rules / governance / rule-as-script"; Tags = @("lidang", "rules", "governance") } }
    if ($p -match 'dead end|controvers|rant|scold') { return @{ Category = "Controversial / review-needed views"; Tags = @("lidang", "controversial", "review-needed") } }
    return @{ Category = "Everyday heuristics / judgment frames"; Tags = @("lidang", "heuristics") }
}

function Get-ImportanceScore([string]$SourceKind, [string]$Title, [string]$Category) {
    $score = 1
    if ($SourceKind -eq "youtube-video") { $score += 2 }
    if ($Title -match 'AI|agent|coding|manus|Georgia Tech|CS|master|doctor|math|university') { $score += 2 }
    if ($Category -match 'AI coding|Immigration|Career|governance|Controversial') { $score += 1 }
    return $score
}

function Get-YtDlpCommand {
    $cmd = Get-Command "yt-dlp" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $localCandidates = @(
        (Join-Path $rootPath ".wiki-tmp\yt-dlp.exe"),
        (Join-Path $rootPath ".wiki-tmp\yt-dlp")
    )
    foreach ($candidate in $localCandidates) {
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return ""
}

function Get-YoutubeBackfill([hashtable]$OldById) {
    $tool = Get-YtDlpCommand
    if ([string]::IsNullOrWhiteSpace($tool)) {
        return [pscustomobject]@{
            status = "tool-unavailable"
            tool = ""
            items = @()
            error = ""
        }
    }
    try {
        $jsonLines = & $tool --flat-playlist --dump-json $youtubeChannelUrl 2>$null
        $items = @()
        foreach ($line in @($jsonLines)) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try {
                $raw = $line | ConvertFrom-Json
                if ($raw.id) {
                    $id = "youtube:$($raw.id)"
                    if (-not $OldById.ContainsKey($id)) {
                        $items += [pscustomobject]@{
                            video_id = [string]$raw.id
                            title = [string]$raw.title
                            url = "https://www.youtube.com/watch?v=$($raw.id)"
                        }
                    }
                }
            }
            catch {
                continue
            }
        }
        return [pscustomobject]@{
            status = "complete"
            tool = $tool
            items = @($items)
            error = ""
        }
    }
    catch {
        return [pscustomobject]@{
            status = "error"
            tool = $tool
            items = @()
            error = Get-ErrorSummary $_
        }
    }
}

function New-BaseEntry([string]$Id, [string]$SemanticHash, [hashtable]$OldById) {
    return @{
        semantic_hash = $SemanticHash
        content_hash = $SemanticHash
        first_seen = Get-FirstSeen $OldById $Id
        last_seen = Get-LastSeen $OldById $Id $SemanticHash
        last_changed = Get-LastChanged $OldById $Id $SemanticHash
        captured_at = Get-CapturedAt $OldById $Id $SemanticHash
    }
}

function New-VideoEntry([object]$Entry, [hashtable]$OldById) {
    $title = [string]$Entry.title
    $link = [string]$Entry.link.href
    $videoId = ($link -replace "^.*[?&]v=", "") -replace "&.*$", ""
    $cat = Get-CategoryInfo $title
    $semanticHash = Get-Sha256Text ($title + "`n" + $link + "`n" + [string]$Entry.published + "`n" + [string]$Entry.updated)
    $id = "youtube:$videoId"
    $base = New-BaseEntry $id $semanticHash $OldById
    $importance = Get-ImportanceScore "youtube-video" $title $cat.Category
    $slug = ConvertTo-Slug ("video-" + $videoId)
    return [pscustomobject]@{
        id = $id
        source_kind = "youtube-video"
        canonical_url = $link
        mirror_urls = @()
        title = $title
        published_at = [string]$Entry.published
        captured_at = $base.captured_at
        content_hash = $base.content_hash
        semantic_hash = $base.semantic_hash
        raw_html_path = ""
        raw_html_hash = ""
        source_confidence = "official-rss"
        category = $cat.Category
        tags = $cat.Tags + @("youtube", "video")
        engagement = [pscustomobject]@{}
        importance_score = $importance
        dedupe_key = $id
        wiki_page = if ($importance -ge 4) { "wiki/sources/lidang-public/$slug.md" } else { "" }
        public_handling = "public-metadata-summary-only"
        summary = "YouTube video from the official Lidang RSS feed: $title."
        first_seen = $base.first_seen
        last_seen = $base.last_seen
        last_changed = $base.last_changed
        crawl_status = "seen-in-youtube-rss"
        backfill_status = "rss-current-window"
    }
}

function New-BackfillVideoEntry([object]$Item, [hashtable]$OldById) {
    $videoId = [string]$Item.video_id
    $title = if ($Item.title) { [string]$Item.title } else { "YouTube video $videoId" }
    $link = if ($Item.url) { [string]$Item.url } else { "https://www.youtube.com/watch?v=$videoId" }
    $cat = Get-CategoryInfo $title
    $semanticHash = Get-Sha256Text ($title + "`n" + $link + "`nbackfill")
    $id = "youtube:$videoId"
    $base = New-BaseEntry $id $semanticHash $OldById
    $importance = Get-ImportanceScore "youtube-video" $title $cat.Category
    $slug = ConvertTo-Slug ("video-" + $videoId)
    return [pscustomobject]@{
        id = $id
        source_kind = "youtube-video"
        canonical_url = $link
        mirror_urls = @()
        title = $title
        published_at = ""
        captured_at = $base.captured_at
        content_hash = $base.content_hash
        semantic_hash = $base.semantic_hash
        raw_html_path = ""
        raw_html_hash = ""
        source_confidence = "youtube-backfill-tool"
        category = $cat.Category
        tags = $cat.Tags + @("youtube", "video", "backfill")
        engagement = [pscustomobject]@{}
        importance_score = $importance
        dedupe_key = $id
        wiki_page = if ($importance -ge 4) { "wiki/sources/lidang-public/$slug.md" } else { "" }
        public_handling = "public-metadata-summary-only"
        summary = "YouTube video discovered through optional historical metadata backfill: $title."
        first_seen = $base.first_seen
        last_seen = $base.last_seen
        last_changed = $base.last_changed
        crawl_status = "seen-in-youtube-backfill"
        backfill_status = "historical-video-seen"
    }
}

function New-XProfileEntry([object[]]$Probes, [hashtable]$OldById) {
    $okProbes = @($Probes | Where-Object { $_.ok })
    $statusIds = @($Probes | ForEach-Object { $_.status_ids } | Sort-Object -Unique)
    $semanticPayload = [pscustomobject]@{
        canonical = $xCanonicalUrl
        ok_urls = @($okProbes | ForEach-Object { $_.url } | Sort-Object)
        status_ids = $statusIds
        crawl_statuses = @($Probes | ForEach-Object { "$($_.url)=$($_.crawl_status)" } | Sort-Object)
    } | ConvertTo-Json -Depth 10 -Compress
    $semanticHash = Get-Sha256Text $semanticPayload
    $id = "x-profile:lidangzzz"
    $base = New-BaseEntry $id $semanticHash $OldById
    return [pscustomobject]@{
        id = $id
        source_kind = "x-profile-probe"
        canonical_url = $xCanonicalUrl
        mirror_urls = $xMirrorUrls
        title = "X profile probe for lidangzzz"
        published_at = ""
        captured_at = $base.captured_at
        content_hash = $base.content_hash
        semantic_hash = $base.semantic_hash
        raw_html_path = (($okProbes | Select-Object -First 1).raw_html_path)
        raw_html_hash = (($okProbes | Select-Object -First 1).raw_html_hash)
        source_confidence = "canonical-profile-plus-nonauthoritative-mirror-probes"
        category = "Everyday heuristics / judgment frames"
        tags = @("lidang", "x", "html-snapshot", "mirror-probe")
        engagement = [pscustomobject]@{}
        importance_score = 1
        dedupe_key = "x-profile:lidangzzz"
        wiki_page = ""
        public_handling = "public-link-probe-metadata-only"
        summary = "Canonical X profile and auxiliary mirrors were probed. Reachable HTML snapshots are cached under raw/lidang-public/html; public wiki pages keep metadata and summaries only."
        first_seen = $base.first_seen
        last_seen = $base.last_seen
        last_changed = $base.last_changed
        crawl_status = if ($okProbes.Count -gt 0) { "profile-html-snapshotted" } else { "profile-unreachable" }
        backfill_status = if ($statusIds.Count -gt 0) { "status-links-seen" } else { "no-status-links-found" }
        probes = $Probes
    }
}

function New-StatusLinkEntry([string]$StatusId, [string]$SourceUrl, [hashtable]$OldById) {
    if ([string]::IsNullOrWhiteSpace($StatusId)) { return $null }
    $canonical = "https://x.com/lidangzzz/status/$StatusId"
    $semanticHash = Get-Sha256Text ($canonical + "`nstatus-link")
    $id = "x-status:$StatusId"
    $base = New-BaseEntry $id $semanticHash $OldById
    return [pscustomobject]@{
        id = $id
        source_kind = "x-status-link"
        canonical_url = $canonical
        mirror_urls = @($SourceUrl)
        title = "X status $StatusId"
        published_at = ""
        captured_at = $base.captured_at
        content_hash = $base.content_hash
        semantic_hash = $base.semantic_hash
        raw_html_path = ""
        raw_html_hash = ""
        source_confidence = "html-discovered-link"
        category = "Everyday heuristics / judgment frames"
        tags = @("lidang", "x", "status-link")
        engagement = [pscustomobject]@{}
        importance_score = 1
        dedupe_key = $id
        wiki_page = ""
        public_handling = "public-link-metadata-only"
        summary = "A status link discovered from reachable HTML. The public wiki records link metadata only."
        first_seen = $base.first_seen
        last_seen = $base.last_seen
        last_changed = $base.last_changed
        crawl_status = "status-link-seen"
        backfill_status = "status-link-seen"
    }
}

function New-ItemPage([object]$Entry) {
    $tagLines = Convert-ToFrontmatterList $Entry.tags
    $sourceLines = (@($Entry.canonical_url) + @($Entry.mirror_urls) | Where-Object { $_ } | Sort-Object -Unique | ForEach-Object { "  - $_" }) -join "`n"
    $title = Escape-Yaml $Entry.title
    return @"
---
title: "$title"
type: source
status: active
created: $($Entry.first_seen)
updated: $($Entry.last_changed)
tags:
$tagLines
source_pages:
$sourceLines
---

# $($Entry.title)

## Source

- Source kind: ``$($Entry.source_kind)``
- Canonical URL: $($Entry.canonical_url)
- Source confidence: ``$($Entry.source_confidence)``
- Public handling: ``$($Entry.public_handling)``
- Semantic hash: ``$($Entry.semantic_hash)``
- Raw HTML path: ``$($Entry.raw_html_path)``
- Published: $($Entry.published_at)
- First seen: $($Entry.first_seen)
- Last changed: $($Entry.last_changed)

## Classification

- Primary category: $($Entry.category)
- Importance score: $($Entry.importance_score)
- Corpus source note: [[2026-05-16-lidang-public-corpus]]
- Topic hub: [[lidang-public-ideas]]
- Taxonomy: [[lidang-idea-taxonomy]]
- Weekly digests: [[lidang-weekly-digests]]

## Summary

$($Entry.summary)

## Public Handling Notes

- EXTRACTED: This page records public metadata from an accessible source.
- INFERRED: Full X text and third-party mirror text should remain local/cache-only unless redistribution is clearly allowed.
- Do not treat mirror discovery as proof that the mirror is complete or authoritative.
"@
}

$rawDir = Join-Path $rootPath "raw\lidang-public"
$inboxDir = Join-Path $rawDir "inbox"
$script:htmlDir = Join-Path $rawDir "html"
$itemDir = Join-Path $rootPath "wiki\sources\lidang-public"
Ensure-Dir $rawDir
Ensure-Dir $inboxDir
Ensure-Dir $script:htmlDir
Ensure-Dir $itemDir

$manifestPath = Join-Path $rawDir "manifest.json"
$oldById = @{}
$oldManifest = $null
if (Test-Path -LiteralPath $manifestPath) {
    try {
        $oldManifest = Read-TextFile $manifestPath | ConvertFrom-Json
        foreach ($entry in @($oldManifest.entries)) { $oldById[$entry.id] = $entry }
    }
    catch {
        $oldManifest = $null
    }
}

$errors = New-Object System.Collections.Generic.List[string]
$entries = New-Object System.Collections.Generic.List[object]
$youtubeTitle = ""
$youtubeCount = 0
$backfill = [pscustomobject]@{ status = "not-run"; tool = ""; items = @(); error = "" }

try {
    [xml]$youtubeXml = Invoke-WebUtf8 $youtubeFeedUrl
    $youtubeTitle = [string]$youtubeXml.feed.title
    $youtubeCount = @($youtubeXml.feed.entry).Count
    foreach ($video in @($youtubeXml.feed.entry)) {
        $entries.Add((New-VideoEntry $video $oldById))
    }
}
catch {
    $errors.Add("YouTube RSS crawl failed: $(Get-ErrorSummary $_)")
}

if ($Mode -eq "Digest") {
    $backfill = Get-YoutubeBackfill $oldById
    if ($backfill.status -eq "error") { $errors.Add("YouTube historical backfill failed: $($backfill.error)") }
    foreach ($item in @($backfill.items)) {
        $candidate = New-BackfillVideoEntry $item $oldById
        if (-not ($entries | Where-Object { $_.id -eq $candidate.id })) {
            $entries.Add($candidate)
        }
    }
}

$xProbes = @()
$xProbes += Invoke-WebProbe $xCanonicalUrl
foreach ($mirror in $xMirrorUrls) { $xProbes += Invoke-WebProbe $mirror }
$entries.Add((New-XProfileEntry $xProbes $oldById))

foreach ($probe in $xProbes) {
    foreach ($statusId in @($probe.status_ids)) {
        $entry = New-StatusLinkEntry $statusId $probe.url $oldById
        if ($null -ne $entry -and -not ($entries | Where-Object { $_.id -eq $entry.id })) { $entries.Add($entry) }
    }
    if (-not $probe.ok) { $errors.Add("Probe failed for $($probe.url): $($probe.error)") }
}

$currentById = @{}
$dedupeSeen = @{}
$uniqueEntries = New-Object System.Collections.Generic.List[object]
foreach ($entry in @($entries | Sort-Object id)) {
    if (-not $currentById.ContainsKey($entry.id)) {
        $currentById[$entry.id] = $entry
        $uniqueEntries.Add($entry)
    }
}
$entries = $uniqueEntries

$removedEntries = @()
foreach ($oldId in $oldById.Keys) {
    if (-not $currentById.ContainsKey($oldId)) { $removedEntries += $oldById[$oldId] }
}
$newEntries = @($entries | Where-Object { -not $oldById.ContainsKey($_.id) })
$updatedEntries = @($entries | Where-Object { $oldById.ContainsKey($_.id) -and (Get-OldHash $oldById $_.id) -ne $_.semantic_hash })
$hasCorpusChanges = ($newEntries.Count -gt 0 -or $updatedEntries.Count -gt 0 -or $removedEntries.Count -gt 0 -or -not (Test-Path -LiteralPath $manifestPath))

$capturePath = Join-Path $inboxDir "$today-$($Mode.ToLowerInvariant()).json"
$captureGeneratedAt = if ((Test-Path -LiteralPath $capturePath) -and -not $hasCorpusChanges) {
    try {
        $oldCapture = Read-TextFile $capturePath | ConvertFrom-Json
        if ($oldCapture.captured_at) { $oldCapture.captured_at } else { $runStamp }
    }
    catch { $runStamp }
}
else { $runStamp }

$capture = [pscustomobject]@{
    schema = "lidang-public-capture-v2"
    captured_at = $captureGeneratedAt
    mode = $Mode
    sources = [pscustomobject]@{
        youtube_feed = $youtubeFeedUrl
        youtube_channel = $youtubeChannelUrl
        x_canonical = $xCanonicalUrl
        x_mirrors = $xMirrorUrls
    }
    backfill = $backfill
    errors = @($errors)
    entries = @($entries | Sort-Object source_kind, published_at, title)
}
Write-TextIfChanged $capturePath ($capture | ConvertTo-Json -Depth 30) | Out-Null

$manifestGeneratedAt = if ($hasCorpusChanges -or -not $oldManifest) { $runStamp } elseif ($oldManifest.generated_at) { $oldManifest.generated_at } else { $runStamp }
$manifestMode = if ($hasCorpusChanges -or -not $oldManifest -or -not $oldManifest.mode) { $Mode } else { $oldManifest.mode }
$manifestBackfill = if ($Mode -eq "Digest" -or $hasCorpusChanges -or -not $oldManifest -or -not $oldManifest.backfill) { $backfill } else { $oldManifest.backfill }
$manifest = [pscustomobject]@{
    schema = "lidang-public-corpus-v2"
    generated_at = $manifestGeneratedAt
    sources = $capture.sources
    public_handling = "Public wiki pages contain official URLs, source metadata, summaries, semantic hashes, confidence labels, mirror availability, and raw HTML provenance. Reachable X/profile HTML snapshots are cached under raw/lidang-public/html, while public wiki pages remain curated Markdown summaries."
    mode = $manifestMode
    entry_count = $entries.Count
    new_entries_this_run = $newEntries.Count
    changed_entries_this_run = $updatedEntries.Count
    removed_entries_this_run = $removedEntries.Count
    backfill = $manifestBackfill
    errors = @($errors)
    entries = @($entries | Sort-Object source_kind, published_at, title)
}
Write-TextIfChanged $manifestPath ($manifest | ConvertTo-Json -Depth 35) | Out-Null

if ($Mode -eq "Digest") {
    $highSignal = @($entries | Where-Object { $_.wiki_page -and $_.importance_score -ge 4 })
    foreach ($entry in $highSignal) {
        $absPage = Join-Path $rootPath $entry.wiki_page
        Write-TextIfChanged $absPage (New-ItemPage $entry) | Out-Null
    }

    $grouped = $entries | Group-Object category | Sort-Object Name
    $sourceKindLines = (($entries | Group-Object source_kind | Sort-Object Name) | ForEach-Object { "- ``$($_.Name)``: $($_.Count)" }) -join "`n"
    $categoryLines = ($grouped | ForEach-Object { "- $($_.Name): $($_.Count)" }) -join "`n"
    $probeLines = ($xProbes | ForEach-Object {
        "- $($_.url): status ``$($_.status)``, ok ``$($_.ok)``, status links $($_.status_ids.Count), raw HTML ``$($_.raw_html_path)``, crawl ``$($_.crawl_status)``, backfill ``$($_.backfill_status)``, note ``$($_.error)``"
    }) -join "`n"
    $highSignalLines = if ($highSignal.Count -gt 0) {
        ($highSignal | Sort-Object published_at -Descending | ForEach-Object {
            $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
            "- [[$wikiId|$(Convert-ToWikiAlias $_.title)]] - $($_.category), score $($_.importance_score)"
        }) -join "`n"
    } else { "- No high-signal single-item pages were generated in this run." }
    $indexLidangLines = @("- Weekly digests", "  - [[sources/lidang-public/$weekId-digest|$weekId digest]]")
    if ($highSignal.Count -gt 0) {
        $indexLidangLines += "- High-signal single items"
        $indexLidangLines += @($highSignal | Sort-Object published_at -Descending | ForEach-Object {
            $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
            "  - [[$wikiId|$(Convert-ToWikiAlias $_.title)]]"
        })
    }
    $weekLines = (($entries | Sort-Object published_at -Descending) | ForEach-Object {
        $url = if ($_.canonical_url) { $_.canonical_url } else { "no-url" }
        "- $($_.published_at) | $($_.source_kind) | $($_.category) | [$($_.title)]($url) | score $($_.importance_score) | semantic ``$($_.semantic_hash)`` | crawl ``$($_.crawl_status)`` | backfill ``$($_.backfill_status)``"
    }) -join "`n"

    $batchPagePath = "wiki/sources/lidang-public/$weekId-digest.md"
    $batchContent = @"
---
title: Lidang Public Ideas Digest $weekId
type: source
status: active
created: $today
updated: $today
tags:
  - lidang
  - public-ideas
  - weekly-digest
source_pages:
  - $youtubeFeedUrl
  - $xCanonicalUrl
---

# Lidang Public Ideas Digest $weekId

## Source

- Batch mode: ``Digest``
- Manifest: ``raw/lidang-public/manifest.json``
- Capture batch: ``raw/lidang-public/inbox/$today-digest.json``
- Public handling: metadata, links, summaries, semantic hashes, raw HTML provenance, and confidence labels only.
- Dedup rule: stable item IDs are the only ingest identity; repeated RSS/profile observations must not create duplicate weekly items.

## Items

$weekLines

## Related

- [[lidang]]
- [[lidang-public-ideas]]
- [[2026-05-16-lidang-public-corpus]]
- [[lidang-idea-taxonomy]]
- [[lidang-weekly-digests]]

## Counterpoints And Gaps

- This digest is based on reachable public feeds/probes, not a complete X archive.
- YouTube RSS exposes recent videos only; optional historical backfill runs only when a project-local or PATH ``yt-dlp`` tool is available.
- Mirror availability can change and should not be treated as authoritative.
"@
    Write-TextIfChanged (Join-Path $rootPath $batchPagePath) $batchContent | Out-Null

    $sourceContent = @"
---
title: 2026-05-16 Lidang Public Corpus
type: source
status: active
created: 2026-05-16
updated: $today
tags:
  - lidang
  - public-corpus
  - ideas
source_pages:
  - $youtubeFeedUrl
  - $youtubeChannelUrl
  - $xCanonicalUrl
---

# 2026-05-16 Lidang Public Corpus

## Provenance

- YouTube RSS: $youtubeFeedUrl
- YouTube channel: $youtubeChannelUrl
- X canonical profile: $xCanonicalUrl
- Auxiliary non-authoritative mirror probes:
$(($xMirrorUrls | ForEach-Object { "  - $_" }) -join "`n")
- Manifest: ``raw/lidang-public/manifest.json``
- Daily captures: ``raw/lidang-public/inbox/``
- Raw HTML snapshots: ``raw/lidang-public/html/YYYY-MM-DD/``

## Crawl Snapshot

- Mode: ``$Mode``
- YouTube RSS title: ``$youtubeTitle``
- YouTube RSS exposed entries: $youtubeCount
- Manifest entries: $($entries.Count)
- New entries this run: $($newEntries.Count)
- Changed semantic entries this run: $($updatedEntries.Count)
- Removed entries this run: $($removedEntries.Count)
- Crawl errors recorded: $($errors.Count)
- Historical YouTube backfill status: ``$($backfill.status)``

## Source Kinds

$sourceKindLines

## X / Mirror Probe Results

$probeLines

## Dedup And Backfill Rules

- EXTRACTED: Stable IDs are mandatory: ``youtube:<video_id>``, ``x-status:<status_id>``, and ``x-profile:lidangzzz``.
- INFERRED: ``semantic_hash`` drives change detection; volatile full HTML changes are raw evidence, not wiki-update triggers by themselves.
- EXTRACTED: ``dedupe_key`` must be stable and must not use a run-specific timestamp or full HTML hash.
- INFERRED: Repeated Light or Digest runs should not duplicate items, refresh ``last_seen`` noisily, or append new log entries unless a new stable ID or semantic change appears.
- INFERRED: Backfill should continue until reachable older YouTube/X items are marked ``seen``, ``unreachable``, ``blocked``, ``tool-unavailable``, or ``no-status-links-found``.

## Public Handling Policy

- EXTRACTED: YouTube RSS is an official feed and can be used for public metadata.
- EXTRACTED: X canonical profile is the preferred public identity URL.
- EXTRACTED: Reachable X/profile HTML is cached as raw evidence because HTML preserves links and extraction opportunities better than lossy Markdown.
- AMBIGUOUS: Third-party mirrors may be incomplete, blocked, stale, or non-authoritative.
- INFERRED: Full X text from mirrors should not be mirrored publicly unless a reliable licensed source is added.
- INFERRED: This corpus should emphasize weekly clustering and high-signal pages because the source stream is frequent and uneven in density.

## Related

- [[lidang]]
- [[lidang-public-ideas]]
- [[lidang-idea-taxonomy]]
- [[lidang-weekly-digests]]
"@

    $entityContent = @"
---
title: Lidang
type: entity
status: active
created: 2026-05-16
updated: $today
tags:
  - lidang
  - public-figure
  - ai-coding
  - career
source_pages:
  - $xCanonicalUrl
  - $youtubeChannelUrl
---

# Lidang

## Corpus Role

Lidang / ``lidangzzz`` is tracked here as a high-frequency public source of path-engineering, AI coding, career, immigration, startup, education, and social-observation heuristics.

## Current Public Surfaces

- EXTRACTED: YouTube RSS title at crawl: ``$youtubeTitle``.
- EXTRACTED: YouTube RSS currently exposed $youtubeCount recent videos.
- EXTRACTED: Canonical X profile URL used by this corpus: $xCanonicalUrl.
- EXTRACTED: Reachable profile or mirror HTML snapshots are stored under ``raw/lidang-public/html/`` for future extraction.
- AMBIGUOUS: Stable public access to full X history was not available through the probed sources during this crawl.

## Use In The Wiki

- Use [[lidang-public-ideas]] before answering questions that ask for a Lidang-style path, AI coding, career, immigration, or startup framing.
- Treat the existing local ``lidang-perspective`` skill as a distilled lens, not as a substitute for current public source checks.
- Re-crawl before making claims about recent posts, video titles, or source availability.

## Related

- [[lidang-public-ideas]]
- [[2026-05-16-lidang-public-corpus]]
- [[lidang-idea-taxonomy]]
- [[lidang-weekly-digests]]
"@

    $topicContent = @"
---
title: Lidang Public Ideas
type: topic
status: active
created: 2026-05-16
updated: $today
tags:
  - lidang
  - public-ideas
  - heuristics
source_pages:
  - $youtubeFeedUrl
  - $xCanonicalUrl
---

# Lidang Public Ideas

This hub tracks Lidang's public idea stream as a high-frequency corpus. The system favors batch summaries, confidence labels, and topic clustering over one page per short post.

## Current Corpus Shape

$sourceKindLines

## Core Use

- Use [[lidang-idea-taxonomy]] to navigate topics.
- Use [[lidang-weekly-digests]] for chronological batches.
- Use high-signal single-item pages only when an item is substantial enough to justify durable retrieval.
- Use source confidence labels before citing any X-derived item.

## Maintenance Rules For Future Agents

- Treat HTML as a first-class raw source format for X/profile probes; store reachable snapshots under ``raw/lidang-public/html/``.
- Use ``semantic_hash`` rather than raw full HTML hash for wiki churn decisions.
- Never create a second item for a stable ID that already exists in ``raw/lidang-public/manifest.json``.
- Continue backfill attempts for older reachable YouTube/X items, but add them only when their stable IDs are absent.
- Do not flood ``wiki/index.md`` with every short post.
- Keep X mirror text out of public pages unless a license-safe source exists.
- Record failed mirror probes because failures are operationally useful.
- Prefer weekly synthesis over raw accumulation.

## Related

- [[lidang]]
- [[2026-05-16-lidang-public-corpus]]
- [[lidang-idea-taxonomy]]
- [[lidang-weekly-digests]]

## Counterpoints And Gaps

- The current corpus is not a complete X archive.
- YouTube RSS only exposes recent videos, so historical video backfill remains dependent on optional tooling or future source access.
- Short-form public statements can be context-dependent and should not be over-interpreted without source review.
"@

    $taxonomySections = foreach ($group in $grouped) {
        $lines = $group.Group | Sort-Object -Property @{ Expression = "importance_score"; Descending = $true }, @{ Expression = "title"; Ascending = $true } | ForEach-Object {
            $url = if ($_.wiki_page) {
                $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
                "[[$wikiId|$(Convert-ToWikiAlias $_.title)]]"
            } else {
                "[$($_.title)]($($_.canonical_url))"
            }
            "- $url - $($_.source_kind), confidence ``$($_.source_confidence)``, score $($_.importance_score), semantic ``$($_.semantic_hash)``"
        }
        "## $($group.Name)`n`n" + ($lines -join "`n")
    }

    $taxonomyContent = @"
---
title: Lidang Idea Taxonomy
type: analysis
status: active
created: 2026-05-16
updated: $today
tags:
  - lidang
  - taxonomy
  - public-ideas
source_pages:
  - $youtubeFeedUrl
  - $xCanonicalUrl
---

# Lidang Idea Taxonomy

This page groups the current Lidang public corpus by idea domain. It is designed for high-frequency, uneven-density sources.

## Snapshot

- Crawl date: $today
- Total manifest entries: $($entries.Count)
- High-signal single pages: $($highSignal.Count)

$($taxonomySections -join "`n`n")

## Related

- [[lidang-public-ideas]]
- [[lidang-weekly-digests]]
- [[2026-05-16-lidang-public-corpus]]

## Counterpoints And Gaps

- Categories are heuristic and should be revised when more X history or transcripts become available.
- Low-density short posts are intentionally aggregated instead of promoted to standalone wiki pages.
- Some titles are provocative; the wiki should preserve source metadata without laundering claims into verified facts.
"@

    $weeklyContent = @"
---
title: Lidang Weekly Digests
type: analysis
status: active
created: 2026-05-16
updated: $today
tags:
  - lidang
  - weekly-digest
  - public-ideas
source_pages:
  - $youtubeFeedUrl
  - $xCanonicalUrl
---

# Lidang Weekly Digests

This page indexes weekly digest batches for the Lidang public ideas corpus.

## Digest Rule

Weekly digests aggregate only new stable IDs, changed semantic items, and newly promoted high-signal items. Raw HTML snapshot changes alone should not create duplicate weekly entries or churn public summaries.

## Current Digests

- [[sources/lidang-public/$weekId-digest|$weekId digest]] - $($entries.Count) captured entries, $($highSignal.Count) high-signal single pages.

## High-Signal Single Pages

$highSignalLines

## Related

- [[lidang]]
- [[lidang-public-ideas]]
- [[lidang-idea-taxonomy]]
- [[2026-05-16-lidang-public-corpus]]

## Counterpoints And Gaps

- Weekly digests are not a full transcript archive.
- Daily light captures may contain candidate metadata that has not yet been synthesized.
- If a better X source is added later, older weekly summaries may need backfill.
"@

    Write-TextIfChanged (Join-Path $rootPath "wiki\sources\2026-05-16-lidang-public-corpus.md") $sourceContent | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki\entities\lidang.md") $entityContent | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki\topics\lidang-public-ideas.md") $topicContent | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\lidang-idea-taxonomy.md") $taxonomyContent | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\lidang-weekly-digests.md") $weeklyContent | Out-Null

    $indexPath = Join-Path $rootPath "wiki\index.md"
    $indexText = Read-TextFile $indexPath
    $indexText = Add-OrReplaceIndexLine $indexText "## Entities" "- [[lidang]] - Public idea-stream corpus for Lidang / lidangzzz, focused on YouTube, X, path engineering, AI coding, and practical heuristics."
    $indexText = Add-OrReplaceIndexLine $indexText "## Topics" "- [[lidang-public-ideas]] - Hub for high-frequency Lidang public ideas with weekly digests, taxonomy, and source-confidence boundaries."
    $indexText = Add-OrReplaceIndexLine $indexText "## Sources" "- [[2026-05-16-lidang-public-corpus]] - Batch ingest of Lidang YouTube RSS, canonical X profile, auxiliary mirror probes, HTML snapshots, and dedupe/backfill rules."
    $indexText = Add-OrReplaceIndexLine $indexText "## Analyses" "- [[lidang-idea-taxonomy]] - Category map for Lidang public ideas across AI coding, career, immigration, startup, education, governance, and heuristics."
    $indexText = Add-OrReplaceIndexLine $indexText "## Analyses" "- [[lidang-weekly-digests]] - Index of weekly digest batches and high-signal Lidang public idea pages."
    $lidangIndexBlock = @"

### Lidang Public Ideas Corpus

$($indexLidangLines -join "`n")

"@
    if ($indexText -notmatch '### Lidang Public Ideas Corpus') {
        $indexText = $indexText -replace '(### Karpathy Public Corpus)', ($lidangIndexBlock + "`$1")
    }
    else {
        $indexText = [regex]::Replace(
            $indexText,
            '(?s)### Lidang Public Ideas Corpus\s+.*?(?=### Karpathy Public Corpus)',
            $lidangIndexBlock
        )
    }
    $indexText = $indexText -replace 'updated: \d{4}-\d{2}-\d{2}', "updated: $today"
    Write-TextIfChanged $indexPath $indexText | Out-Null

    $logPath = Join-Path $rootPath "wiki\log.md"
    $logText = Read-TextFile $logPath
    $logEntry = @"

## [$now] ingest | lidang html snapshots and dedupe rules

- Pages created or updated:
  - [[lidang]]
  - [[lidang-public-ideas]]
  - [[2026-05-16-lidang-public-corpus]]
  - [[lidang-idea-taxonomy]]
  - [[lidang-weekly-digests]]
  - ``wiki/sources/lidang-public/``
- Sources used:
  - $youtubeFeedUrl
  - $youtubeChannelUrl
  - $xCanonicalUrl
  - auxiliary mirror probes listed in the manifest
- Notes:
  - Added raw HTML snapshot tracking under ``raw/lidang-public/html/``.
  - Enforced stable IDs, ``dedupe_key``, ``semantic_hash``, and backfill status fields.
  - Ingested $($entries.Count) public corpus entries in ``$Mode`` mode.
  - New entries this run: $($newEntries.Count).
  - Changed semantic entries this run: $($updatedEntries.Count).
  - Removed entries this run: $($removedEntries.Count).
  - Crawl errors recorded: $($errors.Count).
"@
    if ($hasCorpusChanges -or $logText -notmatch 'ingest \| lidang html snapshots and dedupe rules') {
        Write-TextIfChanged $logPath ($logText.TrimEnd() + $logEntry) | Out-Null
    }

    if (-not $SkipValidation -and -not $DryRun) {
        & (Join-Path $rootPath "scripts\wiki-catalog.ps1") -Root $rootPath | Out-Host
        & (Join-Path $rootPath "scripts\wiki-lint.ps1") -Root $rootPath | Out-Host
    }
}

[pscustomobject]@{
    Mode = $Mode
    ManifestEntries = $entries.Count
    NewEntries = $newEntries.Count
    UpdatedEntries = $updatedEntries.Count
    RemovedEntries = $removedEntries.Count
    Errors = $errors.Count
    BackfillStatus = $backfill.status
    ManifestPath = $manifestPath
    CapturePath = $capturePath
}
