import numpy as np
import pandas as pd

def time_train_val_test_split(df, 
                              time_col="created", 
                              train_size=0.7, 
                              val_size=0.15, 
                              test_size=0.15):
    
    # Datum in datetime umwandeln
    df = df.copy()
    df[time_col] = pd.to_datetime(df[time_col], errors="coerce", utc=True)

    # Zeilen ohne Datum entfernen (sonst kann nicht chronologisch sortiert werden)
    df = df.dropna(subset=[time_col])

    # Chronologisch sortieren
    df = df.sort_values(time_col).reset_index(drop=True)

    # Index-Grenzen berechnen
    n = len(df)
    n_train = int(np.floor(n * train_size))
    n_val = int(np.floor(n * val_size))
    # Rest geht in Test
    train_df = df.iloc[:n_train]
    val_df = df.iloc[n_train:n_train + n_val]
    test_df = df.iloc[n_train + n_val:] 

    return train_df, val_df, test_df  

