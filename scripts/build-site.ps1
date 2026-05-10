param(
    [string]$Root = ".",
    [string]$QuartzRef = "v4"
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$quartzPath = Join-Path $rootPath ".wiki-tmp\quartz"
$contentPath = Join-Path $quartzPath "content"
$publicOutput = Join-Path $rootPath "public"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required to clone Quartz."
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw "node is required to sync the public wiki content."
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "npm is required to install Quartz dependencies. Install npm or run this build in GitHub Actions."
}

if (-not (Test-Path $quartzPath)) {
    git clone --depth 1 --branch $QuartzRef https://github.com/jackyzha0/quartz.git $quartzPath
}

node (Join-Path $rootPath "site\sync-content.mjs") $contentPath
Copy-Item -LiteralPath (Join-Path $rootPath "site\quartz.config.ts") -Destination (Join-Path $quartzPath "quartz.config.ts") -Force
Copy-Item -LiteralPath (Join-Path $rootPath "site\quartz.layout.ts") -Destination (Join-Path $quartzPath "quartz.layout.ts") -Force

Push-Location $quartzPath
try {
    npm ci
    npx quartz build -d content -o public
}
finally {
    Pop-Location
}

if (Test-Path $publicOutput) {
    Remove-Item -LiteralPath $publicOutput -Recurse -Force
}
Copy-Item -LiteralPath (Join-Path $quartzPath "public") -Destination $publicOutput -Recurse

$leaks = Get-ChildItem -LiteralPath $publicOutput -Recurse -File |
    Select-String -Pattern "wiki-private|raw/private" -ErrorAction SilentlyContinue
if ($leaks) {
    throw "Public site build contains private/raw path references."
}

Write-Output "Built public Quartz site at $publicOutput"
