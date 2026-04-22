param(
    [string]$Root = ".",
    [switch]$Stdout
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path (Resolve-Path $Root).Path "scripts\wiki-catalog.py"
$argsList = @($scriptPath, "--root", (Resolve-Path $Root).Path)
if ($Stdout) {
    $argsList += "--stdout"
}

python @argsList
