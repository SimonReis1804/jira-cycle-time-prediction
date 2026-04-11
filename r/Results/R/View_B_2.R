library(readxl)
library(dplyr)
library(tidyr)

# 1) Filtern + Mittelwerte je Experiment/Modell/Features
avg_by_feat <- Master_Tabelle %>%
  filter(
    Features %in% c("Static", "Static+Process"),
    (Modell == "Linear Regression" & Hyperopt == 0) |
      (Modell != "Linear Regression" & Hyperopt == 1)
  ) %>%
  group_by(Experiment, Modell, Features) %>%
  summarise(
    MAE  = mean(MAE,  na.rm = TRUE),
    RMSE = mean(RMSE, na.rm = TRUE),
    R2   = mean(`R²`, na.rm = TRUE),
    MedAE = mean(MedAE, na.rm = TRUE),
    .groups = "drop"
  )

# 2) Breit machen (Static vs Static+Process nebeneinander)
wide_avg <- avg_by_feat %>%
  pivot_wider(
    names_from = Features,
    values_from = c(MAE, RMSE, R2, MedAE),
    names_sep = "__"
  )

# 3) Verbesserung berechnen (Differenz der Durchschnittswerte)
view_b_2 <- wide_avg %>%
  mutate(
    Improve_MAE   = MAE__Static - `MAE__Static+Process`,
    Improve_RMSE  = RMSE__Static - `RMSE__Static+Process`,
    Improve_MedAE = MedAE__Static - `MedAE__Static+Process`,
    Improve_R2    = `R2__Static+Process` - R2__Static,
    
    # Prozentuale Verbesserungen je Metrik
    Improve_MAE_pct = ifelse(MAE__Static == 0, NA, Improve_MAE / MAE__Static * 100),
    Improve_RMSE_pct = ifelse(RMSE__Static == 0, NA, Improve_RMSE / RMSE__Static * 100),
    Improve_MedAE_pct = ifelse(MedAE__Static == 0, NA, Improve_MedAE / MedAE__Static * 100),
    Improve_R2_pct = ifelse(abs(R2__Static) == 0, NA, Improve_R2 / abs(R2__Static) * 100)
  ) %>%
  mutate(across(starts_with("Improve_"), ~ round(.x, 3))) %>%
  select(Experiment, Modell,
         Improve_MAE, Improve_MAE_pct,
         Improve_RMSE, Improve_RMSE_pct,
         Improve_MedAE, Improve_MedAE_pct,
         Improve_R2, Improve_R2_pct)

view_b_2