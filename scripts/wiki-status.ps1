param(
    [string]$Root = ".",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$scriptPath = Join-Path $rootPath "scripts\wiki-status.py"
$argsList = @($scriptPath, "--root", $rootPath)
if ($Json) {
    $argsList += "--json"
}

python @argsList
