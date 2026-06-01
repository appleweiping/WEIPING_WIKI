param(
    [ValidateSet("whole-computer")]
    [string]$Scope = "whole-computer",
    [string]$Root = ".",
    [switch]$Json,
    [int]$MaxTopLevelItems = 40,
    [int]$MaxAuditItems = 25
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path $Root).Path
$scriptPath = Join-Path $resolvedRoot "scripts\wiki.py"
$argsList = @(
    $scriptPath,
    "--root",
    $resolvedRoot,
    "maintain",
    "--scope",
    $Scope,
    "--max-top-level-items",
    $MaxTopLevelItems,
    "--max-audit-items",
    $MaxAuditItems
)

if ($Json) {
    $argsList += "--json"
}

python @argsList
