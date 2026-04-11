# Histogramm der Durchlaufzeit (Cycle Time)
p_cycle_time_days_resolved <- ggplot(mariadb_resolved_valid, aes(tt_resolve_days)) +
  geom_histogram(bins = 50) +
  scale_x_continuous(limits = c(0, quantile(mariadb_resolved_valid$tt_resolve_days, 0.99))) +
  labs(
    title = "Verteilung der Durchlaufzeit gelöster Tickets",
    x = "Durchlaufzeit (Tage)",
    y = "Anzahl Tickets"
  )

ggsave("plots/mariadb_cycle_time_days_resolved_hist.png", p_cycle_time_days_resolved, width = 8, height = 4)