# Für die Funktion "lade_daten" aus der Datei
from src.data.daten_laden_jira import lade_daten
from src.features.feature_encoding_jira import encode_df
# Für RandomForestRegression Model
from sklearn.ensemble import RandomForestRegressor
# Für Train und Test Daten aufzuteilen
from sklearn.model_selection import train_test_split
# Um zu vergleichen wie gut das Modell ist R^2, MAE, RMSE
from sklearn.metrics import mean_absolute_error, make_scorer
# Für Hyperparameter-Optimierung 
from sklearn.model_selection import RandomizedSearchCV
# Für Dataframes
import pandas as pd
import sys
from sklearn.ensemble import (
    GradientBoostingRegressor,
    RandomForestRegressor,
    HistGradientBoostingRegressor
)
from xgboost import XGBRegressor

def optimize_model(model_name: str):
    """
    Führt eine Hyperparameteroptimierung für verschiedene ML-Modelle durch.

    - Durchführung einer Randomized Search zur Optimierung der Hyperparameter
    - Ausgabe der besten Parameter für zwei Feature-Sets:
        1. nur statische Merkmale
        2. statische und prozessbezogene Merkmale

    Ziel ist die Verbesserung der Modellleistung durch geeignete Parametereinstellungen.
    """

    mae_scorer = make_scorer(mean_absolute_error, greater_is_better=False)

    #Daten laden + Feature Engineering durch Encoding
    df_static, df_static_process = lade_daten()
    df_static_encode = encode_df(df_static)
    df_static_process_encode = encode_df(df_static_process)

    # Nur die static Features ohne die Zielvariable
    x_static = df_static_encode.drop(columns=["cycle_time_days"])
    # Nur die Werte der Zielvariablen
    y_static = df_static_encode["cycle_time_days"]

    # Static + Process Features ohne die Zielvariable
    x_static_process = df_static_process_encode.drop(columns=["cycle_time_days"])
    # Nur die Werte der Zielvariablen
    y_static_process = df_static_process_encode["cycle_time_days"]

    x_train_static, x_test_static, y_train_static, y_test_static = train_test_split(
        x_static, 
        y_static,
        # 20% der Daten werden zum Testen genommen 
        test_size=0.2,
        # Reihenfolge wie die Trainings Daten zugeordnet werden
        random_state=432
    )

    x_train_static_process, x_test_static_process, y_train_static_process, y_test_static_process = train_test_split(
        x_static_process, 
        y_static_process,
        # 20% der Daten werden zum Testen genommen 
        test_size=0.2,
        # Reihenfolge wie die Trainings Daten zugeordnet werden
        random_state=432
    )

    if model_name.lower() == "rf":
        model = RandomForestRegressor(random_state=432)
        # Hyperparameter-Optimierung
        # Parameter Einstellung
        param_grid = {
            "n_estimators": [200, 400, 600],
            "max_depth": [None, 10, 20],
            "min_samples_split": [2, 10, 50],
            "min_samples_leaf": [1, 5, 20],
            "max_features": ["sqrt",0.3, 0.5],
            "bootstrap": [True],
            "max_samples": [0.6, 0.8, 0.9],
        }
    elif model_name.lower() == "gbr":
        model = GradientBoostingRegressor(random_state=432)
        param_grid = {
        "n_estimators": [200, 500, 800],
        "learning_rate": [0.01, 0.05, 0.1],
        "max_depth": [2, 3, 4],
        "subsample": [0.6, 0.8, 1.0],
        "min_samples_leaf": [1, 5, 20],
        "max_features": [None, "sqrt", 0.5]
    }
    elif model_name.lower() == "xgbr":
        model = XGBRegressor(random_state=432)
        param_grid = {
            "n_estimators": [300, 600, 1000],
            "learning_rate": [0.01, 0.05, 0.1],
            "max_depth": [3, 5, 8],
            "subsample": [0.6, 0.8, 1.0],
            "colsample_bytree": [0.6, 0.8, 1.0],
            "min_child_weight": [1, 5, 10],
            "reg_lambda": [1.0, 5.0, 10.0],
            "reg_alpha": [0.0, 0.1, 1.0],
        }
    elif model_name.lower() == "histgbr":
        model = HistGradientBoostingRegressor(random_state=432)
        param_grid = {
            "max_iter": [200, 500, 1000],
            "learning_rate": [0.01, 0.05, 0.1],
            "max_leaf_nodes": [15, 31, 63],
            "min_samples_leaf": [10, 20, 50],
            "l2_regularization": [0.0, 0.1, 1.0],
            "max_depth": [None, 3, 8],
        }
    else:
        print("Unbekanntes Modell! Nutze: rf, gbr, xgbr oder histgbr")
        sys.exit()

    # Randomized Grid Search
    RandomGrid = RandomizedSearchCV(
        estimator=model, 
        param_distributions=param_grid,
        n_iter=20, 
        cv=3, 
        verbose=2, 
        n_jobs=-1,
        scoring=mae_scorer,
        random_state=432
    )

    # Modelltraining
    # model trainieren mit den Trainings Daten
    RandomGrid.fit(x_train_static, y_train_static)
    # Test wie gut die Vorhersage ist
    print("\nBeste gefundene RandomForest Parameter (STATIC):")
    print(RandomGrid.best_params_)

    # model trainieren mit den Trainings Daten
    RandomGrid.fit(x_train_static_process, y_train_static_process)
    # Test wie gut die Vorhersage ist
    print("\nBeste gefundene RandomForest Parameter (STATIC + PROCESS):")
    print(RandomGrid.best_params_)

if __name__ == "__main__":
    # Überprüfung ob auch das richtige im Terminal eingegeben wird
    if len(sys.argv) < 2:
        # Fehlermeldung falls nicht
        print("Bitte Modell wählen: linear, rf oder gbr")
        # Programm schließen
        sys.exit(1)

    # Eingabespeicherung aus Terminal
    arg = sys.argv[1]
    # Modellname in die Funktion übergeben
    optimize_model(arg)


