# Jira Cycle Time Prediction (Bachelorarbeit)

Dieses Projekt dient zur Vorhersage von Durchlaufzeiten (Cycle Time) abgeschlossener Jira-Tickets mithilfe von ML-Modellen.
Die Rohdaten liegen in MongoDB (lokal) und werden ohne CSV-Export direkt per PyMongo geladen.

## Projekstruktur
- `src/`: Python Code für Datenextraktion, Feature Encoding, ML-Modelle, Optimierung, Hilfsfunktionen
- `r/`: R Code für Datenanalyse und Erstellung einer Feature-Tabelle

## Reproduzierbarkeit 

### Verwendete Technologien & Voraussetzungen
- R (Version 4.5.2) 
- Python (Version 3.13.9)
- MongoDB (8.2.2)
- Python Pakete siehe `requirements.txt`
- RStudio Pakete siehe `r/`

### Ablauf
1. `r/`Codes ausführen für Datenanalyse und Generierung der Feature-Tabelle
2. `src/` Codes in ein VS Code Projekt einfügen
3. `src/models/`: Modelle ausführen (z.B.: python -m src.models.train_model_jira linear)
4. Ergebnisse dokumentieren in `Master-Tabelle.xlsx`
5. `Master-Tabelle` in RStudio importieren
6. Codes unter `r/Results/R/` ausführen um Ergebnisse zu analysieren

## Daten
Der verwendete Datensatz stammt von: 

https://zenodo.org/records/15719919#:~:text=Jira%20is%20an%20issue%20tracking,using%20the%20Jira%20API%20V2

Die Rohdaten sind nicht in dem Repository enthalten. 





