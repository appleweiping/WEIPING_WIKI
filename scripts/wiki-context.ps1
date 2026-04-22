param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("l0", "l1", "query", "page")]
    [string]$Mode,
    [string]$Value,
    [string]$Root = ".",
    [int]$Top = 6
)

$ErrorActionPreference = "Stop"

$scriptPath = Join-Path (Resolve-Path $Root).Path "scripts\wiki-context.py"
$argsList = @($scriptPath, $Mode)
if ($Value) {
    $argsList += $Value
}
$argsList += @("--root", (Resolve-Path $Root).Path, "--top", $Top)

python @argsList
