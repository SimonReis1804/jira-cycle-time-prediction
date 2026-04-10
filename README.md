# Jira Cycle Time Prediction (Bachelorarbeit)

Dieses Projekt dient zur Vorhersage von Durchlaufzeiten (Cycle Time) abgeschlossener Jira-Tickets mithilfe von ML-Modellen.
Die Rohdaten liegen in MongoDB (lokal) und werden ohne CSV-Export direkt per PyMongo geladen.

## Projektziele
- Feature Engineering aus Jira-Ticketdaten (statische Ticketfelder + Prozess-/Changelog-Features)
- Training und Vergleich verschiedener Regressionsmodelle
- Evaluation mit geeigneten Metriken (z. B. MAE, RMSE) und reproduzierbare Experimente

## Quickstart (tägliches Arbeiten)
1. VSCode: Ordner `jira-ml-cycle-time` öffnen
2. Terminal öffnen und venv aktivieren:
   - Windows: `.venv\Scripts\activate`
3. Test, ob DB-Zugriff klappt:
   - `python -m src.data.repo_test`

## Ordnerübersicht
- `src/` – produktiver Code (Datenzugriff, Features, Modelle)
- `notebooks/` – explorative Analysen und Visualisierung
- `configs/` – Konfigurationen (DB/Collection-Names optional, Experimente, Parameter)
- `tests/` – Tests für Kernfunktionen (optional, aber sinnvoll)

## Konfiguration
- `.env` (nicht versioniert): enthält MongoDB URI + DB/Collection(s)
  - Beispiel: `MONGODB_URI=mongodb://localhost:27017/`

## Ausführen (als Module!)
Starte Skripte immer so:
- `python -m src.<paket>.<modul>`
Beispiel:
- `python -m src.data.repo_test`

## Hinweise
- Keine sensiblen Daten committen (`.env` bleibt lokal und ist in `.gitignore`).
- Bei großen Datenmengen: immer Projection + Streaming verwenden.
