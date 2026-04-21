param(
    [string]$Root = ".",
    [string]$Output = "wiki\\knowledge-graph.md"
)

$ErrorActionPreference = "Stop"

$rootPath = (Resolve-Path $Root).Path
$wikiPath = Join-Path $rootPath "wiki"
$outputPath = Join-Path $rootPath $Output

if (-not (Test-Path $wikiPath)) {
    throw "wiki directory not found: $wikiPath"
}

$files = Get-ChildItem -LiteralPath $wikiPath -Recurse -File -Filter *.md |
    Where-Object { $_.FullName -notlike "*\_templates\*" }

$nodes = @{}
$edges = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
    $source = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $nodes[$source] = $true
    $content = Get-Content $file.FullName -Raw
    $matches = [regex]::Matches($content, '\[\[([^\]]+)\]\]')
    foreach ($match in $matches) {
        $target = $match.Groups[1].Value.Trim()
        if ([string]::IsNullOrWhiteSpace($target)) { continue }
        $target = ($target -split '\|')[0].Trim()
        if ([string]::IsNullOrWhiteSpace($target)) { continue }
        $nodes[$target] = $true
        $edges.Add("$source`t$target")
    }
}

$edgeLines = $edges | Sort-Object -Unique
$nodeCount = ($nodes.Keys | Measure-Object).Count
$edgeCount = ($edgeLines | Measure-Object).Count

$graphLines = New-Object System.Collections.Generic.List[string]
$graphLines.Add("---")
$graphLines.Add("title: Knowledge Graph")
$graphLines.Add("type: analysis")
$graphLines.Add("status: generated")
$graphLines.Add("created: 2026-04-21")
$graphLines.Add("updated: $(Get-Date -Format 'yyyy-MM-dd')")
$graphLines.Add("tags:")
$graphLines.Add("  - graph")
$graphLines.Add("  - generated")
$graphLines.Add("---")
$graphLines.Add("")
$graphLines.Add("# Knowledge Graph")
$graphLines.Add("")
$graphLines.Add("> Auto-generated from public wiki links on $(Get-Date -Format 'yyyy-MM-dd HH:mm').")
$graphLines.Add("> Nodes: $nodeCount | Edges: $edgeCount")
$graphLines.Add("")
$graphLines.Add('```mermaid')
$graphLines.Add("graph LR")

foreach ($edge in $edgeLines) {
    $parts = $edge -split "`t", 2
    $source = $parts[0].Replace('"', "'")
    $target = $parts[1].Replace('"', "'")
    $edgeLine = '  "{0}" --> "{1}"' -f $source, $target
    $graphLines.Add($edgeLine)
}

$graphLines.Add('```')
$graphLines.Add("")
$graphLines.Add("## Notes")
$graphLines.Add("")
$graphLines.Add("- This graph only uses public wiki pages.")
$graphLines.Add("- Private materials are intentionally excluded.")

$parent = Split-Path -Parent $outputPath
if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent | Out-Null
}

Set-Content -LiteralPath $outputPath -Value $graphLines -Encoding UTF8
Write-Output "Wrote $outputPath"
