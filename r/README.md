# R-Skripte

## Beschreibung
Dieser Ordner enthält alle R Skripte zur Datenanalyse, Datenextraktion sowie zur Erstellung der Feature-Tabellen für das Machine Learning.
## Struktur
### BA_Jira_Jira/R
- `00_setupt_jira.R`: Datenextraktion aus MongoDB
- `01_extract_tickets_jira.R`: Statische sowie prozessbezogene Informationen aus den Tickets extrahieren
- `02_ticket_overview_jira.R`: Ticketübersicht als Teil der Datenanalyse
- `03_durchlaufzeit_statistiken_jira.R`: Durchlaufzeitsanalye als Teil der Datenanalyse
- `04_zeitliche_entwicklung_jira.R`: Analyse der zeitlichen Entwicklung der Tickets
- `05_changelog_aktivitätsanalyse.R`: Changelog-Aktivitätsanalyse als Teil der Datenanalyse
- `06_datenqualität_und_eignung_jira.R`: Datenqualitätsanalyse als Teil der Datenanalyse
- `07_feature_table_jira.R`: Erstellung der Feature Tabelle für ML-Modelle

### BA_Jira_Hyperledger/R
In den Projekten die für Experiment 3 genutzt wurden, wurde keine ausführliche Datenanalyse durchgeführt. Die folgenden Skripte dienten der Erstellung einer Feature-Tabelle für die ML-Modelle
- `00_setupt_hyperledger.R`: Datenextraktion aus MongoDB 
- `01_extract_tickets_hyperledger.R`: Statische sowie prozessbezogene Merkmale aus den Tickets extrahieren
- `02_ticket_overview_hyperledger.R`: Abgeschlossene Tickets erstellen
- `03_durchlaufzeit_statistiken_hyperledger.R`: Erstellung eines Histogramms für die Diskussion
- `05_changelog_aktivitätsanalyse.R`: Joins für die Feature-Tabelle  
- `07_feature_table_hyperledger.R`: Erstellung der Feature Tabelle für ML-Modelle

Die R-Skripte in `r/BA_Jira_Jiraecosystem/R`, `r/BA_Jira_Spring/R` und `r/BA_Jira_MariaDB/R` folgendem dem gleichen Ablauf. 

### Results/R

Dieser Ordner enthält die verschiedenen Skripte um eine Master-Tabelle auszuwerten.

## Ablauf
Die Skripte sind nummeriert und sollten auch in gegebener Reihenfolge ausgeführt werden:
1. `00_setup_<Projekt>.R`
2. `01_extract_tickets_<Projekt>.R`
3. `03_durchlaufzeit_statistiken_<Projekt>.R`, `04_zeitliche_entwicklung_<Projekt>.R`,  `05_changelog_aktivitätsanalyse.R`, `06_datenqualität_und_eignung_<Projekt>.R`: Für die Datenanalyse.
4. `07_feature_table_<Projekt>`: Zur Erstellung der gewünschten Feature Tabelle

## Output
- Feature-Tabelle für die ML-Modelle
- Statistische Auswertungen