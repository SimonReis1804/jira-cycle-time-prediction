library(dplyr)
library(tidyr)

# 1) MedAE je Modell in Exp1 (Best Case: Static+Process + Hyperopt-Regel)
exp1_medae <- Master_Tabelle %>%
  filter(
    Experiment == "Exp1",
    Features == "Static+Process",
    (Modell == "Linear Regression" & Hyperopt == 0) |
      (Modell != "Linear Regression" & Hyperopt == 1)
  ) %>%
  group_by(Modell) %>%
  summarise(
    `MedAE (Exp1)` = mean(MedAE, na.rm = TRUE),
    .groups = "drop"
  )

# 2) Exp3: MedAE je Zielprojekt & Modell, dann pro Modell über Projekte mitteln
exp3_avg_medae <- Master_Tabelle %>%
  filter(
    Experiment == "Exp3",
    Features == "Static+Process",
    (Modell == "Linear Regression" & Hyperopt == 0) |
      (Modell != "Linear Regression" & Hyperopt == 1)
  ) %>%
  group_by(Projekt, Modell) %>%
  summarise(
    MedAE_proj = mean(MedAE, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(Modell) %>%
  summarise(
    `⌀ MedAE (Exp3)` = mean(MedAE_proj, na.rm = TRUE),
    .groups = "drop"
  )

# 3) Join + Performance Drop (% Verschlechterung gegenüber Exp1)
view_d_2 <- exp1_medae %>%
  left_join(exp3_avg_medae, by = "Modell") %>%
  mutate(
    Verschlechterung = ifelse(
      is.na(`MedAE (Exp1)`) | `MedAE (Exp1)` == 0,
      NA_real_,
      (`⌀ MedAE (Exp3)` - `MedAE (Exp1)`) / `MedAE (Exp1)` * 100
    )
  ) %>%
  mutate(
    `MedAE (Exp1)` = round(`MedAE (Exp1)`, 3),
    `⌀ MedAE (Exp3)` = round(`⌀ MedAE (Exp3)`, 3),
    Verschlechterung = round(Verschlechterung, 2)
  ) %>%
  select(Modell, `MedAE (Exp1)`, `⌀ MedAE (Exp3)`, Verschlechterung) %>%
  arrange(desc(Verschlechterung))

view_d_2
