library(dplyr)

models <- c("Gradient Boosting",
            "Hist Gradient Boosting",
            "Linear Regression",
            "Random Forest",
            "XGBoost")

view_a_2 <- Master_Tabelle %>%
  filter(
    Experiment == "Exp2",
    Modell %in% models,
    Features == "Static+Process",
    (Modell == "Linear Regression" & Hyperopt == 0) |
      (Modell != "Linear Regression" & Hyperopt == 1)
  ) %>%
  select(Modell, MAE, RMSE, `R²`, MedAE) %>%
  arrange(Modell)

view_a_2