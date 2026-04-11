library(dplyr)
library(lubridate)
library(tidyr)

jiraecosystem_resolved_valid <- jiraecosystem_resolved_valid %>%
  arrange(key) %>%
  distinct(key, .keep_all = TRUE)%>%
  filter(!is.na(priority), priority != "", !priority %in% c("null", "None"))


jiraecosystem_resolved_valid <- jiraecosystem_resolved_valid %>%
  select(key, tt_resolve_days, issue_type, priority, created, resolutiondate, summary, description, assignee)

jiraecosystem_histories_joined <- jiraecosystem_histories_joined %>%
  select(key, change_created, field, fromString, toString)  

# 1) Basis bauen aus allen validen abgeschlossenen Ticket-----------------------

base <- jiraecosystem_resolved_valid %>%
  transmute(
    key,
    cycle_time_days = tt_resolve_days,
    issue_type,
    priority,
    created,
    resolutiondate,
    summary,
    description,
    has_active_assignee_missing = ifelse(is.na(assignee), 1L, 0L),
    has_active_assignee = ifelse(is.na(assignee), 0L, as.integer(assignee))
  )

# 2) Einfache statische Ticket-Features bauen-----------------------------------

base_features <- base %>%
  mutate(
    summary_len = ifelse(is.na(summary), NA_integer_, nchar(summary)),
    description_len = ifelse(is.na(description), NA_integer_, nchar(description)),
    created_month = month(created),
    created_weekday = wday(created, label = TRUE, week_start = 1),
    is_weekend_created = ifelse(
      created_weekday %in% c("Sa", "So"),
      1L,
      0L
    )
  ) %>%
  select(-summary, -description)

# 3) Aggregierte Changelog-Features pro Ticket----------------------------------
resolved_keys <- base_features %>%
  select(key) %>%
  distinct()

jiraecosystem_histories_resolved <- jiraecosystem_histories_joined %>%
  semi_join(resolved_keys, by = "key") %>%
  filter(!is.na(change_created))

# 3.1) Gesamtaktivität im Changelog---------------------------------------------

changelog_activity <- jiraecosystem_histories_resolved %>%
  group_by(key) %>%
  summarise(
    changelog_total   = n(),
    historyEventCount = n_distinct(change_created),
    .groups = "drop"
  )

# 3.2) Statuswechsel pro Ticket-------------------------------------------------

status_changes <- jiraecosystem_histories_resolved %>%
  filter(field == "status") %>%
  mutate(
    from_status = coalesce(as.character(fromString), "NA"),
    to_status   = coalesce(as.character(toString), "NA")
  ) %>%
  distinct(key, change_created, from_status, to_status) %>%
  group_by(key) %>%
  summarise(
    n_status_changes = n(),
    .groups = "drop"
  )

# 3.3) Zeit bis zum ersten Changelog-Event--------------------------------------

first_change <- jiraecosystem_histories_resolved %>%
  group_by(key) %>%
  summarise(
    first_change = min(change_created, na.rm = TRUE),
    .groups = "drop"
  )

time_to_first <- first_change %>%
  left_join(base_features %>% select(key, created) %>% distinct(), by = "key") %>%
  filter(!is.na(created), !is.na(first_change)) %>%
  mutate(
    time_to_first_change_days = as.numeric(difftime(first_change, created, units = "days"))
  ) %>%
  select(key, time_to_first_change_days)

# 3.4) Zeit zwischen aufeinanderfolgenden Changelog-Events pro Ticket-----------

inter_event_times <- jiraecosystem_histories_resolved %>%
  arrange(key, change_created) %>%
  group_by(key) %>%
  mutate(
    prev_change = lag(change_created),
    delta_days  = as.numeric(difftime(change_created, prev_change, units = "days"))
  ) %>%
  ungroup() %>%
  filter(!is.na(delta_days), delta_days >= 0)

time_between_changes_stats <- inter_event_times %>%
  group_by(key) %>%
  summarise(
    avg_time_between_changes = mean(delta_days, na.rm = TRUE),
    sd_time_between_changes  = sd(delta_days, na.rm = TRUE),
    min_time_between_changes = min(delta_days, na.rm = TRUE),
    max_time_between_changes = max(delta_days, na.rm = TRUE),
    .groups = "drop"
  )


# 4) Alles zu einer Feature-Tabelle zusammenführen------------------------------

features <- base_features %>%
  left_join(changelog_activity, by = "key") %>%
  left_join(status_changes, by = "key") %>%
  left_join(time_to_first, by = "key") %>%
  left_join(time_between_changes_stats, by = "key")

# 5) Missing Values sinnvoll behandeln------------------------------------------

features_clean <- features %>%
  mutate(
    changelog_total   = replace_na(changelog_total, 0L),
    historyEventCount = replace_na(historyEventCount, 0L),
    n_status_changes  = replace_na(n_status_changes, 0L)
    # time_to_first_change_days bleibt NA, wenn kein Changelog vorhanden
  ) %>%
  filter(
    !is.na(time_to_first_change_days),
    !is.na(description_len),
    !is.na(avg_time_between_changes),
    !is.na(sd_time_between_changes),
    !is.na(min_time_between_changes),
    !is.na(max_time_between_changes)
    
  )

cat("Tickets vor Filter time_to_first_change_days:", nrow(features), "\n")
cat("Tickets nach Filter time_to_first_change_days:", nrow(features_clean), "\n")
cat("Entfernt wegen NA time_to_first_change_days:", nrow(features) - nrow(features_clean), "\n")
cat("Entfernt wegen NA description_len:",sum(is.na(features$description_len)), "\n")

# 6) Qualität checken-----------------------------------------------------------

stopifnot(nrow(features_clean) == n_distinct(features_clean$key))
stopifnot(all(features_clean$cycle_time_days >= 0, na.rm = TRUE))

cat("Tickets (resolved valid):", nrow(features_clean), "\n")
cat("Tickets ohne Changelog (changelog_total==0):", sum(features_clean$changelog_total == 0, na.rm = TRUE), "\n")

features_final <- features_clean %>%
  select(
    key,
    cycle_time_days,
    created,
    issue_type,
    priority,
    has_active_assignee,
    has_active_assignee_missing,
    summary_len,
    description_len,
    changelog_total,
    historyEventCount,
    n_status_changes,
    time_to_first_change_days,
    avg_time_between_changes,
    created_month,
    created_weekday,
    is_weekend_created,
    avg_time_between_changes,
    sd_time_between_changes,
    min_time_between_changes,
    max_time_between_changes
  )

print(glimpse(features_final))

# 8) MongoDB Export statt CSV --------------------------------------------------

library(mongolite)

features_mongo <- features_final %>%
  mutate(
    created_weekday = as.character(created_weekday)
  )

uri <- "mongodb://localhost:27017"
db_name <- "JiraReposAnon"
col_name <- "jiraecosystem_features_resolved"

con <- mongo(collection = col_name, db = db_name, url = uri)

con$drop()

chunk_size <- 5000
n <- nrow(features_mongo)

for (i in seq(1, n, by = chunk_size)) {
  part <- features_mongo[i:min(i + chunk_size - 1, n), ]
  con$insert(part)
}

con$index(add = '{ "key": 1 }')



cat("MongoDB Insert fertig. Dokumente in Collection:", con$count(), "\n")



