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
        schema = "frontend-project-frameworks-public-registry-v2"
        updated_at = $today
        public_handling = "Curated official project-shell, docs-site, app-framework, build-tooling, and dependency-substrate repositories only; public wiki pages contain metadata, reuse notes, links, hashes, categories, release summaries, and license notes, not full unlicensed source mirrors."
        frameworks = @(
            [pscustomobject]@{ slug = "quartz"; name = "Quartz"; category = "knowledge-site-framework"; homepage = "https://quartz.jzhao.xyz"; docs_url = "https://quartz.jzhao.xyz"; official_demo_url = "https://quartz.jzhao.xyz"; repos = @("jackyzha0/quartz"); keywords = @("quartz", "markdown", "digital garden", "knowledge", "wiki", "docs", "site generator"); reuse_profile = "Markdown-first knowledge site shell with search, graph, backlinks, theming, and static publishing."; project_shell_score = 10; recommended_use_cases = @("personal wiki", "research knowledge base", "digital garden", "public markdown site"); starter_or_template_paths = @("content/", "quartz.config.ts", "quartz.layout.ts"); agent_reuse_notes = "Use when a project needs a navigable markdown knowledge site like vipin wiki; copy the build adapter pattern rather than mirroring content." }
            [pscustomobject]@{ slug = "docusaurus"; name = "Docusaurus"; category = "docs-framework"; homepage = "https://docusaurus.io"; docs_url = "https://docusaurus.io/docs"; official_demo_url = "https://docusaurus.io/showcase"; repos = @("facebook/docusaurus"); keywords = @("docusaurus", "docs", "documentation", "blog", "site", "static site generator"); reuse_profile = "React-based documentation site framework with docs, blog, versioning, i18n, plugins, and themes."; project_shell_score = 10; recommended_use_cases = @("product docs", "open-source docs", "versioned docs", "blog plus docs"); starter_or_template_paths = @("website/", "packages/create-docusaurus/"); agent_reuse_notes = "Use when project docs need versioning, sidebars, plugin ecosystem, and a mature React site shell." }
            [pscustomobject]@{ slug = "vitepress"; name = "VitePress"; category = "docs-framework"; homepage = "https://vitepress.dev"; docs_url = "https://vitepress.dev/guide/getting-started"; official_demo_url = "https://vitepress.dev"; repos = @("vuejs/vitepress"); keywords = @("vitepress", "vite", "vue", "docs", "markdown", "static site generator"); reuse_profile = "Vite + Vue powered static documentation framework with markdown routing and fast local dev."; project_shell_score = 9; recommended_use_cases = @("fast docs", "Vue ecosystem docs", "small public sites", "markdown docs"); starter_or_template_paths = @("docs/", ".vitepress/"); agent_reuse_notes = "Use when a project wants a lightweight docs shell with Vite speed and Vue customization." }
            [pscustomobject]@{ slug = "nextra"; name = "Nextra"; category = "docs-framework"; homepage = "https://nextra.site"; docs_url = "https://nextra.site/docs"; official_demo_url = "https://nextra.site"; repos = @("shuding/nextra"); keywords = @("nextra", "next", "docs", "mdx", "site generation", "documentation"); reuse_profile = "Next.js-based MDX docs/site framework with themes and file-system content routing."; project_shell_score = 9; recommended_use_cases = @("Next.js docs", "MDX documentation", "developer landing docs", "content site"); starter_or_template_paths = @("examples/", "docs/"); agent_reuse_notes = "Use when the desired shell is docs-first but should stay inside the Next.js ecosystem." }
            [pscustomobject]@{ slug = "fumadocs"; name = "Fumadocs"; category = "docs-framework"; homepage = "https://fumadocs.dev"; docs_url = "https://fumadocs.dev/docs"; official_demo_url = "https://fumadocs.dev"; repos = @("fuma-nama/fumadocs"); keywords = @("fumadocs", "docs", "documentation", "next", "mdx", "ui", "source"); reuse_profile = "Flexible React/Next docs framework with UI components, source adapters, and modern docs UX."; project_shell_score = 9; recommended_use_cases = @("polished docs UX", "Next.js docs", "API docs", "AI/tooling docs"); starter_or_template_paths = @("examples/", "apps/docs/"); agent_reuse_notes = "Use when a project wants a modern docs shell with reusable UI patterns and source adapters." }
            [pscustomobject]@{ slug = "starlight"; name = "Starlight"; category = "docs-framework"; homepage = "https://starlight.astro.build"; docs_url = "https://starlight.astro.build/getting-started/"; official_demo_url = "https://starlight.astro.build"; repos = @("withastro/starlight"); keywords = @("starlight", "astro", "docs", "documentation", "accessible", "content"); reuse_profile = "Astro-powered documentation framework with accessible docs UX and content collections."; project_shell_score = 9; recommended_use_cases = @("Astro docs", "content-heavy docs", "accessible documentation", "static docs"); starter_or_template_paths = @("docs/", "examples/"); agent_reuse_notes = "Use when docs should be static, fast, accessible, and integrated with Astro content patterns." }
            [pscustomobject]@{ slug = "astro"; name = "Astro"; category = "site-framework"; homepage = "https://astro.build"; docs_url = "https://docs.astro.build"; official_demo_url = "https://astro.build/themes/"; repos = @("withastro/astro", "withastro/docs", "withastro/starlight"); keywords = @("astro", "islands", "content", "starlight", "static site", "markdown"); reuse_profile = "Content-driven web framework for sites, blogs, docs, and partial-hydration interactive pages."; project_shell_score = 9; recommended_use_cases = @("content site", "marketing site", "docs site", "blog", "islands architecture"); starter_or_template_paths = @("examples/", "packages/create-astro/"); agent_reuse_notes = "Use when the project is content-first but needs selective interactive islands." }
            [pscustomobject]@{ slug = "nextjs"; name = "Next.js"; category = "app-framework"; homepage = "https://nextjs.org"; docs_url = "https://nextjs.org/docs"; official_demo_url = "https://nextjs.org/showcase"; repos = @("vercel/next.js"); keywords = @("next", "nextjs", "app router", "server components", "starter", "template"); reuse_profile = "React full-stack app shell with routing, server rendering, API/server actions, and deployment conventions."; project_shell_score = 10; recommended_use_cases = @("full-stack React app", "SaaS", "dashboard", "commerce", "server-rendered app"); starter_or_template_paths = @("examples/"); agent_reuse_notes = "Use when a new app needs a mainstream React framework with routing, server components, and deployment path." }
            [pscustomobject]@{ slug = "nuxt"; name = "Nuxt"; category = "app-framework"; homepage = "https://nuxt.com"; docs_url = "https://nuxt.com/docs"; official_demo_url = "https://nuxt.com/templates"; repos = @("nuxt/nuxt", "nuxt/ui", "nuxt/content", "nuxt/image"); keywords = @("nuxt", "vue", "content", "image", "template", "starter", "app framework"); reuse_profile = "Vue full-stack app shell with routing, server engine, content module, UI module, and image pipeline."; project_shell_score = 10; recommended_use_cases = @("Vue full-stack app", "content app", "dashboard", "documentation with Nuxt Content"); starter_or_template_paths = @("examples/", "packages/"); agent_reuse_notes = "Use when the desired shell is Vue-first with strong batteries for content, UI, and deployment." }
            [pscustomobject]@{ slug = "sveltekit"; name = "SvelteKit"; category = "app-framework"; homepage = "https://svelte.dev/docs/kit"; docs_url = "https://svelte.dev/docs/kit"; official_demo_url = "https://svelte.dev"; repos = @("sveltejs/kit"); keywords = @("sveltekit", "routing", "adapter", "app framework", "starter"); reuse_profile = "Svelte app shell with file routing, load functions, adapters, and deploy-target abstraction."; project_shell_score = 9; recommended_use_cases = @("Svelte app", "small full-stack app", "fast interactive frontend", "adapter-driven deployment"); starter_or_template_paths = @("packages/create-svelte/", "documentation/docs/"); agent_reuse_notes = "Use when the app should be Svelte-native and deployment-adapter friendly." }
            [pscustomobject]@{ slug = "remix-react-router"; name = "Remix / React Router"; category = "app-framework"; homepage = "https://reactrouter.com"; docs_url = "https://reactrouter.com"; official_demo_url = "https://remix.run"; repos = @("remix-run/react-router", "remix-run/remix"); keywords = @("remix", "react router", "routing", "data router", "starter", "stack"); reuse_profile = "React routing/data framework for app shells with nested routing, loaders/actions, and Remix stack heritage."; project_shell_score = 9; recommended_use_cases = @("routing-heavy React app", "nested data app", "web app with progressive enhancement"); starter_or_template_paths = @("examples/", "templates/"); agent_reuse_notes = "Use when app architecture should center on routing, data loading, mutations, and nested layouts." }
            [pscustomobject]@{ slug = "tanstack-start"; name = "TanStack Start"; category = "app-framework"; homepage = "https://tanstack.com/start"; docs_url = "https://tanstack.com/start/latest"; official_demo_url = "https://tanstack.com/start"; repos = @("TanStack/router"); keywords = @("tanstack", "start", "router", "app framework", "starter"); reuse_profile = "TanStack Router-centered app shell with typed routing and emerging full-stack Start packages."; project_shell_score = 8; recommended_use_cases = @("typed-router app", "TanStack ecosystem app", "experimental full-stack React app"); starter_or_template_paths = @("examples/"); agent_reuse_notes = "Use when typed routing and TanStack ecosystem integration matter more than framework maturity." }
            [pscustomobject]@{ slug = "vite"; name = "Vite"; category = "build-tooling"; homepage = "https://vite.dev"; docs_url = "https://vite.dev/guide/"; official_demo_url = "https://vite.dev"; repos = @("vitejs/vite", "vitejs/vite-plugin-react"); keywords = @("vite", "starter", "template", "build tool", "dev server", "plugin"); reuse_profile = "Frontend build/dev-server foundation and starter scaffolding layer used by many modern frameworks."; project_shell_score = 7; recommended_use_cases = @("custom SPA shell", "library playground", "framework starter", "fast dev server"); starter_or_template_paths = @("packages/create-vite/", "packages/plugin-react/"); agent_reuse_notes = "Use when the project needs a minimal custom frontend shell rather than a full app framework." }
            [pscustomobject]@{ slug = "nitro"; name = "Nitro"; category = "build-tooling"; homepage = "https://nitro.build"; docs_url = "https://nitro.build/guide"; official_demo_url = "https://nitro.build"; repos = @("nitrojs/nitro"); keywords = @("nitro", "server toolkit", "deployment", "server", "unjs", "preset"); reuse_profile = "Server toolkit/deployment substrate used by Nuxt and useful for portable server endpoints."; project_shell_score = 6; recommended_use_cases = @("server runtime layer", "portable API server", "deployment adapter research"); starter_or_template_paths = @("examples/", "playground/"); agent_reuse_notes = "Use as backend/deployment substrate inspiration, not as a visible frontend shell by itself." }
            [pscustomobject]@{ slug = "react"; name = "React"; category = "ui-runtime"; homepage = "https://react.dev"; docs_url = "https://react.dev"; official_demo_url = "https://react.dev"; repos = @("facebook/react", "reactjs/react.dev"); keywords = @("react", "jsx", "fiber", "server components"); reuse_profile = "UI runtime/dependency substrate; usually pair with Next.js, Remix, Docusaurus, Nextra, or Fumadocs for a project shell."; project_shell_score = 4; recommended_use_cases = @("component runtime", "UI substrate", "library ecosystem base"); starter_or_template_paths = @("fixtures/", "compiler/"); agent_reuse_notes = "Do not treat as a complete project shell; choose a React-based framework when starting an app/docs site." }
            [pscustomobject]@{ slug = "vue"; name = "Vue"; category = "ui-runtime"; homepage = "https://vuejs.org"; docs_url = "https://vuejs.org/guide/"; official_demo_url = "https://play.vuejs.org"; repos = @("vuejs/core", "vuejs/docs", "vuejs/router", "vuejs/pinia", "vuejs/devtools"); keywords = @("vue", "pinia", "router", "devtools"); reuse_profile = "UI runtime/dependency substrate; usually pair with Nuxt or VitePress for a full project shell."; project_shell_score = 4; recommended_use_cases = @("Vue component runtime", "state/router ecosystem", "dependency substrate"); starter_or_template_paths = @("packages/", "src/"); agent_reuse_notes = "Do not treat as a complete app shell by itself; use Nuxt or VitePress when a project scaffold is needed." }
            [pscustomobject]@{ slug = "angular"; name = "Angular"; category = "app-framework"; homepage = "https://angular.dev"; docs_url = "https://angular.dev/overview"; official_demo_url = "https://angular.dev"; repos = @("angular/angular", "angular/angular-cli", "angular/components"); keywords = @("angular", "material", "cli", "components", "app framework"); reuse_profile = "Opinionated TypeScript application framework with CLI, routing, components, and Material ecosystem."; project_shell_score = 8; recommended_use_cases = @("enterprise app", "TypeScript app", "opinionated frontend shell", "component-system app"); starter_or_template_paths = @("packages/angular/cli", "src/material/"); agent_reuse_notes = "Use when project wants a batteries-included, TypeScript-heavy, opinionated app framework." }
            [pscustomobject]@{ slug = "svelte"; name = "Svelte"; category = "ui-runtime"; homepage = "https://svelte.dev"; docs_url = "https://svelte.dev/docs"; official_demo_url = "https://svelte.dev/playground"; repos = @("sveltejs/svelte", "sveltejs/kit", "sveltejs/svelte.dev"); keywords = @("svelte", "sveltekit", "compiler"); reuse_profile = "Compiler/runtime substrate; SvelteKit is the project shell layer for apps."; project_shell_score = 5; recommended_use_cases = @("compiled UI runtime", "Svelte component model", "SvelteKit substrate"); starter_or_template_paths = @("packages/", "sites/"); agent_reuse_notes = "Use SvelteKit, not raw Svelte alone, when the goal is a reusable app shell." }
            [pscustomobject]@{ slug = "solid"; name = "Solid"; category = "ui-runtime"; homepage = "https://www.solidjs.com"; docs_url = "https://docs.solidjs.com"; official_demo_url = "https://playground.solidjs.com"; repos = @("solidjs/solid", "solidjs/solid-start", "solidjs/solid-docs"); keywords = @("solid", "fine-grained", "signals", "solidstart"); reuse_profile = "Fine-grained UI runtime plus SolidStart app shell signals; useful for highly reactive apps."; project_shell_score = 6; recommended_use_cases = @("fine-grained reactive UI", "Solid app", "signals-first UI"); starter_or_template_paths = @("packages/", "examples/"); agent_reuse_notes = "Use SolidStart/templates for project shell decisions; raw Solid is runtime substrate." }
            [pscustomobject]@{ slug = "qwik"; name = "Qwik"; category = "app-framework"; homepage = "https://qwik.dev"; docs_url = "https://qwik.dev/docs/"; official_demo_url = "https://qwik.dev/examples/"; repos = @("QwikDev/qwik", "BuilderIO/qwik"); keywords = @("qwik", "resumable", "builderio", "starter", "app framework"); reuse_profile = "Resumability-focused app framework/runtime for highly lazy-loaded interactive sites."; project_shell_score = 8; recommended_use_cases = @("resumable app", "performance-sensitive site", "edge-friendly interactive site"); starter_or_template_paths = @("packages/create-qwik/", "starters/", "examples/"); agent_reuse_notes = "Use when startup performance and resumability are central design goals." }
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
    if ($FrameworkCategory -in @("knowledge-site-framework", "docs-framework", "site-framework", "app-framework", "build-tooling", "ui-runtime")) { return $FrameworkCategory }
    if ($name -match 'docs|dev|website') { return "docs-framework" }
    if ($name -match 'devtools') { return "devtools" }
    if ($name -match 'router') { return "router" }
    if ($name -match 'pinia|state') { return "state-management" }
    if ($name -match 'components|ui') { return "component-system" }
    if ($name -match 'content') { return "content" }
    if ($name -match 'image') { return "image" }
    if ($name -match 'cli|starter|template|example') { return "starter-template" }
    return $FrameworkCategory
}

