param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$CampaignId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$PlaceId,

    [Parameter(Position = 2)]
    [string]$DisplayName,

    [Parameter(Position = 3)]
    [string]$Type = "place",

    [switch]$Force
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

if ($CampaignId -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]*$') { throw "Invalid campaign id." }
if ($PlaceId -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]*$') { throw "Invalid place id." }

$CampaignPath = Join-Path $Root "campaigns/$CampaignId"
if (-not (Test-Path $CampaignPath)) { throw "Campaign does not exist: $CampaignId" }

if ([string]::IsNullOrWhiteSpace($DisplayName)) { $DisplayName = $PlaceId }

$TemplateDir = Join-Path $Root "core/world/templates/place"
if (-not (Test-Path $TemplateDir)) { throw "Place template directory missing: $TemplateDir" }

$TargetDir = Join-Path $CampaignPath "world/places/$PlaceId"
New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $TargetDir "events") -Force | Out-Null

$Required = @("profile.md","geography.md","state.md","history.md")
foreach ($file in $Required) {
    $source = Join-Path $TemplateDir $file
    $target = Join-Path $TargetDir $file
    if (-not (Test-Path $source)) { throw "Template file missing: $source" }
    if ((Test-Path $target) -and -not $Force) { continue }

    $content = Get-Content $source -Raw
    $content = $content.Replace("{{PLACE_ID}}", $PlaceId)
    $content = $content.Replace("{{NAME}}", $DisplayName)
    $content = $content.Replace("{{TYPE}}", $Type)
    Set-Content -Path $target -Value $content -Encoding UTF8
}

$MapPath = Join-Path $CampaignPath "world/places/MAP.md"
if (-not (Test-Path $MapPath)) {
    @"
# Campaign Map

## Places

"@ | Set-Content -Path $MapPath -Encoding UTF8
}

$mapText = Get-Content $MapPath -Raw
$entry = "- $PlaceId | $DisplayName | type: $Type | coords: preliminary"
if ($mapText -notmatch "(?m)^-\s+$([regex]::Escape($PlaceId))\s+\|") {
    Add-Content -Path $MapPath -Value $entry -Encoding UTF8
}

Write-Host "Place structure ready: $PlaceId"
Write-Host "Path: $TargetDir"
