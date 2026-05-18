param(
    [ValidateSet("ysymyth", "alfredyao", "All")]
    [string]$Person = "All",
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
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$userAgent = "vipin-wiki-shunyu-yao-ingest"
$githubToken = if ($env:GITHUB_TOKEN) {
    $env:GITHUB_TOKEN
} elseif ($env:GH_TOKEN) {
    $env:GH_TOKEN
} elseif ([Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "User")) {
    [Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "User")
} elseif ([Environment]::GetEnvironmentVariable("GH_TOKEN", "User")) {
    [Environment]::GetEnvironmentVariable("GH_TOKEN", "User")
} elseif ([Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "Machine")) {
    [Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "Machine")
} elseif ([Environment]::GetEnvironmentVariable("GH_TOKEN", "Machine")) {
    [Environment]::GetEnvironmentVariable("GH_TOKEN", "Machine")
} else {
    ""
}

$people = @{
    ysymyth = [pscustomobject]@{
        key = "ysymyth"
        display_name = "Yao Shunyu / Shunyu Yao / ysymyth"
        chinese_name = "Yao Shunyu (Chinese: ysymyth homepage)"
        entity_page = "wiki/entities/yao-shunyu-ysymyth.md"
        raw_dir = "raw/yao-shunyu-ysymyth"
        item_dir = "wiki/sources/shunyu-yao/ysymyth"
        homepage = "https://ysymyth.github.io/"
        blog = "https://ysymyth.github.io/blog/"
        github_login = "ysymyth"
        scholar = "https://scholar.google.com/citations?user=qJBXk9cAAAAJ"
        twitter = "https://www.twitter.com/ShunyuYao12"
        role = "OpenAI researcher focused on language agents and digital automation."
        do_not_confuse = "Do not confuse with yao-shunyu-alfred, the physics-to-AI researcher at alfredyao.github.io."
    }
    alfredyao = [pscustomobject]@{
        key = "alfredyao"
        display_name = "Dr. Shunyu Yao / alfredyao"
        chinese_name = "Yao Shunyu (Chinese: alfredyao corpus)"
        entity_page = "wiki/entities/yao-shunyu-alfred.md"
        raw_dir = "raw/yao-shunyu-alfred"
        item_dir = "wiki/sources/shunyu-yao/alfredyao"
        homepage = "https://alfredyao.github.io/"
        blog = ""
        github_login = "alfredyao"
        scholar = ""
        twitter = ""
        cv = "https://alfredyao.github.io/Shunyu_Yao_CV.pdf"
        role = "Google DeepMind / Anthropic physics-to-AI researcher focused on quantum physics, RL, and agentic coding."
        do_not_confuse = "Do not confuse with yao-shunyu-ysymyth, the OpenAI language-agents researcher at ysymyth.github.io."
    }
}

function Get-GitHubHtmlRepoNames([string]$Login, [System.Collections.Generic.List[string]]$Errors) {
    try {
        $html = Invoke-WebText "https://github.com/$Login`?tab=repositories"
        $names = [regex]::Matches($html, "href=""/$Login/([^""/?#]+)""") |
            ForEach-Object { $_.Groups[1].Value } |
            Where-Object { $_ -notmatch '^(followers|following|stars|repositories)$' } |
            Sort-Object -Unique
        return @($names)
    }
    catch {
        $Errors.Add("GitHub HTML repo listing failed for $Login`: $($_.Exception.Message)")
        return @()
    }
}

function Get-PlainText([string]$Html) {
    $plain = $Html -replace '(?s)<script.*?</script>', ' '
    $plain = $plain -replace '(?s)<style.*?</style>', ' '
    $plain = $plain -replace '<[^>]+>', ' '
    $plain = [System.Net.WebUtility]::HtmlDecode($plain)
    return (($plain -replace '\s+', ' ').Trim())
}

function Get-Links([string]$Html, [string]$BaseUrl) {
    $links = New-Object System.Collections.Generic.List[object]
    foreach ($m in [regex]::Matches($Html, '<a\s+[^>]*href=["'']([^"'']+)["''][^>]*>(.*?)</a>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
        $href = [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
        $label = Get-PlainText $m.Groups[2].Value
        if ([string]::IsNullOrWhiteSpace($href) -or $href.StartsWith("mailto:") -or $href.StartsWith("#")) { continue }
        try {
            $uri = [System.Uri]::new([System.Uri]::new($BaseUrl), $href)
            $links.Add([pscustomobject]@{ url = $uri.AbsoluteUri; label = $label })
        }
        catch {
            continue
        }
    }
    return @($links | Sort-Object url -Unique)
}

function Get-ArxivId([string]$Url) {
    $m = [regex]::Match($Url, 'arxiv\.org/(?:abs|pdf)/([0-9]{4}\.[0-9]{4,5})(v\d+)?', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($m.Success) { return $m.Groups[1].Value }
    return ""
}

function Get-Doi([string]$Url) {
    $m = [regex]::Match($Url, '10\.\d{4,9}/[-._;()/:A-Z0-9]+', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($m.Success) { return $m.Value }
    return ""
}

function Get-ArxivMetadata([string]$ArxivId) {
    try {
        [xml]$xml = Invoke-WebText "https://export.arxiv.org/api/query?id_list=$ArxivId"
        $item = @($xml.feed.entry) | Select-Object -First 1
        if ($item) {
            return [pscustomobject]@{
                title = (($item.title -replace '\s+', ' ').Trim())
                summary = Get-PlainSummary ([string]$item.summary) 520
                published = [string]$item.published
                authors = @($item.author | ForEach-Object { [string]$_.name })
            }
        }
    }
    catch {
    }
    return $null
}

function Get-CategoryInfo([string]$PersonKey, [string]$Text, [string]$Kind) {
    $p = (($Text, $Kind) -join " ").ToLowerInvariant()
    if ($p -match 'swe|software engineering|github issue|coding|agentic coding') { return @{ Category = "Software engineering agents and benchmarks"; Tags = @("shunyu-yao", $PersonKey, "software-agents") } }
    if ($p -match 'agent|react|tree of thoughts|tot|computer-using|deep research|digital automation|language agents|coala') { return @{ Category = "Language agents / agent architectures"; Tags = @("shunyu-yao", $PersonKey, "language-agents") } }
    if ($p -match 'tool|webshop|intercode|tau-bench|interaction|computer use|user') { return @{ Category = "Tool use / computer use / digital automation"; Tags = @("shunyu-yao", $PersonKey, "tool-use") } }
    if ($p -match 'benchmark|evaluation|eval|bench') { return @{ Category = "Evaluation / benchmark design"; Tags = @("shunyu-yao", $PersonKey, "evaluation") } }
    if ($p -match 'reinforcement|rl|policy|control|behavior cloning') { return @{ Category = "Reinforcement learning and reasoning"; Tags = @("shunyu-yao", $PersonKey, "reinforcement-learning") } }
    if ($p -match 'web|human|user simulation|interaction') { return @{ Category = "Human-agent interaction / user simulation"; Tags = @("shunyu-yao", $PersonKey, "human-agent-interaction") } }
    if ($p -match 'black hole|gravity|scramblon|chaos|holograph|quantum') { return @{ Category = "Quantum chaos / quantum gravity"; Tags = @("shunyu-yao", $PersonKey, "quantum-physics") } }
    if ($p -match 'non-hermitian|skin effect|condensed matter|topolog') { return @{ Category = "Non-Hermitian topology / condensed matter"; Tags = @("shunyu-yao", $PersonKey, "condensed-matter") } }
    if ($p -match 'deepmind|anthropic|physics.*ai|ai researcher') { return @{ Category = "Physics-to-AI research transition"; Tags = @("shunyu-yao", $PersonKey, "physics-to-ai") } }
    if ($p -match 'post|blog|thought|writing|infant year') { return @{ Category = "Public essays / research philosophy"; Tags = @("shunyu-yao", $PersonKey, "public-writing") } }
    return @{ Category = if ($PersonKey -eq "alfredyao") { "Physics-to-AI research transition" } else { "Language agents / agent architectures" }; Tags = @("shunyu-yao", $PersonKey) }
}

function Get-Teaching([string]$Category) {
    switch ($Category) {
        "Language agents / agent architectures" { return "How language models become agents through reasoning, acting, memory, tools, and interface design." }
        "Tool use / computer use / digital automation" { return "How to evaluate and build agents that interact with real software, web environments, and user-facing tasks." }
        "Software engineering agents and benchmarks" { return "How coding agents are benchmarked, scaffolded, and constrained against real repositories and issues." }
        "Evaluation / benchmark design" { return "How to turn agent behavior into measurable tasks, success criteria, and repeatable benchmark environments." }
        "Reinforcement learning and reasoning" { return "How learning, planning, and feedback loops shape agent behavior and model capability." }
        "Human-agent interaction / user simulation" { return "How user goals, interaction protocols, and task environments change what an agent must optimize." }
        "Quantum chaos / quantum gravity" { return "How quantum chaos and gravity concepts connect to information dynamics, scrambling, and theoretical physics." }
        "Non-Hermitian topology / condensed matter" { return "How open/non-Hermitian systems alter topology, spectra, and boundary behavior." }
        "Physics-to-AI research transition" { return "How a physics research background transfers into frontier AI, RL, and agentic coding work." }
        default { return "A public item in the Shunyu Yao corpora that should be interpreted with source provenance and identity separation." }
    }
}

function Get-WikiPageForEntry([object]$Entry, [object]$Cfg) {
    $prefix = if ($Entry.source_kind -match "github") { "github" } elseif ($Entry.source_kind -match "paper|cv") { "paper" } elseif ($Entry.source_kind -match "talk") { "talk" } elseif ($Entry.source_kind -match "post|blog") { "post" } elseif ($Entry.source_kind -match "project") { "project" } else { "source" }
    $slug = ConvertTo-Slug ($Entry.title)
    $idHash = (Get-Sha256Text $Entry.id).Substring(0, 10)
    return "$($Cfg.item_dir)/$prefix-$slug-$idHash.md"
}

function Get-LinkTitle([string]$Label, [string]$Url, [string]$FallbackPrefix) {
    $generic = @("paper", "repo", "code", "project", "tweet", "blog", "blogpost", "product", "system card", "bibtex", "slides", "talk", "demo", "item", "read article")
    $clean = (($Label -replace '\s+', ' ').Trim())
    if ([string]::IsNullOrWhiteSpace($clean) -or $generic -contains $clean.ToLowerInvariant()) {
        $known = @{
            "https://cdn.openai.com/operator_system_card.pdf" = "Computer-Using Agent system card"
            "https://swe-agent.com/paper.pdf" = "SWE-agent paper"
            "https://operator.chatgpt.com/" = "Computer-Using Agent product"
            "https://openai.com/index/computer-using-agent/" = "Computer-Using Agent blogpost"
            "https://openai.com/index/introducing-deep-research/" = "Deep Research blogpost"
            "http://cdn.openai.com/cua/cua2025.bib" = "Computer-Using Agent BibTeX"
            "https://react-lm.github.io/" = "ReAct project"
            "http://www.swe-agent.com/" = "SWE-agent project"
            "http://www.swebench.com/" = "SWE-bench project"
            "https://intercode-benchmark.github.io/" = "InterCode project"
            "https://webshop-pnlp.github.io/" = "WebShop project"
            "https://webshop-pnlp.github.io/#demo" = "WebShop demo"
        }
        if ($known.ContainsKey($Url)) { return $known[$Url] }
        try {
            $uri = [System.Uri]$Url
            $path = ($uri.AbsolutePath.Trim('/') -replace '\.(pdf|html|htm)$', '')
            if ([string]::IsNullOrWhiteSpace($path)) { $path = $uri.Host }
            $leaf = (($path -split '/')[-1] -replace '[-_]+', ' ').Trim()
            if ([string]::IsNullOrWhiteSpace($leaf)) { $leaf = $path -replace '[-_\/]+', ' ' }
            if ($FallbackPrefix -eq "project-or-public-release") { return $leaf }
            return "$FallbackPrefix $leaf"
        }
        catch {
            if ($FallbackPrefix -eq "project-or-public-release") { return $clean }
            return "$FallbackPrefix $clean"
        }
    }
    return $clean
}

function New-Entry([object]$Cfg, [string]$Id, [string]$Kind, [string]$Url, [string]$Title, [string]$Summary, [string]$Date, [string]$License, [object]$Extra, [hashtable]$OldById) {
    $cat = Get-CategoryInfo $Cfg.key (($Title, $Summary, $Url) -join " ") $Kind
    $semanticPayload = [pscustomobject]@{
        id = $Id
        person_key = $Cfg.key
        kind = $Kind
        url = $Url
        title = $Title
        summary = $Summary
        date = $Date
        license = $License
        category = $cat.Category
    } | ConvertTo-Json -Depth 8 -Compress
    $hash = Get-Sha256Text $semanticPayload
    $firstSeen = if ($OldById.ContainsKey($Id) -and $OldById[$Id].first_seen) { $OldById[$Id].first_seen } else { $today }
    $lastChanged = if ($OldById.ContainsKey($Id) -and $OldById[$Id].semantic_hash -eq $hash -and $OldById[$Id].last_changed) { $OldById[$Id].last_changed } else { $today }
    $entry = [pscustomobject]@{
        id = $Id
        person_key = $Cfg.key
        source_kind = $Kind
        canonical_url = $Url
        title = $Title
        authors_or_owners = @()
        venue_or_context = ""
        published_or_updated = $Date
        repo_path = ""
        license = if ($License) { $License } else { "NOASSERTION" }
        content_hash = $hash
        semantic_hash = $hash
        first_seen = $firstSeen
        last_seen = if ($OldById.ContainsKey($Id) -and $OldById[$Id].semantic_hash -eq $hash -and $OldById[$Id].last_seen) { $OldById[$Id].last_seen } else { $today }
        last_changed = $lastChanged
        category = $cat.Category
        tags = $cat.Tags
        summary = $Summary
        what_it_teaches = Get-Teaching $cat.Category
        wiki_page = ""
        public_handling = "public-metadata-summary-hash-link-only"
        source_confidence = "public-source"
        crawl_errors = @()
        extra = $Extra
    }
    $entry.wiki_page = Get-WikiPageForEntry $entry $Cfg
    return $entry
}

function Add-UniqueEntry([System.Collections.Generic.List[object]]$Entries, [object]$Entry) {
    if ($null -eq $Entry) { return }
    if (-not ($Entries | Where-Object { $_.id -eq $Entry.id })) { $Entries.Add($Entry) }
}

function Get-OldManifest([string]$Path) {
    $oldById = @{}
    $oldManifest = $null
    if (Test-Path -LiteralPath $Path) {
        try {
            $oldManifest = Read-TextFile $Path | ConvertFrom-Json
            foreach ($e in @($oldManifest.entries)) { $oldById[$e.id] = $e }
        }
        catch {
            $oldManifest = $null
        }
    }
    return @{ Manifest = $oldManifest; ById = $oldById }
}

function Get-GitHubRepos([string]$Login, [System.Collections.Generic.List[string]]$Errors) {
    try {
        $repos = Invoke-WebJson "https://api.github.com/users/$Login/repos?per_page=100&sort=updated"
        if ($null -ne $repos.PSObject.Properties["value"]) { return @($repos.value) }
        return @($repos)
    }
    catch {
        $Errors.Add("GitHub repos failed for $Login`: $($_.Exception.Message)")
        return @()
    }
}

function Get-GitHubUser([string]$Login, [System.Collections.Generic.List[string]]$Errors) {
    try { return Invoke-WebJson "https://api.github.com/users/$Login" }
    catch {
        $Errors.Add("GitHub user failed for $Login`: $($_.Exception.Message)")
        return $null
    }
}

function Get-RepoReadmeSummary([object]$Repo) {
    try {
        $headers = Get-WebHeaders "https://api.github.com/repos/$($Repo.full_name)/readme" @{ "Accept" = "application/vnd.github.raw" }
        $readme = (Invoke-WebRequest -Uri "https://api.github.com/repos/$($Repo.full_name)/readme" -Headers $headers -UseBasicParsing -TimeoutSec 45).Content
        return Get-PlainSummary $readme 520
    }
    catch {
        if ($Repo.description) { return [string]$Repo.description }
        return "GitHub repository metadata was available, but README text was not available during this crawl."
    }
}

function New-GitHubRepoEntries([object]$Cfg, [hashtable]$OldById, [System.Collections.Generic.List[string]]$Errors) {
    $out = @()
    $user = Get-GitHubUser $Cfg.github_login $Errors
    if ($user) {
        $out += (New-Entry $Cfg "person:$($Cfg.key)" "person-profile" $Cfg.homepage $Cfg.display_name $Cfg.role "" "NOASSERTION" ([pscustomobject]@{ github = $user.html_url; scholar = $Cfg.scholar }) $OldById)
    }
    $repos = @(Get-GitHubRepos $Cfg.github_login $Errors)
    if ($repos.Count -eq 0) {
        foreach ($name in (Get-GitHubHtmlRepoNames $Cfg.github_login $Errors)) {
            $repos += [pscustomobject]@{
                full_name = "$($Cfg.github_login)/$name"
                html_url = "https://github.com/$($Cfg.github_login)/$name"
                description = ""
                updated_at = ""
                license = $null
                stargazers_count = $null
                forks_count = $null
                language = ""
                topics = @()
                default_branch = ""
                homepage = ""
                owner = [pscustomobject]@{ login = $Cfg.github_login }
            }
        }
    }
    foreach ($repo in $repos) {
        $license = if ($repo.license -and $repo.license.spdx_id) { [string]$repo.license.spdx_id } else { "NOASSERTION" }
        $summary = if ($repo.description) { [string]$repo.description } else { "GitHub repository discovered for $($repo.full_name). README/full source is not mirrored publicly unless license-safe." }
        $extra = [pscustomobject]@{
            stars = $repo.stargazers_count
            forks = $repo.forks_count
            language = $repo.language
            topics = @($repo.topics)
            default_branch = $repo.default_branch
            homepage = $repo.homepage
        }
        $entry = New-Entry $Cfg "github:$($repo.full_name)" "github-repository" $repo.html_url $repo.full_name $summary $repo.updated_at $license $extra $OldById
        $entry.authors_or_owners = @($repo.owner.login)
        $entry.repo_path = $repo.full_name
        $entry.source_confidence = "github-api"
        if ($repo.updated_at -eq "") { $entry.source_confidence = "github-html-fallback" }
        if (-not ($out | Where-Object { $_.id -eq $entry.id })) { $out += $entry }
    }
    return @($out)
}

function New-LinkEntriesFromHomepage([object]$Cfg, [string]$Html, [hashtable]$OldById) {
    $out = @()
    $links = Get-Links $Html $Cfg.homepage
    foreach ($link in $links) {
        $url = [string]$link.url
        $label = if ($link.label) { [string]$link.label } else { $url }
        if ($url -match 'github\.com/([^/#?]+/[^/#?]+)') {
            $repoPath = $Matches[1].TrimEnd('/')
            $entry = New-Entry $Cfg "github:$repoPath" "linked-github-repository" $url $repoPath "Repository linked from the canonical homepage: $label." "" "NOASSERTION" ([pscustomobject]@{ homepage_label = $label }) $OldById
            if (-not ($out | Where-Object { $_.id -eq $entry.id })) { $out += $entry }
            continue
        }
        $arxiv = Get-ArxivId $url
        if ($arxiv) {
            $meta = Get-ArxivMetadata $arxiv
            $title = if ($meta -and $meta.title) { $meta.title } else { Get-LinkTitle $label $url "paper" }
            $summary = if ($meta -and $meta.summary) { $meta.summary } else { "Paper linked from the canonical homepage." }
            $date = if ($meta -and $meta.published) { $meta.published } else { "" }
            $entry = New-Entry $Cfg "paper:arxiv:$arxiv" "paper" "https://arxiv.org/abs/$arxiv" $title $summary $date "NOASSERTION" ([pscustomobject]@{ discovered_from = $Cfg.homepage; arxiv = $arxiv }) $OldById
            if ($meta -and $meta.authors) { $entry.authors_or_owners = @($meta.authors) }
            if (-not ($out | Where-Object { $_.id -eq $entry.id })) { $out += $entry }
            continue
        }
        $doi = Get-Doi $url
        if ($doi) {
            $title = Get-LinkTitle $label $url "paper"
            $entry = New-Entry $Cfg "paper:doi:$doi" "paper" $url $title "Paper or scholarly page linked from the canonical homepage." "" "NOASSERTION" ([pscustomobject]@{ discovered_from = $Cfg.homepage }) $OldById
            if (-not ($out | Where-Object { $_.id -eq $entry.id })) { $out += $entry }
            continue
        }
        if ($url -match '\.pdf($|\?)|/papers/|paper\.pdf') {
            $hash = (Get-Sha256Text $url).Substring(0, 16)
            $title = Get-LinkTitle $label $url "paper"
            $entry = New-Entry $Cfg "paper:url:$hash" "paper-or-pdf" $url $title "PDF or paper link discovered from the canonical homepage. Full PDF is not mirrored publicly unless license-safe." "" "NOASSERTION" ([pscustomobject]@{ discovered_from = $Cfg.homepage }) $OldById
            if (-not ($out | Where-Object { $_.id -eq $entry.id })) { $out += $entry }
            continue
        }
        if ($url -match 'youtube\.com|youtu\.be|bilibili\.com|presentation') {
            $hash = (Get-Sha256Text $url).Substring(0, 16)
            $title = Get-LinkTitle $label $url "talk"
            $entry = New-Entry $Cfg "talk:$hash" "talk-or-slides" $url $title "Talk or slides linked from the canonical homepage." "" "NOASSERTION" ([pscustomobject]@{ discovered_from = $Cfg.homepage }) $OldById
            if (-not ($out | Where-Object { $_.id -eq $entry.id })) { $out += $entry }
            continue
        }
        if ($url -match '/posts/|/blog/|openai\.com|anthropic\.com|deepmind|operator\.chatgpt|sierra\.ai|googleblog|microsoft\.com|quantamagazine|react-lm|swebench|swe-agent|webshop|intercode') {
            $hash = (Get-Sha256Text $url).Substring(0, 16)
            $kind = if ($url -match '/posts/|/blog/') { "post" } else { "project-or-public-release" }
            $title = Get-LinkTitle $label $url $kind
            $entry = New-Entry $Cfg "$kind`:$hash" $kind $url $title "Public project, release, blog, or supporting page linked from the canonical homepage." "" "NOASSERTION" ([pscustomobject]@{ discovered_from = $Cfg.homepage }) $OldById
            if (-not ($out | Where-Object { $_.id -eq $entry.id })) { $out += $entry }
            continue
        }
    }
    return @($out)
}

function Search-Arxiv([object]$Cfg, [hashtable]$OldById, [System.Collections.Generic.List[string]]$Errors) {
    $out = @()
    try {
        $query = [System.Uri]::EscapeDataString('au:"Shunyu Yao"')
        [xml]$xml = Invoke-WebText "https://export.arxiv.org/api/query?search_query=$query&start=0&max_results=50&sortBy=submittedDate&sortOrder=descending"
        foreach ($item in @($xml.feed.entry)) {
            $title = (($item.title -replace '\s+', ' ').Trim())
            $authors = @($item.author | ForEach-Object { [string]$_.name })
            $isYsymyth = ($title -match 'agent|language|SWE|ReAct|Tree of Thoughts|WebShop|InterCode|Reflexion|benchmark|Text|Emergent|computer')
            $isAlfred = ($title -match 'non-Hermitian|skin|scramblon|black hole|quantum|gravity|chaos|holograph|diffusion')
            if (($Cfg.key -eq "ysymyth" -and -not $isYsymyth) -or ($Cfg.key -eq "alfredyao" -and -not $isAlfred)) { continue }
            $idUrl = [string]$item.id
            $arxiv = Get-ArxivId $idUrl
            if (-not $arxiv) { continue }
            $summary = Get-PlainSummary ([string]$item.summary) 520
            $entry = New-Entry $Cfg "paper:arxiv:$arxiv" "paper" "https://arxiv.org/abs/$arxiv" $title $summary ([string]$item.published) "NOASSERTION" ([pscustomobject]@{ arxiv = $arxiv; updated = [string]$item.updated }) $OldById
            $entry.authors_or_owners = $authors
            $entry.source_confidence = "arxiv-api-keyword-disambiguated"
            if (-not ($out | Where-Object { $_.id -eq $entry.id })) { $out += $entry }
        }
    }
    catch {
        $Errors.Add("arXiv search failed for $($Cfg.key): $($_.Exception.Message)")
    }
    return @($out)
}

function New-ItemPage([object]$Entry, [object]$Cfg) {
    $tags = (($Entry.tags | Sort-Object -Unique | ForEach-Object { "  - $_" }) -join "`n")
    $sourcePages = "  - $($Entry.canonical_url)"
    $title = Escape-Yaml $Entry.title
    return @"
---
title: "$title"
type: source
status: active
created: $($Entry.first_seen)
updated: $($Entry.last_changed)
tags:
$tags
source_pages:
$sourcePages
---

# $($Entry.title)

## Source

- Person key: ``$($Entry.person_key)``
- Source kind: ``$($Entry.source_kind)``
- Canonical URL: $($Entry.canonical_url)
- License: ``$($Entry.license)``
- Public handling: ``$($Entry.public_handling)``
- Semantic hash: ``$($Entry.semantic_hash)``
- First seen: $($Entry.first_seen)
- Last changed: $($Entry.last_changed)
- Identity guard: $($Cfg.do_not_confuse)

## Classification

- Category: $($Entry.category)
- Topic hub: [[shunyu-yao-public-corpora]]
- Project taxonomy: [[shunyu-yao-project-taxonomy]]
- Paper map: [[shunyu-yao-paper-map]]

## Summary

$($Entry.summary)

## What This Teaches

$($Entry.what_it_teaches)

## Related

- [[shunyu-yao-public-corpora]]
- [[2026-05-16-yao-shunyu-public-corpora]]

## Public Handling Notes

- EXTRACTED: Metadata and links are from public sources.
- INFERRED: Unclear-license full text, PDFs, and source code should not be mirrored into public wiki pages.
- AMBIGUOUS: Items discovered by keyword search are still separated by source identity and category heuristics.
"@
}

function Build-PersonCorpus([object]$Cfg) {
    $rawAbs = Join-Path $rootPath $Cfg.raw_dir
    $itemAbs = Join-Path $rootPath $Cfg.item_dir
    Ensure-Dir $rawAbs
    Ensure-Dir $itemAbs
    $manifestPath = Join-Path $rawAbs "manifest.json"
    $old = Get-OldManifest $manifestPath
    $oldById = $old.ById
    $oldManifest = $old.Manifest
    $errors = New-Object System.Collections.Generic.List[string]
    $entries = New-Object System.Collections.Generic.List[object]
    $homeHtml = ""
    try {
        $homeHtml = Invoke-WebText $Cfg.homepage
        Add-UniqueEntry $entries (New-Entry $Cfg "homepage:$($Cfg.key)" "canonical-homepage" $Cfg.homepage $Cfg.display_name (Get-PlainSummary $homeHtml 520) "" "NOASSERTION" ([pscustomobject]@{ homepage = $Cfg.homepage }) $oldById)
        foreach ($entry in (New-GitHubRepoEntries $Cfg $oldById $errors)) { Add-UniqueEntry $entries $entry }
        foreach ($entry in (New-LinkEntriesFromHomepage $Cfg $homeHtml $oldById)) { Add-UniqueEntry $entries $entry }
    }
    catch {
        $errors.Add("Homepage crawl failed for $($Cfg.key): $($_.Exception.Message)")
    }

    if ($Cfg.blog) {
        try {
            $blogHtml = Invoke-WebText $Cfg.blog
            Add-UniqueEntry $entries (New-Entry $Cfg "post:index:$($Cfg.key)" "blog-index" $Cfg.blog "$($Cfg.display_name) blog" (Get-PlainSummary $blogHtml 420) "" "NOASSERTION" ([pscustomobject]@{ blog = $Cfg.blog }) $oldById)
            foreach ($entry in (New-LinkEntriesFromHomepage $Cfg $blogHtml $oldById)) { Add-UniqueEntry $entries $entry }
        }
        catch {
            $errors.Add("Blog crawl failed for $($Cfg.key): $($_.Exception.Message)")
        }
    }
    if ($Cfg.cv) {
        Add-UniqueEntry $entries (New-Entry $Cfg "paper-or-cv:alfredyao-cv" "cv-pdf-metadata" $Cfg.cv "Shunyu Yao CV" "CV PDF linked from the canonical homepage; tracked as metadata and URL only, not mirrored as public full text." "" "NOASSERTION" ([pscustomobject]@{ discovered_from = $Cfg.homepage }) $oldById)
    }

    foreach ($entry in (Search-Arxiv $Cfg $oldById $errors)) { Add-UniqueEntry $entries $entry }

    $byId = @{}
    $unique = New-Object System.Collections.Generic.List[object]
    foreach ($entry in @($entries | Sort-Object id)) {
        if (-not $byId.ContainsKey($entry.id)) {
            $byId[$entry.id] = $entry
            $unique.Add($entry)
        }
    }
    $entries = $unique

    if ($errors.Count -gt 0 -and $oldById.Count -gt 0) {
        foreach ($oldId in @($oldById.Keys | Sort-Object)) {
            if (-not $byId.ContainsKey($oldId)) {
                $oldEntry = $oldById[$oldId]
                $byId[$oldId] = $oldEntry
                $entries.Add($oldEntry)
            }
        }
    }

    $newEntries = @($entries | Where-Object { -not $oldById.ContainsKey($_.id) })
    $updatedEntries = @($entries | Where-Object { $oldById.ContainsKey($_.id) -and $oldById[$_.id].semantic_hash -ne $_.semantic_hash })
    $removedEntries = @()
    foreach ($oldId in $oldById.Keys) {
        if (-not $byId.ContainsKey($oldId)) { $removedEntries += $oldById[$oldId] }
    }
    $hasChanges = ($newEntries.Count -gt 0 -or $updatedEntries.Count -gt 0 -or $removedEntries.Count -gt 0 -or -not (Test-Path -LiteralPath $manifestPath))

    $manifest = [pscustomobject]@{
        schema = "shunyu-yao-public-corpus-v1"
        person_key = $Cfg.key
        generated_at = if ($hasChanges -or -not $oldManifest) { $runStamp } elseif ($oldManifest.generated_at) { $oldManifest.generated_at } else { $runStamp }
        canonical_homepage = $Cfg.homepage
        github_login = $Cfg.github_login
        public_handling = "Public wiki pages contain metadata, summaries, links, hashes, and license notes. Unclear-license full PDFs, webpages, and source code are not mirrored wholesale."
        identity_guard = $Cfg.do_not_confuse
        entry_count = $entries.Count
        new_entries_this_run = $newEntries.Count
        changed_entries_this_run = $updatedEntries.Count
        removed_entries_this_run = $removedEntries.Count
        errors = @($errors)
        entries = @($entries | Sort-Object source_kind, category, title)
    }
    Write-TextIfChanged $manifestPath ($manifest | ConvertTo-Json -Depth 30) | Out-Null

    foreach ($entry in @($entries | Where-Object { $_.source_kind -notin @("person-profile") })) {
        Write-TextIfChanged (Join-Path $rootPath $entry.wiki_page) (New-ItemPage $entry $Cfg) | Out-Null
    }

    return [pscustomobject]@{
        person_key = $Cfg.key
        entry_count = $manifest.entry_count
        new_entries_this_run = $manifest.new_entries_this_run
        changed_entries_this_run = $manifest.changed_entries_this_run
        removed_entries_this_run = $manifest.removed_entries_this_run
        error_count = $manifest.errors.Count
        manifest_path = $manifestPath
    }
}

function Group-Lines([object[]]$Entries, [string]$Field) {
    return (($Entries | Group-Object $Field | Sort-Object Name) | ForEach-Object { "- $($_.Name): $($_.Count)" }) -join "`n"
}

function Link-Lines([object[]]$Entries, [string]$KindRegex) {
    $filtered = @($Entries | Where-Object { $_.source_kind -match $KindRegex } | Sort-Object person_key, title)
    if ($filtered.Count -eq 0) { return "- None discovered in this run." }
    return ($filtered | ForEach-Object {
        $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
        "- [[$wikiId|$(Convert-ToWikiAlias $_.title)]] - ``$($_.person_key)``, $($_.category)"
    }) -join "`n"
}

$selectedKeys = if ($Person -eq "All") { @("ysymyth", "alfredyao") } else { @($Person) }
$results = @()
foreach ($key in $selectedKeys) {
    $results += Build-PersonCorpus $people[$key]
}

if ($Person -eq "All" -and -not $DryRun) {
    $ysManifest = Read-TextFile (Join-Path $rootPath "raw/yao-shunyu-ysymyth/manifest.json") | ConvertFrom-Json
    $alManifest = Read-TextFile (Join-Path $rootPath "raw/yao-shunyu-alfred/manifest.json") | ConvertFrom-Json
    $allEntries = @(@($ysManifest.entries) + @($alManifest.entries))
    $ys = $ysManifest
    $al = $alManifest
    $sourcePage = "wiki/sources/2026-05-16-yao-shunyu-public-corpora.md"

    $entityY = @"
---
title: Yao Shunyu / Shunyu Yao / ysymyth
type: entity
status: active
created: 2026-05-16
updated: $today
tags:
  - shunyu-yao
  - ysymyth
  - language-agents
source_pages:
  - https://ysymyth.github.io/
  - https://github.com/ysymyth
---

# Yao Shunyu / Shunyu Yao / ysymyth

## Identity

- EXTRACTED: Chinese name on canonical homepage: Yao Shunyu, written in Chinese on the homepage.
- EXTRACTED: Canonical homepage: https://ysymyth.github.io/
- EXTRACTED: GitHub: https://github.com/ysymyth
- EXTRACTED: Current homepage states that he is a researcher at OpenAI and studies agents.
- Identity guard: Do not confuse this page with [[yao-shunyu-alfred]].

## Corpus Snapshot

- Manifest: ``raw/yao-shunyu-ysymyth/manifest.json``
- Entries: $($ys.entry_count)
- New entries this run: $($ys.new_entries_this_run)
- Changed entries this run: $($ys.changed_entries_this_run)
- Errors: $($ys.errors.Count)

## Research Shape

- Language agents, ReAct, Tree of Thoughts, WebShop, Reflexion, InterCode, SWE-bench, SWE-agent, tau-bench, CUA, and Deep Research.
- The important through-line is moving from next-token prediction toward agents that act through tools, interfaces, benchmarks, and real digital tasks.

## Related

- [[shunyu-yao-public-corpora]]
- [[shunyu-yao-project-taxonomy]]
- [[shunyu-yao-paper-map]]
- [[2026-05-16-yao-shunyu-public-corpora]]
"@

    $entityA = @"
---
title: Dr. Shunyu Yao / alfredyao
type: entity
status: active
created: 2026-05-16
updated: $today
tags:
  - shunyu-yao
  - alfredyao
  - physics-to-ai
source_pages:
  - https://alfredyao.github.io/
  - https://github.com/alfredyao
---

# Dr. Shunyu Yao / alfredyao

## Identity

- EXTRACTED: Canonical homepage title: Dr. Shunyu Yao | Physicist & AI Researcher.
- EXTRACTED: Canonical homepage: https://alfredyao.github.io/
- EXTRACTED: GitHub: https://github.com/alfredyao
- EXTRACTED: Homepage describes him as a Senior Staff Research Scientist at Google DeepMind and formerly a Research Scientist at Anthropic.
- Identity guard: Do not confuse this page with [[yao-shunyu-ysymyth]].

## Corpus Snapshot

- Manifest: ``raw/yao-shunyu-alfred/manifest.json``
- Entries: $($al.entry_count)
- New entries this run: $($al.new_entries_this_run)
- Changed entries this run: $($al.changed_entries_this_run)
- Errors: $($al.errors.Count)

## Research Shape

- Non-Hermitian skin effect, quantum chaos/gravity, scramblon theory, RL numerics, agentic coding, and physics-to-AI transition.
- The important through-line is translating theoretical physics habits into frontier AI, RL, and coding-agent systems.

## Related

- [[shunyu-yao-public-corpora]]
- [[shunyu-yao-project-taxonomy]]
- [[shunyu-yao-paper-map]]
- [[2026-05-16-yao-shunyu-public-corpora]]
"@

    $hub = @"
---
title: Shunyu Yao Public Corpora
type: topic
status: active
created: 2026-05-16
updated: $today
tags:
  - shunyu-yao
  - public-corpus
  - agents
  - physics-to-ai
source_pages:
  - https://ysymyth.github.io/
  - https://alfredyao.github.io/
---

# Shunyu Yao Public Corpora

This hub tracks two different public people who are both written as Shunyu Yao in English.

## Identity Guard

- [[yao-shunyu-ysymyth]] is the ysymyth identity: OpenAI, language agents, ReAct, ToT, SWE-agent, SWE-bench, tau-bench, CUA, Deep Research.
- [[yao-shunyu-alfred]] is the alfredyao identity: Google DeepMind / Anthropic, physics-to-AI, quantum physics, RL, agentic coding, non-Hermitian skin effect.
- Future agents must keep separate manifests, item pages, and source claims for the two corpora.

## Corpus Shape

$(Group-Lines $allEntries "person_key")

## Source Kinds

$(Group-Lines $allEntries "source_kind")

## Maintenance Rules

- Use stable IDs and ``semantic_hash`` for no-noise updates.
- Do not mirror unclear-license full PDFs, webpages, or code into public wiki pages.
- Prefer metadata, summaries, source URLs, hashes, categories, and license notes.
- When another same-name Shunyu Yao appears, create a new identity key rather than merging records.

## Related

- [[2026-05-16-yao-shunyu-public-corpora]]
- [[shunyu-yao-project-taxonomy]]
- [[shunyu-yao-paper-map]]
- [[public-corpus-ingest-workflow]]

## Counterpoints And Gaps

- This hub is an index and routing surface, not a substitute for reading the item pages and source URLs.
- GitHub API access can be rate-limited; ``scripts/ingest-shunyu-yao-public.ps1`` uses ``GITHUB_TOKEN`` or ``GH_TOKEN`` when available, then falls back to the public GitHub HTML repository listing if API access still fails.
"@

    $source = @"
---
title: 2026-05-16 Yao Shunyu Public Corpora
type: source
status: active
created: 2026-05-16
updated: $today
tags:
  - shunyu-yao
  - public-corpus
  - batch-ingest
source_pages:
  - https://ysymyth.github.io/
  - https://github.com/ysymyth
  - https://alfredyao.github.io/
  - https://github.com/alfredyao
---

# 2026-05-16 Yao Shunyu Public Corpora

## Provenance

- ysymyth homepage: https://ysymyth.github.io/
- ysymyth GitHub API: https://api.github.com/users/ysymyth
- alfredyao homepage: https://alfredyao.github.io/
- alfredyao GitHub API: https://api.github.com/users/alfredyao
- alfredyao CV pointer: https://alfredyao.github.io/Shunyu_Yao_CV.pdf
- arXiv API query: author ``Shunyu Yao`` with identity/category filters.
- GitHub API calls should use ``GITHUB_TOKEN`` or ``GH_TOKEN`` from the process, user, or machine environment; this raises the rate limit and keeps repository metadata source confidence at ``github-api``.

## Snapshot

- ``ysymyth`` entries: $($ys.entry_count), new $($ys.new_entries_this_run), changed $($ys.changed_entries_this_run), errors $($ys.errors.Count).
- ``alfredyao`` entries: $($al.entry_count), new $($al.new_entries_this_run), changed $($al.changed_entries_this_run), errors $($al.errors.Count).

## Public Handling

- EXTRACTED: Public metadata, URLs, repo license metadata, page summaries, and hashes are safe for public wiki indexing.
- INFERRED: Unclear-license full PDFs, source code, and webpage text are not mirrored wholesale.
- AMBIGUOUS: arXiv author search can mix same-name authors; entries are filtered by title/category and identity context.

## Related

- [[yao-shunyu-ysymyth]]
- [[yao-shunyu-alfred]]
- [[shunyu-yao-public-corpora]]
- [[shunyu-yao-project-taxonomy]]
- [[shunyu-yao-paper-map]]

## Counterpoints And Gaps

- arXiv author search can include same-name collisions, so the ingest applies category and title filters.
- Google Scholar is recorded as a pointer when available but is not treated as a stable machine-readable source.
"@

    $projects = @"
---
title: Shunyu Yao Project Taxonomy
type: analysis
status: active
created: 2026-05-16
updated: $today
tags:
  - shunyu-yao
  - project-taxonomy
source_pages:
  - https://ysymyth.github.io/
  - https://alfredyao.github.io/
---

# Shunyu Yao Project Taxonomy

## Source Kinds

$(Group-Lines $allEntries "source_kind")

## Categories

$(Group-Lines $allEntries "category")

## Repositories And Projects

$(Link-Lines $allEntries "github|project")

## Related

- [[shunyu-yao-public-corpora]]
- [[shunyu-yao-paper-map]]
- [[2026-05-16-yao-shunyu-public-corpora]]

## Counterpoints And Gaps

- Project pages may be discovered from homepage links even when GitHub API is temporarily rate-limited.
- Repo README/source content is summarized conservatively; unclear-license source is not mirrored wholesale.
"@

    $papers = @"
---
title: Shunyu Yao Paper Map
type: analysis
status: active
created: 2026-05-16
updated: $today
tags:
  - shunyu-yao
  - papers
  - research-map
source_pages:
  - https://ysymyth.github.io/
  - https://alfredyao.github.io/
---

# Shunyu Yao Paper Map

## Identity Guard

- ``ysymyth`` papers cluster around language agents, tool use, software-engineering agents, and agent benchmarks.
- ``alfredyao`` papers cluster around quantum physics, non-Hermitian topology, quantum chaos/gravity, and physics-to-AI transition.

## Papers, Theses, Talks, And Scholarly Pointers

$(Link-Lines $allEntries "paper|talk|cv")

## Categories

$(Group-Lines (@($allEntries | Where-Object { $_.source_kind -match "paper|talk|cv" })) "category")

## Related

- [[yao-shunyu-ysymyth]]
- [[yao-shunyu-alfred]]
- [[shunyu-yao-public-corpora]]
- [[shunyu-yao-project-taxonomy]]

## Counterpoints And Gaps

- Some homepage PDF links use generic labels; arXiv metadata is used when available to strengthen titles.
- Non-arXiv PDFs are indexed by URL and summary policy rather than mirrored as full public text.
"@

    $workflow = @"
---
title: Public Corpus Ingest Workflow
type: analysis
status: active
created: 2026-05-16
updated: $today
tags:
  - wiki-workflow
  - public-corpus
  - automation
source_pages:
  - AGENTS.md
  - wiki/sources/2026-05-16-yao-shunyu-public-corpora.md
---

# Public Corpus Ingest Workflow

Use this workflow when the user asks for a complete public corpus such as full GitHub, projects, public releases, papers, posts, and recurring updates.

## Trigger Pattern

- User asks for complete GitHub, all projects, all public releases, all papers, and recurring updates.
- User emphasizes that the corpus is important and future agents must remember the workflow.

## Required Steps

- Disambiguate same-name people before crawling.
- Create separate entity pages, manifests, raw directories, and source pages for distinct identities.
- Use stable item IDs and ``semantic_hash`` to prevent duplicate captures and noisy commits.
- Use safe public indexing: metadata, summaries, links, hashes, categories, and license notes.
- Do not publicly mirror unclear-license full PDFs, source code, or long webpage text.
- Add or update an automation that reruns the ingest, validates, commits scoped changes, and pushes.
- Treat automation outputs as official wiki maintenance. If a run changes raw manifests, source pages, topic pages, analysis pages, ``wiki/catalog.json``, ``wiki/index.md``, or ``wiki/log.md``, stage those scoped outputs, commit them, and push after validation.

## Validation

- Run manifest duplicate checks.
- Run ``scripts/wiki-catalog.ps1``, ``scripts/wiki-lint.ps1``, and ``git diff --check``.
- Ignore unrelated local changes such as ``GetPdf.pdf`` unless the user explicitly asks otherwise.
- Before committing, inspect ``git diff --stat`` and the relevant file diffs so generated changes are real content changes and do not leak private data.
- If ``git status`` reports automation-managed files as modified but hashes and ``git diff`` show no real content changes, treat it as false dirty state from line endings or index metadata. Refresh/normalize the index and report that there was no substantive automation output to commit.
- Never leave real automation output uncommitted at the end of the turn unless validation fails or the user explicitly asks to pause.

## Counterpoints And Gaps

- This workflow is a default pattern, not permission to ignore source-specific licenses or identity ambiguity.
- Some public platforms block automated access; record crawl errors and use stable fallback sources instead of inventing completeness.
- Automation commits still need scope discipline: do not stage unrelated local edits just because an automation run touched nearby wiki sections.
"@

    Write-TextIfChanged (Join-Path $rootPath "wiki/entities/yao-shunyu-ysymyth.md") $entityY | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki/entities/yao-shunyu-alfred.md") $entityA | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki/topics/shunyu-yao-public-corpora.md") $hub | Out-Null
    Write-TextIfChanged (Join-Path $rootPath $sourcePage) $source | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki/analyses/shunyu-yao-project-taxonomy.md") $projects | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki/analyses/shunyu-yao-paper-map.md") $papers | Out-Null
    Write-TextIfChanged (Join-Path $rootPath "wiki/analyses/public-corpus-ingest-workflow.md") $workflow | Out-Null

    $indexPath = Join-Path $rootPath "wiki/index.md"
    $indexText = Read-TextFile $indexPath
    $indexLines = @(
        @{ Heading = "## Entities"; Line = "- [[yao-shunyu-ysymyth]] - ysymyth public corpus for language agents, OpenAI work, ReAct, ToT, SWE-agent, SWE-bench, tau-bench, CUA, and Deep Research." },
        @{ Heading = "## Entities"; Line = "- [[yao-shunyu-alfred]] - alfredyao public corpus for physics-to-AI, Google DeepMind/Anthropic, quantum physics, RL, and agentic coding." },
        @{ Heading = "## Topics"; Line = "- [[shunyu-yao-public-corpora]] - Hub that keeps the two Shunyu Yao public corpora separate and searchable." },
        @{ Heading = "## Sources"; Line = "- [[2026-05-16-yao-shunyu-public-corpora]] - Batch ingest of the ysymyth and alfredyao public corpora." },
        @{ Heading = "## Analyses"; Line = "- [[shunyu-yao-project-taxonomy]] - Project and repository taxonomy across the two Shunyu Yao corpora." },
        @{ Heading = "## Analyses"; Line = "- [[shunyu-yao-paper-map]] - Paper, thesis, talk, and scholarly pointer map for the two Shunyu Yao corpora." },
        @{ Heading = "## Analyses"; Line = "- [[public-corpus-ingest-workflow]] - Reusable workflow for complete public-person corpus ingests with automation and safe public indexing." }
    )
    foreach ($item in $indexLines) {
        if ($indexText -notmatch [regex]::Escape($item.Line)) {
            $indexText = $indexText -replace "($($item.Heading)\s*)", "`$1`n$($item.Line)`n"
        }
    }
    $itemLines = @($allEntries | Where-Object { $_.wiki_page -and $_.source_kind -ne "person-profile" } | Sort-Object person_key, source_kind, title | ForEach-Object {
        $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
        "  - [[$wikiId|$(Convert-ToWikiAlias $_.title)]] - ``$($_.person_key)``, ``$($_.source_kind)``"
    })
    $corpusBlock = @"

### Shunyu Yao Public Corpora

- Hubs
  - [[shunyu-yao-public-corpora]]
  - [[shunyu-yao-project-taxonomy]]
  - [[shunyu-yao-paper-map]]
- Items
$($itemLines -join "`n")

"@
    if ($indexText -notmatch '### Shunyu Yao Public Corpora') {
        if ($indexText -match '### Lidang Public Ideas Corpus') {
            $indexText = $indexText -replace '(### Lidang Public Ideas Corpus)', ($corpusBlock + "`$1")
        }
        elseif ($indexText -match '### Karpathy Public Corpus') {
            $indexText = $indexText -replace '(### Karpathy Public Corpus)', ($corpusBlock + "`$1")
        }
        else {
            $indexText = $indexText.TrimEnd() + $corpusBlock
        }
    }
    else {
        $indexText = [regex]::Replace($indexText, '(?s)### Shunyu Yao Public Corpora\s+.*?(?=### Lidang Public Ideas Corpus|### Karpathy Public Corpus|\z)', $corpusBlock)
    }
    $indexText = $indexText -replace 'updated: \d{4}-\d{2}-\d{2}', "updated: $today"
    Write-TextIfChanged $indexPath $indexText | Out-Null

    $agentsPath = Join-Path $rootPath "AGENTS.md"
    $agentsText = Read-TextFile $agentsPath
    if ($agentsText -notmatch 'Public Person Corpus Workflow') {
        $insert = @"

## Public Person Corpus Workflow

When the user asks for a complete public corpus using phrases such as full GitHub, all projects, all public releases, all papers, or recurring updates, treat it as a durable public-corpus ingest request.

- First disambiguate same-name people before crawling.
- Create separate entity pages, manifests, raw directories, and source pages for distinct identities.
- Use stable IDs and semantic hashes to prevent duplicate captures and noisy commits.
- Use safe public indexing: metadata, summaries, links, hashes, categories, and license notes; do not publicly mirror unclear-license full PDFs, source code, or long webpage text.
- Add/update automation so future agents rerun the ingest, validate, commit scoped changes, and push.
- See [[public-corpus-ingest-workflow]] for the maintained wiki version of this workflow.
"@
        $agentsText = $agentsText.TrimEnd() + $insert + "`n"
        Write-TextIfChanged $agentsPath $agentsText | Out-Null
    }

    $logPath = Join-Path $rootPath "wiki/log.md"
    $logText = Read-TextFile $logPath
    $logEntry = @"

## [$now] ingest | shunyu yao public corpora

- Pages created or updated:
  - [[yao-shunyu-ysymyth]]
  - [[yao-shunyu-alfred]]
  - [[shunyu-yao-public-corpora]]
  - [[2026-05-16-yao-shunyu-public-corpora]]
  - [[shunyu-yao-project-taxonomy]]
  - [[shunyu-yao-paper-map]]
  - [[public-corpus-ingest-workflow]]
- Sources used:
  - https://ysymyth.github.io/
  - https://github.com/ysymyth
  - https://alfredyao.github.io/
  - https://github.com/alfredyao
  - arXiv API metadata
- Notes:
  - Created separate public corpora for ``ysymyth`` and ``alfredyao``.
  - Stored manifests under ``raw/yao-shunyu-ysymyth/`` and ``raw/yao-shunyu-alfred/``.
  - Added reusable public-person corpus workflow guidance for future agents.
"@
    if ($logText -notmatch 'ingest \| shunyu yao public corpora') {
        Write-TextIfChanged $logPath ($logText.TrimEnd() + $logEntry) | Out-Null
    }
}

if (-not $SkipValidation -and -not $DryRun) {
    & (Join-Path $rootPath "scripts/wiki-catalog.ps1") -Root $rootPath | Out-Host
    & (Join-Path $rootPath "scripts/wiki-lint.ps1") -Root $rootPath | Out-Host
}

[pscustomobject]@{
    Person = $Person
    Corpora = @($results | ForEach-Object { [pscustomobject]@{ person_key = $_.person_key; entries = $_.entry_count; new_entries = $_.new_entries_this_run; changed_entries = $_.changed_entries_this_run; removed_entries = $_.removed_entries_this_run; errors = $_.error_count; manifest = $_.manifest_path } })
}
