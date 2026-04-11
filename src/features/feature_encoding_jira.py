# Für Dataframes
import pandas as pd
# Für OneHotEncoding bei issue_type
from sklearn.preprocessing import OneHotEncoder
# Für OrdinalEncoder bei priority
from sklearn.preprocessing import OrdinalEncoder
from src.data.daten_laden_jira import lade_daten
import numpy as np


def encode_df(df):
    # Issue Type: OHE
    # Behandlung von fehlenden Werten
    ohe = OneHotEncoder(handle_unknown='ignore', sparse_output=False).set_output(transform='pandas')
    # Zuordnung der einzelnen Typen zu 0/1
    ohe_df = ohe.fit_transform(df[['issue_type']])

    # Priority: OE
    # Variable für die verschiedenen Prioritäten anlegen
    priorities = ['Low', 'Medium', 'High', 'Highest']
    # Wird uns die Randordnung erlauben zu definieren
    oe = OrdinalEncoder(categories=[priorities])
    # Tabelle wieder zusammenführen
    df['priority'] = oe.fit_transform(df[['priority']])

    # zyklisches Encoding
    df["month_sin"] = np.sin(2 * np.pi * df["created_month"] / 12)
    df["month_cos"] = np.cos(2 * np.pi * df["created_month"] / 12)    

    # Created Weekday: OHE
    # Behandlung von fehlenden Werten
    weekday_ohe = OneHotEncoder(handle_unknown='ignore', sparse_output=False).set_output(transform='pandas')
    # Zuordnung der einzelnen Tage zu 0/1
    weekday_df = weekday_ohe.fit_transform(df[['created_weekday']])

    # Zusammenführen
    df = pd.concat([
        df.drop(columns=['issue_type', 'created_weekday']), 
        ohe_df, 
        weekday_df
        ], axis=1)
    
    return df
    

