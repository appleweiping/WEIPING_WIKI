param(
    [ValidateSet("Light", "Digest")]
    [string]$Mode = "Digest",
    [string]$Root = ".",
    [switch]$DryRun,
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$today = (Get-Date).ToString("yyyy-MM-dd")
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm")
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

function Read-TextFile([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function ConvertTo-Slug([string]$Text) {
    $slug = $Text.ToLowerInvariant() -replace '\.(md|html|htm|txt)$', ''
    $slug = $slug -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')
    if ([string]::IsNullOrWhiteSpace($slug)) { return "item" }
    return $slug
}

function Escape-Yaml([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    return (($Text -replace '"', '\"') -replace "(`r`n|`n|`r)", " ").Trim()
}

function Get-Sha256Text([string]$Text) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally {
        $sha.Dispose()
    }
}

function Write-TextIfChanged([string]$Path, [string]$Content) {
    $normalized = $Content.TrimEnd() + "`n"
    if ((Test-Path -LiteralPath $Path) -and ((Read-TextFile $Path) -eq $normalized)) {
        return $false
    }
    if (-not $DryRun) {
        Ensure-Dir (Split-Path -Parent $Path)
        [System.IO.File]::WriteAllText($Path, $normalized, $utf8NoBom)
    }
    return $true
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

function Invoke-WebProbe([string]$Url) {
    try {
        $content = Invoke-WebUtf8 $Url
        $title = [regex]::Match($content, "<title>(.*?)</title>").Groups[1].Value
        $statusMatches = [regex]::Matches($content, '(?:https?://(?:x|twitter)\.com)?/lidangzzz/status/\d+') |
            ForEach-Object { $_.Value } |
            Sort-Object -Unique
        return [pscustomobject]@{
            url = $Url
            ok = $true
            status = 200
            length = $content.Length
            title = $title
            status_links = @($statusMatches)
            content_hash = Get-Sha256Text $content
            error = ""
        }
    }
    catch {
        return [pscustomobject]@{
            url = $Url
            ok = $false
            status = "ERR"
            length = 0
            title = ""
            status_links = @()
            content_hash = ""
            error = Get-ErrorSummary $_
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

function Get-FirstSeen([hashtable]$OldById, [string]$Id) {
    if ($OldById.ContainsKey($Id) -and $OldById[$Id].first_seen) { return $OldById[$Id].first_seen }
    return $today
}

function Get-LastChanged([hashtable]$OldById, [string]$Id, [string]$Hash) {
    if ($OldById.ContainsKey($Id) -and $OldById[$Id].content_hash -eq $Hash -and $OldById[$Id].last_changed) {
        return $OldById[$Id].last_changed
    }
    return $today
}

function Convert-ToFrontmatterList([string[]]$Items) {
    if ($null -eq $Items -or $Items.Count -eq 0) { return "  - lidang" }
    return (($Items | Sort-Object -Unique | ForEach-Object { "  - $_" }) -join "`n")
}

function Convert-ToWikiAlias([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return "untitled" }
    return (($Text -replace '[\[\]\|]', '') -replace '\s+', ' ').Trim()
}

function Add-OrReplaceIndexLine([string]$Text, [string]$Heading, [string]$Line) {
    if ($Text -match [regex]::Escape($Line)) { return $Text }
    return ($Text -replace "($Heading\s*)", "`$1`n$Line`n")
}

function New-VideoEntry([object]$Entry, [hashtable]$OldById) {
    $title = [string]$Entry.title
    $link = [string]$Entry.link.href
    $videoId = ($link -replace "^.*[?&]v=", "") -replace "&.*$", ""
    $cat = Get-CategoryInfo $title
    $hash = Get-Sha256Text ($title + "`n" + $link + "`n" + [string]$Entry.published + "`n" + [string]$Entry.updated)
    $id = "youtube:$videoId"
    $importance = Get-ImportanceScore "youtube-video" $title $cat.Category
    $slug = ConvertTo-Slug ("video-" + $videoId)
    return [pscustomobject]@{
        id = $id
        source_kind = "youtube-video"
        canonical_url = $link
        mirror_urls = @()
        title = $title
        published_at = [string]$Entry.published
        captured_at = (Get-Date).ToString("o")
        content_hash = $hash
        source_confidence = "official-rss"
        category = $cat.Category
        tags = $cat.Tags + @("youtube", "video")
        engagement = [pscustomobject]@{}
        importance_score = $importance
        dedupe_key = $hash
        wiki_page = if ($importance -ge 4) { "wiki/sources/lidang-public/$slug.md" } else { "" }
        public_handling = "public-metadata-summary-only"
        summary = "YouTube video from the official Lidang RSS feed: $title."
        first_seen = Get-FirstSeen $OldById $id
        last_seen = $today
        last_changed = Get-LastChanged $OldById $id $hash
    }
}

function New-XProfileEntry([object[]]$Probes, [hashtable]$OldById) {
    $probeText = ($Probes | ConvertTo-Json -Depth 8)
    $hash = Get-Sha256Text $probeText
    $id = "x-profile:lidangzzz"
    return [pscustomobject]@{
        id = $id
        source_kind = "x-profile-probe"
        canonical_url = $xCanonicalUrl
        mirror_urls = $xMirrorUrls
        title = "X profile probe for lidangzzz"
        published_at = ""
        captured_at = (Get-Date).ToString("o")
        content_hash = $hash
        source_confidence = "canonical-profile-plus-nonauthoritative-mirror-probes"
        category = "Everyday heuristics / judgment frames"
        tags = @("lidang", "x", "mirror-probe")
        engagement = [pscustomobject]@{}
        importance_score = 1
        dedupe_key = "x-profile:lidangzzz"
        wiki_page = ""
        public_handling = "public-link-probe-metadata-only"
        summary = "Canonical X profile and auxiliary mirrors were probed. Full X text is not mirrored publicly; unavailable mirrors are recorded as crawl errors."
        first_seen = Get-FirstSeen $OldById $id
        last_seen = $today
        last_changed = Get-LastChanged $OldById $id $hash
        probes = $Probes
    }
}

function New-StatusLinkEntry([string]$Url, [string]$SourceUrl, [hashtable]$OldById) {
    $statusId = ([regex]::Match($Url, '/status/(\d+)')).Groups[1].Value
    if ([string]::IsNullOrWhiteSpace($statusId)) { return $null }
    $canonical = "https://x.com/lidangzzz/status/$statusId"
    $hash = Get-Sha256Text ($canonical + "`n" + $SourceUrl)
    $id = "x-status:$statusId"
    return [pscustomobject]@{
        id = $id
        source_kind = "x-status-link"
        canonical_url = $canonical
        mirror_urls = @($SourceUrl)
        title = "X status $statusId"
        published_at = ""
        captured_at = (Get-Date).ToString("o")
        content_hash = $hash
        source_confidence = "mirror-discovered-link"
        category = "Everyday heuristics / judgment frames"
        tags = @("lidang", "x", "status-link")
        engagement = [pscustomobject]@{}
        importance_score = 1
        dedupe_key = $canonical
        wiki_page = ""
        public_handling = "public-link-metadata-only"
        summary = "A status link discovered from an auxiliary source. The public wiki records link metadata only."
        first_seen = Get-FirstSeen $OldById $id
        last_seen = $today
        last_changed = Get-LastChanged $OldById $id $hash
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
- Content hash: ``$($Entry.content_hash)``
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
$itemDir = Join-Path $rootPath "wiki\sources\lidang-public"
Ensure-Dir $rawDir
Ensure-Dir $inboxDir
Ensure-Dir $itemDir

$manifestPath = Join-Path $rawDir "manifest.json"
$oldById = @{}
$oldManifest = $null
if (Test-Path -LiteralPath $manifestPath) {
    try {
        $oldManifest = Read-TextFile $manifestPath | ConvertFrom-Json
        foreach ($entry in $oldManifest.entries) { $oldById[$entry.id] = $entry }
    }
    catch {
        $oldManifest = $null
    }
}

$errors = New-Object System.Collections.Generic.List[string]
$entries = New-Object System.Collections.Generic.List[object]
$youtubeTitle = ""
$youtubeCount = 0

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

$xProbes = @()
$xProbes += Invoke-WebProbe $xCanonicalUrl
foreach ($mirror in $xMirrorUrls) { $xProbes += Invoke-WebProbe $mirror }
$entries.Add((New-XProfileEntry $xProbes $oldById))

foreach ($probe in $xProbes) {
    foreach ($statusUrl in @($probe.status_links)) {
        $entry = New-StatusLinkEntry $statusUrl $probe.url $oldById
        if ($null -ne $entry) { $entries.Add($entry) }
    }
    if (-not $probe.ok) { $errors.Add("Probe failed for $($probe.url): $($probe.error)") }
}

$currentById = @{}
foreach ($entry in $entries) { $currentById[$entry.id] = $entry }
$removedEntries = @()
foreach ($oldId in $oldById.Keys) {
    if (-not $currentById.ContainsKey($oldId)) { $removedEntries += $oldById[$oldId] }
}
$newEntries = @($entries | Where-Object { -not $oldById.ContainsKey($_.id) })
$updatedEntries = @($entries | Where-Object { $oldById.ContainsKey($_.id) -and $oldById[$_.id].content_hash -ne $_.content_hash })
$hasCorpusChanges = ($newEntries.Count -gt 0 -or $updatedEntries.Count -gt 0 -or $removedEntries.Count -gt 0 -or -not (Test-Path -LiteralPath $manifestPath))

$capture = [pscustomobject]@{
    schema = "lidang-public-capture-v1"
    captured_at = (Get-Date).ToString("o")
    mode = $Mode
    sources = [pscustomobject]@{
        youtube_feed = $youtubeFeedUrl
        youtube_channel = $youtubeChannelUrl
        x_canonical = $xCanonicalUrl
        x_mirrors = $xMirrorUrls
    }
    errors = @($errors)
    entries = @($entries | Sort-Object source_kind, published_at, title)
}
$capturePath = Join-Path $inboxDir "$today-$($Mode.ToLowerInvariant()).json"
Write-TextIfChanged $capturePath ($capture | ConvertTo-Json -Depth 20) | Out-Null

$manifest = [pscustomobject]@{
    schema = "lidang-public-corpus-v1"
    generated_at = if ($hasCorpusChanges -or -not $oldManifest) { (Get-Date).ToString("o") } elseif ($oldManifest.generated_at) { $oldManifest.generated_at } else { (Get-Date).ToString("o") }
    sources = $capture.sources
    public_handling = "Public wiki pages contain official URLs, source metadata, summaries, hashes, confidence labels, and mirror availability. Full X text from mirrors is local/cache-only unless redistribution is clearly allowed."
    mode = $Mode
    entry_count = $entries.Count
    new_entries_this_run = $newEntries.Count
    changed_entries_this_run = $updatedEntries.Count
    removed_entries_this_run = $removedEntries.Count
    errors = @($errors)
    entries = @($entries | Sort-Object source_kind, published_at, title)
}
Write-TextIfChanged $manifestPath ($manifest | ConvertTo-Json -Depth 30) | Out-Null

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
        "- $($_.url): status ``$($_.status)``, ok ``$($_.ok)``, status links $($_.status_links.Count), note ``$($_.error)``"
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
        "- $($_.published_at) | $($_.source_kind) | $($_.category) | [$($_.title)]($url) | score $($_.importance_score) | $($_.source_confidence)"
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
- Public handling: metadata, links, summaries, hashes, and confidence labels only.

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
- YouTube RSS exposes recent videos only; older video history needs a separate historical backfill source.
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

## Crawl Snapshot

- Mode: ``$Mode``
- YouTube RSS title: ``$youtubeTitle``
- YouTube RSS exposed entries: $youtubeCount
- Manifest entries: $($entries.Count)
- New entries this run: $($newEntries.Count)
- Changed entries this run: $($updatedEntries.Count)
- Removed entries this run: $($removedEntries.Count)
- Crawl errors recorded: $($errors.Count)

## Source Kinds

$sourceKindLines

## X / Mirror Probe Results

$probeLines

## Public Handling Policy

- EXTRACTED: YouTube RSS is an official feed and can be used for public metadata.
- EXTRACTED: X canonical profile is the preferred public identity URL.
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
- YouTube RSS only exposes recent videos, so historical video backfill remains a separate task.
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
            "- $url - $($_.source_kind), confidence ``$($_.source_confidence)``, score $($_.importance_score)"
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
    $indexText = Add-OrReplaceIndexLine $indexText "## Sources" "- [[2026-05-16-lidang-public-corpus]] - Batch ingest of Lidang YouTube RSS, canonical X profile, and auxiliary mirror probes."
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

## [$now] ingest | lidang public ideas corpus

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
  - Ingested $($entries.Count) public corpus entries in ``$Mode`` mode.
  - New entries this run: $($newEntries.Count).
  - Changed entries this run: $($updatedEntries.Count).
  - Removed entries this run: $($removedEntries.Count).
  - Crawl errors recorded: $($errors.Count).
  - Manifest stored at ``raw/lidang-public/manifest.json``.
"@
    if ($hasCorpusChanges -or $logText -notmatch 'ingest \| lidang public ideas corpus') {
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
    ManifestPath = $manifestPath
    CapturePath = $capturePath
}
