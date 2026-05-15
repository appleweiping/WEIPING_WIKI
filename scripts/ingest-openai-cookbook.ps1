param(
    [string]$Root = ".",
    [switch]$DryRun,
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$today = (Get-Date).ToString("yyyy-MM-dd")
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm")
$cookbookUrl = "https://developers.openai.com/cookbook"
$repoTreeUrl = "https://api.github.com/repos/openai/openai-cookbook/git/trees/main?recursive=1"
$rawBase = "https://raw.githubusercontent.com/openai/openai-cookbook/main/"
$githubBase = "https://github.com/openai/openai-cookbook/blob/main/"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-TextFile([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function ConvertTo-Slug([string]$Text) {
    $slug = $Text.ToLowerInvariant() -replace '\.(ipynb|mdx|md)$', ''
    $slug = $slug -replace '[^a-z0-9]+', '-'
    return $slug.Trim('-')
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

function Get-TitleFromPath([string]$CookbookPath) {
    $leaf = ($CookbookPath -split '/')[-1]
    $leaf = $leaf -replace '\.(ipynb|mdx|md)$', ''
    $leaf = $leaf -replace '[_-]+', ' '
    return (Get-Culture).TextInfo.ToTitleCase($leaf.ToLowerInvariant())
}

function Get-CategoryInfo([string]$CookbookPath) {
    $p = $CookbookPath.ToLowerInvariant()
    if ($p -match 'agents_sdk|agentkit|orchestrating_agents|object_oriented_agentic|parallel_agents') { return @{ Category = "Agents SDK / agent workflows"; Tags = @("openai", "cookbook", "agents", "agent-workflows") } }
    if ($p -match 'responses_api|responses_|reasoning_items|tool_orchestration') { return @{ Category = "Responses API / tool orchestration"; Tags = @("openai", "cookbook", "responses-api", "tools") } }
    if ($p -match 'chatgpt|gpt_actions') { return @{ Category = "ChatGPT / GPT Actions"; Tags = @("openai", "cookbook", "chatgpt", "gpt-actions") } }
    if ($p -match 'codex') { return @{ Category = "Codex / coding agents"; Tags = @("openai", "cookbook", "codex", "coding-agents") } }
    if ($p -match 'evaluation|evals|judge|eval') { return @{ Category = "Evaluation / eval flywheels"; Tags = @("openai", "cookbook", "evaluation", "evals") } }
    if ($p -match 'rag|retrieval|file_search|search|vector|embedding|qdrant|pinecone|weaviate|chroma|redis|supabase|mongodb|elasticsearch|pgvector|azuresearch') { return @{ Category = "RAG / retrieval / vector databases"; Tags = @("openai", "cookbook", "rag", "retrieval") } }
    if ($p -match 'fine[-_]?tun|reinforcement_fine_tuning|dpo|rft') { return @{ Category = "Fine-tuning / reinforcement fine-tuning"; Tags = @("openai", "cookbook", "fine-tuning") } }
    if ($p -match 'realtime|voice|speech|tts|whisper|transcription') { return @{ Category = "Realtime / voice / transcription"; Tags = @("openai", "cookbook", "realtime", "voice") } }
    if ($p -match 'image|vision|video|dall|sora|multimodal|gpt4v') { return @{ Category = "Multimodal / image / video"; Tags = @("openai", "cookbook", "multimodal") } }
    if ($p -match 'gpt-oss|harmony') { return @{ Category = "gpt-oss / open-weight deployment"; Tags = @("openai", "cookbook", "gpt-oss") } }
    if ($p -match 'gpt-5|o-series|reasoning') { return @{ Category = "GPT-5 / reasoning / prompting"; Tags = @("openai", "cookbook", "gpt-5", "reasoning") } }
    if ($p -match 'structured_outputs|function_call|openapi|tool_required') { return @{ Category = "Structured outputs / function calling"; Tags = @("openai", "cookbook", "structured-outputs", "function-calling") } }
    if ($p -match 'deep_research|mcp') { return @{ Category = "Deep Research / MCP"; Tags = @("openai", "cookbook", "deep-research", "mcp") } }
    if ($p -match 'third_party|partners|azure') { return @{ Category = "Third-party integrations"; Tags = @("openai", "cookbook", "integration") } }
    return @{ Category = "General OpenAI API patterns"; Tags = @("openai", "cookbook") }
}

function Convert-NotebookToMarkdown([string]$JsonText) {
    $nb = $JsonText | ConvertFrom-Json
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($cell in $nb.cells) {
        $source = ""
        if ($null -ne $cell.source) {
            if ($cell.source -is [array]) { $source = ($cell.source -join "") } else { $source = [string]$cell.source }
        }
        if ([string]::IsNullOrWhiteSpace($source)) { continue }
        if ($cell.cell_type -eq "markdown") {
            $out.Add($source.TrimEnd())
            $out.Add("")
        }
        elseif ($cell.cell_type -eq "code") {
            $out.Add('```python')
            $out.Add($source.TrimEnd())
            $out.Add('```')
            $out.Add("")
        }
    }
    return ($out -join "`n").Trim()
}

function Get-LeadSummary([string]$Markdown, [string]$FallbackTitle) {
    $plain = $Markdown -replace '(?s)```.*?```', ' '
    $plain = $plain -replace '(?m)^---.*?---\s*', ' '
    $plain = $plain -replace '(?m)^#+\s*', ''
    $plain = $plain -replace '\[[^\]]+\]\([^)]+\)', '$1'
    $plain = $plain -replace '[#*_>`|]', ' '
    $plain = $plain -replace '\s+', ' '
    $plain = $plain.Trim()
    if ($plain.Length -eq 0) { return "OpenAI Cookbook entry for $FallbackTitle." }
    if ($plain.Length -gt 360) { return $plain.Substring(0, 360).Trim() + "..." }
    return $plain
}

function Get-TeachingBullets([string]$Path, [string]$Category) {
    $lower = $Path.ToLowerInvariant()
    $bullets = New-Object System.Collections.Generic.List[string]
    if ($lower -match 'agent') { $bullets.Add("How to structure agent workflows, tool use, memory, evaluation, or multi-agent coordination.") }
    if ($lower -match 'eval|judge') { $bullets.Add("How to turn model behavior into measurable evaluation cases and improvement loops.") }
    if ($lower -match 'rag|retrieval|vector|embedding|search') { $bullets.Add("How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.") }
    if ($lower -match 'realtime|voice|speech|whisper') { $bullets.Add("How to build low-latency speech, transcription, or voice interaction pipelines.") }
    if ($lower -match 'fine|tuning|rft|dpo') { $bullets.Add("How to prepare data or workflows for model adaptation and fine-tuning.") }
    if ($lower -match 'function|structured|openapi|tool') { $bullets.Add("How to expose tools, APIs, schemas, or structured outputs to model workflows.") }
    if ($lower -match 'codex') { $bullets.Add("How to use Codex for coding-agent workflows, repair loops, reviews, or secure engineering automation.") }
    if ($bullets.Count -eq 0) { $bullets.Add("A concrete OpenAI implementation pattern in the category: $Category.") }
    return $bullets
}

function Escape-WikiLinkSyntax([string]$Markdown) {
    # Cookbook code/data often contains shell tests or arrays like [[ ... ]].
    # Escape them so the local Obsidian-style wiki linter does not treat them
    # as internal wiki links.
    $escaped = $Markdown -replace '\[\[', '&#91;&#91;' -replace '\]\]', '&#93;&#93;'
    $escaped = $escaped -replace '(?m)^(<{7}|={7}|>{7})', '`$1'
    return ($escaped -replace '(?m)[ \t]+$', '')
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

$rawDir = Join-Path $rootPath "raw\openai-cookbook"
$itemDir = Join-Path $rootPath "wiki\sources\openai-cookbook"
Ensure-Dir $rawDir
Ensure-Dir $itemDir

$html = (Invoke-WebRequest -Uri $cookbookUrl -UseBasicParsing -TimeoutSec 90).Content
$hrefs = [regex]::Matches($html, "href=[""']([^""']+)[""']") |
    ForEach-Object { $_.Groups[1].Value } |
    Where-Object { $_ -match '^/cookbook/(examples|articles)/' } |
    Sort-Object -Unique

if ($hrefs.Count -lt 100) {
    throw "Cookbook discovery returned only $($hrefs.Count) links; refusing to update manifest."
}

$tree = Invoke-RestMethod -Uri $repoTreeUrl -TimeoutSec 90
$sourceFiles = $tree.tree |
    Where-Object { $_.type -eq "blob" -and $_.path -match '^(examples|articles)/' -and $_.path -match '\.(md|mdx|ipynb)$' }

$sourceMap = @{}
foreach ($file in $sourceFiles) {
    $parts = $file.path -split '/'
    $kind = $parts[0]
    $rel = ($parts[1..($parts.Length - 1)] -join '/')
    $key = "$kind/$(ConvertTo-Slug $rel)"
    if (-not $sourceMap.ContainsKey($key)) { $sourceMap[$key] = @() }
    $sourceMap[$key] += $file.path
}

$existingManifestPath = Join-Path $rawDir "manifest.json"
$existingByPath = @{}
if (Test-Path -LiteralPath $existingManifestPath) {
    $old = Read-TextFile $existingManifestPath | ConvertFrom-Json
    foreach ($entry in $old.entries) { $existingByPath[$entry.cookbook_path] = $entry }
}

$entries = New-Object System.Collections.Generic.List[object]
$changedPages = 0
$newEntries = 0
$updatedEntries = 0
$errors = New-Object System.Collections.Generic.List[string]

foreach ($href in $hrefs) {
    $rel = $href -replace '^/cookbook/', ''
    $kind = ($rel -split '/', 2)[0]
    $slugRel = ($rel -split '/', 2)[1]
    $key = "$kind/$(ConvertTo-Slug $slugRel)"
    if (-not $sourceMap.ContainsKey($key)) {
        $errors.Add("No source mapping for $href")
        continue
    }
    $sourcePath = ($sourceMap[$key] | Sort-Object Length | Select-Object -First 1)
    $canonicalUrl = "https://developers.openai.com$href"
    $rawUrl = $rawBase + ($sourcePath -replace ' ', '%20')
    $githubUrl = $githubBase + ($sourcePath -replace ' ', '%20')
    $sourceText = (Invoke-WebRequest -Uri $rawUrl -UseBasicParsing -TimeoutSec 90).Content
    $ext = [System.IO.Path]::GetExtension($sourcePath).ToLowerInvariant()
    $mirrorText = if ($ext -eq ".ipynb") { Convert-NotebookToMarkdown $sourceText } else { $sourceText.Trim() }
    $mirrorText = Escape-WikiLinkSyntax $mirrorText
    $contentHash = Get-Sha256Text $sourceText
    $title = Get-TitleFromPath $sourcePath
    $cat = Get-CategoryInfo $sourcePath
    $pageSlug = ConvertTo-Slug $rel
    $pagePath = "wiki/sources/openai-cookbook/$pageSlug.md"
    $absPagePath = Join-Path $rootPath $pagePath
    $summary = Get-LeadSummary $mirrorText $title
    $teach = Get-TeachingBullets $sourcePath $cat.Category
    $oldEntry = $existingByPath[$rel]
    $firstSeen = if ($null -ne $oldEntry -and $oldEntry.first_seen) { $oldEntry.first_seen } else { $today }
    $lastChanged = if ($null -ne $oldEntry -and $oldEntry.content_hash -eq $contentHash -and $oldEntry.last_changed) { $oldEntry.last_changed } else { $today }
    if ($null -eq $oldEntry) { $newEntries++ }
    elseif ($oldEntry.content_hash -ne $contentHash) { $updatedEntries++ }

    $tagLines = ($cat.Tags + @(
        $(if ($kind -eq "articles") { "article" } else { "example" }),
        $(if ($ext -eq ".ipynb") { "notebook" } else { "markdown-source" })
    ) | Sort-Object -Unique | ForEach-Object { "  - $_" }) -join "`n"
    $teachingLines = ($teach | ForEach-Object { "- $_" }) -join "`n"
    $content = @"
---
title: "$title"
type: source
status: mirrored
created: $firstSeen
updated: $today
tags:
$tagLines
source_pages:
  - $canonicalUrl
  - $githubUrl
---

# $title

## Source

- Canonical Cookbook page: $canonicalUrl
- OpenAI Cookbook source: $githubUrl
- Raw source: $rawUrl
- Source path: ``$sourcePath``
- Source kind: ``$kind``
- Source format: ``$ext``
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: ``$contentHash``

## Classification

- Primary category: $($cat.Category)
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

$summary

## What This Teaches

$teachingLines

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

$mirrorText
"@
    if (Write-TextIfChanged $absPagePath $content) { $changedPages++ }

    $entries.Add([pscustomobject]@{
        url = $canonicalUrl
        cookbook_path = $rel
        source_path = $sourcePath
        github_url = $githubUrl
        raw_url = $rawUrl
        category = $cat.Category
        title = $title
        source_kind = "openai-cookbook-github"
        source_format = $ext.TrimStart(".")
        content_hash = $contentHash
        first_seen = $firstSeen
        last_seen = $today
        last_changed = $lastChanged
        wiki_page = $pagePath
    })
}

if ($errors.Count -gt 0) {
    throw ($errors -join "`n")
}

$grouped = $entries | Group-Object category | Sort-Object Name
$categorySections = foreach ($group in $grouped) {
    $lines = $group.Group | Sort-Object title | ForEach-Object {
        $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
        "- [[$wikiId|$($_.title)]] - $($_.cookbook_path)"
    }
    "## $($group.Name)`n`n" + ($lines -join "`n")
}

$indexCookbookLines = foreach ($group in $grouped) {
    $lines = $group.Group | Sort-Object title | ForEach-Object {
        $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
        "  - [[$wikiId|$($_.title)]]"
    }
    "- $($group.Name)`n" + ($lines -join "`n")
}

$hubContent = @"
---
title: OpenAI Cookbook
type: topic
status: active
created: 2026-05-15
updated: $today
tags:
  - openai
  - cookbook
  - llm
  - api-patterns
---

# OpenAI Cookbook

The OpenAI Cookbook is a high-value implementation reference for OpenAI API usage patterns, agent workflows, evaluations, RAG, multimodal systems, Realtime/voice, fine-tuning, Codex, and production integrations.

## Why It Matters

- EXTRACTED: The current ingest discovered $($entries.Count) Cookbook article/example pages from `https://developers.openai.com/cookbook`.
- EXTRACTED: Every discovered developers page mapped to a source file in the MIT-licensed `openai/openai-cookbook` GitHub repository during this crawl.
- INFERRED: This source should be treated as a living implementation library rather than a static tutorial because new examples and articles can appear over time.

## How To Use This Hub

- Start with [[openai-cookbook-taxonomy]] when choosing examples by domain.
- Use individual mirrored source pages under ``wiki/sources/openai-cookbook/`` for exact example content.
- Check current official OpenAI docs before copying model names, SDK calls, or parameters into production code.
- Run ``scripts/ingest-openai-cookbook.ps1`` to refresh the mirror and detect new or changed examples.

## Major Categories

$(($grouped | ForEach-Object { "- $($_.Name): $($_.Count) pages" }) -join "`n")

## Related

- [[2026-05-15-openai-cookbook]]
- [[openai-cookbook-taxonomy]]
- [[llm-based-recommendation]]
- [[personal-knowledge-systems]]

## Counterpoints And Gaps

- Some Cookbook examples may lag the newest OpenAI API guidance; always check current official docs before production use.
- The taxonomy is path-and-keyword based, so cross-cutting examples may belong to more than one category.
"@

$sourceContent = @"
---
title: 2026-05-15 OpenAI Cookbook
type: source
status: active
created: 2026-05-15
updated: $today
tags:
  - openai
  - cookbook
  - batch-ingest
  - api-patterns
source_pages:
  - https://developers.openai.com/cookbook
  - https://github.com/openai/openai-cookbook
---

# 2026-05-15 OpenAI Cookbook

## Provenance

- Canonical discovery page: https://developers.openai.com/cookbook
- Preferred full-text source: https://github.com/openai/openai-cookbook
- License basis: OpenAI Cookbook repository MIT license.
- Crawl date: $today
- Discovered Cookbook pages: $($entries.Count)
- Manifest: ``raw/openai-cookbook/manifest.json``

## Ingest Policy

- Treat the developers page as the source of current Cookbook navigation.
- Treat GitHub source files as the preferred mirror source when the developers URL maps to an MIT-licensed source file.
- Keep source URLs, raw URLs, source paths, hashes, and first/last seen metadata in the manifest.
- Re-run weekly via Codex automation and commit only scoped Cookbook/wiki changes.

## Current Category Counts

$(($grouped | ForEach-Object { "- $($_.Name): $($_.Count)" }) -join "`n")

## Related

- [[openai-cookbook]]
- [[openai-cookbook-taxonomy]]
"@

$taxonomyContent = @"
---
title: OpenAI Cookbook Taxonomy
type: analysis
status: active
created: 2026-05-15
updated: $today
tags:
  - openai
  - cookbook
  - taxonomy
  - llm
---

# OpenAI Cookbook Taxonomy

This page groups the mirrored OpenAI Cookbook article/example pages by implementation domain. It is generated by `scripts/ingest-openai-cookbook.ps1`.

## Snapshot

- Crawl date: $today
- Mirrored pages: $($entries.Count)
- New manifest entries this run: $newEntries
- Changed source hashes this run: $updatedEntries

$($categorySections -join "`n`n")

## Related

- [[openai-cookbook]]
- [[2026-05-15-openai-cookbook]]

## Counterpoints And Gaps

- This taxonomy optimizes retrieval and navigation, not a definitive product ontology.
- Generated titles come from source paths and may be less polished than the rendered developers site titles.
"@

Write-TextIfChanged (Join-Path $rootPath "wiki\topics\openai-cookbook.md") $hubContent | Out-Null
Write-TextIfChanged (Join-Path $rootPath "wiki\sources\2026-05-15-openai-cookbook.md") $sourceContent | Out-Null
Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\openai-cookbook-taxonomy.md") $taxonomyContent | Out-Null

$manifest = [pscustomobject]@{
    schema = "openai-cookbook-manifest-v1"
    generated_at = (Get-Date).ToString("o")
    discovery_url = $cookbookUrl
    github_repository = "https://github.com/openai/openai-cookbook"
    license_basis = "MIT license in openai/openai-cookbook"
    entry_count = $entries.Count
    entries = @($entries | Sort-Object cookbook_path)
}
$manifestJson = $manifest | ConvertTo-Json -Depth 20
Write-TextIfChanged $existingManifestPath $manifestJson | Out-Null

$indexPath = Join-Path $rootPath "wiki\index.md"
$indexText = Read-TextFile $indexPath
if ($indexText -notmatch '\[\[openai-cookbook\]\]') {
    $indexText = $indexText -replace '(## Topics\s*)', "`$1`n- [[openai-cookbook]] - Mirrored OpenAI Cookbook implementation library with categorized examples, articles, source hashes, and weekly refresh workflow.`n"
}
if ($indexText -notmatch '\[\[2026-05-15-openai-cookbook\]\]') {
    $indexText = $indexText -replace '(## Sources\s*)', "`$1`n- [[2026-05-15-openai-cookbook]] - Batch ingest of the official OpenAI Cookbook developers index and MIT-licensed GitHub source mirror.`n"
}
if ($indexText -notmatch '\[\[openai-cookbook-taxonomy\]\]') {
    $indexText = $indexText -replace '(## Analyses\s*)', "`$1`n- [[openai-cookbook-taxonomy]] - Category map of mirrored OpenAI Cookbook examples and articles.`n"
}
$cookbookIndexBlock = @"

### OpenAI Cookbook Mirror

$($indexCookbookLines -join "`n")

"@
if ($indexText -notmatch '### OpenAI Cookbook Mirror') {
    $indexText = $indexText -replace '(## Topics\s*)', ($cookbookIndexBlock + "`$1")
}
$indexText = $indexText -replace 'updated: \d{4}-\d{2}-\d{2}', "updated: $today"
Write-TextIfChanged $indexPath $indexText | Out-Null

$logPath = Join-Path $rootPath "wiki\log.md"
$logText = Read-TextFile $logPath
$logEntry = @"

## [$now] ingest | openai cookbook mirror

- Pages created or updated:
  - [[openai-cookbook]]
  - [[2026-05-15-openai-cookbook]]
  - [[openai-cookbook-taxonomy]]
  - ``wiki/sources/openai-cookbook/``
- Sources used:
  - https://developers.openai.com/cookbook
  - https://github.com/openai/openai-cookbook
- Notes:
  - Mirrored $($entries.Count) Cookbook article/example pages.
  - New manifest entries this run: $newEntries.
  - Changed source hashes this run: $updatedEntries.
  - Manifest stored at ``raw/openai-cookbook/manifest.json``.
"@
if ($logText -notmatch 'ingest \| openai cookbook mirror') {
    Write-TextIfChanged $logPath ($logText.TrimEnd() + $logEntry) | Out-Null
}

if (-not $SkipValidation -and -not $DryRun) {
    & (Join-Path $rootPath "scripts\wiki-catalog.ps1") -Root $rootPath | Out-Host
    & (Join-Path $rootPath "scripts\wiki-lint.ps1") -Root $rootPath | Out-Host
}

[pscustomobject]@{
    DiscoveredLinks = $hrefs.Count
    ManifestEntries = $entries.Count
    NewEntries = $newEntries
    UpdatedEntries = $updatedEntries
    ChangedPages = $changedPages
    ManifestPath = $existingManifestPath
}
