param(
    [string]$Root = ".",
    [string]$QuartzRef = "v4"
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$quartzPath = Join-Path $rootPath ".wiki-tmp\quartz"
$contentPath = Join-Path $quartzPath "content"
$publicOutput = Join-Path $rootPath "public"
$localNodeRoot = Join-Path $rootPath ".wiki-tmp\node"

function Get-CommandPath {
    param([string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }
    return $null
}

function Install-LocalNode {
    param([string]$InstallRoot)

    $marker = Join-Path $InstallRoot "node\node.exe"
    if (Test-Path $marker) {
        return (Split-Path -Parent $marker)
    }

    $downloadDir = Join-Path $InstallRoot "download"
    $extractDir = Join-Path $InstallRoot "extract"
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    $versions = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json"
    $version = ($versions | Where-Object { $_.version -like "v22.*" } | Select-Object -First 1).version
    if (-not $version) {
        throw "Could not find a Node 22 release from nodejs.org."
    }

    $zipName = "node-$version-win-x64.zip"
    $zipPath = Join-Path $downloadDir $zipName
    $url = "https://nodejs.org/dist/$version/$zipName"
    Write-Host "Downloading local Node toolchain: $url"
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $zipPath

    if (Test-Path $extractDir) {
        Remove-Item -LiteralPath $extractDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

    $nodeDir = Get-ChildItem -LiteralPath $extractDir -Directory | Select-Object -First 1
    if (-not $nodeDir) {
        throw "Downloaded Node archive did not contain a toolchain directory."
    }

    $finalDir = Join-Path $InstallRoot "node"
    if (Test-Path $finalDir) {
        Remove-Item -LiteralPath $finalDir -Recurse -Force
    }
    Move-Item -LiteralPath $nodeDir.FullName -Destination $finalDir
    return $finalDir
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required to clone Quartz."
}

$nodeCmd = Get-CommandPath "node"
$npmCmd = Get-CommandPath "npm"
if (-not $nodeCmd -or -not $npmCmd) {
    $nodeDir = Install-LocalNode -InstallRoot $localNodeRoot
    $nodeCmd = Join-Path $nodeDir "node.exe"
    $npmCmd = Join-Path $nodeDir "npm.cmd"
}
if (-not (Test-Path $nodeCmd)) {
    throw "node is required to sync the public wiki content."
}
if (-not (Test-Path $npmCmd)) {
    throw "npm is required to install Quartz dependencies."
}

if ((Test-Path $quartzPath) -and -not (Test-Path (Join-Path $quartzPath "package.json"))) {
    Remove-Item -LiteralPath $quartzPath -Recurse -Force
}
if (-not (Test-Path $quartzPath)) {
    git clone --depth 1 --branch $QuartzRef https://github.com/jackyzha0/quartz.git $quartzPath
}

& $nodeCmd (Join-Path $rootPath "site\sync-content.mjs") $contentPath
Copy-Item -LiteralPath (Join-Path $rootPath "site\quartz.config.ts") -Destination (Join-Path $quartzPath "quartz.config.ts") -Force
Copy-Item -LiteralPath (Join-Path $rootPath "site\quartz.layout.ts") -Destination (Join-Path $quartzPath "quartz.layout.ts") -Force

Push-Location $quartzPath
try {
    & $npmCmd ci
    & $npmCmd exec quartz build -- -d content -o public
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
