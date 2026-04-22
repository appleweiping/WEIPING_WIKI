param(
    [Parameter(Mandatory = $true)]
    [string]$Query,
    [string]$Root = ".",
    [int]$Top = 8,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path (Resolve-Path $Root).Path "scripts\wiki-search.py"
$argsList = @($scriptPath, $Query, "--root", (Resolve-Path $Root).Path, "--top", $Top)
if ($Json) {
    $argsList += "--json"
}

python @argsList
