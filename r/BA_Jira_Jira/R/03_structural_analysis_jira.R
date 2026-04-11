library(dplyr)
library(lubridate)

# Lade Daten (robust)
jira_tickets <- readRDS("data/jira_tickets.rds")
jira_changelog_flat <- readRDS("data/jira_changelog_flat.rds")

jira_histories_joined <- jira_changelog_flat %>%
  filter(!is.na(created), !is.na(change_created)) %>%
  filter(change_created >= created)


# erstes Changelog-Event pro Ticket
first_change_per_ticket <- jira_histories_joined %>%
  group_by(key) %>%
  summarise(
    created = first(created),
    first_change = min(change_created, na.rm = TRUE),
    time_to_first_change_hours = as.numeric(difftime(first_change, created, units = "hours")),
    time_to_first_change_days  = time_to_first_change_hours / 24,
    .groups = "drop"
  )


# ZEIT ZWISCHEN DEN CHANGELOG-EVENTS----------------------------

# event-to-event Differenzen pro Ticket
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


