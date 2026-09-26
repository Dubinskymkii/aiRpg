param(
    [Parameter(Position = 0)]
    [ValidateSet("new", "start", "list", "active", "save", "saves", "restore", "status", "validate", "help")]
    [string]$Command = "help",

    [Parameter(Position = 1)]
    [string]$CampaignId,

    [Parameter(Position = 2)]
    [string]$Name,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$CampaignsDir = Join-Path $Root "campaigns"
$StateDir = Join-Path $Root ".airpg"
$ActiveFile = Join-Path $StateDir "ACTIVE_CAMPAIGN"

function New-Dir($Path) {
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Write-Utf8($Path, $Content) {
    $parent = Split-Path -Parent $Path
    New-Dir $parent
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

function Assert-CampaignId($Id) {
    if ([string]::IsNullOrWhiteSpace($Id)) {
        throw "Campaign id is required."
    }
    if ($Id -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]*$') {
        throw "Campaign id may contain only letters, numbers, underscores, and hyphens."
    }
}

function Get-CampaignPath($Id) {
    return Join-Path $CampaignsDir $Id
}

function New-WorldSkeleton($CampaignPath, $Title) {
    $world = Join-Path $CampaignPath "world"

    $worldDirs = @(
        "artifacts",
        "characters/players",
        "characters/secondary",
        "characters/tertiary",
        "factions",
        "history",
        "places",
        "sessions"
    )

    New-Dir (Join-Path $CampaignPath "saves")
    New-Dir (Join-Path $CampaignPath "assets/maps")
    New-Dir (Join-Path $CampaignPath "assets/portraits")
    New-Dir $world
    foreach ($dir in $worldDirs) {
        New-Dir (Join-Path $world $dir)
    }

    Write-Utf8 (Join-Path $CampaignPath "CAMPAIGN.md") @"
# $Title

Id: $(Split-Path -Leaf $CampaignPath)
Status: active

## Notes

- `core/` is the rules and structure template.
- Campaign canon lives in `world/`.
- Saves live in `saves/`.
"@

    Write-Utf8 (Join-Path $world "sessions/ACTIVE.md") @"
# Active Session

Current campaign: $Title

Current scene:

Where the group is:

Who is nearby:

Immediate goal:

Immediate threat:

Read before continuing:
- `core/rules/RULES.md`
- `core/world/COMPACTION.md`
- `campaigns/$(Split-Path -Leaf $CampaignPath)/world/sessions/ACTIVE.md`

Active events:

Uncompacted changes:

GM working notes:

Last updated: campaign created.
"@

    Write-Utf8 (Join-Path $world "history/recent.md") "# Recent History`n`nNo campaign events yet."
    Write-Utf8 (Join-Path $world "history/middle.md") "# Middle History`n`nNo campaign events yet."
    Write-Utf8 (Join-Path $world "history/mythology.md") "# Mythology`n`nNo campaign mythology established yet."
    Write-Utf8 (Join-Path $world "history/timeline.md") "# Timeline`n`nNo campaign timeline entries yet."

    Write-Utf8 (Join-Path $world "places/MAP.md") @"
# Campaign Map

No campaign map established yet.

Use `core/world/places/README.md` as the structure reference.
"@

    Write-Utf8 (Join-Path $world "artifacts/README.md") "# Campaign Artifacts`n`nUse `core/world/artifacts/README.md` as the structure reference."
    Write-Utf8 (Join-Path $world "characters/README.md") "# Campaign Characters`n`nUse `core/world/characters/KNOWLEDGE.md` as the structure reference."
    Write-Utf8 (Join-Path $world "factions/README.md") "# Campaign Factions`n`nUse `core/world/factions/README.md` as the structure reference."
    Write-Utf8 (Join-Path $world "places/README.md") "# Campaign Places`n`nUse `core/world/places/README.md` as the structure reference."
    Write-Utf8 (Join-Path $CampaignPath "assets/README.md") "# Campaign Assets`n`nMaps, portraits, and other campaign-specific visual assets live here."
}

function Copy-Directory($Source, $Destination) {
    if (-not (Test-Path $Source)) {
        throw "Source directory does not exist: $Source"
    }
    if (Test-Path $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }
    New-Dir (Split-Path -Parent $Destination)
    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse
}

function Show-Help {
    @"
Campaign tool

Commands:
  new <campaign_id> [title]       Create a campaign from the core skeleton.
  start <campaign_id> [title]     Create a campaign and make it active.
  list                            List campaigns.
  active [campaign_id]            Show or set active campaign.
  status                          Show active campaign and important paths.
  validate <campaign_id>          Validate campaign structure and canon invariants.
  save <campaign_id> <save_id>    Snapshot campaign world into saves/<save_id>.
  saves <campaign_id>             List saves for a campaign.
  restore <campaign_id> <save_id> -Force
                                  Restore a save over campaign world.

Examples:
  .\tools\campaign.ps1 start mira_01 "Mira campaign"
  .\tools\campaign.ps1 new oiven_01 "Oiven campaign"
  .\tools\campaign.ps1 active oiven_01
  .\tools\campaign.ps1 validate oiven_01
  .\tools\campaign.ps1 save oiven_01 before_archive_return
"@
}

New-Dir $CampaignsDir
New-Dir $StateDir

switch ($Command) {
    "new" {
        Assert-CampaignId $CampaignId
        $campaignPath = Get-CampaignPath $CampaignId
        if (Test-Path $campaignPath) {
            throw "Campaign already exists: $CampaignId"
        }
        $title = if ([string]::IsNullOrWhiteSpace($Name)) { $CampaignId } else { $Name }
        New-Dir $campaignPath
        New-WorldSkeleton $campaignPath $title
        Write-Host "Created campaign: $CampaignId"
        Write-Host "Path: $campaignPath"
    }

    "start" {
        Assert-CampaignId $CampaignId
        $campaignPath = Get-CampaignPath $CampaignId
        if (Test-Path $campaignPath) {
            throw "Campaign already exists: $CampaignId"
        }
        $title = if ([string]::IsNullOrWhiteSpace($Name)) { $CampaignId } else { $Name }
        New-Dir $campaignPath
        New-WorldSkeleton $campaignPath $title
        Write-Utf8 $ActiveFile $CampaignId
        Write-Host "Created and activated campaign: $CampaignId"
        Write-Host "Path: $campaignPath"
    }

    "list" {
        Get-ChildItem -Path $CampaignsDir -Directory | ForEach-Object {
            $marker = ""
            if ((Test-Path $ActiveFile) -and ((Get-Content $ActiveFile -Raw).Trim() -eq $_.Name)) {
                $marker = "* "
            }
            Write-Host "$marker$($_.Name)"
        }
    }

    "active" {
        if ([string]::IsNullOrWhiteSpace($CampaignId)) {
            if (Test-Path $ActiveFile) {
                Write-Host ((Get-Content $ActiveFile -Raw).Trim())
            }
            else {
                Write-Host "No active campaign set."
            }
            break
        }
        Assert-CampaignId $CampaignId
        $campaignPath = Get-CampaignPath $CampaignId
        if (-not (Test-Path $campaignPath)) {
            throw "Campaign does not exist: $CampaignId"
        }
        Write-Utf8 $ActiveFile $CampaignId
        Write-Host "Active campaign: $CampaignId"
    }

    "status" {
        $active = if (Test-Path $ActiveFile) { (Get-Content $ActiveFile -Raw).Trim() } else { "" }
        if ([string]::IsNullOrWhiteSpace($active)) {
            Write-Host "Active campaign: none"
        }
        else {
            Write-Host "Active campaign: $active"
            Write-Host "World: $(Join-Path (Get-CampaignPath $active) 'world')"
            Write-Host "Session: $(Join-Path (Get-CampaignPath $active) 'world/sessions/ACTIVE.md')"
            Write-Host "Saves: $(Join-Path (Get-CampaignPath $active) 'saves')"
        }
    }

    "save" {
        Assert-CampaignId $CampaignId
        Assert-CampaignId $Name

        & (Join-Path $PSScriptRoot "validate-campaign.ps1") -CampaignId $CampaignId
        if ($LASTEXITCODE -ne 0) {
            throw "Campaign validation failed. Save aborted."
        }
        $campaignPath = Get-CampaignPath $CampaignId
        $worldPath = Join-Path $campaignPath "world"
        $savePath = Join-Path $campaignPath "saves/$Name"
        if (-not (Test-Path $worldPath)) {
            throw "Campaign world does not exist: $worldPath"
        }
        if ((Test-Path $savePath) -and -not $Force) {
            throw "Save already exists: $Name. Use -Force to overwrite."
        }
        New-Dir $savePath
        Copy-Directory $worldPath (Join-Path $savePath "world")
        Write-Utf8 (Join-Path $savePath "SAVE.md") @"
# Save: $Name

Campaign: $CampaignId
Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
Source: campaigns/$CampaignId/world
"@
        Write-Host "Saved campaign '$CampaignId' as '$Name'."
    }

    "validate" {
        Assert-CampaignId $CampaignId
        & (Join-Path $PSScriptRoot "validate-campaign.ps1") -CampaignId $CampaignId
        if ($LASTEXITCODE -ne 0) {
            throw "Campaign validation failed."
        }
    }

    "saves" {
        Assert-CampaignId $CampaignId
        $saveRoot = Join-Path (Get-CampaignPath $CampaignId) "saves"
        if (-not (Test-Path $saveRoot)) {
            Write-Host "No saves."
            break
        }
        Get-ChildItem -Path $saveRoot -Directory | ForEach-Object { Write-Host $_.Name }
    }

    "restore" {
        Assert-CampaignId $CampaignId
        Assert-CampaignId $Name
        if (-not $Force) {
            throw "Restore overwrites campaign world. Re-run with -Force."
        }
        $campaignPath = Get-CampaignPath $CampaignId
        $saveWorld = Join-Path $campaignPath "saves/$Name/world"
        $worldPath = Join-Path $campaignPath "world"
        Copy-Directory $saveWorld $worldPath
        Write-Host "Restored '$CampaignId' from save '$Name'."
    }

    "help" {
        Show-Help
    }
}
