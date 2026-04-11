library(dplyr)
library(tidyr)

# Best-Case Ranking: Static+Process + Hyperopt==1 
view_c_1 <- Master_Tabelle %>%
  filter(
    Experiment %in% c("Exp1", "Exp2"),
    Features == "Static+Process",
    ((Modell == "Linear Regression" & Hyperopt == 0) | 
       (Modell != "Linear Regression" & Hyperopt == 1))
  ) %>%
  group_by(Experiment, Modell) %>%
  summarise(
    MedAE = mean(MedAE, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from  = Experiment,
    values_from = MedAE,
    names_prefix = "MedAE ("
  ) %>%
  rename(
    `MedAE (Exp1)` = `MedAE (Exp1`,
    `MedAE (Exp2)` = `MedAE (Exp2`
  ) %>%
  mutate(
    Avg_MedAE = rowMeans(across(c(`MedAE (Exp1)`, `MedAE (Exp2)`)), na.rm = TRUE)
  ) %>%
  arrange(Avg_MedAE) %>%
  mutate(Rang = row_number()) %>%
  select(Rang, Modell, `MedAE (Exp1)`, `MedAE (Exp2)`)

view_c_1
