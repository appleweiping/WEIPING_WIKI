param(
    [string]$Root = ".",
    [ValidateSet("Light", "Digest")]
    [string]$Mode = "Digest",
    [switch]$DryRun,
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$today = (Get-Date).ToString("yyyy-MM-dd")
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm")
$runStamp = (Get-Date).ToString("o")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-TextFile([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
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

function Convert-ToFrontmatterList([string[]]$Items) {
    if ($null -eq $Items -or $Items.Count -eq 0) { return "  - frontend-frameworks" }
    return (($Items | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique | ForEach-Object { "  - $_" }) -join "`n")
}

function Invoke-GitHubJson([string]$Url) {
    $headers = @{
        "User-Agent" = "vipin-wiki-frontend-frameworks-ingest"
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

function Convert-ToObjectArray([object]$Value) {
    if ($null -eq $Value) { return @() }
    if ($Value -is [System.Array]) { return @($Value) }
    if ($Value.PSObject.Properties.Name -contains "items") { return @($Value.items) }
    return @($Value)
}

function Invoke-GitHubText([string]$Url) {
    $headers = @{ "User-Agent" = "vipin-wiki-frontend-frameworks-ingest" }
    return (Invoke-WebRequest -Uri $Url -Headers $headers -UseBasicParsing -TimeoutSec 90).Content
}

function Resolve-RepoAlias([string]$RepoFullName, [object]$Repo) {
    if ($RepoFullName -eq "BuilderIO/qwik") { return "QwikDev/qwik" }
    if (-not [string]::IsNullOrWhiteSpace($Repo.full_name)) {
        return [string]$Repo.full_name
    }
    return $RepoFullName
}

function New-Registry {
    return [pscustomobject]@{
        schema = "frontend-frameworks-public-registry-v1"
        updated_at = $today
        public_handling = "Curated official framework-related repositories only; public wiki pages contain metadata, summaries, links, hashes, categories, release summaries, and license notes, not full unlicensed source mirrors."
        frameworks = @(
            [pscustomobject]@{ slug = "react"; name = "React"; category = "ui-framework"; homepage = "https://react.dev"; repos = @("facebook/react", "reactjs/react.dev"); keywords = @("react", "jsx", "fiber", "server components") }
            [pscustomobject]@{ slug = "vue"; name = "Vue"; category = "ui-framework"; homepage = "https://vuejs.org"; repos = @("vuejs/core", "vuejs/docs", "vuejs/router", "vuejs/pinia", "vuejs/devtools"); keywords = @("vue", "pinia", "router", "devtools") }
            [pscustomobject]@{ slug = "angular"; name = "Angular"; category = "ui-framework"; homepage = "https://angular.dev"; repos = @("angular/angular", "angular/angular-cli", "angular/components"); keywords = @("angular", "material", "cli", "components") }
            [pscustomobject]@{ slug = "svelte"; name = "Svelte"; category = "compiler-runtime"; homepage = "https://svelte.dev"; repos = @("sveltejs/svelte", "sveltejs/kit", "sveltejs/svelte.dev"); keywords = @("svelte", "sveltekit", "compiler") }
            [pscustomobject]@{ slug = "solid"; name = "Solid"; category = "ui-framework"; homepage = "https://www.solidjs.com"; repos = @("solidjs/solid", "solidjs/solid-start", "solidjs/solid-docs"); keywords = @("solid", "fine-grained", "signals") }
            [pscustomobject]@{ slug = "qwik"; name = "Qwik"; category = "compiler-runtime"; homepage = "https://qwik.dev"; repos = @("QwikDev/qwik", "BuilderIO/qwik"); keywords = @("qwik", "resumable", "builderio") }
            [pscustomobject]@{ slug = "astro"; name = "Astro"; category = "meta-framework"; homepage = "https://astro.build"; repos = @("withastro/astro", "withastro/docs", "withastro/starlight"); keywords = @("astro", "islands", "content", "starlight") }
            [pscustomobject]@{ slug = "nextjs"; name = "Next.js"; category = "meta-framework"; homepage = "https://nextjs.org"; repos = @("vercel/next.js"); keywords = @("next", "nextjs", "app router", "server components") }
            [pscustomobject]@{ slug = "nuxt"; name = "Nuxt"; category = "meta-framework"; homepage = "https://nuxt.com"; repos = @("nuxt/nuxt", "nuxt/ui", "nuxt/content", "nuxt/image"); keywords = @("nuxt", "vue", "content", "image") }
            [pscustomobject]@{ slug = "sveltekit"; name = "SvelteKit"; category = "meta-framework"; homepage = "https://svelte.dev/docs/kit"; repos = @("sveltejs/kit"); keywords = @("sveltekit", "routing", "adapter") }
            [pscustomobject]@{ slug = "remix-react-router"; name = "Remix / React Router"; category = "meta-framework"; homepage = "https://reactrouter.com"; repos = @("remix-run/react-router", "remix-run/remix"); keywords = @("remix", "react router", "routing", "data router") }
            [pscustomobject]@{ slug = "tanstack-start"; name = "TanStack Start"; category = "meta-framework"; homepage = "https://tanstack.com/start"; repos = @("TanStack/router"); keywords = @("tanstack", "start", "router") }
        )
    }
}

function Get-FrameworkSlugsForRepo([object]$Registry, [string]$RepoFullName) {
    return @($Registry.frameworks | Where-Object {
        $repoSet = @($_.repos)
        if ($repoSet -contains $RepoFullName) { return $true }
        if ($RepoFullName -eq "QwikDev/qwik" -and $repoSet -contains "BuilderIO/qwik") { return $true }
        return $false
    } | ForEach-Object { $_.slug })
}

function Get-FrameworkNamesForRepo([object]$Registry, [string]$RepoFullName) {
    return @($Registry.frameworks | Where-Object {
        $repoSet = @($_.repos)
        if ($repoSet -contains $RepoFullName) { return $true }
        if ($RepoFullName -eq "QwikDev/qwik" -and $repoSet -contains "BuilderIO/qwik") { return $true }
        return $false
    } | ForEach-Object { $_.name })
}

function Get-EcosystemRole([string]$FrameworkCategory, [string]$RepoName) {
    $name = $RepoName.ToLowerInvariant()
    if ($name -match 'docs|dev|website') { return "docs" }
    if ($name -match 'devtools') { return "devtools" }
    if ($name -match 'router') { return "router" }
    if ($name -match 'pinia|state') { return "state-management" }
    if ($name -match 'components|ui') { return "component-system" }
    if ($name -match 'content') { return "content" }
    if ($name -match 'image') { return "image" }
    if ($name -match 'cli') { return "starter-or-examples" }
    return $FrameworkCategory
}

function Get-PrimaryLanguage([object]$Languages, [object]$Repo) {
    if ($null -ne $Languages) {
        $props = @($Languages.PSObject.Properties | Sort-Object -Property Value -Descending)
        if ($props.Count -gt 0) { return $props[0].Name }
    }
    if ($Repo.language) { return [string]$Repo.language }
    return ""
}

function Get-FileExtensionProfile([object[]]$TreeItems) {
    $files = @($TreeItems | Where-Object { $_.type -eq "blob" } | ForEach-Object { $_.path })
    $stats = $files |
        ForEach-Object {
            $ext = [System.IO.Path]::GetExtension($_).ToLowerInvariant()
            if ([string]::IsNullOrWhiteSpace($ext)) { "[none]" } else { $ext }
        } |
        Group-Object |
        Sort-Object -Property @{ Expression = "Count"; Descending = $true }, @{ Expression = "Name"; Ascending = $true } |
        Select-Object -First 12
    return @($stats | ForEach-Object { [pscustomobject]@{ extension = $_.Name; count = $_.Count } })
}

function Get-TopLevelProfile([object[]]$TreeItems) {
    $files = @($TreeItems | Where-Object { $_.type -eq "blob" } | ForEach-Object { $_.path })
    $stats = $files |
        ForEach-Object {
            $parts = $_ -split '/'
            if ($parts.Count -gt 1) { $parts[0] } else { "[root]" }
        } |
        Group-Object |
        Sort-Object -Property @{ Expression = "Count"; Descending = $true }, @{ Expression = "Name"; Ascending = $true } |
        Select-Object -First 12
    return @($stats | ForEach-Object { [pscustomobject]@{ path = $_.Name; count = $_.Count } })
}

function Find-TreePath([object[]]$TreeItems, [string[]]$Names) {
    foreach ($name in $Names) {
        $match = @($TreeItems | Where-Object { $_.type -eq "blob" -and ([System.IO.Path]::GetFileName($_.path) -ieq $name -or [System.IO.Path]::GetFileName($_.path) -ilike "$name.*") } | Sort-Object { ($_.path -split '/').Count }, path | Select-Object -First 1)
        if ($match.Count -gt 0) { return $match[0].path }
    }
    return ""
}

function Get-ReleaseIdeaBullets([string]$Text) {
    $bullets = New-Object System.Collections.Generic.List[string]
    if ([string]::IsNullOrWhiteSpace($Text)) { return @("No release body was available during this crawl.") }
    $lines = @($Text -split "(`r`n|`n|`r)" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^[*-]\s+\S' })
    $keywords = 'breaking|migration|migrate|deprecated|new|feature|api|compiler|runtime|router|routing|data|server|client|performance|fix|security|adapter|react|vue|svelte|solid|qwik|astro|next|nuxt'
    foreach ($line in $lines) {
        if ($line -match $keywords) {
            $clean = ($line -replace '^[*-]\s+', '') -replace '\s+', ' '
            if ($clean.Length -gt 220) { $clean = $clean.Substring(0, 220).Trim() + "..." }
            $bullets.Add((Escape-WikiText $clean))
        }
        if ($bullets.Count -ge 5) { break }
    }
    if ($bullets.Count -eq 0) {
        $bullets.Add((Get-ShortText -Text $Text -Limit 220))
    }
    return @($bullets)
}

function Get-PublicHandling([object]$Repo) {
    $license = ""
    if ($Repo.license -and $Repo.license.spdx_id) { $license = [string]$Repo.license.spdx_id }
    if ($license -and $license -ne "NOASSERTION") { return "public-summary-plus-license-aware-metadata" }
    return "public-summary-local-archive-only"
}

function Format-FrameworkLink([string]$Slug, [string]$Name) {
    return "[[entities/frontend-frameworks/$Slug|$Name]]"
}

function Add-OrReplaceIndexLine([string]$Text, [string]$Heading, [string]$Line) {
    if ($Text -match [regex]::Escape($Line)) { return $Text }
    $pattern = "(?m)^$([regex]::Escape($Heading))\s*$"
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) { return $Text.TrimEnd() + "`n`n$Heading`n`n$Line`n" }
    $insertAt = $match.Index + $match.Length
    return $Text.Insert($insertAt, "`n`n$Line")
}

function Set-GeneratedIndexSection([string]$Text, [string]$Content) {
    $start = "<!-- frontend-frameworks-public:index:start -->"
    $end = "<!-- frontend-frameworks-public:index:end -->"
    $section = "$start`n$Content`n$end"
    $pattern = "(?s)$([regex]::Escape($start)).*?$([regex]::Escape($end))"
    if ($Text -match $pattern) { return [regex]::Replace($Text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $section }) }
    return $Text.TrimEnd() + "`n`n$section`n"
}

function New-FrameworkPage([object]$Framework, [object[]]$RepoEntries, [object[]]$ReleaseEntries) {
    $repoLineItems = @($RepoEntries | Sort-Object repo_full_name | ForEach-Object {
        '- [[sources/frontend-frameworks/{0}|{1}]] - {2}, {3}, stars {4}, latest release `{5}`' -f $_.page_slug, $_.repo_full_name, $_.ecosystem_role, $_.primary_language, $_.stars, $_.latest_release_tag
    })
    $repoLines = $repoLineItems -join "`n"
    if ([string]::IsNullOrWhiteSpace($repoLines)) { $repoLines = "- No repositories were captured." }
    $releaseLineItems = @($ReleaseEntries | Sort-Object published_at -Descending | Select-Object -First 10 | ForEach-Object {
        '- [[sources/frontend-frameworks/releases/{0}|{1} {2}]] - {3}' -f $_.page_slug, $_.repo_full_name, $_.tag_name, $_.published_at
    })
    $releaseLines = $releaseLineItems -join "`n"
    if ([string]::IsNullOrWhiteSpace($releaseLines)) { $releaseLines = "- No releases were captured." }
    $title = Escape-Yaml $Framework.name
    $tags = Convert-ToFrontmatterList @("frontend-frameworks", $Framework.slug, $Framework.category)
    return @"
---
title: "$title"
type: entity
status: active
created: $today
updated: $today
tags:
$tags
source_pages:
  - $($Framework.homepage)
---

# $($Framework.name)

## Role

- EXTRACTED: Registry category: ``$($Framework.category)``.
- EXTRACTED: Homepage: $($Framework.homepage)
- EXTRACTED: Curated official repositories captured in this corpus: $($RepoEntries.Count).

## Repositories

$repoLines

## Recent Captured Releases

$releaseLines

## Navigation

- [[frontend-frameworks-public]]
- [[frontend-framework-taxonomy]]
- [[frontend-framework-idea-map]]
"@
}

function New-RepoPage([object]$Entry) {
    $tags = Convert-ToFrontmatterList @("frontend-frameworks", $Entry.framework_slug, $Entry.ecosystem_role, $Entry.primary_language)
    if ($Entry.topics.Count -gt 0) {
        $topicLines = @($Entry.topics | ForEach-Object { "- ``$_``" }) -join "`n"
    }
    else {
        $topicLines = "- No GitHub topics were exposed."
    }
    if ($Entry.languages.PSObject.Properties.Count -gt 0) {
        $languageLines = @($Entry.languages.PSObject.Properties | Sort-Object Value -Descending | Select-Object -First 8 | ForEach-Object { "- {0}: {1}" -f $_.Name, $_.Value }) -join "`n"
    }
    else {
        $languageLines = "- No language breakdown was available."
    }
    if ($Entry.file_extension_profile.Count -gt 0) {
        $extensionLines = @($Entry.file_extension_profile | ForEach-Object { "- ``{0}``: {1}" -f $_.extension, $_.count }) -join "`n"
    }
    else {
        $extensionLines = "- No tree profile was available."
    }
    $releaseLine = if ($Entry.latest_release_tag) { '- Latest captured release: [[sources/frontend-frameworks/releases/{0}|{1}]]' -f $Entry.latest_release_page_slug, $Entry.latest_release_tag } else { "- No GitHub release was captured." }
    $title = Escape-Yaml $Entry.repo_full_name
    $frameworkLinks = @()
    for ($i = 0; $i -lt $Entry.framework_slugs.Count; $i++) {
        $frameworkLinks += (Format-FrameworkLink $Entry.framework_slugs[$i] $Entry.framework_names[$i])
    }
    $frameworkLink = $frameworkLinks -join ", "
    return @"
---
title: "$title"
type: source
status: active
created: $($Entry.first_seen)
updated: $today
tags:
$tags
source_pages:
  - $($Entry.canonical_url)
---

# $($Entry.repo_full_name)

## Source

- Source kind: ``github-repository``
- Canonical URL: $($Entry.canonical_url)
- Framework: $frameworkLink
- Ecosystem role: ``$($Entry.ecosystem_role)``
- Source confidence: ``$($Entry.source_confidence)``
- Public handling: ``$($Entry.public_handling)``
- Semantic hash: ``$($Entry.semantic_hash)``

## Summary

$($Entry.summary)

## Repository Snapshot

- Default branch: ``$($Entry.default_branch)``
- HEAD SHA: ``$($Entry.head_sha)``
- Stars at crawl: $($Entry.stars)
- Forks at crawl: $($Entry.forks)
- Open issues at crawl: $($Entry.open_issues)
- Primary language: ``$($Entry.primary_language)``
- License: ``$($Entry.license)``
- README path: ``$($Entry.readme_path)``
- README hash: ``$($Entry.readme_hash)``
- Changelog path: ``$($Entry.changelog_path)``
- Changelog hash: ``$($Entry.changelog_hash)``
$releaseLine

## Language Profile

$languageLines

## File Extension Profile

$extensionLines

## GitHub Topics

$topicLines

## Navigation

- [[frontend-frameworks-public]]
- [[frontend-framework-taxonomy]]
- [[frontend-framework-idea-map]]

## Public Handling Notes

- EXTRACTED: This page records metadata, links, summaries, and hashes from public GitHub sources.
- INFERRED: Full source code and long release text are not mirrored into the public wiki.
- Re-crawl before making current claims about stars, releases, or file structure.
"@
}

function New-ReleasePage([object]$Entry) {
    $tags = Convert-ToFrontmatterList @("frontend-frameworks", $Entry.framework_slug, "release", $Entry.ecosystem_role)
    $ideaLines = @($Entry.idea_bullets | ForEach-Object { "- $_" }) -join "`n"
    $title = Escape-Yaml "$($Entry.repo_full_name) $($Entry.tag_name)"
    $repoLink = "[[sources/frontend-frameworks/{0}|{1}]]" -f $Entry.repo_page_slug, $Entry.repo_full_name
    $frameworkLinks = @()
    for ($i = 0; $i -lt $Entry.framework_slugs.Count; $i++) {
        $frameworkLinks += (Format-FrameworkLink $Entry.framework_slugs[$i] $Entry.framework_names[$i])
    }
    $frameworkLink = $frameworkLinks -join ", "
    return @"
---
title: "$title"
type: source
status: active
created: $($Entry.first_seen)
updated: $today
tags:
$tags
source_pages:
  - $($Entry.canonical_url)
---

# $($Entry.repo_full_name) $($Entry.tag_name)

## Source

- Source kind: ``github-release``
- Canonical URL: $($Entry.canonical_url)
- Repository: $repoLink
- Framework: $frameworkLink
- Published: $($Entry.published_at)
- Prerelease: ``$($Entry.prerelease)``
- Author: ``$($Entry.author)``
- Body hash: ``$($Entry.body_hash)``
- Semantic hash: ``$($Entry.semantic_hash)``

## Release Ideas

$ideaLines

## Summary

$($Entry.summary)

## Public Handling Notes

- EXTRACTED: This page records release metadata and a concise idea summary.
- INFERRED: The full release body is not mirrored publicly; use the canonical GitHub URL for complete text.
"@
}

$rawDir = Join-Path $rootPath "raw\frontend-frameworks-public"
$inboxDir = Join-Path $rawDir "inbox"
$registryPath = Join-Path $rawDir "registry.json"
$manifestPath = Join-Path $rawDir "manifest.json"
$sourceDir = Join-Path $rootPath "wiki\sources\frontend-frameworks"
$releaseDir = Join-Path $sourceDir "releases"
$entityDir = Join-Path $rootPath "wiki\entities\frontend-frameworks"
Ensure-Dir $rawDir
Ensure-Dir $inboxDir
Ensure-Dir $sourceDir
Ensure-Dir $releaseDir
Ensure-Dir $entityDir

if (-not (Test-Path -LiteralPath $registryPath)) {
    Write-TextIfChanged $registryPath ((New-Registry) | ConvertTo-Json -Depth 8) | Out-Null
}

$registry = if (Test-Path -LiteralPath $registryPath) { Read-TextFile $registryPath | ConvertFrom-Json } else { New-Registry }
$oldById = @{}
if (Test-Path -LiteralPath $manifestPath) {
    $oldManifest = Read-TextFile $manifestPath | ConvertFrom-Json
    foreach ($entry in $oldManifest.entries) { $oldById[$entry.id] = $entry }
}

$entries = New-Object System.Collections.Generic.List[object]
$errors = New-Object System.Collections.Generic.List[string]
$repoEntries = New-Object System.Collections.Generic.List[object]
$releaseEntries = New-Object System.Collections.Generic.List[object]
$candidateEntries = New-Object System.Collections.Generic.List[object]
$seenRepoIds = @{}
$seenReleaseIds = @{}
$seenCandidateIds = @{}

foreach ($framework in $registry.frameworks) {
    $frameworkId = "framework:$($framework.slug)"
    $repoIds = @($framework.repos | ForEach-Object { "github:$_" })
    $frameworkHash = Get-Sha256Text (($framework | ConvertTo-Json -Depth 8) + ($repoIds -join "|"))
    $frameworkRepos = @($framework.repos | Sort-Object -Unique)
    $firstSeen = if ($oldById.ContainsKey($frameworkId) -and $oldById[$frameworkId].first_seen) { $oldById[$frameworkId].first_seen } else { $today }
    $lastChanged = if ($oldById.ContainsKey($frameworkId) -and $oldById[$frameworkId].semantic_hash -eq $frameworkHash -and $oldById[$frameworkId].last_changed) { $oldById[$frameworkId].last_changed } else { $today }
    $entries.Add([pscustomobject]@{
        id = $frameworkId
        dedupe_key = $frameworkId
        source_kind = "framework"
        framework_slug = $framework.slug
        framework_name = $framework.name
        canonical_url = $framework.homepage
        ecosystem_role = $framework.category
        repos = @($frameworkRepos)
        content_hash = $frameworkHash
        semantic_hash = $frameworkHash
        first_seen = $firstSeen
        last_seen = $today
        last_changed = $lastChanged
        public_handling = "public-summary-metadata-only"
        source_confidence = "curated-registry"
        wiki_page = "wiki/entities/frontend-frameworks/$($framework.slug).md"
        summary = "$($framework.name) is tracked as a curated frontend framework corpus entry with official related repositories."
    })

    foreach ($repoFullName in $frameworkRepos) {
        $repoId = "github:$repoFullName"
        if ($seenRepoIds.ContainsKey($repoId)) { continue }
        $seenRepoIds[$repoId] = $true
        $parts = $repoFullName -split '/'
        if ($parts.Count -ne 2) {
            $errors.Add("Invalid repo full name in registry: $repoFullName")
            continue
        }
        $owner = $parts[0]
        $repoName = $parts[1]
        try {
            $repo = Invoke-GitHubJson "https://api.github.com/repos/$owner/$repoName"
            $canonicalRepoFullName = Resolve-RepoAlias $repoFullName $repo
            $canonicalRepoId = "github:$canonicalRepoFullName"
            if ($canonicalRepoId -ne $repoId) {
                if ($seenRepoIds.ContainsKey($canonicalRepoId)) { continue }
                $seenRepoIds[$canonicalRepoId] = $true
            }
            $languages = Invoke-GitHubJson "https://api.github.com/repos/$owner/$repoName/languages"
            $tree = Invoke-GitHubJson "https://api.github.com/repos/$owner/$repoName/git/trees/$($repo.default_branch)?recursive=1"
            $treeItems = @($tree.tree)
            $readmePath = Find-TreePath $treeItems @("README", "Readme", "readme")
            $changelogPath = Find-TreePath $treeItems @("CHANGELOG", "Changelog", "changelog", "CHANGES", "RELEASES")
            $readmeText = ""
            $readmeHash = ""
            if ($readmePath) {
                try {
                    $readmeText = Invoke-GitHubText "https://raw.githubusercontent.com/$repoFullName/$($repo.default_branch)/$($readmePath -replace ' ', '%20')"
                    $readmeHash = Get-Sha256Text $readmeText
                }
                catch {
                    $errors.Add("README fetch failed for ${repoFullName}: $($_.Exception.Message)")
                }
            }
            $changelogText = ""
            $changelogHash = ""
            if ($changelogPath) {
                try {
                    $changelogText = Invoke-GitHubText "https://raw.githubusercontent.com/$repoFullName/$($repo.default_branch)/$($changelogPath -replace ' ', '%20')"
                    $changelogHash = Get-Sha256Text $changelogText
                }
                catch {
                    $errors.Add("Changelog fetch failed for ${repoFullName}: $($_.Exception.Message)")
                }
            }
            $headSha = ""
            if ($tree.sha) { $headSha = [string]$tree.sha }
            $repoSummary = Get-ShortText -Text (($repo.description, $readmeText) -join "`n`n") -Limit 640
            $topics = @()
            if ($repo.topics) { $topics = @($repo.topics) }
            $extensionProfile = Get-FileExtensionProfile $treeItems
            $topLevelProfile = Get-TopLevelProfile $treeItems
            $primaryLanguage = Get-PrimaryLanguage $languages $repo
            $role = Get-EcosystemRole $framework.category $repoName
            $frameworkSlugsForRepo = @(Get-FrameworkSlugsForRepo $registry $canonicalRepoFullName)
            $frameworkNamesForRepo = @(Get-FrameworkNamesForRepo $registry $canonicalRepoFullName)
            $license = if ($repo.license -and $repo.license.spdx_id) { [string]$repo.license.spdx_id } else { "NOASSERTION" }
            $semanticMaterial = @(
                $repo.full_name
                $repo.description
                $repo.default_branch
                $headSha
                $readmeHash
                $changelogHash
                ($topics -join "|")
                ($languages | ConvertTo-Json -Depth 5)
            ) -join "`n"
            $semanticHash = Get-Sha256Text $semanticMaterial
            $contentHash = Get-Sha256Text (($repo | ConvertTo-Json -Depth 12) + ($languages | ConvertTo-Json -Depth 8) + $readmeHash + $changelogHash)
            $firstSeenRepo = if ($oldById.ContainsKey($canonicalRepoId) -and $oldById[$canonicalRepoId].first_seen) { $oldById[$canonicalRepoId].first_seen } elseif ($oldById.ContainsKey($repoId) -and $oldById[$repoId].first_seen) { $oldById[$repoId].first_seen } else { $today }
            $lastChangedRepo = if ($oldById.ContainsKey($canonicalRepoId) -and $oldById[$canonicalRepoId].semantic_hash -eq $semanticHash -and $oldById[$canonicalRepoId].last_changed) { $oldById[$canonicalRepoId].last_changed } else { $today }
            $repoPageSlug = ConvertTo-Slug $canonicalRepoFullName
            $repoEntry = [pscustomobject]@{
                id = $canonicalRepoId
                dedupe_key = $canonicalRepoId
                source_kind = "github-repository"
                framework_slug = $framework.slug
                framework_name = $framework.name
                framework_slugs = @($frameworkSlugsForRepo)
                framework_names = @($frameworkNamesForRepo)
                repo_full_name = [string]$repo.full_name
                repo_owner = [string]($canonicalRepoFullName -split '/')[0]
                repo_name = [string]($canonicalRepoFullName -split '/')[1]
                registry_repo_full_name = [string]$repoFullName
                canonical_url = [string]$repo.html_url
                ecosystem_role = $role
                primary_language = $primaryLanguage
                languages = $languages
                file_extension_profile = @($extensionProfile)
                top_level_profile = @($topLevelProfile)
                license = $license
                public_handling = Get-PublicHandling $repo
                source_confidence = "github-api"
                default_branch = [string]$repo.default_branch
                head_sha = $headSha
                stars = [int]$repo.stargazers_count
                forks = [int]$repo.forks_count
                open_issues = [int]$repo.open_issues_count
                topics = @($topics)
                readme_path = $readmePath
                readme_hash = $readmeHash
                changelog_path = $changelogPath
                changelog_hash = $changelogHash
                content_hash = $contentHash
                semantic_hash = $semanticHash
                first_seen = $firstSeenRepo
                last_seen = $today
                last_changed = $lastChangedRepo
                page_slug = $repoPageSlug
                wiki_page = "wiki/sources/frontend-frameworks/$repoPageSlug.md"
                summary = $repoSummary
                latest_release_tag = ""
                latest_release_page_slug = ""
            }

            $releases = @()
            try {
                $releases = Convert-ToObjectArray (Invoke-GitHubJson "https://api.github.com/repos/$owner/$repoName/releases?per_page=5")
            }
            catch {
                $errors.Add("Release fetch failed for ${repoFullName}: $($_.Exception.Message)")
            }
            $meaningfulReleases = @($releases | Where-Object { $_.tag_name -and -not [string]::IsNullOrWhiteSpace($_.body) } | Select-Object -First 3)
            if ($Mode -eq "Light") { $meaningfulReleases = @($meaningfulReleases | Select-Object -First 1) }
            foreach ($release in $meaningfulReleases) {
                $releaseId = "github-release:${canonicalRepoFullName}:$($release.tag_name)"
                if ($seenReleaseIds.ContainsKey($releaseId)) { continue }
                $seenReleaseIds[$releaseId] = $true
                $body = if ($release.body) { [string]$release.body } else { "" }
                $bodyHash = Get-Sha256Text $body
                $releaseSemanticHash = Get-Sha256Text (($release.tag_name, $release.name, $release.published_at, $bodyHash) -join "`n")
                $firstSeenRelease = if ($oldById.ContainsKey($releaseId) -and $oldById[$releaseId].first_seen) { $oldById[$releaseId].first_seen } else { $today }
                $lastChangedRelease = if ($oldById.ContainsKey($releaseId) -and $oldById[$releaseId].semantic_hash -eq $releaseSemanticHash -and $oldById[$releaseId].last_changed) { $oldById[$releaseId].last_changed } else { $today }
                $releasePageSlug = ConvertTo-Slug "$canonicalRepoFullName-$($release.tag_name)"
                $releaseEntry = [pscustomobject]@{
                    id = $releaseId
                    dedupe_key = $releaseId
                    source_kind = "github-release"
                    framework_slug = $framework.slug
                    framework_name = $framework.name
                    framework_slugs = @($frameworkSlugsForRepo)
                    framework_names = @($frameworkNamesForRepo)
                    repo_full_name = [string]$canonicalRepoFullName
                    repo_page_slug = $repoPageSlug
                    tag_name = [string]$release.tag_name
                    name = [string]$release.name
                    canonical_url = [string]$release.html_url
                    published_at = [string]$release.published_at
                    prerelease = [bool]$release.prerelease
                    author = if ($release.author -and $release.author.login) { [string]$release.author.login } else { "" }
                    body_hash = $bodyHash
                    content_hash = $bodyHash
                    semantic_hash = $releaseSemanticHash
                    idea_bullets = @(Get-ReleaseIdeaBullets $body)
                    summary = Get-ShortText -Text $body -Limit 520
                    ecosystem_role = $role
                    public_handling = "public-release-summary-body-hash-only"
                    source_confidence = "github-api"
                    first_seen = $firstSeenRelease
                    last_seen = $today
                    last_changed = $lastChangedRelease
                    page_slug = $releasePageSlug
                    wiki_page = "wiki/sources/frontend-frameworks/releases/$releasePageSlug.md"
                }
                $releaseEntries.Add($releaseEntry)
                $entries.Add($releaseEntry)
            }
            $latestRelease = @($releaseEntries | Where-Object { $_.repo_full_name -eq $repo.full_name } | Sort-Object published_at -Descending | Select-Object -First 1)
            if ($latestRelease.Count -gt 0) {
                $repoEntry.latest_release_tag = [string]$latestRelease[0].tag_name
                $repoEntry.latest_release_page_slug = $latestRelease[0].page_slug
            }
            $repoEntries.Add($repoEntry)
            $entries.Add($repoEntry)
        }
        catch {
            $errors.Add("Repository ingest failed for ${repoFullName}: $($_.Exception.Message)")
        }
    }

    $owners = @($framework.repos | ForEach-Object { ($_ -split '/')[0] } | Sort-Object -Unique)
    foreach ($owner in $owners) {
        try {
            $orgRepos = Convert-ToObjectArray (Invoke-GitHubJson "https://api.github.com/orgs/$owner/repos?per_page=100&sort=updated")
        }
        catch {
            try {
                $orgRepos = Convert-ToObjectArray (Invoke-GitHubJson "https://api.github.com/users/$owner/repos?per_page=100&sort=updated")
            }
            catch {
                $errors.Add("Candidate discovery failed for ${owner}: $($_.Exception.Message)")
                continue
            }
        }
        $ownerCandidateCount = 0
        foreach ($candidate in ($orgRepos | Sort-Object stargazers_count -Descending)) {
            if ($ownerCandidateCount -ge 8) { break }
            $candidateFullName = [string]$candidate.full_name
            if ([string]::IsNullOrWhiteSpace($candidateFullName) -or $candidateFullName -match '\s') { continue }
            if ($frameworkRepos -contains $candidateFullName) { continue }
            $candidateText = (($candidate.name, $candidate.description) + @($candidate.topics)) -join " "
            $isMatch = $false
            foreach ($keyword in $framework.keywords) {
                if ($candidateText -match [regex]::Escape($keyword)) { $isMatch = $true; break }
            }
            if (-not $isMatch) { continue }
            $candidateId = "github-candidate:$candidateFullName"
            if ($seenCandidateIds.ContainsKey($candidateId)) { continue }
            $seenCandidateIds[$candidateId] = $true
            $candidateHash = Get-Sha256Text (($candidate.full_name, $candidate.description, $candidate.updated_at, $candidate.pushed_at) -join "`n")
            $candidateSummary = Get-ShortText -Text ([string]$candidate.description) -Limit 260
            $candidateFirstSeen = if ($oldById.ContainsKey($candidateId) -and $oldById[$candidateId].first_seen) { $oldById[$candidateId].first_seen } else { $today }
            $candidateLastChanged = if ($oldById.ContainsKey($candidateId) -and $oldById[$candidateId].semantic_hash -eq $candidateHash -and $oldById[$candidateId].last_changed) { $oldById[$candidateId].last_changed } else { $today }
            $candidateEntry = [pscustomobject]@{
                id = $candidateId
                dedupe_key = $candidateId
                source_kind = "github-candidate"
                framework_slug = $framework.slug
                framework_name = $framework.name
                repo_full_name = $candidateFullName
                canonical_url = [string]$candidate.html_url
                summary = $candidateSummary
                stars = if ($candidate.stargazers_count -is [array]) { [int]$candidate.stargazers_count[0] } else { [int]$candidate.stargazers_count }
                updated_at = [string]$candidate.updated_at
                pushed_at = [string]$candidate.pushed_at
                content_hash = $candidateHash
                semantic_hash = $candidateHash
                first_seen = $candidateFirstSeen
                last_seen = $today
                last_changed = $candidateLastChanged
                public_handling = "candidate-metadata-only"
                source_confidence = "github-api-candidate-discovery"
                wiki_page = ""
            }
            $candidateEntries.Add($candidateEntry)
            $entries.Add($candidateEntry)
            $ownerCandidateCount++
        }
    }
}

$oldEntryIds = @()
if (Test-Path -LiteralPath $manifestPath) { $oldEntryIds = @($oldById.Keys) }
$newEntries = @($entries | Where-Object { -not $oldById.ContainsKey($_.id) })
$updatedEntries = @($entries | Where-Object { $oldById.ContainsKey($_.id) -and $oldById[$_.id].semantic_hash -ne $_.semantic_hash })
$removedEntries = @($oldEntryIds | Where-Object { $entries.id -notcontains $_ })

foreach ($repoEntry in $repoEntries) {
    Write-TextIfChanged (Join-Path $sourceDir "$($repoEntry.page_slug).md") (New-RepoPage $repoEntry) | Out-Null
}
foreach ($releaseEntry in $releaseEntries) {
    Write-TextIfChanged (Join-Path $releaseDir "$($releaseEntry.page_slug).md") (New-ReleasePage $releaseEntry) | Out-Null
}
foreach ($framework in $registry.frameworks) {
    $frameworkRepos = @($repoEntries | Where-Object { @($_.framework_slugs) -contains $framework.slug })
    $frameworkReleases = @($releaseEntries | Where-Object { @($_.framework_slugs) -contains $framework.slug })
    Write-TextIfChanged (Join-Path $entityDir "$($framework.slug).md") (New-FrameworkPage $framework $frameworkRepos $frameworkReleases) | Out-Null
}

$frameworkRows = @($registry.frameworks | Sort-Object name | ForEach-Object {
    $framework = $_
    $frameworkRepos = @($repoEntries | Where-Object { @($_.framework_slugs) -contains $framework.slug })
    "| {0} | ``{1}`` | {2} | {3} |" -f (Format-FrameworkLink $framework.slug $framework.name), $framework.category, $frameworkRepos.Count, $framework.homepage
}) -join "`n"

$roleGroups = @($repoEntries | Group-Object ecosystem_role | Sort-Object Name | ForEach-Object {
    $group = $_
    $lines = @($group.Group | Sort-Object framework_name, repo_full_name | ForEach-Object {
        "- [[sources/frontend-frameworks/{0}|{1}]] - {2}, {3}, stars {4}" -f $_.page_slug, $_.repo_full_name, (Format-FrameworkLink $_.framework_slug $_.framework_name), $_.primary_language, $_.stars
    }) -join "`n"
    "## $($group.Name)`n`n$lines"
}) -join "`n`n"

$languageGroups = @($repoEntries | Where-Object { $_.primary_language } | Group-Object primary_language | Sort-Object Count -Descending | ForEach-Object {
    $group = $_
    $repos = ($group.Group | Sort-Object repo_full_name | ForEach-Object { "[[sources/frontend-frameworks/{0}|{1}]]" -f $_.page_slug, $_.repo_full_name }) -join ", "
    "- ``$($group.Name)``: $repos"
}) -join "`n"

$candidateLines = @($candidateEntries | Sort-Object framework_name, stars -Descending | Select-Object -First 80 | ForEach-Object {
    "- {0}: [{1}]({2}) - stars {3}, {4}" -f $_.framework_name, $_.repo_full_name, $_.canonical_url, $_.stars, $_.summary
}) -join "`n"
if ([string]::IsNullOrWhiteSpace($candidateLines)) { $candidateLines = "- No candidate repositories matched this run." }

$hubContent = @"
---
title: Frontend Frameworks Public Corpus
type: topic
status: active
created: $today
updated: $today
tags:
  - frontend-frameworks
  - public-corpus
  - github
source_pages:
  - raw/frontend-frameworks-public/registry.json
  - raw/frontend-frameworks-public/manifest.json
---

# Frontend Frameworks Public Corpus

This hub tracks a curated public corpus of mainstream and innovative frontend frameworks. It captures official framework-related GitHub repositories, release summaries, language profiles, and navigable wiki pages without mirroring full source code into the public wiki.

## Framework Matrix

| Framework | Role | Captured repos | Homepage |
| --- | --- | ---: | --- |
$frameworkRows

## Entry Points

- [[frontend-framework-taxonomy]] - Browse repositories by ecosystem role.
- [[frontend-framework-idea-map]] - Read the main ideas and release themes.
- ``raw/frontend-frameworks-public/manifest.json`` - Local manifest with stable IDs, hashes, candidate records, and provenance.

## Languages

$languageGroups

## Needs Review

$candidateLines

## Maintenance Rules

- Stable IDs are mandatory: ``framework:<slug>``, ``github:<owner>/<repo>``, ``github-release:<owner>/<repo>:<tag_name>``, and ``github-candidate:<owner>/<repo>``.
- Do not promote candidates into public repo pages until ``raw/frontend-frameworks-public/registry.json`` explicitly includes them.
- Public pages contain metadata, summaries, hashes, and links only.
- Re-run ``scripts/ingest-frontend-frameworks-public.ps1`` before making current claims about stars, releases, or repo structure.

## Counterpoints And Gaps

- AMBIGUOUS: The corpus is complete only inside the curated registry boundary, not across every repo in each owner organization.
- AMBIGUOUS: Candidate discovery is keyword-based and may miss official repos whose descriptions/topics do not match the current framework keywords.
- INFERRED: Stars, file profiles, and release ordering are crawl-time signals and should not be treated as stable quality rankings.
"@
Write-TextIfChanged (Join-Path $rootPath "wiki\topics\frontend-frameworks-public.md") $hubContent | Out-Null

$taxonomyContent = @"
---
title: Frontend Framework Taxonomy
type: analysis
status: active
created: $today
updated: $today
tags:
  - frontend-frameworks
  - taxonomy
  - github
source_pages:
  - raw/frontend-frameworks-public/registry.json
  - raw/frontend-frameworks-public/manifest.json
---

# Frontend Framework Taxonomy

This taxonomy groups the captured frontend framework repositories by ecosystem role.

$roleGroups

## Related

- [[frontend-frameworks-public]]
- [[frontend-framework-idea-map]]

## Counterpoints And Gaps

- AMBIGUOUS: Ecosystem roles are heuristic labels based on registry category and repo naming; some repos legitimately span multiple roles.
- INFERRED: Role grouping is for navigation and retrieval, not a definitive taxonomy of each framework's architecture.
"@
Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\frontend-framework-taxonomy.md") $taxonomyContent | Out-Null

$ideaSections = @($registry.frameworks | Sort-Object name | ForEach-Object {
    $framework = $_
    $frameworkRepos = @($repoEntries | Where-Object { @($_.framework_slugs) -contains $framework.slug } | Sort-Object repo_full_name)
    $frameworkReleases = @($releaseEntries | Where-Object { @($_.framework_slugs) -contains $framework.slug } | Sort-Object published_at -Descending | Select-Object -First 5)
    $repoLines = @($frameworkRepos | ForEach-Object { "- [[sources/frontend-frameworks/{0}|{1}]]: {2}" -f $_.page_slug, $_.repo_full_name, $_.summary }) -join "`n"
    if ([string]::IsNullOrWhiteSpace($repoLines)) { $repoLines = "- No repository summaries were captured." }
    $releaseLines = ($frameworkReleases | ForEach-Object {
        $ideas = ($_.idea_bullets | Select-Object -First 2) -join "; "
        "- [[sources/frontend-frameworks/releases/{0}|{1}]]: {2}" -f $_.page_slug, $_.tag_name, $ideas
    }) -join "`n"
    if ([string]::IsNullOrWhiteSpace($releaseLines)) { $releaseLines = "- No release summaries were captured." }
    "## $($framework.name)`n`n### Repository Ideas`n`n$repoLines`n`n### Release Ideas`n`n$releaseLines"
}) -join "`n`n"

$ideaContent = @"
---
title: Frontend Framework Idea Map
type: analysis
status: active
created: $today
updated: $today
tags:
  - frontend-frameworks
  - idea-map
  - releases
source_pages:
  - raw/frontend-frameworks-public/registry.json
  - raw/frontend-frameworks-public/manifest.json
---

# Frontend Framework Idea Map

This page explains what each captured framework project is trying to do and preserves high-signal release ideas for retrieval.

$ideaSections

## Related

- [[frontend-frameworks-public]]
- [[frontend-framework-taxonomy]]

## Counterpoints And Gaps

- AMBIGUOUS: Release idea bullets are extracted summaries from GitHub release bodies and may omit lower-signal fixes or package-specific context.
- INFERRED: Repository summaries come from README/changelog snippets and metadata; use canonical GitHub links for full current project intent.
"@
Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\frontend-framework-idea-map.md") $ideaContent | Out-Null

$sourceContent = @"
---
title: 2026-05-16 Frontend Frameworks Public Corpus
type: source
status: active
created: $today
updated: $today
tags:
  - frontend-frameworks
  - public-corpus
  - github
---

# 2026-05-16 Frontend Frameworks Public Corpus

## Provenance

- Registry: `raw/frontend-frameworks-public/registry.json`
- Manifest: `raw/frontend-frameworks-public/manifest.json`
- Daily capture: `raw/frontend-frameworks-public/inbox/$today-$($Mode.ToLowerInvariant()).json`
- GitHub API repository, language, tree, and release endpoints.

## Snapshot

- Mode: `$Mode`
- Frameworks: $($registry.frameworks.Count)
- Official repositories captured: $($repoEntries.Count)
- Releases captured: $($releaseEntries.Count)
- Candidate repositories recorded: $($candidateEntries.Count)
- New entries this run: $($newEntries.Count)
- Changed semantic entries this run: $($updatedEntries.Count)
- Removed entries this run: $($removedEntries.Count)
- Crawl errors recorded: $($errors.Count)

## Public Handling

- EXTRACTED: Public pages record GitHub metadata, summaries, release idea bullets, hashes, and canonical links.
- INFERRED: Full source code and long release bodies remain outside the public wiki unless a future license-aware mirror policy is added.
- AMBIGUOUS: Candidate repositories require human registry review before promotion.

## Related

- [[frontend-frameworks-public]]
- [[frontend-framework-taxonomy]]
- [[frontend-framework-idea-map]]
"@
Write-TextIfChanged (Join-Path $rootPath "wiki\sources\2026-05-16-frontend-frameworks-public-corpus.md") $sourceContent | Out-Null

$homePath = Join-Path $rootPath "wiki\home.md"
if (Test-Path -LiteralPath $homePath) {
    $homeText = Read-TextFile $homePath
    $homeLine = "- [[frontend-frameworks-public]] - Curated public corpus for mainstream and innovative frontend frameworks, GitHub repos, releases, and idea maps."
    if ($homeText -notmatch [regex]::Escape($homeLine)) {
        $homeText = $homeText -replace "(## Knowledge Shortcuts)", "## Knowledge Shortcuts`n`n$homeLine"
        Write-TextIfChanged $homePath $homeText | Out-Null
    }
}

$indexPath = Join-Path $rootPath "wiki\index.md"
if (Test-Path -LiteralPath $indexPath) {
    $indexText = Read-TextFile $indexPath
    $indexText = Add-OrReplaceIndexLine $indexText "## Topics" "- [[frontend-frameworks-public]] - Curated public corpus for mainstream and innovative frontend frameworks, official GitHub repositories, releases, languages, and idea maps."
    $indexText = Add-OrReplaceIndexLine $indexText "## Sources" "- [[2026-05-16-frontend-frameworks-public-corpus]] - Batch ingest of frontend framework GitHub repositories, release summaries, language profiles, and candidate discovery."
    $indexText = Add-OrReplaceIndexLine $indexText "## Analyses" "- [[frontend-framework-taxonomy]] - Category map of captured frontend framework repositories by ecosystem role."
    $indexText = Add-OrReplaceIndexLine $indexText "## Analyses" "- [[frontend-framework-idea-map]] - Idea and release map for captured frontend frameworks."
    $entityIndexLines = @($registry.frameworks | Sort-Object name | ForEach-Object {
        "- [[entities/frontend-frameworks/{0}|{1}]] - Framework entity page for curated repos, latest captured releases, and navigation." -f $_.slug, $_.name
    }) -join "`n"
    $repoIndexLines = @($repoEntries | Sort-Object repo_full_name | ForEach-Object {
        "- [[sources/frontend-frameworks/{0}|{1}]] - GitHub repo source page for {2}, language profile, release pointer, hashes, and metadata." -f $_.page_slug, $_.repo_full_name, ($_.framework_names -join ", ")
    }) -join "`n"
    $releaseIndexLines = @($releaseEntries | Sort-Object repo_full_name, tag_name | ForEach-Object {
        "- [[sources/frontend-frameworks/releases/{0}|{1} {2}]] - Captured GitHub release summary and body hash." -f $_.page_slug, $_.repo_full_name, $_.tag_name
    }) -join "`n"
    $generatedIndex = @"
## Frontend Framework Corpus Generated Pages

### Framework Entities

$entityIndexLines

### Repository Sources

$repoIndexLines

### Release Sources

$releaseIndexLines
"@
    $indexText = Set-GeneratedIndexSection $indexText $generatedIndex
    Write-TextIfChanged $indexPath $indexText | Out-Null
}

$logPath = Join-Path $rootPath "wiki\log.md"
if (Test-Path -LiteralPath $logPath) {
    $logText = Read-TextFile $logPath
    $logEntry = @"
## [$now] ingest | frontend frameworks public corpus

- Pages created or updated:
  - [[frontend-frameworks-public]]
  - [[2026-05-16-frontend-frameworks-public-corpus]]
  - [[frontend-framework-taxonomy]]
  - [[frontend-framework-idea-map]]
  - `wiki/entities/frontend-frameworks/`
  - `wiki/sources/frontend-frameworks/`
- Sources used:
  - GitHub repository, language, tree, and release APIs for the curated registry in `raw/frontend-frameworks-public/registry.json`
- Notes:
  - Captured $($registry.frameworks.Count) frameworks, $($repoEntries.Count) official repositories, $($releaseEntries.Count) release records, and $($candidateEntries.Count) candidate repositories.
  - New entries this run: $($newEntries.Count).
  - Changed semantic entries this run: $($updatedEntries.Count).
  - Removed entries this run: $($removedEntries.Count).
  - Crawl errors recorded: $($errors.Count).

"@
    if ($logText -notmatch 'ingest \| frontend frameworks public corpus') {
        Write-TextIfChanged $logPath ($logEntry + $logText.TrimStart()) | Out-Null
    }
}

$manifestEntries = @($entries | Sort-Object source_kind, framework_slug, id)
$manifest = [pscustomobject]@{
    schema = "frontend-frameworks-public-corpus-v1"
    generated_at = if (($newEntries.Count -gt 0) -or ($updatedEntries.Count -gt 0) -or -not (Test-Path -LiteralPath $manifestPath)) { $runStamp } elseif ($oldManifest -and $oldManifest.generated_at) { $oldManifest.generated_at } else { $runStamp }
    mode = $Mode
    public_handling = "Public wiki pages contain metadata, summaries, release idea bullets, hashes, language profiles, and links only; full source code and long unlicensed release text are not mirrored publicly."
    registry_path = "raw/frontend-frameworks-public/registry.json"
    entry_count = $manifestEntries.Count
    framework_count = $registry.frameworks.Count
    repo_count = $repoEntries.Count
    release_count = $releaseEntries.Count
    candidate_count = $candidateEntries.Count
    new_entries_this_run = $newEntries.Count
    changed_entries_this_run = $updatedEntries.Count
    removed_entries_this_run = $removedEntries.Count
    errors = @($errors)
    entries = @($manifestEntries)
}
Write-TextIfChanged $manifestPath ($manifest | ConvertTo-Json -Depth 35) | Out-Null

$capture = [pscustomobject]@{
    schema = "frontend-frameworks-public-capture-v1"
    captured_at = $runStamp
    mode = $Mode
    registry_path = "raw/frontend-frameworks-public/registry.json"
    new_entries = @($newEntries.id)
    updated_entries = @($updatedEntries.id)
    errors = @($errors)
    entries = @($manifestEntries)
}
Write-TextIfChanged (Join-Path $inboxDir "$today-$($Mode.ToLowerInvariant()).json") ($capture | ConvertTo-Json -Depth 35) | Out-Null

if (-not $SkipValidation -and -not $DryRun) {
    & powershell -ExecutionPolicy Bypass -File (Join-Path $rootPath "scripts\wiki-catalog.ps1") | Out-Null
    & powershell -ExecutionPolicy Bypass -File (Join-Path $rootPath "scripts\wiki-lint.ps1") | Out-Null
}

[pscustomobject]@{
    Mode = $Mode
    Frameworks = $registry.frameworks.Count
    Repositories = $repoEntries.Count
    Releases = $releaseEntries.Count
    Candidates = $candidateEntries.Count
    NewEntries = $newEntries.Count
    UpdatedEntries = $updatedEntries.Count
    RemovedEntries = $removedEntries.Count
    Errors = $errors.Count
    ManifestPath = $manifestPath
}
