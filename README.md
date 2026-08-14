# aiRPG

A tiny command-line RPG prototype for experimenting with three kinds of input:

- Plain text: in-character player actions, such as `go north`, `take torch`, or `talk to Mira`.
- Out-of-context commands: system/player commands prefixed with `/`, such as `/help`, `/new`, `/look`, `/save`, and `/quit`.
- Game creation commands: live world-editing commands prefixed with `!`, such as `!room`, `!item`, `!npc`, `!link`, and `!place`.

## Campaigns

`core/` is the rules and structure skeleton. New playable campaign state should live in `campaigns/<campaign_id>/`.

Use the campaign tool:

```powershell
.\tools\campaign.ps1 help
.\tools\campaign.ps1 start mira_01 "Mira campaign"
.\tools\campaign.ps1 new oiven_01 "Oiven campaign"
.\tools\campaign.ps1 import-core oiven_legacy "Oiven legacy import"
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
/help
/new mira_01 | Mira campaign
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
!room Crystal Cave | Quartz walls hum softly.
!link north | Crystal Cave
go north
!item brass coin | Warm, scratched, and strangely heavy.
!place item | brass coin | Crystal Cave
take brass coin
```
