# 01) TICKET-OVERVIEW-----------------------------------------------------------
library(writexl)
# 01.1) TICKETS GESAMT----------------------------------------------------------
cat("Anzahl mariadb-Collection-Tickets (roh):", nrow(mariadb_tickets), "\n\n")

# 01.2) TICKETS RESOLVED--------------------------------------------------------
# created & resolutiondate sind aktuell meist Character -> in POSIXct umwandeln
mariadb_tickets$created        <- as.POSIXct(mariadb_tickets$created,        format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
mariadb_tickets$resolutiondate <- as.POSIXct(mariadb_tickets$resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
# Für gelöste Tickets: resolutiondate nicht NA
mariadb_resolved <- mariadb_tickets[!is.na(mariadb_tickets$resolutiondate), ]
cat("Anzahl gelöster mariadb-Collection-Tickets:", nrow(mariadb_resolved), "\n\n")

# Durchlaufzeit in Tagen
mariadb_resolved$tt_resolve_days <- as.numeric(mariadb_resolved$resolutiondate - mariadb_resolved$created, units = "days")

# nur sinnvolle, nicht-negative Durchlaufzeiten
mariadb_resolved_valid <- mariadb_resolved %>%
  filter(!is.na(tt_resolve_days),
         tt_resolve_days >= 0)

cat("Anzahl mariadb-Collection Valide resolved Tickets (roh):", nrow(mariadb_resolved_valid), "\n\n")