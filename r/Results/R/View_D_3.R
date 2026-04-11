library(dplyr)

# Einfluss der Hyperparameteroptimierung in Exp3:
# "ohne" = Hyperopt 0, "mit" = Hyperopt 1
view_d_3 <- Master_Tabelle %>%
  filter(
    Experiment == "Exp3",
    Features == "Static+Process",
    Modell != "Linear Regression"   # LR hat kein Hyperopt=1, daher nicht vergleichbar
  ) %>%
  group_by(Modell, Hyperopt) %>%
  summarise(
    MedAE = mean(MedAE, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::pivot_wider(
    names_from = Hyperopt,
    values_from = MedAE,
    names_prefix = "MedAE_"
  ) %>%
  transmute(
    Modell,
    `MedAE ohne` = MedAE_0,
    `MedAE mit`  = MedAE_1,
    `Verbesserung in %` = ifelse(
      is.na(`MedAE ohne`) | `MedAE ohne` == 0,
      NA_real_,
      (`MedAE ohne` - `MedAE mit`) / `MedAE ohne` * 100
    )
  ) %>%
  arrange(`MedAE mit`) %>%
  mutate(
    `MedAE ohne` = round(`MedAE ohne`, 3),
    `MedAE mit`  = round(`MedAE mit`, 3),
    `Verbesserung in %` = round(`Verbesserung in %`, 2)
  )

view_d_3
