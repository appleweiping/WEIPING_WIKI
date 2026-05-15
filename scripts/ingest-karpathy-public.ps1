param(
    [string]$Root = ".",
    [switch]$DryRun,
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$today = (Get-Date).ToString("yyyy-MM-dd")
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$githubUserUrl = "https://api.github.com/users/karpathy"
$githubReposUrl = "https://api.github.com/users/karpathy/repos?per_page=100&sort=updated"
$githubGistsUrl = "https://api.github.com/users/karpathy/gists?per_page=100"
$homeUrl = "https://karpathy.ai/"
$blogFeedUrl = "https://karpathy.github.io/feed.xml"
$youtubeFeedUrl = "https://www.youtube.com/feeds/videos.xml?channel_id=UCXUPKJO5MZQN11PqgIvyuvQ"
$tweetsUrl = "https://karpathy.ai/tweets.html"

function Read-TextFile([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
    }
}

function ConvertTo-Slug([string]$Text) {
    $slug = $Text.ToLowerInvariant() -replace '\.(md|html|htm|ipynb|txt)$', ''
    $slug = $slug -replace '[^a-z0-9]+', '-'
    return $slug.Trim('-')
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

function Invoke-WebText([string]$Url) {
    $headers = @{ "User-Agent" = "vipin-wiki-karpathy-ingest" }
    return (Invoke-WebRequest -Uri $Url -Headers $headers -UseBasicParsing -TimeoutSec 90).Content
}

function Invoke-WebJson([string]$Url) {
    $headers = @{ "User-Agent" = "vipin-wiki-karpathy-ingest" }
    return Invoke-RestMethod -Uri $Url -Headers $headers -TimeoutSec 90
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

function Get-CategoryInfo([string]$Name, [string]$Description, [string[]]$Paths) {
    $text = (($Name, $Description) + $Paths) -join " "
    $p = $text.ToLowerInvariant()
    if ($p -match 'autoresearch|agent|council') { return @{ Category = "Research automation / agentic science"; Tags = @("karpathy", "agents", "research-automation") } }
    if ($p -match 'nanogpt|mingpt|gpt|llm|llama|transformer|chat') { return @{ Category = "LLM training and inference systems"; Tags = @("karpathy", "llm", "training", "inference") } }
    if ($p -match 'token|bpe|minbpe') { return @{ Category = "Tokenization and language modeling"; Tags = @("karpathy", "tokenization", "language-modeling") } }
    if ($p -match 'micrograd|makemore|zero-to-hero|backprop|neural') { return @{ Category = "Neural network fundamentals"; Tags = @("karpathy", "neural-networks", "education") } }
    if ($p -match 'caption|vision|image|convnet|stable-diffusion|neuraltalk') { return @{ Category = "Vision / multimodal / captioning"; Tags = @("karpathy", "vision", "multimodal") } }
    if ($p -match 'arxiv|paper|reader|research') { return @{ Category = "Research tooling and paper workflows"; Tags = @("karpathy", "research-tooling", "papers") } }
    if ($p -match 'javascript|browser|convnetjs|web') { return @{ Category = "Browser / JavaScript ML experiments"; Tags = @("karpathy", "javascript", "browser-ml") } }
    if ($p -match 'course|lecture|build|from-scratch|101|zero') { return @{ Category = "LLM education / from-scratch pedagogy"; Tags = @("karpathy", "education", "from-scratch") } }
    return @{ Category = "Minimal implementations"; Tags = @("karpathy", "minimal-implementation") }
}

function Get-TeachingBullets([string]$Category, [string]$Name) {
    switch ($Category) {
        "Research automation / agentic science" { return @("How Karpathy frames autonomous research loops, experiment iteration, and AI-assisted discovery.", "Useful for designing agent workflows that improve through concrete experiments instead of one-off prompting.") }
        "LLM training and inference systems" { return @("How modern LLM training or inference can be reduced to compact, inspectable systems.", "Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.") }
        "Tokenization and language modeling" { return @("How tokenization and sequence modeling mechanics connect to practical LLM behavior.", "Useful when debugging prompts, corpora, token budgets, or tokenizer-dependent failures.") }
        "Neural network fundamentals" { return @("How core neural network ideas can be rebuilt from first principles.", "Useful for grounding later LLM work in gradients, activations, optimization, and model internals.") }
        "Vision / multimodal / captioning" { return @("How earlier vision and captioning systems connect representation learning with language outputs.", "Useful historical context for multimodal LLM research and evaluation.") }
        "Research tooling and paper workflows" { return @("How tooling can compress research reading, search, filtering, and sense-making.", "Useful for improving this wiki's own ingest, ranking, and review workflows.") }
        "Browser / JavaScript ML experiments" { return @("How ML ideas can be made interactive and inspectable in the browser.", "Useful for teaching interfaces and lightweight demos.") }
        "LLM education / from-scratch pedagogy" { return @("How to teach advanced AI systems by rebuilding the smallest complete version.", "Useful as a standard for non-toy educational projects: compact, runnable, and conceptually complete.") }
        default { return @("How a complex idea can be compressed into a minimal but working implementation.", "Useful as a reference style for serious small systems rather than decorative demos.") }
    }
}

function Get-WhyItMatters([string]$Category) {
    if ($Category -match 'education|fundamentals') { return "This is high-priority for Vipin because it supports durable first-principles understanding instead of shallow API use." }
    if ($Category -match 'Research automation|tooling') { return "This is high-priority for Vipin because it informs agent workflows, paper digestion, wiki maintenance, and autonomous research loops." }
    if ($Category -match 'LLM|Tokenization') { return "This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment." }
    return "This matters as part of Karpathy's broader pattern: compress hard technical systems into readable, inspectable, working artifacts."
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
    if ($null -eq $Items -or $Items.Count -eq 0) { return "  - karpathy" }
    return (($Items | Sort-Object -Unique | ForEach-Object { "  - $_" }) -join "`n")
}

function Convert-ToWikiAlias([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return "untitled" }
    return (($Text -replace '[\[\]\|]', '') -replace '\s+', ' ').Trim()
}

function Get-RepoLocalPath([string]$RepoName) {
    return Join-Path (Join-Path $rootPath ".wiki-tmp\karpathy-repos") (ConvertTo-Slug $RepoName)
}

function Sync-Repo([object]$Repo, [System.Collections.Generic.List[string]]$Errors) {
    $repoPath = Get-RepoLocalPath $Repo.name
    if ($DryRun) { return $repoPath }
    Ensure-Dir (Split-Path -Parent $repoPath)
    $branch = if ($Repo.default_branch) { [string]$Repo.default_branch } else { "master" }
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        if (Test-Path -LiteralPath (Join-Path $repoPath ".git")) {
            $fetchOutput = & git -C $repoPath fetch --depth 1 --no-tags origin $branch 2>&1
            if ($LASTEXITCODE -ne 0) {
                $Errors.Add("Repository fetch failed for $($Repo.name): $($fetchOutput -join ' ')")
                return $repoPath
            }
            $checkoutOutput = & git -C $repoPath checkout -f FETCH_HEAD 2>&1
            if ($LASTEXITCODE -ne 0) {
                $Errors.Add("Repository checkout failed for $($Repo.name): $($checkoutOutput -join ' ')")
                return $repoPath
            }
        }
        else {
            $cloneOutput = & git clone --depth 1 --no-tags --branch $branch $Repo.clone_url $repoPath 2>&1
            if ($LASTEXITCODE -ne 0) {
                $Errors.Add("Repository clone failed for $($Repo.name): $($cloneOutput -join ' ')")
            }
        }
    }
    catch {
        $Errors.Add("Repository sync failed for $($Repo.name): $($_.Exception.Message)")
    }
    finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }
    return $repoPath
}

function Find-FirstFile([string]$RepoPath, [string[]]$Names) {
    foreach ($name in $Names) {
        $match = Get-ChildItem -LiteralPath $RepoPath -File -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ieq $name -or $_.Name -ilike "$name.*" } |
            Select-Object -First 1
        if ($null -ne $match) { return $match.FullName }
    }
    return $null
}

