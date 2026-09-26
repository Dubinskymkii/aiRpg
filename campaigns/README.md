# Campaigns

Эта папка хранит отдельные игровые кампании.

`core/` остается костяком проекта: правила, инструкции, шаблоны структуры мира и правила компактизации. Конкретная игра должна жить в отдельной папке кампании.

## Формат Кампании

```text
campaigns/
  campaign_id/
    CAMPAIGN.md
    assets/
      maps/
      portraits/
    world/
      artifacts/
      characters/
        players/
        secondary/
        tertiary/
      factions/
      history/
      places/
      sessions/
    saves/
      save_id/
        SAVE.md
        world/
```

## Активная Кампания

Активная кампания указывается в `.airpg/ACTIVE_CAMPAIGN`.

Игровой мастер должен читать `world/sessions/ACTIVE.md` активной кампании. В `core/world/` игровых сессий и канона нет.

## Инструмент

Основной инструмент:

```powershell
.\tools\campaign.ps1 list
.\tools\campaign.ps1 new hero_01 "Новая кампания"
.\tools\campaign.ps1 active oiven_01
.\tools\campaign.ps1 save oiven_01 before_archive_return
.\tools\campaign.ps1 saves oiven_01
```

`new` создает пустую кампанию из структуры ядра.

Восстановление сейва перезаписывает `campaigns/<id>/world/`, поэтому требует `-Force`:

```powershell
.\tools\campaign.ps1 restore oiven_01 before_archive_return -Force
```
