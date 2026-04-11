# src/models

Dieser Ordner enthält die implementierten ML-Modelle

## Inhalt
- Implementiernug der ML-Modelle: Linear Regression, Gradient Boosting, Hist Gradient Boosting, Random Forest, XGBoost
- Die Modelle werden auf Basis der Feature-Tabellen trainiert und evaluiert
- Modelle sind mit und ohne Hyperparameter ausführbar
- 3 verschiedene Experimente werden mit der Implementierung abgedeckt

## Hinweis
Ein Modell kann über das entsprechende Skript ausgeführt werden:
```bash
python -m src.models.train_model_<modell> <modell>
```

### Beispiel

```bash
python -m src.models.train_model_jira rf
```
