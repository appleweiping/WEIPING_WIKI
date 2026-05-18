---
title: "Logs Platform"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - chatgpt
  - cookbook
  - example
  - gpt-actions
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/chatgpt/compliance_api/logs_platform
  - https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/compliance_api/logs_platform.ipynb
---

# Logs Platform

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/chatgpt/compliance_api/logs_platform
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/compliance_api/logs_platform.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/chatgpt/compliance_api/logs_platform.ipynb
- Source path: `examples/chatgpt/compliance_api/logs_platform.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `cd88a865f95e7a20d2c81b839e9d6dfa58eb87456629b6bfd73b70ff39fcae33`

## Classification

- Primary category: ChatGPT / GPT Actions
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

OpenAI Compliance Logs Platform quickstart Use this notebook to get started using the OpenAI Compliance Logs Platform. The examples focus on downloading log files so you can ingest them into your SIEM or data lake. - Help Center Overview - API Reference Prerequisites - An Enterprise Compliance API key exported as COMPLIANCE API KEY . - The ChatGPT account ID...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: ChatGPT / GPT Actions.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# OpenAI Compliance Logs Platform quickstart

Use this notebook to get started using the OpenAI Compliance Logs Platform. The examples focus on downloading log files so you can ingest them into your SIEM or data lake.

- [Help Center Overview](https://help.openai.com/en/articles/9261474-compliance-api-for-chatgpt-enterprise-edu-and-chatgpt-for-teachers)
- [API Reference](https://chatgpt.com/admin/api-reference#tag/Compliance-API-Logs-Platform)

## Prerequisites

- An Enterprise Compliance API key exported as `COMPLIANCE_API_KEY`.
- The ChatGPT account ID or the API Platform Org ID for the principal in question.
- Specific requirements for your environment

## Quickstart Scripts

Provided below are functionally identical scripts - one for Unix-based and one for Windows-based environments.
These scripts give an example of how one could build an integration with the Compliance API to retrieve and process
log data for given event types and time ranges.
These scripts handle listing and paging through the available log files and downloading them - writing the output to stdout.

Example invocations of these scripts are embedded in their help blocks - execute them with no arguments to see them.

## Option 1: Unix-based

Prerequisites:
- Save the script locally as `download_compliance_files.sh` and mark it executable
- Make sure you have up-to-date `bash`, `curl`, `sed`, and `date` installed.
- Format the date you want to get every log `after` as an ISO 8601 string including timezone.

Run the script akin to `./download_compliance_files.sh <workspace_or_org_id> <event_type> <limit> <after>`

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <workspace_or_org_id> <event_type> <limit> <after>" >&2
  echo >&2
  echo 'Examples: ' >&2
  echo 'COMPLIANCE_API_KEY=<KEY> ./download_compliance_files.sh f7f33107-5fb9-4ee1-8922-3eae76b5b5a0 AUTH_LOG 100 "$(date -u -v-1d +%Y-%m-%dT%H:%M:%SZ)" > output.jsonl' >&2
  echo 'COMPLIANCE_API_KEY=<KEY> ./download_compliance_files.sh org-p13k3klgno5cqxbf0q8hpgrk AUTH_LOG 100 "$(date -u -v-1d +%Y-%m-%dT%H:%M:%SZ)" > output.jsonl' >&2
}

if &#91;&#91; $# -ne 4 &#93;&#93;; then
  usage
  exit 2
fi

PRINCIPAL_ID="$1"
EVENT_TYPE="$2"
LIMIT="$3"
INITIAL_AFTER="$4"

# Require COMPLIANCE_API_KEY to be present and non-empty before using it
if &#91;&#91; -z "${COMPLIANCE_API_KEY:-}" &#93;&#93;; then
  echo "COMPLIANCE_API_KEY environment variable is required. e.g.:" >&2
  echo "COMPLIANCE_API_KEY=<KEY> $0 <workspace_or_org_id> <event_type> <limit> <after>" >&2
  exit 2
fi

API_BASE="https://api.chatgpt.com/v1/compliance"
AUTH_HEADER=("-H" "Authorization: Bearer ${COMPLIANCE_API_KEY}")

# Determine whether the first arg is a workspace ID or an org ID.
# If it starts with "org-" treat it as an organization ID and switch the path segment accordingly.
SCOPE_SEGMENT="workspaces"
if &#91;&#91; "${PRINCIPAL_ID}" == org-* &#93;&#93;; then
  SCOPE_SEGMENT="organizations"
fi

# Perform a curl request and fail fast on HTTP errors, logging context to stderr.
# Usage: perform_curl "description of action" <curl args...>
perform_curl() {
  local description="$1"
  shift
  # Capture body and HTTP status code, keeping body on stdout-like var
  # We append a newline before the status to reliably split even if body has no trailing newline.
  local combined
  if ! combined=$(curl -sS -w "\n%{http_code}" "$@"); then
    echo "Network/transport error while ${description}" >&2
    exit 1
  fi
  local http_code
  http_code="${combined##*$'\n'}"
  local body
  body="${combined%$'\n'*}"

  if &#91;&#91; ! "${http_code}" =~ ^2[0-9][0-9]$ &#93;&#93;; then
    echo "HTTP error ${http_code} while ${description}:" >&2
    if &#91;&#91; -n "${body}" &#93;&#93;; then
      # Print the body to stderr so it doesn't corrupt stdout stream
      echo "${body}" | jq . >&2
    fi
    exit 1
  fi

  # On success, emit body to stdout for callers to consume
  echo "${body}"
}

list_logs() {
  local after="$1"
  perform_curl "listing logs (after=${after}, event_type=${EVENT_TYPE}, limit=${LIMIT})" \
    -G \
    "${API_BASE}/${SCOPE_SEGMENT}/${PRINCIPAL_ID}/logs" \
    "${AUTH_HEADER[@]}" \
    --data-urlencode "limit=${LIMIT}" \
    --data-urlencode "event_type=${EVENT_TYPE}" \
    --data-urlencode "after=${after}"
}

download_log() {
  local id="$1"
  echo "Fetching logs for ID: ${id}" >&2
  perform_curl "downloading log id=${id}" \
    -G -L \
    "${API_BASE}/${SCOPE_SEGMENT}/${PRINCIPAL_ID}/logs/${id}" \
    "${AUTH_HEADER[@]}"
}

to_local_human() {
  local iso="$1"
  if &#91;&#91; -z "${iso}" || "${iso}" == "null" &#93;&#93;; then
    echo ""
    return 0
  fi

  local iso_norm
  iso_norm=$(echo -n "${iso}" \
    | sed -E 's/\.[0-9]+(Z|[+-][0-9:]+)$/\1/' \
    | sed -E 's/([+-]00:00)$/Z/')

  # macOS/BSD date: parse UTC to epoch then format in local timezone
  local epoch
  epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "${iso_norm}" +%s 2>/dev/null) || true
  if &#91;&#91; -n "${epoch}" &#93;&#93;; then
    date -r "${epoch}" "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null && return 0
  fi

  # Fallback to original if parsing failed
  echo "${iso}"
}

current_after="${INITIAL_AFTER}"
page=1
total_downloaded=0
while true; do
  echo "Fetching page ${page} with after='${current_after}' (local: $(to_local_human "${current_after}"))" >&2
  response_json="$(list_logs "${current_after}")"

  # Count and download each ID from the current page (if any)
  page_count="$(echo "${response_json}" | jq '.data | length')"
  if &#91;&#91; "${page_count}" -gt 0 &#93;&#93;; then
    echo "${response_json}" | jq -r '.data[].id' | while read -r id; do
      download_log "${id}"
    done
    total_downloaded=$((total_downloaded + page_count))
  fi

  has_more="$(echo "${response_json}" | jq -r '.has_more')"
  current_after="$(echo "${response_json}" | jq -r '.last_end_time')"
  if &#91;&#91; "${has_more}" == "true" &#93;&#93;; then
    page=$((page + 1))
  else
    break
  fi
done

if &#91;&#91; "${total_downloaded}" -eq 0 && ( -z "${current_after}" || "${current_after}" == "null" ) &#93;&#93;; then
  echo "No results found for event_type ${EVENT_TYPE} after ${INITIAL_AFTER}" >&2
else
  echo "Completed downloading ${total_downloaded} log files up to ${current_after} (local: $(to_local_human "${current_after}"))" >&2
fi
```

