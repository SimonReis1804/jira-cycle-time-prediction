library(dplyr)

view_d_1 <- Master_Tabelle %>%
  filter(
    Experiment == "Exp3",
    Projekt %in% c("Hyperledger", "Jiraecosystem", "Mariadb", "Spring"),
    Features == "Static+Process",
    (Modell == "Linear Regression" & Hyperopt == 0) |
      (Modell != "Linear Regression" & Hyperopt == 1)
  ) %>%
  group_by(Projekt) %>%
  summarise(
    `⌀ MAE`   = mean(MAE, na.rm = TRUE),
    `⌀ RMSE`  = mean(RMSE, na.rm = TRUE),
    `⌀ MedAE` = mean(MedAE, na.rm = TRUE),
    `⌀ R²`    = mean(`R²`, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(across(where(is.numeric), ~ round(.x, 3))) %>%
  arrange(`⌀ MAE`)

view_d_1
