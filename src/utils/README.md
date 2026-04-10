# src/utils/

Hilfsfunktionen, die von mehreren Modulen genutzt werden.

## Was hier rein soll
- Logging-Setup (einheitliche Logs für Datenzugriff, Feature Engineering, Training)
- Gemeinsame Metriken (z. B. rmse, mae wrapper)
- Pfad-Utilities (z. B. "wo speichere ich reports?")
- Kleine Validierungshelfer (z. B. assert-Checks für DataFrames)

## Regeln
- Kein DB-Zugriff, kein Feature Engineering, kein Modelltraining.
- Nur wiederverwendbare Helper.
