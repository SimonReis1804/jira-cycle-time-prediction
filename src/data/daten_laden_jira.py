 # Für Connection zu MongoDB Compass
from pymongo import MongoClient
# Für Dataframes
import pandas as pd

def lade_daten():
    # Verbindung herstellen
    client = MongoClient("mongodb://localhost:27017") 
    # Datenbank wählen
    db = client["JiraReposAnon"]
    # Collection wählen
    collection = db["jira_features_resolved"]
    # Static Features herausfiltern
    static_features = {
        # Static Features
        "issue_type": 1,
        "priority": 1,
        "summary_len": 1,
        "description_len": 1,
        "created_month": 1,
        "created_weekday": 1,
        "is_weekend_created": 1,

        # Zielvariable
        "cycle_time_days": 1,
        "_id": 0
    }

    # Static + process Features
    static_process_features = {
        # Static Features
        "issue_type": 1,
        "priority": 1,
        "summary_len": 1,
        "description_len": 1,
        "created_month": 1,
        "created_weekday": 1,
        "is_weekend_created": 1,

        # Prozessbezogene Features
        "changelog_total": 1,
        "historyEventCount": 1,
        "n_status_changes": 1,
        "time_to_first_change_days": 1,
        "avg_time_between_changes": 1,
        "has_active_assignee": 1,
        "has_active_assignee_missing": 1,
        "sd_time_between_changes": 1,
        "min_time_between_changes": 1,
        "max_time_between_changes": 1,

        # Zielvariable
        "cycle_time_days": 1,
        "_id": 0
    }

    # Es wird ein Dataframe erstellt mit den Static Features
    results_static = collection.find({}, static_features)
    df_static = pd.DataFrame(data=results_static)

    # Es wird ein Dataframe erstellt mit den Static + Process Features
    results_static_process = collection.find({}, static_process_features)
    df_static_process = pd.DataFrame(data=results_static_process)

    # Dataframe zurück geben
    return df_static, df_static_process


