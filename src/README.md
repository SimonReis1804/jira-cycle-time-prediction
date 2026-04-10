# src/

Enthält den gesamten produktiven Python-Code des Projekts.

## Struktur
- `data/`     MongoDB-Verbindung und Queries (Repository-Ledger)
- `features/` Feature Engineering (Rohdaten -> Modell-Features)
- `models/`   Training, Tuning, Evaluation, Modellvergleich
- `utils/`    Hilfsfunktionen (Logging, Pfade, Metriken, Common Helpers)

## Regeln
- Keine Notebooks hier.
- Skripte als Module starten (`python -m ...`).
- DB-Zugriff ausschließlich über `src/data/` kapseln (kein MongoClient in features/models).
