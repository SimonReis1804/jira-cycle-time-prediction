# Für Dataframes
import pandas as pd
# Eingbae über Terminal
import sys
import numpy as np
# Für die Funktion "lade_daten" aus der Datei
from src.data.daten_laden_jira import lade_daten
from src.features.feature_encoding_jira import encode_df
# ML-Modelle
from sklearn.ensemble import (
    GradientBoostingRegressor,
    RandomForestRegressor,
    HistGradientBoostingRegressor
)
from xgboost import XGBRegressor

# Für Train und Test Daten aufzuteilen
from sklearn.model_selection import train_test_split
# Um zu vergleichen wie gut das Modell ist R^2, MAE, RMSE
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error, median_absolute_error

def train_model(model_name: str):
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

    # Modellauswah
    if model_name.lower() == "rf":
        model_static = RandomForestRegressor(random_state=432,
                                            n_estimators=200,
                                            min_samples_split=2,
                                            min_samples_leaf=1,
                                            max_samples=0.9,
                                            max_features=0.3,
                                            max_depth=None,
                                            bootstrap=True)
        model_static_process = RandomForestRegressor(random_state=432,
                                                 n_estimators=400,
                                                 min_samples_split=2,
                                                 min_samples_leaf=1,
                                                 max_samples=0.8,
                                                 max_features=0.5,
                                                 max_depth=None,
                                                 bootstrap=True)
    elif model_name.lower() == "gbr":
        model_static = GradientBoostingRegressor(random_state=432,
                                         n_estimators=200,
                                         subsample=1.0,
                                         min_samples_leaf=20,
                                         max_features=None,
                                         max_depth=4,
                                         learning_rate=0.1)
        model_static_process = GradientBoostingRegressor(random_state=432,
                                         n_estimators=800,
                                         subsample=0.8,
                                         min_samples_leaf=1,
                                         max_features=0.5,
                                         max_depth=4,
                                         learning_rate=0.1)
    elif model_name.lower() == "xgbr":
        model_static = XGBRegressor(random_state=432,
                                subsample=0.8,
                                reg_lambda=1.0,
                                reg_alpha=1.0,
                                n_estimators=1000,
                                min_child_weight=5,
                                max_depth=8,
                                learning_rate=0.01,
                                colsample_bytree=0.6)
        model_static_process = XGBRegressor(random_state=432,
                                        subsample=1.0,
                                        reg_lambda=10.0,
                                        reg_alpha=1.0,
                                        n_estimators=1000,
                                        min_child_weight=5,
                                        max_depth=8,
                                        learning_rate=0.05,
                                        colsample_bytree=0.8)
    elif model_name.lower() == "histgbr":
        model_static = HistGradientBoostingRegressor(random_state=432,
                                                min_samples_leaf=20,
                                                max_leaf_nodes=63,
                                                max_iter=200,
                                                max_depth=8,
                                                learning_rate=0.1,
                                                l2_regularization=1.0)
        model_static_process = HistGradientBoostingRegressor(random_state=432,
                                                         min_samples_leaf=50,
                                                         max_leaf_nodes=31,
                                                         max_iter=500,
                                                         max_depth=None,
                                                         learning_rate=0.1,
                                                         l2_regularization=1.0)
    else:
        print("Unbekanntes Modell! Nutze: linear, rf, gbr, xgbr oder histgbr")
        sys.exit()

    # Modelltraining
    # model trainieren mit den Trainings Daten
    model_static.fit(x_train_static, y_train_static)
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
    model_static_process.fit(x_train_static_process, y_train_static_process)
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
