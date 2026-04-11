# 01) TICKET-OVERVIEW-----------------------------------------------------------
library(writexl)
# 01.1) TICKETS GESAMT----------------------------------------------------------
cat("Anzahl jiraecosystem-Collection-Tickets (roh):", nrow(jiraecosystem_tickets), "\n\n")

# 01.2) TICKETS RESOLVED--------------------------------------------------------
# created & resolutiondate sind aktuell meist Character -> in POSIXct umwandeln
jiraecosystem_tickets$created        <- as.POSIXct(jiraecosystem_tickets$created,        format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
jiraecosystem_tickets$resolutiondate <- as.POSIXct(jiraecosystem_tickets$resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
# Für gelöste Tickets: resolutiondate nicht NA
jiraecosystem_resolved <- jiraecosystem_tickets[!is.na(jiraecosystem_tickets$resolutiondate), ]
cat("Anzahl gelöster jiraecosystem-Collection-Tickets:", nrow(jiraecosystem_resolved), "\n\n")

# Durchlaufzeit in Tagen
jiraecosystem_resolved$tt_resolve_days <- as.numeric(jiraecosystem_resolved$resolutiondate - jiraecosystem_resolved$created, units = "days")

# nur sinnvolle, nicht-negative Durchlaufzeiten
jiraecosystem_resolved_valid <- jiraecosystem_resolved %>%
  filter(!is.na(tt_resolve_days),
         tt_resolve_days >= 0)

cat("Anzahl jiraecosystem-Collection Valide resolved Tickets (roh):", nrow(jiraecosystem_resolved_valid), "\n\n")