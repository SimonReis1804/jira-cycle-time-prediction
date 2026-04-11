import pandas as pd
import sys
import numpy as np
from src.data.daten_laden_jira import lade_daten
from src.data.daten_laden_hyperledger import lade_daten_hyperledger
from src.features.map_issue_type import map_issue_type
from src.features.map_priority import map_priority
from src.features.feature_encoding_generalization import encode_general_fit, encode_general_transform
from sklearn.ensemble import (
    GradientBoostingRegressor,
    RandomForestRegressor,
    HistGradientBoostingRegressor
)
from xgboost import XGBRegressor
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error, median_absolute_error


def train_model(model_name: str):
    """
    Trainiert ein Modell auf Jira-Daten und testet es auf Hyperledger-Daten. Es wurden Hyperparameter eingefügt, die mittels Validation Set konfiguriert wurden.

    Es werden zwei Feature-Sets betrachtet:
    1. nur statische Merkmale
    2. statische + prozessbezogene Merkmale

    Ziel ist die Untersuchung der projektübergreifenden Generalisierbarkeit und welchen Einfluss eine Hyperparameteroptimierung auf die Vorhersage hat.
    """
    df_static_jira, df_static_process_jira = lade_daten()
    df_static_hyperledger, df_static_process_hyperledger = lade_daten_hyperledger()

    df_static_jira["issue_type_grouped"] = df_static_jira["issue_type"].apply(map_issue_type)
    df_static_process_jira["issue_type_grouped"] = df_static_process_jira["issue_type"].apply(map_issue_type)
    df_static_hyperledger["issue_type_grouped"] = df_static_hyperledger["issue_type"].apply(map_issue_type)
    df_static_process_hyperledger["issue_type_grouped"] = df_static_process_hyperledger["issue_type"].apply(map_issue_type)

    df_static_jira["priority_level"] = df_static_jira["priority"].apply(map_priority)
    df_static_process_jira["priority_level"] = df_static_process_jira["priority"].apply(map_priority)
    df_static_hyperledger["priority_level"] = df_static_hyperledger["priority"].apply(map_priority)
    df_static_process_hyperledger["priority_level"] = df_static_process_hyperledger["priority"].apply(map_priority)

    issue_ohe_static, weekday_ohe_static = encode_general_fit(df_static_jira)
    issue_ohe_static_process, weekday_ohe_static_process = encode_general_fit(df_static_process_jira)

    jira_static_enc = encode_general_transform(df_static_jira, issue_ohe_static, weekday_ohe_static)
    jira_static_process_enc = encode_general_transform(df_static_process_jira, issue_ohe_static_process, weekday_ohe_static_process)

    hyperledger_static_enc = encode_general_transform(df_static_hyperledger, issue_ohe_static, weekday_ohe_static)
    hyperledger_static_process_enc = encode_general_transform(df_static_process_hyperledger, issue_ohe_static_process, weekday_ohe_static_process)

    x_static_jira = jira_static_enc.drop(columns=["cycle_time_days"])
    y_static_jira = jira_static_enc["cycle_time_days"]
    x_static_process_jira = jira_static_process_enc.drop(columns=["cycle_time_days"])
    y_static_process_jira = jira_static_process_enc["cycle_time_days"]

    x_static_hyperledger = hyperledger_static_enc.drop(columns=["cycle_time_days"])
    y_static_hyperledger = hyperledger_static_enc["cycle_time_days"]
    x_static_process_hyperledger = hyperledger_static_process_enc.drop(columns=["cycle_time_days"])
    y_static_process_hyperledger = hyperledger_static_process_enc["cycle_time_days"]

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

    #===================================
    # MODELL MIT STATIC-FEATURES
    #===================================
    model_static.fit(x_static_jira, y_static_jira)
    y_pred_static = model_static.predict(x_static_hyperledger)
    r2_static = r2_score(y_static_hyperledger, y_pred_static)
    MAE_static = float(mean_absolute_error(y_static_hyperledger, y_pred_static))
    RMSE_static = np.sqrt(mean_squared_error(y_static_hyperledger, y_pred_static))
    MedAE_static = median_absolute_error(y_static_hyperledger, y_pred_static)

    print (f"Static-Features R²: {model_name} {r2_static:.4f}")
    print (f"Static-Features MAE: {model_name} {MAE_static:.4f}")
    print (f"Static-Features RMSE: {model_name} {RMSE_static:.4f}")
    print (f"Static-Features MedAE: {model_name} {MedAE_static:.4f}")

    #===================================
    # MODELL MIT STATIC+PROCESS-FEATURES
    #===================================
    model_static_process.fit(x_static_process_jira, y_static_process_jira)
    y_pred_static_process = model_static_process.predict(x_static_process_hyperledger)
    r2_static_process = r2_score(y_static_process_hyperledger, y_pred_static_process)
    MAE_static_process = float(mean_absolute_error(y_static_process_hyperledger, y_pred_static_process))
    RMSE_static_process = np.sqrt(mean_squared_error(y_static_process_hyperledger, y_pred_static_process))
    MedAE_static_process = median_absolute_error(y_static_process_hyperledger, y_pred_static_process)

    print (f"Static-Features R²: {model_name} {r2_static_process:.4f}")
    print (f"Static-Features MAE: {model_name} {MAE_static_process:.4f}")
    print (f"Static-Features RMSE: {model_name} {RMSE_static_process:.4f}")
    print (f"Static-Features MedAE: {model_name} {MedAE_static_process:.4f}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Bitte Modell wählen: linear, rf oder gbr")
        sys.exit(1)

    arg = sys.argv[1]
    train_model(arg)
