# aiRPG

A tiny command-line RPG prototype for experimenting with three kinds of input:

- Plain text: in-character player actions, such as `go north`, `take torch`, or `talk to Mira`.
- Commands use a single prefix: `*`. Examples: `*help`, `*new`, `*look`, `*save`, `*status`, `*inventory`, and `*quit`.
- Live world-editing commands use the same prefix: `*room`, `*item`, `*npc`, `*link`, and `*place`.
- Any `*text` that is not a known command is treated as an out-of-game message to the agent.

## Campaigns

`core/` is the rules and structure skeleton. New playable campaign state should live in `campaigns/<campaign_id>/`.

Use the campaign tool:

```powershell
.\tools\campaign.ps1 help
.\tools\campaign.ps1 start mira_01 "Mira campaign"
.\tools\campaign.ps1 new oiven_01 "Oiven campaign"
.\tools\campaign.ps1 active oiven_01
.\tools\campaign.ps1 save oiven_01 before_archive_return
```

Campaign saves are stored in:

```text
campaigns/<campaign_id>/saves/
```

## Run

```powershell
.\rpg.ps1
```

There is also a Python version for later:

```powershell
python rpg.py
```

## Quick Start

Try:

```text
*help
*new mira_01 | Mira campaign
look
take torch
talk to Mira
go north
take silver key
go south
go east
use silver key
go east
```

## Creation Examples

```text
*room Crystal Cave | Quartz walls hum softly.
*link north | Crystal Cave
go north
*item brass coin | Warm, scratched, and strangely heavy.
*place item | brass coin | Crystal Cave
take brass coin
```


## Campaign integrity tools

- `tools/promote-character.ps1 <campaign_id> <character_id> <main|secondary|tertiary> [display_name] [role]`
  creates the complete character file structure from `core/world/templates/character/`.
- `tools/validate-campaign.ps1 -CampaignId <campaign_id>`
  checks required world folders, complete character structures, ACTIVE.md references, and ACTIVE.md size.
- `tools/campaign.ps1 validate <campaign_id>`
  is the convenient validator entry point.
- `tools/campaign.ps1 save ...`
  validates first and refuses to save a structurally invalid campaign.


## CI validation

GitHub Actions runs `Validate RPG campaigns` on pushes to `master`, pull requests, and manual dispatch.
It executes `tools/campaign.ps1 validate` for every directory under `campaigns/`.
A structurally invalid campaign makes the workflow fail.
