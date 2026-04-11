# 03) ZEITLICHE ENTWICKLUNG-----------------------------------------------------
# 03.1) TICKETS AN WOCHENENDEN--------------------------------------------------

tickets_weekend <- jira_tickets %>%
  filter(!is.na(created)) %>%
  mutate(
    weekday = wday(created, label = TRUE, week_start = 1),
    is_weekend = weekday %in% c("Sa", "So")
  ) %>%
  count(is_weekend)

# 03.2) TICKETS PRO WOCHENTAG---------------------------------------------------

tickets_by_weekday <- jira_tickets %>%
  filter(!is.na(created)) %>%
  mutate(
    weekday = wday(created, label = TRUE, week_start = 1)
  ) %>%
  count(weekday)

# 03.6) DATEN IN EXCEL SPEICHERN------------------------------------------------
#Zeitliche Entwicklung
zeitliche_enwicklung <- list(
  weekend_tickets   = tickets_weekend,
  weekday_tickets     = tickets_by_weekday
)

write_xlsx(
  zeitliche_enwicklung,
  path = "tables/jira_zeitliche_entwicklung.xlsx"
)

cat("\n01 Zeitliche Entwicklung für Jira Collection abgeschlossen. Plots liegen im Ordner 'plots', Tabellen liegen im Ordner 'tables'.\n")








