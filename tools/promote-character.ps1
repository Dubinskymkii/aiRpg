param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$CampaignId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$CharacterId,

    [Parameter(Mandatory = $true, Position = 2)]
    [ValidateSet("players", "secondary", "tertiary")]
    [string]$Category,

    [Parameter(Position = 3)]
    [string]$DisplayName,

    [Parameter(Position = 4)]
    [string]$Role,

    [switch]$Force
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

if ($CampaignId -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]*$') {
    throw "Invalid campaign id."
}
if ($CharacterId -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]*$') {
    throw "Invalid character id."
}

$CampaignPath = Join-Path $Root "campaigns/$CampaignId"
if (-not (Test-Path $CampaignPath)) {
    throw "Campaign does not exist: $CampaignId"
}

if ([string]::IsNullOrWhiteSpace($DisplayName)) {
    $DisplayName = $CharacterId
}
if ([string]::IsNullOrWhiteSpace($Role)) {
    $Role = "Пока не установлено"
}

$TemplateDir = Join-Path $Root "core/world/templates/character"
if (-not (Test-Path $TemplateDir)) {
    throw "Character template directory missing: $TemplateDir"
}

$TargetDir = Join-Path $CampaignPath "world/characters/$Category/$CharacterId"
New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

$Required = @(
    "profile.md",
    "stats.md",
    "speech_style.md",
    "current_goals.md",
    "long_term_goals.md",
    "inventory.md",
    "relationships.md",
    "short_memory.md",
    "long_memory.md"
)

foreach ($file in $Required) {
    $source = Join-Path $TemplateDir $file
    $target = Join-Path $TargetDir $file

    if (-not (Test-Path $source)) {
        throw "Template file missing: $source"
    }

    if ((Test-Path $target) -and -not $Force) {
        continue
    }

    $content = Get-Content $source -Raw
    $content = $content.Replace("{{CHARACTER_ID}}", $CharacterId)
    $content = $content.Replace("{{NAME}}", $DisplayName)
    $content = $content.Replace("{{CATEGORY}}", $Category)
    $content = $content.Replace("{{ROLE}}", $Role)
    Set-Content -Path $target -Value $content -Encoding UTF8
}

Write-Host "Character structure ready: $Category/$CharacterId"
Write-Host "Path: $TargetDir"
