param(
    [string]$CcCmd = "D:\devtools\cc.cmd",
    [string]$PixelCatExe = "D:\devtools\pixelcat-app.exe",
    [string]$PixelCatConfig = "$env:APPDATA\PixelCat\config.json",
    [string]$HostName = "127.0.0.1",
    [int]$Port = 8990,
    [switch]$LaunchIfMissing,
    [switch]$SkipApiProbe,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

function Test-TcpPort {
    param(
        [string]$HostName,
        [int]$Port,
        [int]$TimeoutMs = 1500
    )

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $async = $client.BeginConnect($HostName, $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($TimeoutMs)) {
            return $false
        }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

function Get-PixelCatApiKey {
    param([string]$ConfigPath)

    if ($env:ANTHROPIC_AUTH_TOKEN) {
        return $env:ANTHROPIC_AUTH_TOKEN
    }
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        return $null
    }

    $raw = Get-Content -LiteralPath $ConfigPath -Raw -ErrorAction Stop
    $match = [regex]::Match($raw, '"apiKey"\s*:\s*"([^"]+)"')
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return $null
}

function Invoke-PixelCatProbe {
    param(
        [string]$BaseUrl,
        [string]$ApiKey
    )

    if (-not $ApiKey) {
        return @{
            ok = $false
            status = "missing_api_key"
            http_status = $null
            detail = "No ANTHROPIC_AUTH_TOKEN or PixelCat config apiKey was found."
        }
    }

    $headers = @{
        "x-api-key" = $ApiKey
        "anthropic-version" = "2023-06-01"
        "content-type" = "application/json"
    }
    $body = @{
        model = "claude-haiku-4-5-20251001"
        max_tokens = 1
        messages = @(@{
            role = "user"
            content = "O"
        })
    } | ConvertTo-Json -Depth 5

    try {
        Add-Type -AssemblyName System.Net.Http -ErrorAction SilentlyContinue
        $client = [System.Net.Http.HttpClient]::new()
        $client.Timeout = [TimeSpan]::FromSeconds(25)
        $request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Post, "$BaseUrl/v1/messages")
        foreach ($key in $headers.Keys) {
            if ($key -eq "content-type") { continue }
            [void]$request.Headers.TryAddWithoutValidation($key, $headers[$key])
        }
        $request.Content = [System.Net.Http.StringContent]::new($body, [Text.Encoding]::UTF8, "application/json")
        $response = $client.SendAsync($request).GetAwaiter().GetResult()
        $responseBody = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        if (-not $response.IsSuccessStatusCode) {
            throw [System.Net.WebException]::new("HTTP $([int]$response.StatusCode): $responseBody")
        }
        return @{
            ok = $true
            status = "api_ok"
            http_status = [int]$response.StatusCode
            detail = "PixelCat accepted a minimal Anthropic-compatible messages request."
        }
    } catch {
        $resp = $_.Exception.Response
        $code = if ($resp) { [int]$resp.StatusCode } else { $null }
        $bodyText = ""
        if ($resp) {
            try {
                $reader = [IO.StreamReader]::new($resp.GetResponseStream())
                $bodyText = $reader.ReadToEnd()
            } catch {
                $bodyText = ""
            }
        }
        if (-not $bodyText -and $_.Exception.Message -match '^HTTP\s+(\d+):\s*(.*)$') {
            $code = [int]$Matches[1]
            $bodyText = $Matches[2]
        }

        $status = "api_error"
        $recommendation = "Inspect PixelCat, then retry this script."
        if ($code -eq 502 -and ($bodyText -match "0/1" -or $bodyText -match "(?i)credential|disabled|upstream")) {
            $status = "upstream_credentials_disabled"
            $recommendation = "PixelCat is running, but its upstream credential pool is disabled. In the PixelCat panel, fix credential/network state, try TUN or another IP/exit node, then rerun this script."
        } elseif ($code -in 401, 403) {
            $status = "local_auth_failed"
            $recommendation = "Check ANTHROPIC_AUTH_TOKEN or the PixelCat config apiKey."
        } elseif ($code -eq 429) {
            $status = "rate_limited"
            $recommendation = "Wait for the rate limit window or lower concurrent CC calls."
        }

        return @{
            ok = $false
            status = $status
            http_status = $code
            detail = $bodyText
            recommendation = $recommendation
        }
    }
}

$result = [ordered]@{
    cc_cmd = $CcCmd
    cc_exists = Test-Path -LiteralPath $CcCmd
    cc_version = $null
    pixelcat_exe = $PixelCatExe
    pixelcat_exe_exists = Test-Path -LiteralPath $PixelCatExe
    pixelcat_port = "$HostName`:$Port"
    port_listening = $false
    api_probe = $null
    final_status = "unknown"
    recommendation = $null
}

if ($result.cc_exists) {
    try {
        $result.cc_version = (& $CcCmd --version 2>&1 | Out-String).Trim()
    } catch {
        $result.cc_version = "version check failed: $($_.Exception.Message)"
    }
}

$result.port_listening = Test-TcpPort -HostName $HostName -Port $Port

if (-not $result.port_listening -and $LaunchIfMissing -and $result.pixelcat_exe_exists) {
    Start-Process -FilePath $PixelCatExe -WindowStyle Normal
    Start-Sleep -Seconds 4
    $result.port_listening = Test-TcpPort -HostName $HostName -Port $Port
}

if (-not $result.cc_exists) {
    $result.final_status = "cc_cmd_missing"
    $result.recommendation = "Restore D:\devtools\cc.cmd before using the CC partner family."
} elseif (-not $result.port_listening) {
    $result.final_status = "pixelcat_not_listening"
    $result.recommendation = "Open PixelCat or rerun with -LaunchIfMissing, then retry."
} elseif ($SkipApiProbe) {
    $result.final_status = "port_ok_api_not_checked"
    $result.recommendation = "Port is open, but run without -SkipApiProbe before counting CC partners as available."
} else {
    $apiKey = Get-PixelCatApiKey -ConfigPath $PixelCatConfig
    $probe = Invoke-PixelCatProbe -BaseUrl "http://$HostName`:$Port" -ApiKey $apiKey
    $result.api_probe = $probe
    $result.final_status = $probe.status
    $result.recommendation = if ($probe.ok) { "CC partner path is available." } else { $probe.recommendation }
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    Write-Output "cc: $($result.cc_version)"
    Write-Output "PixelCat port $($result.pixelcat_port): $($result.port_listening)"
    Write-Output "Status: $($result.final_status)"
    if ($result.api_probe -and $result.api_probe.http_status) {
        Write-Output "HTTP: $($result.api_probe.http_status)"
    }
    if ($result.recommendation) {
        Write-Output "Recommendation: $($result.recommendation)"
    }
}