function Get-FrameworkField([object]$Framework, [string]$Name, [object]$Default = "") {
    if ($Framework.PSObject.Properties.Name -contains $Name -and $null -ne $Framework.$Name) { return $Framework.$Name }
    return $Default
}

function Convert-ToMarkdownList([object]$Items, [string]$Fallback) {
    $list = @(Convert-ToObjectArray $Items | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    if ($list.Count -eq 0) { return "- $Fallback" }
    return ($list | ForEach-Object { "- $(Escape-WikiText ([string]$_))" }) -join "`n"
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
    $keywords = 'breaking|migration|migrate|deprecated|new|feature|api|compiler|runtime|router|routing|data|server|client|performance|fix|security|adapter|react|vue|svelte|solid|qwik|astro|next|nuxt|docs|documentation|markdown|mdx|theme|plugin|template|starter|example|content|deploy|deployment|config|layout|sidebar|search|i18n|version'
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
    $reuseProfile = Escape-WikiText ([string](Get-FrameworkField $Framework "reuse_profile" "No reuse profile was recorded in the registry."))
    $score = Get-FrameworkField $Framework "project_shell_score" ""
    $docsUrl = Get-FrameworkField $Framework "docs_url" ""
    $demoUrl = Get-FrameworkField $Framework "official_demo_url" ""
    $useCaseLines = Convert-ToMarkdownList (Get-FrameworkField $Framework "recommended_use_cases" @()) "No recommended use cases were recorded."
    $starterLines = Convert-ToMarkdownList (Get-FrameworkField $Framework "starter_or_template_paths" @()) "No starter/template paths were recorded."
    $agentNotes = Escape-WikiText ([string](Get-FrameworkField $Framework "agent_reuse_notes" "No agent reuse notes were recorded."))
    $shellNote = if ($Framework.category -eq "ui-runtime") { "- INFERRED: This is usually a dependency substrate, not a complete project shell; pick a paired app/docs framework when starting a new project." } else { "- INFERRED: This can be evaluated as a reusable project shell or major project layer." }
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
- EXTRACTED: Docs URL: $docsUrl
- EXTRACTED: Demo/showcase URL: $demoUrl
- EXTRACTED: Project shell score: ``$score``.
- EXTRACTED: Curated official repositories captured in this corpus: $($RepoEntries.Count).
$shellNote

## Reuse Profile

$reuseProfile

## Recommended Use Cases

$useCaseLines

## Starter Or Template Clues

$starterLines

## Agent Reuse Notes

$agentNotes

## Repositories

$repoLines

## Recent Captured Releases

$releaseLines

## Navigation

- [[frontend-frameworks-public]]
- [[frontend-project-shell-taxonomy]]
- [[frontend-framework-reuse-map]]
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
    $docsUrl = if ($Entry.docs_url) { [string]$Entry.docs_url } else { "Not recorded." }
    $demoUrl = if ($Entry.official_demo_url) { [string]$Entry.official_demo_url } else { "Not recorded." }
    $reuseProfile = Escape-WikiText ([string]$Entry.reuse_profile)
    $agentNotes = Escape-WikiText ([string]$Entry.agent_reuse_notes)
    $useCaseLines = Convert-ToMarkdownList $Entry.recommended_use_cases "No recommended use cases were recorded."
    $starterLines = Convert-ToMarkdownList $Entry.starter_or_template_paths "No starter/template paths were recorded."
    $shellGuidance = if ($Entry.ecosystem_role -eq "ui-runtime") { "- INFERRED: Treat this repo as a runtime/dependency substrate; do not start from it alone when the goal is a full project shell." } else { "- INFERRED: Treat this repo as a reusable shell/layer candidate; inspect docs, examples, and release notes before transplanting patterns." }
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
- Documentation URL: $docsUrl
- Demo/showcase URL: $demoUrl
- Framework: $frameworkLink
- Ecosystem role: ``$($Entry.ecosystem_role)``
- Project shell score: ``$($Entry.project_shell_score)``
- Source confidence: ``$($Entry.source_confidence)``
- Public handling: ``$($Entry.public_handling)``
- Semantic hash: ``$($Entry.semantic_hash)``

## Summary

$($Entry.summary)

## Reuse Profile

$reuseProfile

## When To Reuse

$useCaseLines

## Starter Or Template Clues

$starterLines

## Agent Reuse Notes

$agentNotes
$shellGuidance

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
- [[frontend-project-shell-taxonomy]]
- [[frontend-framework-reuse-map]]

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

## Navigation

- [[frontend-frameworks-public]]
- [[frontend-framework-reuse-map]]
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

$newRegistry = New-Registry
Write-TextIfChanged $registryPath ($newRegistry | ConvertTo-Json -Depth 12) | Out-Null

$registry = if ($DryRun) { $newRegistry } else { Read-TextFile $registryPath | ConvertFrom-Json }
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
        docs_url = Get-FrameworkField $framework "docs_url" ""
        official_demo_url = Get-FrameworkField $framework "official_demo_url" ""
        ecosystem_role = $framework.category
        repos = @($frameworkRepos)
        reuse_profile = Get-FrameworkField $framework "reuse_profile" ""
        project_shell_score = Get-FrameworkField $framework "project_shell_score" ""
        recommended_use_cases = @(Convert-ToObjectArray (Get-FrameworkField $framework "recommended_use_cases" @()))
        starter_or_template_paths = @(Convert-ToObjectArray (Get-FrameworkField $framework "starter_or_template_paths" @()))
        agent_reuse_notes = Get-FrameworkField $framework "agent_reuse_notes" ""
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
                docs_url = Get-FrameworkField $framework "docs_url" ""
                official_demo_url = Get-FrameworkField $framework "official_demo_url" ""
                ecosystem_role = $role
                reuse_profile = Get-FrameworkField $framework "reuse_profile" ""
                project_shell_score = Get-FrameworkField $framework "project_shell_score" ""
                recommended_use_cases = @(Convert-ToObjectArray (Get-FrameworkField $framework "recommended_use_cases" @()))
                starter_or_template_paths = @(Convert-ToObjectArray (Get-FrameworkField $framework "starter_or_template_paths" @()))
                agent_reuse_notes = Get-FrameworkField $framework "agent_reuse_notes" ""
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
                    docs_url = Get-FrameworkField $framework "docs_url" ""
                    official_demo_url = Get-FrameworkField $framework "official_demo_url" ""
                    published_at = [string]$release.published_at
                    prerelease = [bool]$release.prerelease
                    author = if ($release.author -and $release.author.login) { [string]$release.author.login } else { "" }
                    body_hash = $bodyHash
                    content_hash = $bodyHash
                    semantic_hash = $releaseSemanticHash
                    idea_bullets = @(Get-ReleaseIdeaBullets $body)
                    summary = Get-ShortText -Text $body -Limit 520
                    ecosystem_role = $role
                    project_shell_score = Get-FrameworkField $framework "project_shell_score" ""
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
            $shellKeywords = @("docs", "documentation", "site generator", "starter", "template", "theme", "content", "markdown", "mdx", "ssg", "app framework", "example", "showcase", "plugin") + @($framework.keywords)
            foreach ($keyword in ($shellKeywords | Sort-Object -Unique)) {
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

function Get-FrameworkRowsForCategories([string[]]$Categories) {
    $rows = @($registry.frameworks | Where-Object { $Categories -contains $_.category } | Sort-Object @{ Expression = "project_shell_score"; Descending = $true }, name | ForEach-Object {
        $framework = $_
        $frameworkRepos = @($repoEntries | Where-Object { @($_.framework_slugs) -contains $framework.slug })
        "| {0} | ``{1}`` | ``{2}`` | {3} | {4} | {5} |" -f (Format-FrameworkLink $framework.slug $framework.name), $framework.category, (Get-FrameworkField $framework "project_shell_score" ""), $frameworkRepos.Count, (Get-FrameworkField $framework "docs_url" $framework.homepage), (Get-FrameworkField $framework "official_demo_url" "")
    })
    if ($rows.Count -eq 0) { return "| No frameworks captured. |  |  |  |  |  |" }
    return $rows -join "`n"
}

$knowledgeRows = Get-FrameworkRowsForCategories @("knowledge-site-framework")
$docsRows = Get-FrameworkRowsForCategories @("docs-framework")
$appRows = Get-FrameworkRowsForCategories @("app-framework", "site-framework")
$toolRows = Get-FrameworkRowsForCategories @("build-tooling")
$runtimeRows = Get-FrameworkRowsForCategories @("ui-runtime")

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

This hub tracks reusable frontend project frameworks: knowledge-site shells, documentation frameworks, app frameworks, build substrates, and lower-level UI runtimes. The goal is project reuse: when a future project needs a frontend, a human or agent should be able to click through from use case to framework, repository, docs, demo, and release ideas.

The current ``vipin wiki`` publishing layer uses Quartz v4 through the local ``site/`` adapter and ``.wiki-tmp/quartz`` build flow.

## Choose By Project Need

### I Need A Personal Wiki Or Knowledge Site

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
$knowledgeRows

### I Need Documentation Or Developer Docs

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
$docsRows

### I Need A Website Or App Shell

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
$appRows

### I Need Build Or Server Tooling

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
$toolRows

### I Need A UI Runtime Or Dependency Substrate

These are important, but usually not enough by themselves for a complete project shell.

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
$runtimeRows

## Full Matrix

| Framework | Role | Captured repos | Homepage |
| --- | --- | ---: | --- |
$frameworkRows

## Entry Points

- [[frontend-project-shell-taxonomy]] - Browse frameworks by reusable project-shell role.
- [[frontend-framework-reuse-map]] - Decide which framework to migrate into a future project.
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
- Treat ``ui-runtime`` entries as dependency substrates unless their registry notes explicitly identify a complete project shell.

## Counterpoints And Gaps

- AMBIGUOUS: The corpus is complete only inside the curated project-framework registry boundary, not across every repo in each owner organization.
- AMBIGUOUS: Candidate discovery is keyword-based and may miss official repos whose descriptions/topics do not match project-shell keywords.
- INFERRED: Stars, file profiles, and release ordering are crawl-time signals and should not be treated as stable quality rankings.
"@
Write-TextIfChanged (Join-Path $rootPath "wiki\topics\frontend-frameworks-public.md") $hubContent | Out-Null

$taxonomyContent = @"
---
title: Frontend Project Shell Taxonomy
type: analysis
status: active
created: $today
updated: $today
tags:
  - frontend-frameworks
  - project-shells
  - taxonomy
  - github
source_pages:
  - raw/frontend-frameworks-public/registry.json
  - raw/frontend-frameworks-public/manifest.json
---

# Frontend Project Shell Taxonomy

This taxonomy groups captured frontend repositories by reusable project role rather than popularity alone. Its first question is: can this help start or migrate a future frontend project?

## Shell Score Guide

- ``10``: complete project shell with docs, routing/content conventions, examples, and clear deployment path.
- ``8-9``: strong app/site shell, sometimes with a narrower ecosystem or more evolving API.
- ``6-7``: important tooling or partial shell; useful when composing a custom project.
- ``4-5``: dependency substrate/runtime; pair with a framework shell before starting a project.

$roleGroups

## Related

- [[frontend-frameworks-public]]
- [[frontend-framework-reuse-map]]

## Counterpoints And Gaps

- AMBIGUOUS: Ecosystem roles are registry-level project-reuse labels; some repos legitimately span docs, app, and runtime layers.
- INFERRED: Role grouping is for project selection and retrieval, not a definitive taxonomy of each framework's architecture.
"@
Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\frontend-project-shell-taxonomy.md") $taxonomyContent | Out-Null

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
title: Frontend Framework Reuse Map
type: analysis
status: active
created: $today
updated: $today
tags:
  - frontend-frameworks
  - project-shells
  - reuse-map
  - releases
source_pages:
  - raw/frontend-frameworks-public/registry.json
  - raw/frontend-frameworks-public/manifest.json
---

# Frontend Framework Reuse Map

This page explains what each captured frontend project framework is trying to provide, when to reuse it, and which release ideas matter for future project migration.

$ideaSections

## Related

- [[frontend-frameworks-public]]
- [[frontend-project-shell-taxonomy]]

## Counterpoints And Gaps

- AMBIGUOUS: Release idea bullets are extracted summaries from GitHub release bodies and may omit lower-signal fixes or package-specific context.
- INFERRED: Repository summaries come from README/changelog snippets and metadata; use canonical GitHub links for full current project intent before migrating patterns.
"@
Write-TextIfChanged (Join-Path $rootPath "wiki\analyses\frontend-framework-reuse-map.md") $ideaContent | Out-Null

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

## Corpus Interpretation

- EXTRACTED: This corpus is now organized around reusable frontend project shells: knowledge-site frameworks, documentation frameworks, app frameworks, build tooling, and UI/runtime substrates.
- INFERRED: UI runtime entries such as React and Vue are important dependency layers but are not usually complete project shells by themselves.
- EXTRACTED: The current ``vipin wiki`` public site build uses Quartz v4 through the local ``site/`` adapter and temporary Quartz checkout flow.

## Public Handling

- EXTRACTED: Public pages record GitHub metadata, summaries, reuse notes, release idea bullets, hashes, docs/demo links, and canonical links.
- INFERRED: Full source code and long release bodies remain outside the public wiki unless a future license-aware mirror policy is added.
- AMBIGUOUS: Candidate repositories require human registry review before promotion.

## Related

- [[frontend-frameworks-public]]
- [[frontend-project-shell-taxonomy]]
- [[frontend-framework-reuse-map]]
"@
Write-TextIfChanged (Join-Path $rootPath "wiki\sources\2026-05-16-frontend-frameworks-public-corpus.md") $sourceContent | Out-Null

$homePath = Join-Path $rootPath "wiki\home.md"
if (Test-Path -LiteralPath $homePath) {
    $homeText = Read-TextFile $homePath
    $homeLine = "- [[frontend-frameworks-public]] - Curated public corpus for reusable frontend project shells, docs/wiki frameworks, app frameworks, build tooling, and release ideas."
    if ($homeText -notmatch [regex]::Escape($homeLine)) {
        $homeText = $homeText -replace '(?m)^- \[\[frontend-frameworks-public\]\].*\r?\n?', ''
        $homeText = $homeText -replace "(## Knowledge Shortcuts)", "## Knowledge Shortcuts`n`n$homeLine"
        Write-TextIfChanged $homePath $homeText | Out-Null
    }
}

$indexPath = Join-Path $rootPath "wiki\index.md"
if (Test-Path -LiteralPath $indexPath) {
    $indexText = Read-TextFile $indexPath
    $indexText = $indexText -replace '(?m)^- \[\[frontend-frameworks-public\]\].*\r?\n?', ''
    $indexText = $indexText -replace '(?m)^- \[\[frontend-framework-taxonomy\]\].*\r?\n?', ''
    $indexText = $indexText -replace '(?m)^- \[\[frontend-framework-idea-map\]\].*\r?\n?', ''
    $indexText = Add-OrReplaceIndexLine $indexText "## Topics" "- [[frontend-frameworks-public]] - Curated public corpus for reusable frontend project shells, documentation/wiki frameworks, app frameworks, build tooling, and release ideas."
    $indexText = Add-OrReplaceIndexLine $indexText "## Sources" "- [[2026-05-16-frontend-frameworks-public-corpus]] - Batch ingest of frontend project framework GitHub repositories, release summaries, reuse metadata, language profiles, and candidate discovery."
    $indexText = Add-OrReplaceIndexLine $indexText "## Analyses" "- [[frontend-project-shell-taxonomy]] - Category map of captured frontend project frameworks by reusable shell role."
    $indexText = Add-OrReplaceIndexLine $indexText "## Analyses" "- [[frontend-framework-reuse-map]] - Reuse and migration map for captured frontend project frameworks."
    $entityIndexLines = @($registry.frameworks | Sort-Object name | ForEach-Object {
        "- [[entities/frontend-frameworks/{0}|{1}]] - Project framework entity page with reuse profile, shell score, curated repos, releases, docs, and navigation." -f $_.slug, $_.name
    }) -join "`n"
    $repoIndexLines = @($repoEntries | Sort-Object repo_full_name | ForEach-Object {
        "- [[sources/frontend-frameworks/{0}|{1}]] - GitHub repo source page for {2}, reuse profile, docs/demo links, language profile, release pointer, hashes, and metadata." -f $_.page_slug, $_.repo_full_name, ($_.framework_names -join ", ")
    }) -join "`n"
    $releaseIndexLines = @($releaseEntries | Sort-Object repo_full_name, tag_name | ForEach-Object {
        "- [[sources/frontend-frameworks/releases/{0}|{1} {2}]] - Captured GitHub release summary, project-shell idea bullets, and body hash." -f $_.page_slug, $_.repo_full_name, $_.tag_name
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
  - [[frontend-project-shell-taxonomy]]
  - [[frontend-framework-reuse-map]]
  - `wiki/entities/frontend-frameworks/`
  - `wiki/sources/frontend-frameworks/`
- Sources used:
  - GitHub repository, language, tree, and release APIs for the curated registry in `raw/frontend-frameworks-public/registry.json`
- Notes:
  - Reframed the corpus around reusable frontend project shells, documentation/wiki frameworks, app frameworks, build tooling, and UI/runtime substrates.
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
    schema = "frontend-project-frameworks-public-corpus-v2"
    generated_at = if (($newEntries.Count -gt 0) -or ($updatedEntries.Count -gt 0) -or -not (Test-Path -LiteralPath $manifestPath)) { $runStamp } elseif ($oldManifest -and $oldManifest.generated_at) { $oldManifest.generated_at } else { $runStamp }
    mode = $Mode
    public_handling = "Public wiki pages contain metadata, reuse profiles, docs/demo links, project-shell release idea bullets, hashes, language profiles, and links only; full source code and long unlicensed release text are not mirrored publicly."
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
    schema = "frontend-project-frameworks-public-capture-v2"
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
