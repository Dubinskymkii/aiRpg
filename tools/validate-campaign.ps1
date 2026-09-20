param(
    [Parameter(Position = 0)]
    [string]$CampaignId
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$StateDir = Join-Path $Root ".airpg"
$ActiveCampaignFile = Join-Path $StateDir "ACTIVE_CAMPAIGN"

if ([string]::IsNullOrWhiteSpace($CampaignId)) {
    if (-not (Test-Path $ActiveCampaignFile)) {
        Write-Error "Campaign id is required and no active campaign is set."
        exit 1
    }
    $CampaignId = (Get-Content $ActiveCampaignFile -Raw).Trim()
}

if ($CampaignId -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]*$') {
    Write-Error "Invalid campaign id: $CampaignId"
    exit 1
}

$CampaignPath = Join-Path $Root "campaigns/$CampaignId"
$WorldPath = Join-Path $CampaignPath "world"
$CharactersPath = Join-Path $WorldPath "characters"
$ActivePath = Join-Path $WorldPath "sessions/ACTIVE.md"
$PlacesPath = Join-Path $WorldPath "places"
$MapPath = Join-Path $PlacesPath "MAP.md"

$Errors = New-Object System.Collections.Generic.List[string]
$Warnings = New-Object System.Collections.Generic.List[string]

function Add-ValidationError([string]$Message) {
    $script:Errors.Add($Message)
}

function Add-ValidationWarning([string]$Message) {
    $script:Warnings.Add($Message)
}

function Require-Path([string]$Path, [string]$Label) {
    if (-not (Test-Path $Path)) {
        Add-ValidationError "$Label missing: $Path"
        return $false
    }
    return $true
}

if (-not (Require-Path $CampaignPath "Campaign")) { }
if (-not (Require-Path $WorldPath "World")) { }

$RequiredWorldDirs = @(
    "characters/main",
    "characters/secondary",
    "characters/tertiary",
    "places",
    "factions",
    "artifacts",
    "history",
    "sessions"
)

foreach ($dir in $RequiredWorldDirs) {
    Require-Path (Join-Path $WorldPath $dir) "World directory" | Out-Null
}

Require-Path $MapPath "Campaign map" | Out-Null

$RequiredPlaceFiles = @("profile.md","geography.md","state.md","history.md")
if (Test-Path $PlacesPath) {
    foreach ($placeDir in Get-ChildItem -Path $PlacesPath -Directory) {
        foreach ($file in $RequiredPlaceFiles) {
            $filePath = Join-Path $placeDir.FullName $file
            if (-not (Test-Path $filePath)) {
                Add-ValidationError "Place '$($placeDir.Name)' missing $file"
            }
        }
        $eventsDir = Join-Path $placeDir.FullName "events"
        if (-not (Test-Path $eventsDir)) {
            Add-ValidationError "Place '$($placeDir.Name)' missing events/ directory"
        }
    }
}

if (Test-Path $MapPath) {
    $mapText = Get-Content $MapPath -Raw
    foreach ($placeDir in Get-ChildItem -Path $PlacesPath -Directory) {
        if ($mapText -notmatch "(?m)^-\s+$([regex]::Escape($placeDir.Name))\s+\|") {
            Add-ValidationError "Place '$($placeDir.Name)' is missing from MAP.md"
        }
    }
}

$RequiredCharacterFiles = @(
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

foreach ($category in @("main", "secondary", "tertiary")) {
    $categoryPath = Join-Path $CharactersPath $category
    if (-not (Test-Path $categoryPath)) { continue }

    foreach ($characterDir in Get-ChildItem -Path $categoryPath -Directory) {
        foreach ($file in $RequiredCharacterFiles) {
            $filePath = Join-Path $characterDir.FullName $file
            if (-not (Test-Path $filePath)) {
                Add-ValidationError "Character '$($characterDir.Name)' [$category] missing $file"
            }
        }
    }
}

$MainPath = Join-Path $CharactersPath "main"
if ((Test-Path $MainPath) -and ((Get-ChildItem -Path $MainPath -Directory).Count -eq 0)) {
    Add-ValidationWarning "No main character exists yet."
}

if (Require-Path $ActivePath "ACTIVE session") {
    $activeLines = Get-Content $ActivePath
    if ($activeLines.Count -gt 150) {
        Add-ValidationError "ACTIVE.md has $($activeLines.Count) lines; limit is 150. Compact stable canon into its proper files."
    }
    elseif ($activeLines.Count -gt 110) {
        Add-ValidationWarning "ACTIVE.md has $($activeLines.Count) lines and is approaching the 150-line limit."
    }

    $activeText = Get-Content $ActivePath -Raw
    $matches = [regex]::Matches($activeText, '(?m)^\s*-\s*\x60([^\x60]+)\x60\s*$')
    foreach ($match in $matches) {
        $relative = $match.Groups[1].Value.Trim()
        if ($relative -match '^(core|campaigns)/') {
            $target = Join-Path $Root ($relative -replace '/', [IO.Path]::DirectorySeparatorChar)
            if (-not (Test-Path $target)) {
                Add-ValidationError "ACTIVE.md references missing file: $relative"
            }
        }
    }
}

$YarkoLikeInventories = Get-ChildItem -Path (Join-Path $CharactersPath "main") -Directory -ErrorAction SilentlyContinue
foreach ($hero in $YarkoLikeInventories) {
    $inventory = Join-Path $hero.FullName "inventory.md"
    if (Test-Path $inventory) {
        $text = Get-Content $inventory -Raw
        if ([string]::IsNullOrWhiteSpace($text)) {
            Add-ValidationError "Main character '$($hero.Name)' has empty inventory.md"
        }
    }
}

foreach ($warning in $Warnings) {
    Write-Host "WARN: $warning" -ForegroundColor Yellow
}

if ($Errors.Count -gt 0) {
    foreach ($errorMessage in $Errors) {
        Write-Host "ERROR: $errorMessage" -ForegroundColor Red
    }
    Write-Host "Validation failed: $($Errors.Count) error(s), $($Warnings.Count) warning(s)." -ForegroundColor Red
    exit 1
}

Write-Host "Validation OK: campaign '$CampaignId' ($($Warnings.Count) warning(s))." -ForegroundColor Green
exit 0
