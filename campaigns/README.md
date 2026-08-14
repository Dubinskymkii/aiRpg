# Campaigns

Эта папка хранит отдельные игровые кампании.

`core/` остается костяком проекта: правила, инструкции, шаблоны структуры мира и правила компактизации. Конкретная игра должна жить в отдельной папке кампании.

## Формат Кампании

```text
campaigns/
  campaign_id/
    CAMPAIGN.md
    world/
      artifacts/
      characters/
        main/
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

Если активная кампания задана, игровой мастер должен читать ее `world/sessions/ACTIVE.md`, а не старый `core/world/sessions/ACTIVE.md`.

## Инструмент

Основной инструмент:

```powershell
.\tools\campaign.ps1 list
.\tools\campaign.ps1 new oiven_01 "Первая кампания Ойвена"
.\tools\campaign.ps1 import-core oiven_legacy "Импорт текущей кампании"
.\tools\campaign.ps1 active oiven_01
.\tools\campaign.ps1 save oiven_01 before_archive_return
.\tools\campaign.ps1 saves oiven_01
```

`new` создает пустую кампанию из структуры ядра.

`import-core` копирует текущий legacy-мир из `core/world` в новую кампанию. Команда не удаляет и не меняет `core/world`.

Восстановление сейва перезаписывает `campaigns/<id>/world/`, поэтому требует `-Force`:

```powershell
.\tools\campaign.ps1 restore oiven_01 before_archive_return -Force
```
