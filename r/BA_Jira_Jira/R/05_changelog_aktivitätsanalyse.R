# 04) CHANGELOG/AKTIVITÄTSANALYSE-----------------------------------------------
# 04.1) CHANGELOG-EVENTS PRO TICKET (MEAN,MEDIAN,MAX)---------------------------

# Nur Status-Änderungen herausfiltern
jira_status_changes <- jira_changelog_flat %>%
  filter(field == "status")

# Anzahl Statuswechsel pro Ticket
status_changes_per_ticket <- jira_status_changes %>%
  group_by(key) %>%
  summarise(
    n_status_changes = n(),
    .groups = "drop"
  )

cat("\nDurchschnittliche Anzahl Statuswechsel pro Ticket:\n")
status_changes_per_ticket %>%
  summarise(
    mean_changes   = mean(n_status_changes),
    median_changes = median(n_status_changes),
    max_changes    = max(n_status_changes)
  ) %>%
  print()

status_changes_summary <- status_changes_per_ticket %>%
  summarise(
    n_tickets = n(),
    mean_changes   = mean(n_status_changes),
    median_changes = median(n_status_changes),
    max_changes    = max(n_status_changes)
  )

cat("\nVerteilung der Anzahl Statuswechsel pro Ticket:\n")
print(table(status_changes_per_ticket$n_status_changes))

status_changes_distribution <- status_changes_per_ticket %>%
  count(n_status_changes, name = "n_tickets") %>%
  arrange(n_status_changes)

# 04.2) ZEIT BIS ZUM ERSTEN CHANGELOG-EVENT NACH CREATED------------------------
# IST FÜR ALLE TICKETS, NICHT NUR GELÖSTE
created_by_ticket <- jira_tickets %>%
  select(key, ticket_created = created) %>%
  distinct()

jira_histories_joined <- jira_changelog_flat %>%
  left_join(created_by_ticket, by = "key") %>%
  filter(!is.na(ticket_created), !is.na(change_created)) %>%
  filter(change_created >= ticket_created)


# erstes Changelog-Event pro Ticket
first_change_per_ticket <- jira_histories_joined %>%
  group_by(key) %>%
  summarise(
    ticket_created = first(ticket_created),
    first_change = min(change_created, na.rm = TRUE),
    time_to_first_change_hours = as.numeric(difftime(first_change, ticket_created, units = "hours")),
    time_to_first_change_days  = time_to_first_change_hours / 24,
    .groups = "drop"
  )

# Gesamtstatistik
time_to_first_summary <- first_change_per_ticket %>%
  summarise(
    n_tickets = n(),
    mean_days = mean(time_to_first_change_days, na.rm = TRUE),
    median_days = median(time_to_first_change_days, na.rm = TRUE),
    mean_hours = mean(time_to_first_change_hours, na.rm = TRUE),
    median_hours = median(time_to_first_change_hours, na.rm = TRUE)
  )

cat("\nZeit bis zum ersten Changelog-Event nach created:\n")
print(time_to_first_summary)

# 04.3) ZEITEN ZWISCHEN ÄNDERUNGEN----------------------------------------------

inter_event_times <- jira_histories_joined %>%
  arrange(key, change_created) %>%
  group_by(key) %>%
  mutate(
    prev_change = lag(change_created),
    delta_hours = as.numeric(difftime(change_created, prev_change, units = "hours")),
    delta_days  = delta_hours / 24
  ) %>%
  ungroup() %>%
  filter(!is.na(delta_hours), delta_hours >= 0)  # erstes Event hat NA, negative wären Datenfehler

# Gesamtstatistik über alle Deltas (alle Tickets zusammen)
inter_event_summary_overall <- inter_event_times %>%
  summarise(
    n_deltas = n(),
    mean_days = mean(delta_days, na.rm = TRUE),
    median_days = median(delta_days, na.rm = TRUE),
    mean_hours = mean(delta_hours, na.rm = TRUE),
    median_hours = median(delta_hours, na.rm = TRUE)
  )

cat("\nZeit zwischen den Changelog-Events (komplett):\n")
print(inter_event_summary_overall)

# 04.5) DATEN IN EXCEL SPEICHERN------------------------------------------------
#Changelog/Aktivitätsanalyse
changelog_tables <- list(
  summary_stats                  = status_changes_summary,
  distribution                   = status_changes_distribution,
  time_to_first_change           = time_to_first_summary
)

write_xlsx(
  changelog_tables,
  path = "tables/jira_changelog_analysis.xlsx"
)

cat("\n01 Changelog/Aktivitätsanalyse für Jira Collection abgeschlossen. Plots liegen im Ordner 'plots',Tabellen liegen im Ordner 'tables'.\n")

