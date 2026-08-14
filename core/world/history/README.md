# История кампании

`core/world/history/` не хранит историю конкретного мира. Файлы истории каждой игры находятся в:

```text
campaigns/<campaign_id>/world/history/
  recent.md
  middle.md
  mythology.md
  timeline.md
```

Новая кампания получает эти файлы через `tools/campaign.ps1 new` или `start`.
