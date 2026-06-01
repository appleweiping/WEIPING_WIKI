param(
    [int]$MaxTopLevelItems = 160,
    [switch]$IncludeHidden
)

$ErrorActionPreference = "Stop"

function Format-Size($bytes) {
    if ($null -eq $bytes -or $bytes -eq "") { return "" }
    $n = [double]$bytes
    foreach ($unit in @("B", "KB", "MB", "GB", "TB")) {
        if ($n -lt 1024 -or $unit -eq "TB") {
            return ("{0:N1} {1}" -f $n, $unit)
        }
        $n = $n / 1024
    }
}

function Escape-MarkdownCell($text) {
    if ($null -eq $text) { return "" }
    return ([string]$text) -replace '\|', '\|'
}

function Write-TopLevel($root) {
    if (-not (Test-Path -LiteralPath $root)) {
        return
    }
    Write-Output ""
    Write-Output "## Top Level: $root"
    Write-Output ""
    Write-Output "| Name | Kind | Size | Last modified |"
    Write-Output "| --- | --- | ---: | --- |"

    $items = Get-ChildItem -LiteralPath $root -Force:$IncludeHidden -ErrorAction SilentlyContinue |
        Sort-Object { -not $_.PSIsContainer }, Name |
        Select-Object -First $MaxTopLevelItems

    foreach ($item in $items) {
        $kind = if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            "link/junction"
        } elseif ($item.PSIsContainer) {
            "dir"
        } else {
            "file"
        }
        $name = Escape-MarkdownCell $item.Name
        $size = if ($item.PSIsContainer) { "" } else { Format-Size $item.Length }
        Write-Output "| $name | $kind | $size | $($item.LastWriteTime.ToString('yyyy-MM-dd HH:mm')) |"
    }
}

Write-Output "# Computer Inventory Snapshot"
Write-Output ""
Write-Output ("Generated: {0}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz"))
Write-Output ""
Write-Output "This is a shallow public-safety-oriented inventory. It lists drive and top-level routing facts only; it does not read file contents."
Write-Output ""
Write-Output "## Drives"
Write-Output ""
Write-Output "| Drive | Root | Used | Free |"
Write-Output "| --- | --- | ---: | ---: |"

Get-PSDrive -PSProvider FileSystem |
    Sort-Object Name |
    ForEach-Object {
        Write-Output "| $(Escape-MarkdownCell $_.Name) | $(Escape-MarkdownCell $_.Root) | $(Format-Size $_.Used) | $(Format-Size $_.Free) |"
    }

foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Sort-Object Name)) {
    Write-TopLevel $drive.Root
}

$userProfile = [Environment]::GetFolderPath("UserProfile")
if ($userProfile) {
    Write-TopLevel $userProfile
    Write-Output ""
    Write-Output "## User Profile Junctions"
    Write-Output ""
    Write-Output '```text'
    $junctionCommand = 'dir "' + $userProfile + '" /AL'
    & cmd.exe /d /c $junctionCommand 2>$null
    Write-Output '```'
}
