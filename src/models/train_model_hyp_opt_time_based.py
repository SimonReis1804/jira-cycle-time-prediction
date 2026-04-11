# Für Dataframes
import pandas as pd
import numpy as np
# Eingbae über Terminal
import sys
# Für die Funktion "lade_daten" aus der Datei
from src.data.daten_laden_time_based import lade_daten
from src.features.feature_encoding_time_based import encode_splits
from src.utils.data_split import time_train_val_test_split
# ML-Modelle
from sklearn.ensemble import (
    GradientBoostingRegressor,
    RandomForestRegressor,
    HistGradientBoostingRegressor
)
from xgboost import XGBRegressor

# Um zu vergleichen wie gut das Modell ist R^2, MAE, RMSE
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error, median_absolute_error

def train_model(model_name: str):
    """
    Trainiert ein Modell (zeitbezogen) innerhalb eins Jira-Projektes. Optimale Hyperparameter wurden eingefügt.
    
    Es werden zwei Feature-Sets betrachtet
    1. Statische Merkmale
    2. Statische und prozessbezogene Merkmale
    
    Besonderheiten
    - Trainiert werden die Modelle auf den ältesten 70% der Daten
    - Gestet auf den neuesten 15% der Daten
    - Die Konfiguration der Hyperparameter fand mittels Validation Set statt
    
    Ziel ist es zu schauen wie Modelle auf eine zeitbezogene Datenaufteilung reagieren und welche Rolle der Einfluss einer Hyperparameteroptimierung hat
    """
    #Daten laden 
    df_static, df_static_process = lade_daten()

    # Chronologischer Split mit Hilfsfunktion: time_train_val_test_split
    train_static, val_static, test_static = time_train_val_test_split(df_static, time_col="created")
    train_static_process, val_static_process, test_static_process = time_train_val_test_split(df_static_process, time_col="created")

    # Created wieder rausnehmen (wird nur für den Split genutzt)
    train_static = train_static.drop(columns="created")
    val_static = val_static.drop(columns="created")
    test_static = test_static.drop(columns="created")

    train_static_process = train_static_process.drop(columns="created")
    val_static_process = val_static_process.drop(columns="created")
    test_static_process = test_static_process.drop(columns="created")

    # Feature Encoding getrennt pro Split
    train_static_encode, val_static_encode, test_static_encode = encode_splits(train_static, val_static,test_static)
    train_static_process_encode, val_static_process_encode, test_static_process_encode = encode_splits(train_static_process, val_static_process, test_static_process)

    # Nur die static Features ohne die Zielvariable
    x_train_static = train_static_encode.drop(columns=["cycle_time_days"])
    # Nur die Werte der Zielvariablen
    y_train_static = train_static_encode["cycle_time_days"]

    x_val_static = val_static_encode.drop(columns=["cycle_time_days"])
    y_val_static = val_static_encode["cycle_time_days"]

    x_test_static = test_static_encode.drop(columns=["cycle_time_days"])
    y_test_static = test_static_encode["cycle_time_days"]

    # Train + Val zusammenführen, sodass keine Daten verloren gehen
    x_trainval_static = pd.concat([x_train_static, x_val_static], axis=0)
    y_trainval_static = pd.concat([y_train_static, y_val_static], axis=0)

    x_train_static_process = train_static_process_encode.drop(columns=["cycle_time_days"])
    y_train_static_process = train_static_process_encode["cycle_time_days"]

    x_val_static_process = val_static_process_encode.drop(columns=["cycle_time_days"])
    y_val_static_process = val_static_process_encode["cycle_time_days"]

    x_test_static_process = test_static_process_encode.drop(columns=["cycle_time_days"])
    y_test_static_process = test_static_process_encode["cycle_time_days"]

    # Train + Val zusammenführen, sodass keine Daten verloren gehen
    x_trainval_static_process = pd.concat([x_train_static_process, x_val_static_process], axis=0)
    y_trainval_static_process = pd.concat([y_train_static_process, y_val_static_process], axis=0)

    if model_name.lower() == "rf":
        model_static = RandomForestRegressor(random_state=432,
                                            n_estimators=400,
                                            min_samples_split=2,
                                            min_samples_leaf=20,
                                            max_samples=0.9,
                                            max_features="sqrt",
                                            max_depth=10,
                                            bootstrap=True)
        model_static_process = RandomForestRegressor(random_state=432,
                                                 n_estimators=400,
                                                 min_samples_split=10,
                                                 min_samples_leaf=5,
                                                 max_samples=0.6,
                                                 max_features=0.5,
                                                 max_depth=None,
                                                 bootstrap=True)
    elif model_name.lower() == "gbr":
        model_static = GradientBoostingRegressor(random_state=432,
                                         n_estimators=200,
                                         subsample=1.0,
                                         min_samples_leaf=5,
                                         max_features="sqrt",
                                         max_depth=3,
                                         learning_rate=0.05)
        model_static_process = GradientBoostingRegressor(random_state=432,
                                         n_estimators=500,
                                         subsample=1,
                                         min_samples_leaf=5,
                                         max_features=None,
                                         max_depth=4,
                                         learning_rate=0.1)
    elif model_name.lower() == "xgbr":
        model_static = XGBRegressor(random_state=432,
                                subsample=0.8,
                                reg_lambda=5.0,
                                reg_alpha=1.0,
                                n_estimators=300,
                                min_child_weight=5,
                                max_depth=5,
                                learning_rate=0.01,
                                colsample_bytree=0.8)
        model_static_process = XGBRegressor(random_state=432,
                                        subsample=0.6,
                                        reg_lambda=10.0,
                                        reg_alpha=1.0,
                                        n_estimators=600,
                                        min_child_weight=1,
                                        max_depth=8,
                                        learning_rate=0.05,
                                        colsample_bytree=1.0)
    elif model_name.lower() == "histgbr":
        model_static = HistGradientBoostingRegressor(random_state=432,
                                                min_samples_leaf=10,
                                                max_leaf_nodes=31,
                                                max_iter=1000,
                                                max_depth=8,
                                                learning_rate=0.01,
                                                l2_regularization=1.0)
        model_static_process = HistGradientBoostingRegressor(random_state=432,
                                                         min_samples_leaf=50,
                                                         max_leaf_nodes=31,
                                                         max_iter=500,
                                                         max_depth=None,
                                                         learning_rate=0.1,
                                                         l2_regularization=1.0)
    else:
        print("Unbekanntes Modell! Nutze: rf, gbr, xgbr oder histgbr")
        sys.exit()

    # Modelltraining
    # Modell trainieren mit den Trainings Daten
    model_static.fit(x_trainval_static, y_trainval_static)
    # Die Vorhersage des Targets wird hier gespeichert
    y_pred_static = model_static.predict(x_test_static)

    # Test wie gut die Vorhersage ist
    r2_static = r2_score(y_test_static, y_pred_static)
    MAE_static = float(mean_absolute_error(y_test_static, y_pred_static))
    RMSE_static = np.sqrt(mean_squared_error(y_test_static, y_pred_static))
    MedAE_static = median_absolute_error(y_test_static, y_pred_static)

    print(f"Static-Features R²: {model_name} {r2_static:.4f}")
    print(f"Static-Features MAE: {model_name}, {MAE_static:.4f}")
    print (f"Static-Features RMSE: {model_name} {RMSE_static:.4f}")
    print (f"Static-Features MedAE: {model_name} {MedAE_static:.4f}")

    # model trainieren mit den Trainings Daten
    model_static_process.fit(x_trainval_static_process, y_trainval_static_process)
    # Die Vorhersage des Targets wird hier gespeichert
    y_pred_static_process = model_static_process.predict(x_test_static_process)
    # Test wie gut die Vorhersage ist
    r2_static_process = r2_score(y_test_static_process, y_pred_static_process)
    MAE_static_process = float(mean_absolute_error(y_test_static_process, y_pred_static_process))
    RMSE_static_process = np.sqrt(mean_squared_error(y_test_static_process, y_pred_static_process))
    MedAE_static_process = median_absolute_error(y_test_static_process, y_pred_static_process)

    print(f"Static & Process -Features R²: {model_name} {r2_static_process:.4f}")
    print(f"Static & Process -Features MAE: {model_name}, {MAE_static_process:.4f}")
    print (f"Static-Features RMSE: {model_name} {RMSE_static_process:.4f}")
    print (f"Static-Features MedAE: {model_name} {MedAE_static_process:.4f}")

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
    train_model(arg)
