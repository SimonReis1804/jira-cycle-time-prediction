from src.data.daten_laden_time_based import lade_daten
from src.features.feature_encoding_time_based import encode_splits
from src.utils.reporting import save_results
from src.utils.data_split import time_train_val_test_split
from sklearn.model_selection import RandomizedSearchCV, TimeSeriesSplit
from sklearn.metrics import mean_absolute_error, make_scorer
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
    Führt eine Hyperparameteroptimierung mittels Validation-Set für verschiedene ML-Modelle durch.

    - Durchführung einer Randomized Search zur Optimierung der Hyperparameter
    - Ausgabe der besten Parameter für zwei Feature-Sets:
        1. nur statische Merkmale
        2. statische und prozessbezogene Merkmale

    Ziel ist die Verbesserung der Modellleistung durch geeignete Parametereinstellungen.
    """

    mae_scorer = make_scorer(mean_absolute_error, greater_is_better=False)

    #Daten laden 
    df_static, df_static_process = lade_daten()

    # Chronologischer Split mit Hilfsfunktion: time_train_val_test_split
    train_static, val_static, test_static = time_train_val_test_split(df_static, time_col="created")
    train_static_process, val_static_process, test_static_process = time_train_val_test_split(df_static_process, time_col="created")

    # Created wieder rausnehmen (wird nur für den Split genutzt)
    train_static = train_static.drop(columns="created")
    val_static = val_static.drop(columns="created")

    train_static_process = train_static_process.drop(columns="created")
    val_static_process = val_static_process.drop(columns="created")

    # Feature Encoding getrennt pro Split
    train_static_encode, val_static_encode, test_static_encode = encode_splits(train_static, val_static,test_static)
    train_static_process_encode, val_static_process_encode, test_static_process_encode = encode_splits(train_static_process, val_static_process, test_static_process)

    # Nur die static Features ohne die Zielvariable
    x_train_static = train_static_encode.drop(columns=["cycle_time_days"])
    # Nur die Werte der Zielvariablen
    y_train_static = train_static_encode["cycle_time_days"]

    x_val_static = val_static_encode.drop(columns=["cycle_time_days"])
    y_val_static = val_static_encode["cycle_time_days"]

    x_train_static_process = train_static_process_encode.drop(columns=["cycle_time_days"])
    y_train_static_process = train_static_process_encode["cycle_time_days"]

    x_val_static_process = val_static_process_encode.drop(columns=["cycle_time_days"])
    y_val_static_process = val_static_process_encode["cycle_time_days"]

    # train + val zusammenführen
    x_trainval_static = pd.concat([x_train_static, x_val_static], axis=0)
    y_trainval_static = pd.concat([y_train_static, y_val_static], axis=0)
    x_trainval_static_process = pd.concat([x_train_static_process, x_val_static_process], axis=0)
    y_trainval_static_process = pd.concat([y_train_static_process, y_val_static_process], axis=0)

    # Modellauswahl
    if model_name.lower() == "rf":
        model = RandomForestRegressor(random_state=432)
        param_grid = {
            # Anzahl an Bäumen in random forest
            "n_estimators": [200, 400, 600],
            # Maximale Zahl von Level in trees
            "max_depth": [None, 10, 20],
            # Minimum number of samples required to split a node
            "min_samples_split": [2, 10, 50],
            # Minimum number of samples required at each leaf node
            "min_samples_leaf": [1, 5, 20],
            # Number of features to consider at every split
            "max_features": ["sqrt",0.3, 0.5],
            # Method of selecting samples for training each tree
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

    # Time-aware CV (nur Vergangenheit -> Zukunft)
    tscv = TimeSeriesSplit(n_splits=5)

    # Randomized Grid Search
    RandomGrid = RandomizedSearchCV(
        estimator=model, 
        param_distributions=param_grid,
        n_iter=20, 
        cv=tscv, 
        verbose=2, 
        n_jobs=-1,
        scoring=mae_scorer,
        random_state=432
    )

    # Modelltraining
    # model trainieren mit den Trainings + val Daten
    RandomGrid.fit(x_trainval_static, y_trainval_static)
    print("\nBeste gefundene RandomForest Parameter (STATIC):")
    print(RandomGrid.best_params_)

    # model trainieren mit den Trainings + val Daten
    RandomGrid.fit(x_trainval_static_process, y_trainval_static_process)
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
