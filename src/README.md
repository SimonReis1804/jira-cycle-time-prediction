# src/

Enthält den gesamten Python-Code zur Ausführung und Evaluation der ML-Modelle.

## Struktur
- `data/`: Datenvorverarbeitung und Laden der Feature-Tabellen
- `features/`: Feature Engineering
- `models/`: Implementierung der ML-Modelle
- `optimization`: Hyperparameteroptimierung
- `utils/`: Hilfsfunktion

## Setup
1. Repository clonen:
```bash
git clone https://github.com/SimonReis1804/jira-cycle-time-prediction
cd jira-cycle-time-prediction
```

2. Virtuelle Umgebung installieren und aktivieren: 
```bash
python -m venv .venv
.venv\Scripts\activate
```

3. Abhängigkeiten installieren:
```bash
pip install -r requirements.txt
```

4. Konfigurationsdatei erstellen:
```bash
.env Datei basierend auf folgendem Beispiel erstellen
MONGODB_URI=mongodb://localhost:27017/
MONGODB_DB=JiraReposAnon 
```