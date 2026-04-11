# 01) TICKET-OVERVIEW-----------------------------------------------------------
library(writexl)
# 01.1) TICKETS GESAMT----------------------------------------------------------
cat("Anzahl hyperledger-Collection-Tickets (roh):", nrow(hyperledger_tickets), "\n\n")

# 01.2) TICKETS RESOLVED--------------------------------------------------------
# created & resolutiondate sind aktuell meist Character -> in POSIXct umwandeln
hyperledger_tickets$created        <- as.POSIXct(hyperledger_tickets$created,        format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
hyperledger_tickets$resolutiondate <- as.POSIXct(hyperledger_tickets$resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
# Für gelöste Tickets: resolutiondate nicht NA
hyperledger_resolved <- hyperledger_tickets[!is.na(hyperledger_tickets$resolutiondate), ]
cat("Anzahl gelöster hyperledger-Collection-Tickets:", nrow(hyperledger_resolved), "\n\n")

# Durchlaufzeit in Tagen
hyperledger_resolved$tt_resolve_days <- as.numeric(hyperledger_resolved$resolutiondate - hyperledger_resolved$created, units = "days")

# nur sinnvolle, nicht-negative Durchlaufzeiten
hyperledger_resolved_valid <- hyperledger_resolved %>%
  filter(!is.na(tt_resolve_days),
         tt_resolve_days >= 0)

cat("Anzahl hyperledger-Collection Valide resolved Tickets (roh):", nrow(hyperledger_resolved_valid), "\n\n")