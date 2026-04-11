# 01) TICKET-OVERVIEW-----------------------------------------------------------
library(writexl)
# 01.1) TICKETS GESAMT----------------------------------------------------------
cat("Anzahl spring-Collection-Tickets (roh):", nrow(spring_tickets), "\n\n")

# 01.2) TICKETS RESOLVED--------------------------------------------------------
# created & resolutiondate sind aktuell meist Character -> in POSIXct umwandeln
spring_tickets$created        <- as.POSIXct(spring_tickets$created,        format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
spring_tickets$resolutiondate <- as.POSIXct(spring_tickets$resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
# Für gelöste Tickets: resolutiondate nicht NA
spring_resolved <- spring_tickets[!is.na(spring_tickets$resolutiondate), ]
cat("Anzahl gelöster spring-Collection-Tickets:", nrow(spring_resolved), "\n\n")

# Durchlaufzeit in Tagen
spring_resolved$tt_resolve_days <- as.numeric(spring_resolved$resolutiondate - spring_resolved$created, units = "days")

# nur sinnvolle, nicht-negative Durchlaufzeiten
spring_resolved_valid <- spring_resolved %>%
  filter(!is.na(tt_resolve_days),
         tt_resolve_days >= 0)

cat("Anzahl spring-Collection Valide resolved Tickets (roh):", nrow(spring_resolved_valid), "\n\n")