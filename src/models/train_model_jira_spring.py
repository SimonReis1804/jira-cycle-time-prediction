import pandas as pd
import sys
import numpy as np
from src.data.daten_laden_jira import lade_daten
from src.data.daten_laden_spring import lade_daten_spring
from src.features.map_issue_type import map_issue_type
from src.features.map_priority import map_priority
from src.features.feature_encoding_generalization import encode_general_fit, encode_general_transform
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import (
    GradientBoostingRegressor,
    RandomForestRegressor,
    HistGradientBoostingRegressor
)
from xgboost import XGBRegressor
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error, median_absolute_error


def train_model(model_name: str):
    df_static_jira, df_static_process_jira = lade_daten()
    df_static_spring, df_static_process_spring = lade_daten_spring()

    df_static_jira["issue_type_grouped"] = df_static_jira["issue_type"].apply(map_issue_type)
    df_static_process_jira["issue_type_grouped"] = df_static_process_jira["issue_type"].apply(map_issue_type)
    df_static_spring["issue_type_grouped"] = df_static_spring["issue_type"].apply(map_issue_type)
    df_static_process_spring["issue_type_grouped"] = df_static_process_spring["issue_type"].apply(map_issue_type)

    df_static_jira["priority_level"] = df_static_jira["priority"].apply(map_priority)
    df_static_process_jira["priority_level"] = df_static_process_jira["priority"].apply(map_priority)
    df_static_spring["priority_level"] = df_static_spring["priority"].apply(map_priority)
    df_static_process_spring["priority_level"] = df_static_process_spring["priority"].apply(map_priority)

    issue_ohe_static, weekday_ohe_static = encode_general_fit(df_static_jira)
    issue_ohe_static_process, weekday_ohe_static_process = encode_general_fit(df_static_process_jira)

    jira_static_enc = encode_general_transform(df_static_jira, issue_ohe_static, weekday_ohe_static)
    jira_static_process_enc = encode_general_transform(df_static_process_jira, issue_ohe_static_process, weekday_ohe_static_process)

    spring_static_enc = encode_general_transform(df_static_spring, issue_ohe_static, weekday_ohe_static)
    spring_static_process_enc = encode_general_transform(df_static_process_spring, issue_ohe_static_process, weekday_ohe_static_process)

    x_static_jira = jira_static_enc.drop(columns=["cycle_time_days"])
    y_static_jira = jira_static_enc["cycle_time_days"]
    x_static_process_jira = jira_static_process_enc.drop(columns=["cycle_time_days"])
    y_static_process_jira = jira_static_process_enc["cycle_time_days"]

    x_static_spring = spring_static_enc.drop(columns=["cycle_time_days"])
    y_static_spring = spring_static_enc["cycle_time_days"]
    x_static_process_spring = spring_static_process_enc.drop(columns=["cycle_time_days"])
    y_static_process_spring = spring_static_process_enc["cycle_time_days"]


    if model_name.lower() == "linear":
        model = LinearRegression()
    elif model_name.lower() == "rf":
        model = RandomForestRegressor(random_state=432)
    elif model_name.lower() == "gbr":
        model = GradientBoostingRegressor(random_state=432)
    elif model_name.lower() == "xgbr":
        model = XGBRegressor(random_state=432)
    elif model_name.lower() == "histgbr":
        model = HistGradientBoostingRegressor(random_state=432)
    else:
        print("Unbekanntes Modell! Nutze: linear, rf, gbr, xgbr oder histgbr")
        sys.exit()

    #===================================
    # MODELL MIT STATIC-FEATURES
    #===================================
    model.fit(x_static_jira, y_static_jira)
    y_pred_static = model.predict(x_static_spring)
    r2_static = r2_score(y_static_spring, y_pred_static)
    MAE_static = float(mean_absolute_error(y_static_spring, y_pred_static))
    RMSE_static = np.sqrt(mean_squared_error(y_static_spring, y_pred_static))
    MedAE_static = median_absolute_error(y_static_spring, y_pred_static)

    print (f"Static-Features R²: {model_name} {r2_static:.4f}")
    print (f"Static-Features MAE: {model_name} {MAE_static:.4f}")
    print (f"Static-Features RMSE: {model_name} {RMSE_static:.4f}")
    print (f"Static-Features MedAE: {model_name} {MedAE_static:.4f}")

    #===================================
    # MODELL MIT STATIC+PROCESS-FEATURES
    #===================================
    model.fit(x_static_process_jira, y_static_process_jira)
    y_pred_static_process = model.predict(x_static_process_spring)
    r2_static_process = r2_score(y_static_process_spring, y_pred_static_process)
    MAE_static_process = float(mean_absolute_error(y_static_process_spring, y_pred_static_process))
    RMSE_static_process = np.sqrt(mean_squared_error(y_static_process_spring, y_pred_static_process))
    MedAE_static_process = median_absolute_error(y_static_process_spring, y_pred_static_process)

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