## Option 2: Windows-based

Prerequisites:
- Save the script locally as `download_compliance_files.ps1`
- Open PowerShell (Version 5.1+) and navigate to the directory where the script is saved.

Run the script akin to `.\download_compliance_files.ps1 <workspace_or_org_id> <event_type> <limit> <after>`

```ps
#!/usr/bin/env pwsh
#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Web

function Show-Usage {
    [Console]::Error.WriteLine(@"
Usage: .\download_compliance_files.ps1 <workspace_or_org_id> <event_type> <limit> <after>

Example:
  `$env:COMPLIANCE_API_KEY = '<KEY>'
  .\download_compliance_files.ps1 f7f33107-5fb9-4ee1-8922-3eae76b5b5a0 AUTH_LOG 100 (Get-Date -AsUTC).AddDays(-1).ToString('yyyy-MM-ddTHH:mm:ssZ') |
    Out-File -Encoding utf8 output.jsonl

Example (org id):
  `$env:COMPLIANCE_API_KEY = '<KEY>'
  .\download_compliance_files.ps1 org-p13k3klgno5cqxbf0q8hpgrk AUTH_LOG 100 (Get-Date -AsUTC).AddDays(-1).ToString('yyyy-MM-ddTHH:mm:ssZ') |
    Out-File -Encoding utf8 output.jsonl
"@)
}

if ($args.Count -ne 4) {
    Show-Usage
    exit 2
}

if (-not $env:COMPLIANCE_API_KEY) {
    [Console]::Error.WriteLine('COMPLIANCE_API_KEY environment variable must be set.')
    exit 2
}

$PrincipalId = $args[0]
$EventType = $args[1]
$Limit = $args[2]
$InitialAfter = $args[3]

$ApiBase = 'https://api.chatgpt.com/v1/compliance'

if ($PrincipalId.StartsWith('org-')) {
    $ScopeSegment = 'organizations'
} else {
    $ScopeSegment = 'workspaces'
}

$handler = [System.Net.Http.HttpClientHandler]::new()
$client = [System.Net.Http.HttpClient]::new($handler)
$client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue('Bearer', $env:COMPLIANCE_API_KEY)

function Invoke-ComplianceRequest {
    param(
        [Parameter(Mandatory = $true)] [string] $Description,
        [Parameter(Mandatory = $true)] [string] $Path,
        [hashtable] $Query = @{}
    )

    $builder = [System.UriBuilder]::new("$ApiBase/$ScopeSegment/$PrincipalId/$Path")
    $queryString = [System.Web.HttpUtility]::ParseQueryString($builder.Query)
    foreach ($key in $Query.Keys) {
        $queryString[$key] = $Query[$key]
    }
    $builder.Query = $queryString.ToString()

    try {
        $response = $client.GetAsync($builder.Uri).GetAwaiter().GetResult()
    } catch {
        [Console]::Error.WriteLine("Network/transport error while $Description")
        exit 1
    }

    $body = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    if (-not $response.IsSuccessStatusCode) {
        [Console]::Error.WriteLine("HTTP error $($response.StatusCode.value__) while ${Description}:")
        if ($body) {
            try {
                $parsed = $body | ConvertFrom-Json
                $parsed | ConvertTo-Json -Depth 10 | Write-Error
            } catch {
                [Console]::Error.WriteLine($body)
            }
        }
        exit 1
    }

    Write-Output $body
}

function List-Logs {
    param(
        [Parameter(Mandatory = $true)] [string] $After
    )

    Invoke-ComplianceRequest -Description "listing logs (after=$After, event_type=$EventType, limit=$Limit)" -Path 'logs' -Query @{
        limit      = $Limit
        event_type = $EventType
        after      = $After
    }
}

function Download-Log {
    param(
        [Parameter(Mandatory = $true)] [string] $Id
    )

    [Console]::Error.WriteLine("Fetching logs for ID: $Id")
    Invoke-ComplianceRequest -Description "downloading log id=$Id" -Path "logs/$Id"
}

function ConvertTo-LocalHuman {
    param(
        [string] $Iso
    )

    if (-not $Iso -or $Iso -eq 'null') {
        return ''
    }

    try {
        $dt = [datetimeoffset]::Parse($Iso)
        return $dt.ToLocalTime().ToString('yyyy-MM-dd HH:mm:ss zzz')
    } catch {
        return $Iso
    }
}

$currentAfter = $InitialAfter
$page = 1
$totalDownloaded = 0
while ($true) {
    [Console]::Error.WriteLine("Fetching page $page with after='$currentAfter' (local: $(ConvertTo-LocalHuman -Iso $currentAfter))")
    $responseJson = List-Logs -After $currentAfter
    $responseObj = $responseJson | ConvertFrom-Json

    $pageCount = $responseObj.data.Count
    if ($pageCount -gt 0) {
        foreach ($entry in $responseObj.data) {
            Download-Log -Id $entry.id
        }
        $totalDownloaded += $pageCount
    }

    $hasMore = $false
    if ($null -ne $responseObj.has_more) {
        $hasMore = [System.Convert]::ToBoolean($responseObj.has_more)
    }

    $currentAfter = $responseObj.last_end_time
    if ($hasMore) {
        $page += 1
    } else {
        break
    }
}

if ($totalDownloaded -eq 0 -and ([string]::IsNullOrEmpty($currentAfter) -or $currentAfter -eq 'null')) {
    [Console]::Error.WriteLine("No results found for event_type $EventType after $InitialAfter")
} else {
    [Console]::Error.WriteLine("Completed downloading $totalDownloaded log files up to $currentAfter (local: $(ConvertTo-LocalHuman -Iso $currentAfter))")
}

$client.Dispose()
$handler.Dispose()
```
