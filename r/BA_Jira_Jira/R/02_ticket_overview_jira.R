# 01) TICKET-OVERVIEW-----------------------------------------------------------
library(writexl)
# 01.1) TICKETS GESAMT----------------------------------------------------------
cat("Anzahl Jira-Collection-Tickets (roh):", nrow(jira_tickets), "\n\n")

# 01.2) TICKETS RESOLVED--------------------------------------------------------
# created & resolutiondate sind aktuell meist Character -> in POSIXct umwandeln
jira_tickets$created        <- as.POSIXct(jira_tickets$created,        format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
jira_tickets$resolutiondate <- as.POSIXct(jira_tickets$resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
# Für gelöste Tickets: resolutiondate nicht NA
jira_resolved <- jira_tickets[!is.na(jira_tickets$resolutiondate), ]
cat("Anzahl gelöster Jira-Collection-Tickets:", nrow(jira_resolved), "\n\n")

# Durchlaufzeit in Tagen
jira_resolved$tt_resolve_days <- as.numeric(jira_resolved$resolutiondate - jira_resolved$created, units = "days")

# nur sinnvolle, nicht-negative Durchlaufzeiten
jira_resolved_valid <- jira_resolved %>%
  filter(!is.na(tt_resolve_days),
         tt_resolve_days >= 0)

cat("Anzahl Jira-Collection Valide resolved Tickets (roh):", nrow(jira_resolved_valid), "\n\n")

# 01.3.1) TICKETS JE ISSUE TYPE, PRIORITY, STATUS-------------------------------

# Issue-Type-Verteilung
issue_type_counts <- jira_tickets %>%
  count(issue_type, sort = TRUE)

cat("Issue-Type-Verteilung:\n")
print(issue_type_counts)

# Priority-Verteilung
priority_counts <- jira_tickets %>%
  count(priority, sort = TRUE)

cat("\nPriority-Verteilung:\n")
print(priority_counts)

# Status-Verteilung (aktueller Status)
status_counts <- jira_tickets %>%
  count(status, sort = TRUE)

cat("\nStatus-Verteilung:\n")
print(status_counts)


# 01.3.2) TICKETS RESOLVED JE ISSUE TYPE, PRIORITY, STATUS----------------------

issue_type_counts_resolved <- jira_resolved_valid %>%
  count(issue_type, sort = TRUE)

cat("Issue-Type-Verteilung-resolved:\n")
print(issue_type_counts_resolved)

# Priority-Verteilung-resolved
priority_counts_resolved <- jira_resolved_valid %>%
  count(priority, sort = TRUE)

cat("\nPriority-Verteilung-resolved:\n")
print(priority_counts_resolved)

# Status-Verteilung-resolved (aktueller Status)
status_counts_resolved <- jira_resolved_valid %>%
  count(status, sort = TRUE)

cat("\nStatus-Verteilung-resolved:\n")
print(status_counts_resolved)

# 01.4) LÄNGE VON SUMMARY & DESCRIPTION-----------------------------------------

summary_length_chars <- jira_resolved_valid %>%
  filter(!is.na(summary)) %>%
  mutate(
    summary_length = nchar(summary)
  )

summary_length_stats <- summary_length_chars %>%
  summarise(
    n_tickets = n(),
    mean_chars   = mean(summary_length),
    median_chars = median(summary_length),
    sd_chars     = sd(summary_length),
    min_chars    = min(summary_length),
    max_chars    = max(summary_length)
  )

cat("\nZeichenlänge Summary:\n")
print(summary_length_stats)

description_length_chars <- jira_resolved_valid %>%
  filter(!is.na(description)) %>%
  mutate(
    description_length = nchar(description)
  )

description_length_stats <- description_length_chars %>%
  summarise(
    n_tickets = n(),
    mean_chars   = mean(description_length),
    median_chars = median(description_length),
    sd_chars     = sd(description_length),
    min_chars    = min(description_length),
    max_chars    = max(description_length)
  )

cat("\nZeichenlänge Description:\n")
print(description_length_stats)

# 01.5) ASSIGNEE----------------------------------------------------------------

# 01.6) TICKET-OVERVIEW: PLOTS--------------------------------------------------

# Histogramm Summary length
p_summary_len <- ggplot(summary_length_chars,
                        aes(x = summary_length)) +
  geom_histogram(bins = 50) +
  labs(
    title = "Verteilung der Summary-Länge (Zeichen)",
    x = "Anzahl Zeichen",
    y = "Anzahl Tickets"
  )

ggsave("plots/jira_summary_length_hist.png",
       p_summary_len, width = 7, height = 4)


# Histogramm Description length
p_description_len <- ggplot(description_length_chars,
                        aes(x = description_length)) +
  geom_histogram(bins = 50) +
  labs(
    title = "Verteilung der Description-Länge (Zeichen)",
    x = "Anzahl Zeichen",
    y = "Anzahl Tickets"
  )

ggsave("plots/jira_desciption_length_hist.png",
       p_summary_len, width = 7, height = 4)

# 01.7) DATEN IN EXCEL SPEICHERN------------------------------------------------
ticket_overview_tables <- list(
  ticket_counts_all      = data.frame(n_tickets = nrow(jira_tickets)),
  ticket_counts_resolved = data.frame(n_resolved = nrow(jira_resolved_valid)),
  issue_type_all         = issue_type_counts,
  priority_all           = priority_counts,
  status_all             = status_counts,
  issue_type_resolved    = issue_type_counts_resolved,
  priority_resolved      = priority_counts_resolved,
  status_resolved        = status_counts_resolved,
  summary_length_stats   = summary_length_stats,
  description_length_stats = description_length_stats
)

write_xlsx(
  ticket_overview_tables,
  path = "tables/jira_ticket_overview.xlsx"
)

# DATEN FÜR SPÄTER SPEICHERN----------------------------------------------------
saveRDS(jira_resolved,       file = "data/jira_resolved.rds")
saveRDS(jira_resolved_valid, file = "data/jira_resolved_valid.rds")

cat("\n01 Ticket Overview für Jira Collection abgeschlossen. Plots liegen im Ordner 'plots', Daten in 'data/', Tabellen liegen im Ordner 'tables'.\n")


