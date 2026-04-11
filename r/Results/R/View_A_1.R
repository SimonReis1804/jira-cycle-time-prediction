library(dplyr)

models <- c("Gradient Boosting",
            "Hist Gradient Boosting",
            "Linear Regression",
            "Random Forest",
            "XGBoost")

view_a_1 <- Master_Tabelle %>%
  filter(
    Experiment == "Exp1",
    Modell %in% models,
    Features == "Static+Process",
    (Modell == "Linear Regression" & Hyperopt == 0) |
      (Modell != "Linear Regression" & Hyperopt == 1)
  ) %>%
  select(Modell, MAE, RMSE, `R²`, MedAE) %>%
  arrange(Modell)

view_a_1