# aiRPG

A tiny command-line RPG prototype for experimenting with three kinds of input:

- Plain text: in-character player actions, such as `go north`, `take torch`, or `talk to Mira`.
- Out-of-context commands: system/player commands prefixed with `/`, such as `/help`, `/look`, `/save`, and `/quit`.
- Game creation commands: live world-editing commands prefixed with `!`, such as `!room`, `!item`, `!npc`, `!link`, and `!place`.

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
