library(dplyr)
library(tidyr)

# 1) filtern + Mittelwerte je Experiment/Modell/Features
avg_by_model <- Master_Tabelle %>%
  filter(
    Features %in% c("Static", "Static+Process"),
    (Modell == "Linear Regression" & Hyperopt == 0) |
      (Modell != "Linear Regression" & Hyperopt == 1)
  ) %>%
  group_by(Experiment, Modell, Features) %>%
  summarise(
    MAE   = mean(MAE, na.rm = TRUE),
    RMSE  = mean(RMSE, na.rm = TRUE),
    MedAE = mean(MedAE, na.rm = TRUE),
    R2    = mean(`R²`, na.rm = TRUE),
    .groups = "drop"
  )

# 2) Über alle Modelle je Experiment/Features den gemeinsamen Durchschnitt bilden
avg_all_models <- avg_by_model %>%
  group_by(Experiment, Features) %>%
  summarise(
    MAE   = mean(MAE, na.rm = TRUE),
    RMSE  = mean(RMSE, na.rm = TRUE),
    MedAE = mean(MedAE, na.rm = TRUE),
    R2    = mean(R2, na.rm = TRUE),
    .groups = "drop"
  )

# 3) Static vs Static+Process nebeneinander + Improvement berechnen
view_b_1 <- avg_all_models %>%
  pivot_wider(
    names_from = Features,
    values_from = c(MAE, RMSE, MedAE, R2),
    names_sep = "__"
  ) %>%
  transmute(
    Experiment,
    Improve_MAE   = MAE__Static - `MAE__Static+Process`,
    Improve_RMSE  = RMSE__Static - `RMSE__Static+Process`,
    Improve_MedAE = MedAE__Static - `MedAE__Static+Process`,
    `Improve_R²`  = `R2__Static+Process` - R2__Static
  ) %>%
  arrange(Experiment)

view_b_1
