import pandas as pd
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder

PRIORITIES = ["Low", "Medium", "High", "Highest"]

def fit_encoders(train_df: pd.DataFrame):
    """
    Lernt die Kategorien/Mapping NUR anhand der Trainingsdaten.
    """
    ohe = OneHotEncoder(handle_unknown="ignore", sparse_output=False).set_output(transform="pandas")
    ohe.fit(train_df[["issue_type"]])

    ohe_weekday = OneHotEncoder(handle_unknown="ignore", sparse_output=False).set_output(transform="pandas")
    ohe_weekday.fit(train_df[["created_weekday"]])

    oe = OrdinalEncoder(categories=[PRIORITIES])
    oe.fit(train_df[["priority"]])

    return ohe, ohe_weekday, oe


def transform_with_encoders(df: pd.DataFrame, ohe: OneHotEncoder, ohe_weekday: OneHotEncoder, oe: OrdinalEncoder) -> pd.DataFrame:
    """
    Wendet die bereits gelernten Encoder auf beliebige Daten an (train/val/test).
    Ergebnis hat konsistente Spalten.
    """
    df = df.copy()

    ohe_df = ohe.transform(df[["issue_type"]])
    weekday_df = ohe_weekday.transform(df[["created_weekday"]])
    df["priority"] = oe.transform(df[["priority"]])

    df = pd.concat(
        [df.drop(columns=["issue_type", "created_weekday"]), ohe_df, weekday_df], 
        axis=1)
    return df


def encode_splits(train_df: pd.DataFrame, val_df: pd.DataFrame, test_df: pd.DataFrame):
    """
    Fit auf train, transform auf train/val/test.
    """
    ohe, ohe_weekday, oe = fit_encoders(train_df)
    train_enc = transform_with_encoders(train_df, ohe, ohe_weekday, oe)
    val_enc = transform_with_encoders(val_df, ohe, ohe_weekday, oe)
    test_enc = transform_with_encoders(test_df, ohe, ohe_weekday, oe)
    return train_enc, val_enc, test_enc
