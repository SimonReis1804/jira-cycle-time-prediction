import pandas as pd
from sklearn.preprocessing import OneHotEncoder
import numpy as np

def encode_general_fit(train_df):
    issue_ohe = OneHotEncoder(handle_unknown="ignore", sparse_output=False).set_output(transform="pandas")
    weekday_ohe = OneHotEncoder(handle_unknown="ignore", sparse_output=False).set_output(transform="pandas")

    issue_ohe.fit(train_df[["issue_type_grouped"]])
    weekday_ohe.fit(train_df[["created_weekday"]])

    return issue_ohe, weekday_ohe

def encode_general_transform(df, issue_ohe, weekday_ohe):
    ohe_df = issue_ohe.transform(df[["issue_type_grouped"]])
    weekday_df = weekday_ohe.transform(df[["created_weekday"]])

    df = df.copy()
    df["month_sin"] = np.sin(2 * np.pi * df["created_month"] / 12)
    df["month_cos"] = np.cos(2 * np.pi * df["created_month"] / 12)

    df = pd.concat(
        [df.drop(columns=["issue_type", "priority", "issue_type_grouped", "created_weekday"]),  # priority raus, du nutzt priority_level
         ohe_df,
         weekday_df],
        axis=1
    )
    
    return df
