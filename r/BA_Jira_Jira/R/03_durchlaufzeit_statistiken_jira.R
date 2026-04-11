# 02) DURCHLAUFZEIT-STATISTIKEN-------------------------------------------------
# 02.1) DURCHLAUFZEIT-STATISTIKEN: FÜR ALLE GELÖSTEN TICKETS--------------------

stats_overall <- jira_resolved_valid %>%
  summarise(
    n_tickets   = n(),
    mean_days   = mean(tt_resolve_days, na.rm = TRUE),
    median_days = median(tt_resolve_days, na.rm = TRUE),
    sd_days     = sd(tt_resolve_days, na.rm = TRUE),
    min_days    = min(tt_resolve_days, na.rm = TRUE),
    max_days    = max(tt_resolve_days, na.rm = TRUE)
  )

cat("\nDeskriptive Statistik über alle gelösten Tickets:\n")
print(stats_overall)

# 02.2) DURCHLAUFZEIT-STATISTIKEN: JE ISSUE TYPE--------------------------------

tt_by_issue_type <- jira_resolved_valid %>%
  group_by(issue_type) %>%
  summarise(
    n_tickets   = n(),
    median_days = median(tt_resolve_days),
    mean_days   = mean(tt_resolve_days),
    sd_days     = sd(tt_resolve_days),
    .groups = "drop"
  )

cat("\nDurchlaufzeit (Tage) je Issue-Typ:\n")
print(tt_by_issue_type)

# 02.3) DURCHLAUFZEIT-STATISTIKEN: JE PRIORITY----------------------------------

tt_by_priority <- jira_resolved_valid %>%
  group_by(priority) %>%
  summarise(
    n_tickets   = n(),
    median_days = median(tt_resolve_days),
    mean_days   = mean(tt_resolve_days),
    sd_days     = sd(tt_resolve_days),
    .groups = "drop"
  )

cat("\nDurchlaufzeit (Tage) je Priority:\n")
print(tt_by_priority)

# 02.4) DURCHLAUFZEIT-STATISTIKEN: QUANTILE & IQR-------------------------------

cycle_time_quantiles <- jira_resolved_valid %>%
  summarise(
    n_tickets = n(),
    q25 = quantile(tt_resolve_days, 0.25, na.rm = TRUE),
    q50 = quantile(tt_resolve_days, 0.50, na.rm = TRUE),
    q75 = quantile(tt_resolve_days, 0.75, na.rm = TRUE),
    iqr = IQR(tt_resolve_days, na.rm = TRUE)
  )

cat("\nQuantile & IQR (Cycle Time) – nur gelöste Tickets:\n")
print(cycle_time_quantiles)

# 02.5) %-ANTEIL AUSREißer------------------------------------------------------

q <- quantile(jira_resolved_valid$tt_resolve_days, probs = c(0.25, 0.75), na.rm = TRUE)
q1 <- q[1]; q3 <- q[2]
iqr_val <- q3 - q1

lower_fence <- q1 - 1.5 * iqr_val
upper_fence <- q3 + 1.5 * iqr_val

outlier_flags_iqr <- jira_resolved_valid %>%
  mutate(
    is_outlier_iqr = (tt_resolve_days < lower_fence) | (tt_resolve_days > upper_fence)
  )

outlier_share_iqr <- outlier_flags_iqr %>%
  summarise(
    n = n(),
    n_outliers = sum(is_outlier_iqr, na.rm = TRUE),
    pct_outliers = 100 * n_outliers / n
  )

cat("\nAusreißer-Anteil (IQR-Regel, 1.5*IQR):\n")
print(outlier_share_iqr)

cat("\nIQR-Grenzen:\n")
print(data.frame(lower_fence = lower_fence, upper_fence = upper_fence))

# 02.6) DURCHLAUFZEIT-STATISTIKEN: PLOTS----------------------------------------
library(ggplot2)

# Histogramm der Durchlaufzeit (Cycle Time)
p_cycle_time_days_resolved <- ggplot(jira_resolved_valid, aes(tt_resolve_days)) +
  geom_histogram(bins = 50) +
  scale_x_continuous(limits = c(0, quantile(jira_resolved_valid$tt_resolve_days, 0.99))) +
  labs(
    title = "Verteilung der Durchlaufzeit gelöster Tickets",
    x = "Durchlaufzeit (Tage)",
    y = "Anzahl Tickets"
  )

ggsave("plots/jira_cycle_time_days_resolved_hist.png", p_cycle_time_days_resolved, width = 8, height = 4)

# Boxplot für Durchlaufzeit je Issue Type
p_cycle_time_issue_type_days <- ggplot(jira_resolved_valid, aes(issue_type, tt_resolve_days)) +
  geom_boxplot(outlier.alpha = 0.2) +
  scale_y_continuous(limits = c(0, quantile(jira_resolved_valid$tt_resolve_days, 0.95))) +
  labs(
    title = "Durchlaufzeit nach Issue-Typ",
    x = "Issue Type",
    y = "Durchlaufzeit (Tage)"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("plots/jira_cycle_time_issue_type_days_boxplot.png", p_cycle_time_issue_type_days, width = 8, height = 4)

# Boxplot für Durchlaufzeit je Priority
p_cycle_time_priority_days <- ggplot(jira_resolved_valid, aes(priority, tt_resolve_days)) +
  geom_boxplot(outlier.alpha = 0.2) +
  scale_y_continuous(limits = c(0, quantile(jira_resolved_valid$tt_resolve_days, 0.95))) +
  labs(
    title = "Durchlaufzeit nach Priority",
    x = "Priority",
    y = "Durchlaufzeit (Tage)"
  )

ggsave("plots/jira_p_cycle_time_priority_days_boxplot.png", p_cycle_time_priority_days, width = 8, height = 4)

# 02.7) DATEN IN EXCEL SPEICHERN------------------------------------------------
#Durchlaufzeit-Statistiken
cycle_time_tables <- list(
  overall_stats   = stats_overall,
  quantiles_iqr   = cycle_time_quantiles,
  by_issue_type   = tt_by_issue_type,
  by_priority     = tt_by_priority,
  outlier_iqr     = outlier_share_iqr,
  outlier_fences  = data.frame(lower_fence, upper_fence)
)

write_xlsx(
  cycle_time_tables,
  path = "tables/jira_cycle_time_statistics.xlsx"
)

cat("\n01 Durchlaufzeit Statistiken für Jira Collection abgeschlossen. Plots liegen im Ordner 'plots', Tabellen liegen im Ordner 'tables'.\n")