function Get-RepoFiles([string]$RepoPath) {
    try {
        $files = & git -C $RepoPath ls-files
        return @($files | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }
    catch {
        return @()
    }
}

function Get-ExtensionStats([string[]]$Files) {
    $stats = $Files |
        ForEach-Object {
            $ext = [System.IO.Path]::GetExtension($_).ToLowerInvariant()
            if ([string]::IsNullOrWhiteSpace($ext)) { "[none]" } else { $ext }
        } |
        Group-Object |
        Sort-Object -Property @{ Expression = "Count"; Descending = $true }, @{ Expression = "Name"; Ascending = $true } |
        Select-Object -First 12
    return @($stats | ForEach-Object { [pscustomobject]@{ extension = $_.Name; count = $_.Count } })
}

function Get-TopLevelStats([string[]]$Files) {
    $stats = $Files |
        ForEach-Object {
            $parts = $_ -split '/'
            if ($parts.Count -gt 1) { $parts[0] } else { "[root]" }
        } |
        Group-Object |
        Sort-Object -Property @{ Expression = "Count"; Descending = $true }, @{ Expression = "Name"; Ascending = $true } |
        Select-Object -First 12
    return @($stats | ForEach-Object { [pscustomobject]@{ path = $_.Name; count = $_.Count } })
}

function Get-GitTags([string]$RepoPath) {
    try {
        $tags = & git -C $RepoPath tag --list
        return @($tags | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object | Select-Object -Last 20)
    }
    catch {
        return @()
    }
}

function Get-GitHead([string]$RepoPath) {
    try {
        return (& git -C $RepoPath rev-parse HEAD).Trim()
    }
    catch {
        return ""
    }
}

function New-RepoEntry([object]$Repo, [hashtable]$OldById, [System.Collections.Generic.List[string]]$Errors) {
    $repoPath = Sync-Repo $Repo $Errors
    $readmePath = if (Test-Path -LiteralPath $repoPath) { Find-FirstFile $repoPath @("README", "Readme", "readme") } else { $null }
    $licensePath = if (Test-Path -LiteralPath $repoPath) { Find-FirstFile $repoPath @("LICENSE", "LICENCE", "COPYING", "NOTICE") } else { $null }
    $readme = if ($readmePath) { Read-TextFile $readmePath } else { "" }
    $licenseText = if ($licensePath) { Read-TextFile $licensePath } else { "" }
    $files = if (Test-Path -LiteralPath $repoPath) { Get-RepoFiles $repoPath } else { @() }
    $head = if (Test-Path -LiteralPath $repoPath) { Get-GitHead $repoPath } else { "" }
    $tags = if (Test-Path -LiteralPath $repoPath) { Get-GitTags $repoPath } else { @() }
    $cat = Get-CategoryInfo $Repo.name $Repo.description $files
    $id = "github:$($Repo.name)"
    $licenseName = if ($Repo.license -and $Repo.license.spdx_id) { [string]$Repo.license.spdx_id } elseif ($licensePath) { "local-license-file" } else { "NOASSERTION" }
    $distributionPolicy = if ($licenseName -and $licenseName -ne "NOASSERTION") { "public-summary-plus-license-aware-excerpts" } else { "public-summary-local-archive-only" }
    $mirrorStatus = if ($licenseName -and $licenseName -ne "NOASSERTION") { "partial excerpt" } else { "summary-only" }
    $hashInput = (@(
        $Repo.full_name, $Repo.description, $Repo.html_url, $Repo.default_branch, $head,
        $licenseName, (Get-Sha256Text $readme), (Get-Sha256Text $licenseText),
        ($files -join "`n"), ($tags -join "`n")
    ) -join "`n")
    $hash = Get-Sha256Text $hashInput
    $slug = ConvertTo-Slug $Repo.name
    $pagePath = "wiki/sources/karpathy-public/github-$slug.md"
    $firstSeen = Get-FirstSeen $OldById $id
    $lastChanged = Get-LastChanged $OldById $id $hash
    $summary = Get-PlainSummary $readme 620
    $teach = Get-TeachingBullets $cat.Category $Repo.name

    return [pscustomobject]@{
        id = $id
        source_kind = "github-repository"
        title = $Repo.name
        url = $Repo.html_url
        source_url = $Repo.html_url
        clone_url = $Repo.clone_url
        description = $Repo.description
        category = $cat.Category
        tags = $cat.Tags
        license = $licenseName
        distribution_policy = $distributionPolicy
        mirror_status = $mirrorStatus
        content_hash = $hash
        first_seen = $firstSeen
        last_seen = $today
        last_changed = $lastChanged
        wiki_page = $pagePath
        repo = [pscustomobject]@{
            name = $Repo.name
            full_name = $Repo.full_name
            default_branch = $Repo.default_branch
            stars = $Repo.stargazers_count
            forks = $Repo.forks_count
            watchers = $Repo.watchers_count
            open_issues = $Repo.open_issues_count
            pushed_at = $Repo.pushed_at
            updated_at = $Repo.updated_at
            created_at = $Repo.created_at
            archived = $Repo.archived
            fork = $Repo.fork
            head = $head
            file_count = $files.Count
            top_level = @(Get-TopLevelStats $files)
            extensions = @(Get-ExtensionStats $files)
            sample_files = @($files | Sort-Object | Select-Object -First 120)
            tags = @($tags)
            readme_path = if ($readmePath) { Split-Path -Leaf $readmePath } else { "" }
            license_path = if ($licensePath) { Split-Path -Leaf $licensePath } else { "" }
        }
        summary = $summary
        teaching = @($teach)
        why_it_matters = Get-WhyItMatters $cat.Category
    }
}

function New-BlogEntry([object]$Item, [hashtable]$OldById) {
    $title = [string]$Item.title
    $link = [string]$Item.link
    $description = [string]$Item.description
    $slug = ConvertTo-Slug (($link -replace '^https?://', '') -replace '/', '-')
    $id = "blog:$link"
    $hash = Get-Sha256Text ($title + "`n" + $link + "`n" + $description)
    $firstSeen = Get-FirstSeen $OldById $id
    $lastChanged = Get-LastChanged $OldById $id $hash
    return [pscustomobject]@{
        id = $id
        source_kind = "blog-rss-item"
        title = $title
        url = $link
        source_url = $blogFeedUrl
        category = "Personal heuristics / AI philosophy / learning advice"
        tags = @("karpathy", "blog", "ideas")
        license = "NOASSERTION"
        distribution_policy = "public-summary-local-archive-only"
        mirror_status = "summary-only"
        content_hash = $hash
        first_seen = $firstSeen
        last_seen = $today
        last_changed = $lastChanged
        wiki_page = "wiki/sources/karpathy-public/blog-$slug.md"
        published_at = [string]$Item.pubDate
        summary = Get-PlainSummary $description 720
        teaching = @("How Karpathy frames technical judgment, learning, research, or AI systems in long-form prose.", "Useful as a high-signal idea source for research taste, project framing, and agent workflow design.")
        why_it_matters = "Karpathy's posts often crystallize reusable heuristics; this wiki should preserve the ideas without relying on chat memory."
    }
}

function New-VideoEntry([object]$Entry, [hashtable]$OldById) {
    $title = [string]$Entry.title
    $link = [string]$Entry.link.href
    $videoId = ($link -replace '^.*[?&]v=', '') -replace '&.*$', ''
    $videoSlug = ConvertTo-Slug $title
    $id = "youtube:$videoId"
    $hash = Get-Sha256Text ($title + "`n" + $link + "`n" + [string]$Entry.published + "`n" + [string]$Entry.updated)
    $firstSeen = Get-FirstSeen $OldById $id
    $lastChanged = Get-LastChanged $OldById $id $hash
    return [pscustomobject]@{
        id = $id
        source_kind = "youtube-video"
        title = $title
        url = $link
        source_url = $youtubeFeedUrl
        category = "Talks, courses, and videos"
        tags = @("karpathy", "youtube", "lecture", "video")
        license = "YouTube-standard"
        distribution_policy = "public-metadata-summary-only"
        mirror_status = "summary-only"
        content_hash = $hash
        first_seen = $firstSeen
        last_seen = $today
        last_changed = $lastChanged
        wiki_page = "wiki/sources/karpathy-public/video-$videoSlug.md"
        published_at = [string]$Entry.published
        summary = "YouTube video from Karpathy's public channel: $title."
        teaching = @("Use as a lecture-style source for Karpathy's from-scratch explanations and AI system intuition.", "Pair with linked GitHub repos when a lecture has an accompanying codebase.")
        why_it_matters = "These videos are among the clearest public sources for Karpathy's pedagogy and implementation taste."
    }
}

function New-GistEntry([object]$Gist, [hashtable]$OldById) {
    $title = if ($Gist.description) { [string]$Gist.description } else { "Karpathy gist $($Gist.id)" }
    $fileNames = @($Gist.files.PSObject.Properties | ForEach-Object { $_.Name })
    $hash = Get-Sha256Text (($Gist.id, $title, $Gist.html_url, ($fileNames -join "`n"), $Gist.updated_at) -join "`n")
    $id = "gist:$($Gist.id)"
    $firstSeen = Get-FirstSeen $OldById $id
    $lastChanged = Get-LastChanged $OldById $id $hash
    return [pscustomobject]@{
        id = $id
        source_kind = "github-gist"
        title = $title
        url = $Gist.html_url
        source_url = $githubGistsUrl
        category = "Minimal implementations"
        tags = @("karpathy", "gist", "code")
        license = "NOASSERTION"
        distribution_policy = "public-summary-local-archive-only"
        mirror_status = "summary-only"
        content_hash = $hash
        first_seen = $firstSeen
        last_seen = $today
        last_changed = $lastChanged
        wiki_page = "wiki/sources/karpathy-public/gist-$($Gist.id).md"
        published_at = [string]$Gist.created_at
        updated_at = [string]$Gist.updated_at
        files = @($fileNames)
        summary = "Public GitHub gist by Karpathy. Files: $(($fileNames | Select-Object -First 12) -join ', ')."
        teaching = @("Use as a small public code or note artifact linked to Karpathy's broader work.", "Treat licensing as unasserted unless a gist file explicitly declares one.")
        why_it_matters = "Gists often capture compact ideas that do not deserve a full repository but can be important for tracing public thinking."
    }
}

function New-TweetEntry([string]$StatusUrl, [hashtable]$OldById) {
    $statusId = ([regex]::Match($StatusUrl, '/status/(\d+)')).Groups[1].Value
    $id = "tweet:$statusId"
    $hash = Get-Sha256Text $StatusUrl
    $firstSeen = Get-FirstSeen $OldById $id
    $lastChanged = Get-LastChanged $OldById $id $hash
    return [pscustomobject]@{
        id = $id
        source_kind = "curated-status-link"
        title = "Curated Karpathy status $statusId"
        url = $StatusUrl
        source_url = $tweetsUrl
        category = "Personal heuristics / AI philosophy / learning advice"
        tags = @("karpathy", "tweet", "curated-link", "ideas")
        license = "NOASSERTION"
        distribution_policy = "public-link-metadata-only"
        mirror_status = "summary-only"
        content_hash = $hash
        first_seen = $firstSeen
        last_seen = $today
        last_changed = $lastChanged
        wiki_page = "wiki/sources/karpathy-public/tweet-$statusId.md"
        summary = "A status URL included on Karpathy's official curated/favorite tweets page. The public wiki records provenance and link metadata only."
        teaching = @("Use as a pointer to Karpathy's curated short-form idea stream.", "Do not treat this page as a full tweet archive or quote source.")
        why_it_matters = "Karpathy's short-form links can point to useful heuristics, but source stability and licensing require conservative public handling."
    }
}

function New-HomepageEntry([string]$Html, [hashtable]$OldById) {
    $links = [regex]::Matches($Html, 'href=["'']([^"'']+)["'']') |
        ForEach-Object { $_.Groups[1].Value } |
        Where-Object { $_ -and $_ -notmatch '^(#|mailto:|javascript:)' } |
        Sort-Object -Unique
    $hash = Get-Sha256Text $Html
    $id = "website:karpathy.ai"
    return [pscustomobject]@{
        id = $id
        source_kind = "personal-homepage"
        title = "Karpathy personal homepage"
        url = $homeUrl
        source_url = $homeUrl
        category = "Personal heuristics / AI philosophy / learning advice"
        tags = @("karpathy", "homepage", "profile")
        license = "NOASSERTION"
        distribution_policy = "public-summary-link-map-only"
        mirror_status = "summary-only"
        content_hash = $hash
        first_seen = Get-FirstSeen $OldById $id
        last_seen = $today
        last_changed = Get-LastChanged $OldById $id $hash
        wiki_page = "wiki/sources/karpathy-public/website-karpathy-ai.md"
        links = @($links)
        summary = Get-PlainSummary $Html 720
        teaching = @("Use the homepage as the routing source for Karpathy's official public identity, projects, talks, papers, blog, and social links.", "Prefer this page over search snippets when deciding whether a source is official enough to ingest.")
        why_it_matters = "The homepage is the official discovery surface that ties together Karpathy's public projects and publications."
    }
}

function New-ItemPage([object]$Entry) {
    $tagLines = Convert-ToFrontmatterList $Entry.tags
    $sourcePages = @($Entry.url, $Entry.source_url) | Where-Object { $_ } | Sort-Object -Unique
    $sourceLines = ($sourcePages | ForEach-Object { "  - $_" }) -join "`n"
    $teachingLines = ($Entry.teaching | ForEach-Object { "- $_" }) -join "`n"
    $title = Escape-Yaml $Entry.title
    $extra = ""

    if ($Entry.source_kind -eq "github-repository") {
        $extLines = ($Entry.repo.extensions | ForEach-Object { "- ``$($_.extension)``: $($_.count)" }) -join "`n"
        $topLines = ($Entry.repo.top_level | ForEach-Object { "- ``$($_.path)``: $($_.count)" }) -join "`n"
        $sampleLines = ($Entry.repo.sample_files | Select-Object -First 80 | ForEach-Object { "- ``$_``" }) -join "`n"
        $tagLines2 = if ($Entry.repo.tags.Count -gt 0) { ($Entry.repo.tags | ForEach-Object { "- ``$_``" }) -join "`n" } else { "- No git tags found in the shallow local clone." }
        $extra = @"

## Repository Snapshot

- Full name: ``$($Entry.repo.full_name)``
- Default branch: ``$($Entry.repo.default_branch)``
- HEAD: ``$($Entry.repo.head)``
- Stars at crawl: $($Entry.repo.stars)
- Forks at crawl: $($Entry.repo.forks)
- File count: $($Entry.repo.file_count)
- README path: ``$($Entry.repo.readme_path)``
- License path: ``$($Entry.repo.license_path)``
- Created: $($Entry.repo.created_at)
- Updated: $($Entry.repo.updated_at)
- Pushed: $($Entry.repo.pushed_at)

### Top-Level Structure

$topLines

### File Extension Profile

$extLines

### Tags / Release-Like Markers

$tagLines2

### Sample File Tree

$sampleLines
"@
    }
    elseif ($Entry.source_kind -eq "personal-homepage" -and $Entry.links) {
        $linkLines = ($Entry.links | Select-Object -First 120 | ForEach-Object { "- $_" }) -join "`n"
        $extra = @"

## Discovered Links

$linkLines
"@
    }
    elseif ($Entry.source_kind -eq "github-gist" -and $Entry.files) {
        $fileLines = ($Entry.files | ForEach-Object { "- ``$_``" }) -join "`n"
        $extra = @"

## Gist Files

$fileLines
"@
    }

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
- URL: $($Entry.url)
- Discovery source: $($Entry.source_url)
- License: ``$($Entry.license)``
- Distribution policy: ``$($Entry.distribution_policy)``
- Public mirror status: ``$($Entry.mirror_status)``
- Content hash: ``$($Entry.content_hash)``
- First seen: $($Entry.first_seen)
- Last changed: $($Entry.last_changed)

## Classification

- Primary category: $($Entry.category)
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

$($Entry.summary)

## What This Teaches

$teachingLines

## Why It Matters

$($Entry.why_it_matters)
$extra

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
"@
}

function Add-OrReplaceIndexLine([string]$Text, [string]$Heading, [string]$Line) {
    if ($Text -match [regex]::Escape($Line)) { return $Text }
    return ($Text -replace "($Heading\s*)", "`$1`n$Line`n")
}

$rawDir = Join-Path $rootPath "raw\karpathy-public"
$itemDir = Join-Path $rootPath "wiki\sources\karpathy-public"
Ensure-Dir $rawDir
Ensure-Dir $itemDir

$manifestPath = Join-Path $rawDir "manifest.json"
$oldById = @{}
if (Test-Path -LiteralPath $manifestPath) {
    $oldManifest = Read-TextFile $manifestPath | ConvertFrom-Json
    foreach ($entry in $oldManifest.entries) { $oldById[$entry.id] = $entry }
}

$errors = New-Object System.Collections.Generic.List[string]
$entries = New-Object System.Collections.Generic.List[object]

$user = Invoke-WebJson $githubUserUrl
$repos = Invoke-WebJson $githubReposUrl
if ($repos.Count -lt 50) { throw "GitHub repo discovery returned only $($repos.Count) repos; refusing to update corpus." }

foreach ($repo in ($repos | Sort-Object name)) {
    $entries.Add((New-RepoEntry $repo $oldById $errors))
}

try {
    $homeHtml = Invoke-WebText $homeUrl
    $entries.Add((New-HomepageEntry $homeHtml $oldById))
}
catch {
    $errors.Add("Homepage crawl failed: $($_.Exception.Message)")
}

try {
    [xml]$blogXml = Invoke-WebText $blogFeedUrl
    foreach ($item in @($blogXml.rss.channel.item)) {
        $entries.Add((New-BlogEntry $item $oldById))
    }
}
catch {
    $errors.Add("Blog RSS crawl failed: $($_.Exception.Message)")
}

try {
    [xml]$youtubeXml = Invoke-WebText $youtubeFeedUrl
    foreach ($video in @($youtubeXml.feed.entry)) {
        $entries.Add((New-VideoEntry $video $oldById))
    }
}
catch {
    $errors.Add("YouTube RSS crawl failed: $($_.Exception.Message)")
}

try {
    $gists = Invoke-WebJson $githubGistsUrl
    foreach ($gist in $gists) {
        $entries.Add((New-GistEntry $gist $oldById))
    }
}
catch {
    $errors.Add("Gist crawl failed: $($_.Exception.Message)")
}

try {
    $tweetsHtml = Invoke-WebText $tweetsUrl
    $statusUrls = [regex]::Matches($tweetsHtml, 'https?://(?:twitter|x)\.com/karpathy/status/\d+') |
        ForEach-Object { $_.Value -replace '^https://x\.com', 'https://twitter.com' } |
        Sort-Object -Unique
    if ($statusUrls.Count -eq 0) { $errors.Add("Curated tweets page returned zero status links.") }
    foreach ($statusUrl in $statusUrls) {
        $entries.Add((New-TweetEntry $statusUrl $oldById))
    }
}
catch {
    $errors.Add("Curated tweets crawl failed: $($_.Exception.Message)")
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

$changedPages = 0
foreach ($entry in $entries) {
    $absPage = Join-Path $rootPath $entry.wiki_page
    if (Write-TextIfChanged $absPage (New-ItemPage $entry)) { $changedPages++ }
}

$grouped = $entries | Group-Object category | Sort-Object Name
$categorySections = foreach ($group in $grouped) {
    $repoCount = @($group.Group | Where-Object { $_.source_kind -eq "github-repository" }).Count
    $lines = $group.Group | Sort-Object source_kind, title | ForEach-Object {
        $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
        "- [[$wikiId|$(Convert-ToWikiAlias $_.title)]] - $($_.source_kind), $($_.mirror_status)"
    }
    "## $($group.Name)`n`n- Items: $($group.Count)`n- GitHub repositories: $repoCount`n`n" + ($lines -join "`n")
}

$ideaGroups = $entries | Where-Object { $_.source_kind -ne "curated-status-link" } | Group-Object category | Sort-Object Name
$ideaSections = foreach ($group in $ideaGroups) {
    $lines = $group.Group | Sort-Object title | Select-Object -First 25 | ForEach-Object {
        $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
        "- [[$wikiId|$(Convert-ToWikiAlias $_.title)]]: $($_.summary)"
    }
    "## $($group.Name)`n`n" + ($lines -join "`n")
}

$licenseGroups = $entries | Group-Object license | Sort-Object Name
$licenseLines = ($licenseGroups | ForEach-Object { "- ``$($_.Name)``: $($_.Count)" }) -join "`n"
$sourceKindLines = (($entries | Group-Object source_kind | Sort-Object Name) | ForEach-Object { "- ``$($_.Name)``: $($_.Count)" }) -join "`n"
$categoryLines = ($grouped | ForEach-Object { "- $($_.Name): $($_.Count)" }) -join "`n"
$indexKarpathyLines = foreach ($group in $grouped) {
    $lines = $group.Group | Sort-Object source_kind, title | ForEach-Object {
        $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
        "  - [[$wikiId|$(Convert-ToWikiAlias $_.title)]]"
    }
    "- $($group.Name)`n" + ($lines -join "`n")
}
$repoEntries = @($entries | Where-Object { $_.source_kind -eq "github-repository" })
$topRepos = $repoEntries | Sort-Object { -[int]$_.repo.stars } | Select-Object -First 20
$topRepoLines = ($topRepos | ForEach-Object {
    $wikiId = ($_.wiki_page -replace '^wiki/', '' -replace '\.md$', '')
    "- [[$wikiId|$(Convert-ToWikiAlias $_.title)]] - $($_.repo.stars) stars, $($_.category)"
}) -join "`n"

$sourceContent = @"
---
title: 2026-05-15 Karpathy Public Corpus
type: source
status: active
created: 2026-05-15
updated: $today
tags:
  - karpathy
  - batch-ingest
  - public-corpus
  - ai
source_pages:
  - $githubUserUrl
  - $homeUrl
  - $blogFeedUrl
  - $youtubeFeedUrl
  - $tweetsUrl
---

# 2026-05-15 Karpathy Public Corpus

## Provenance

- GitHub profile/API: $githubUserUrl
- GitHub repositories API: $githubReposUrl
- GitHub gists API: $githubGistsUrl
- Personal homepage: $homeUrl
- Blog RSS: $blogFeedUrl
- YouTube RSS: $youtubeFeedUrl
- Curated tweet/status links: $tweetsUrl
- Manifest: ``raw/karpathy-public/manifest.json``
- Local repo cache: ``.wiki-tmp/karpathy-repos``; this is operational cache, not public wiki content.

## Crawl Snapshot

- GitHub profile login: ``$($user.login)``
- GitHub display name: $($user.name)
- Public repos discovered: $($repos.Count)
- Manifest entries: $($entries.Count)
- New entries this run: $($newEntries.Count)
- Changed entries this run: $($updatedEntries.Count)
- Removed entries this run: $($removedEntries.Count)
- Crawl errors recorded: $($errors.Count)

## Source Kinds

$sourceKindLines

## License / Public Handling Counts

$licenseLines

## Ingest Policy

- EXTRACTED: Public GitHub repository metadata, README/license files, file trees, git tags, blog RSS items, YouTube feed metadata, gists, homepage links, and curated tweet/status URLs are captured where accessible.
- INFERRED: Unlicensed source text/code should be treated as local preservation plus public summary, not as permission for wholesale public redistribution.
- The wiki may publish metadata, summaries, hashes, categories, and links for unlicensed material.
- Full local preservation can live in ignored caches or private raw folders; public pages must retain mirror/distribution policy fields.
- Re-run with ``scripts/ingest-karpathy-public.ps1`` to refresh the corpus.

## Related

- [[andrej-karpathy]]
- [[karpathy-public-work]]
- [[karpathy-project-taxonomy]]
- [[karpathy-idea-map]]
"@

$entityContent = @"
---
title: Andrej Karpathy
type: entity
status: active
created: 2026-05-15
updated: $today
tags:
  - karpathy
  - ai
  - llm
  - public-figure
source_pages:
  - $githubUserUrl
  - $homeUrl
---

# Andrej Karpathy

## Current Public Corpus Role

Andrej Karpathy is tracked in this wiki as a high-priority public source for first-principles AI education, compact implementations, LLM systems, research tooling, and reusable technical heuristics.

## Extracted Public Profile Signals

- EXTRACTED: GitHub login: ``$($user.login)``.
- EXTRACTED: GitHub name field: $($user.name).
- EXTRACTED: GitHub bio: $($user.bio).
- EXTRACTED: GitHub blog/social field: $($user.blog).
- EXTRACTED: GitHub public repositories at crawl: $($repos.Count).
- EXTRACTED: GitHub followers at crawl: $($user.followers).

## Highest-Signal Public Project Clusters

$categoryLines

## Why This Matters For Vipin

- Karpathy's strongest pattern is serious minimalism: small, runnable artifacts that expose the essence of a system.
- His materials are especially relevant to LLM research taste, agent workflow design, education, and implementation judgment.
- Future agents should treat Karpathy sources as a living corpus and check [[karpathy-public-work]] before answering questions about his projects or ideas.

## Related

- [[karpathy-public-work]]
- [[karpathy-project-taxonomy]]
- [[karpathy-idea-map]]
- [[2026-05-15-karpathy-public-corpus]]
"@

$topicContent = @"
---
title: Karpathy Public Work
type: topic
status: active
created: 2026-05-15
updated: $today
tags:
  - karpathy
  - ai
  - llm
  - public-corpus
source_pages:
  - $githubUserUrl
  - $homeUrl
---

# Karpathy Public Work

This hub routes future agents to Karpathy's public projects, writing, videos, gists, and curated short-form idea links.

## How To Use This Hub

- Start with [[karpathy-project-taxonomy]] for project/category navigation.
- Use [[karpathy-idea-map]] for reusable ideas, heuristics, and teaching patterns.
- Use [[2026-05-15-karpathy-public-corpus]] for source provenance, crawl policy, and public/private handling.
- Use per-item pages under ``wiki/sources/karpathy-public/`` for source-specific metadata and summaries.

## Current Corpus Counts

$sourceKindLines

## Top GitHub Repositories By Stars At Crawl

$topRepoLines

## Maintenance Rule For Future Agents

- Re-crawl before making current claims about repository counts, stars, releases, or new posts.
- Do not rely on search snippets when an official source surface exists.
- Keep unlicensed full text/code out of public redistribution; use summaries, hashes, and links unless the source license permits more.
- Preserve Karpathy's reusable heuristics as durable wiki synthesis rather than leaving them in chat.

## Counterpoints And Gaps

- This corpus is broad and source-grounded, but public feeds do not guarantee a complete historical archive of every public statement.
- Curated status links are pointers, not a full text tweet mirror.
- Star counts, repository metadata, and public profile numbers are time-sensitive and require a fresh crawl before use in current claims.

## Related

- [[andrej-karpathy]]
- [[karpathy-project-taxonomy]]
- [[karpathy-idea-map]]
- [[2026-05-15-karpathy-public-corpus]]
"@

$taxonomyContent = @"
---
title: Karpathy Project Taxonomy
type: analysis
status: active
created: 2026-05-15
updated: $today
tags:
  - karpathy
  - taxonomy
  - ai-projects
source_pages:
  - $githubReposUrl
---

# Karpathy Project Taxonomy

This taxonomy groups Karpathy public corpus items by the role they play in AI learning, implementation, and research tooling.

## Snapshot

- Crawl date: $today
- Total items: $($entries.Count)
- GitHub repositories: $($repoEntries.Count)
- New entries this run: $($newEntries.Count)
- Changed entries this run: $($updatedEntries.Count)

$($categorySections -join "`n`n")

## Related

- [[karpathy-public-work]]
- [[karpathy-idea-map]]
- [[2026-05-15-karpathy-public-corpus]]

## Counterpoints And Gaps

- Generated categories are heuristic and should be refined when a repo's README or file tree shows a stronger interpretation.
- Some repositories are forks, experiments, or old teaching artifacts; popularity should not be mistaken for current endorsement.
- Source code is summarized through file trees and metadata unless public redistribution is clearly license-safe.
"@

$ideaContent = @"
---
title: Karpathy Idea Map
type: analysis
status: active
created: 2026-05-15
updated: $today
tags:
  - karpathy
  - ideas
  - heuristics
  - ai
source_pages:
  - $blogFeedUrl
  - $youtubeFeedUrl
  - $tweetsUrl
---

# Karpathy Idea Map

This page turns the public corpus into a retrieval map for Karpathy's reusable ideas: first-principles building, serious minimalism, from-scratch pedagogy, research tooling, LLM systems, and agentic experimentation.

## Reading Pattern

- EXTRACTED: Repositories provide runnable artifacts and implementation taste.
- EXTRACTED: Blog posts and videos provide long-form explanations and heuristics.
- EXTRACTED: The curated tweet page provides official pointers to short-form ideas but is not a complete tweet archive.
- INFERRED: The strongest recurring pattern is to compress a hard system into the smallest complete artifact that still teaches the real mechanism.

$($ideaSections -join "`n`n")

## Related

- [[andrej-karpathy]]
- [[karpathy-public-work]]
- [[karpathy-project-taxonomy]]
- [[2026-05-15-karpathy-public-corpus]]

## Counterpoints And Gaps

- The idea map is a synthesis aid, not a replacement for reading the linked original posts, videos, and repositories.
- Short-form status links are recorded conservatively because the source page is curated and licensing is not explicit.
- Future crawls may add new sources that change which ideas deserve the most emphasis.
"@

Write-TextIfChanged (Join-Path $rootPath "wiki\sources\2026-05-15-karpathy-public-corpus.md") $sourceContent | Out-Null
Write-TextIfChanged (Join-Path $rootPath "wiki\entities\andrej-karpathy.md") $entityContent | Out-Null
Write-TextIfChanged (Join-Path $rootPath "wiki\topics\karpathy-public-work.md") $topicContent | Out-Null
Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\karpathy-project-taxonomy.md") $taxonomyContent | Out-Null
Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\karpathy-idea-map.md") $ideaContent | Out-Null

$manifestEntries = @($entries | Sort-Object source_kind, title | ForEach-Object {
    [pscustomobject]@{
        id = $_.id
        title = $_.title
        source_kind = $_.source_kind
        url = $_.url
        source_url = $_.source_url
        category = $_.category
        tags = $_.tags
        license = $_.license
        distribution_policy = $_.distribution_policy
        mirror_status = $_.mirror_status
        content_hash = $_.content_hash
        first_seen = $_.first_seen
        last_seen = $_.last_seen
        last_changed = $_.last_changed
        wiki_page = $_.wiki_page
        repo = $_.repo
        files = $_.files
        published_at = $_.published_at
        updated_at = $_.updated_at
    }
})

$manifest = [pscustomobject]@{
    schema = "karpathy-public-corpus-v1"
    generated_at = if ($hasCorpusChanges -or -not (Test-Path -LiteralPath $manifestPath)) { (Get-Date).ToString("o") } elseif ($oldManifest.generated_at) { $oldManifest.generated_at } else { (Get-Date).ToString("o") }
    sources = [pscustomobject]@{
        github_user = $githubUserUrl
        github_repos = $githubReposUrl
        github_gists = $githubGistsUrl
        homepage = $homeUrl
        blog_feed = $blogFeedUrl
        youtube_feed = $youtubeFeedUrl
        curated_tweets = $tweetsUrl
    }
    public_handling = "Public wiki pages contain metadata, summaries, hashes, and license-aware excerpts. Unlicensed full text/code is local-only unless a license permits redistribution."
    entry_count = $manifestEntries.Count
    new_entries_this_run = $newEntries.Count
    changed_entries_this_run = $updatedEntries.Count
    removed_entries_this_run = $removedEntries.Count
    errors = @($errors)
    entries = @($manifestEntries)
}
Write-TextIfChanged $manifestPath ($manifest | ConvertTo-Json -Depth 30) | Out-Null

$indexPath = Join-Path $rootPath "wiki\index.md"
$indexText = Read-TextFile $indexPath
$indexText = Add-OrReplaceIndexLine $indexText "## Entities" "- [[andrej-karpathy]] - Public AI researcher/educator corpus focused on GitHub projects, writing, videos, and reusable technical heuristics."
$indexText = Add-OrReplaceIndexLine $indexText "## Topics" "- [[karpathy-public-work]] - Hub for Karpathy's public projects, posts, videos, gists, and curated idea links."
$indexText = Add-OrReplaceIndexLine $indexText "## Sources" "- [[2026-05-15-karpathy-public-corpus]] - Batch ingest of Karpathy's GitHub repositories, official homepage, blog RSS, YouTube feed, gists, and curated status links."
$indexText = Add-OrReplaceIndexLine $indexText "## Analyses" "- [[karpathy-project-taxonomy]] - Category map of Karpathy public corpus items by implementation and idea domain."
$indexText = Add-OrReplaceIndexLine $indexText "## Analyses" "- [[karpathy-idea-map]] - Synthesis map of Karpathy's reusable technical heuristics and public idea surfaces."
$karpathyIndexBlock = @"

### Karpathy Public Corpus

$($indexKarpathyLines -join "`n")

"@
if ($indexText -notmatch '### Karpathy Public Corpus') {
    $indexText = $indexText -replace '(### OpenAI Cookbook Mirror)', ($karpathyIndexBlock + "`$1")
}
else {
    $indexText = [regex]::Replace(
        $indexText,
        '(?s)### Karpathy Public Corpus\s+.*?(?=### OpenAI Cookbook Mirror)',
        $karpathyIndexBlock
    )
}
$indexText = $indexText -replace 'updated: \d{4}-\d{2}-\d{2}', "updated: $today"
Write-TextIfChanged $indexPath $indexText | Out-Null

$logPath = Join-Path $rootPath "wiki\log.md"
$logText = Read-TextFile $logPath
$logEntry = @"

## [$now] ingest | karpathy public corpus

- Pages created or updated:
  - [[andrej-karpathy]]
  - [[karpathy-public-work]]
  - [[2026-05-15-karpathy-public-corpus]]
  - [[karpathy-project-taxonomy]]
  - [[karpathy-idea-map]]
  - ``wiki/sources/karpathy-public/``
- Sources used:
  - $githubUserUrl
  - $githubReposUrl
  - $githubGistsUrl
  - $homeUrl
  - $blogFeedUrl
  - $youtubeFeedUrl
  - $tweetsUrl
- Notes:
  - Ingested $($entries.Count) public corpus entries, including $($repoEntries.Count) GitHub repositories.
  - New entries this run: $($newEntries.Count).
  - Changed entries this run: $($updatedEntries.Count).
  - Removed entries this run: $($removedEntries.Count).
  - Crawl errors recorded: $($errors.Count).
  - Manifest stored at ``raw/karpathy-public/manifest.json``.
"@
if ($hasCorpusChanges -or $logText -notmatch 'ingest \| karpathy public corpus') {
    Write-TextIfChanged $logPath ($logText.TrimEnd() + $logEntry) | Out-Null
}

if (-not $SkipValidation -and -not $DryRun) {
    & (Join-Path $rootPath "scripts\wiki-catalog.ps1") -Root $rootPath | Out-Host
    & (Join-Path $rootPath "scripts\wiki-lint.ps1") -Root $rootPath | Out-Host
}

[pscustomobject]@{
    GitHubRepos = $repos.Count
    ManifestEntries = $entries.Count
    NewEntries = $newEntries.Count
    UpdatedEntries = $updatedEntries.Count
    RemovedEntries = $removedEntries.Count
    ChangedPages = $changedPages
    Errors = $errors.Count
    ManifestPath = $manifestPath
}
