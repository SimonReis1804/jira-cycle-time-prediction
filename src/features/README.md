# src/features/

Feature Engineering: Rohdaten aus MongoDB -> tabellarische Features für ML.

## Was hier rein soll (für die Bachelorarbeit)
1. **Feature Builder**
   - Skript/Funktion, die aus Jira-Dokumenten ein Feature-DataFrame erzeugt
   - Trennung: "statische Features" vs. "Prozess-/Changelog-Features"

2. **Feature-Sets / Experimente**
   - `baseline_features`: nur statische Ticketfelder
   - `process_features`: zusätzlich Prozessfeatures (Statuswechsel, Zeiten in Status etc.)
   - Damit kannst du in der Arbeit sauber vergleichen: *bringt Prozessinformation Verbesserung?*

3. **Preprocessing**
   - Datums-/Zeitfeatures (Wochentag, Monat, ggf. Trend)
   - Kategorische Features (Issue Type, Priority) -> Encoding (später via sklearn Pipeline)
   - Umgang mit Ausreißern / Log-Transform der Target-Variable (falls methodisch geplant)

4. **Validierung der Features**
   - Checks: fehlende Werte, Dubletten, plausibles Target (Cycle Time > 0)
   - Optional: simple Summary-Reports (Anzahl Datensätze, Verteilungen)

## Output
- Optional: Feature-Dataset lokal speichern (z. B. Parquet) **nur** als Features, nicht als Rohdaten.
- Alternativ: Features direkt “on the fly” fürs Training erzeugen (langsamer, aber ohne Persistenz).

## Regeln
- Keine MongoClient-Logik hier (nur Repository nutzen).
- Große Daten: Streaming + Projection.
- Feature-Namen stabil halten (wichtig für Modellvergleich und Dokumentation).
