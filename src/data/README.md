# src/data/

Data Access Layer: Verbindung zu MongoDB und standardisierte Datenzugriffe.
Test für das pushen
## Was hier rein soll (für die Bachelorarbeit)
1. **MongoDB Client**
   - Aufbau einer zentralen Verbindung (Singleton/Reuse)
   - `ping()`/Health Check
   - `get_db()`, `get_collection()` oder mehrere Collections (falls nötig)

2. **Repository-Funktionen (Queries)**
   - Kleine Abfragen zum Debuggen (`find_many`, `sample_one`)
   - Große Abfragen per Streaming (`stream`) mit `batch_size`
   - Projection-Helper, um nur benötigte Felder zu laden

3. **Jira-spezifische Query-Methoden (später)**
   - `stream_resolved_issues(...)` (nur abgeschlossene Tickets)
   - Filter nach Projekt/Zeitraum (falls relevant)
   - Optional: Aggregation Pipelines für Feature-Bausteine (z. B. Statuswechsel)

## Bereits implementiert
- `mongo_client.py` (Verbindung, ping)
- `jira_repository.py` (count/sample/find_many/stream)
- `repo_test.py` (Testlauf)

## Regeln / Performance
- Immer Projection nutzen (Jira-Dokumente sind groß).
- Für >100k Dokumente ausschließlich `stream()` nutzen.
- Keine Business-Logik/Feature Engineering hier (gehört nach `features/`).
