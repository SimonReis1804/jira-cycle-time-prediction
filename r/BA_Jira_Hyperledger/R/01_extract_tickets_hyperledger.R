source("R/00_setup_hyperledger.R")
library(dplyr)

# Ticket-Level (1 Zeile pro Ticket)
pipeline_hyperledger_tickets <- '
[
  { "$project": {
      "key": 1,
      "summary": "$fields.summary",
      "description": "$fields.description",
      "assignee": "$fields.assignee.active",
      "created": "$fields.created",
      "resolutiondate": "$fields.resolutiondate",
      "status": "$fields.status.name",
      "priority": "$fields.priority.name",
      "issue_type": "$fields.issuetype.name",
      "labels": "$fields.labels",
      "project_key": "$fields.project.key",
      "_id": 0
  }}
]
'
hyperledger_tickets <- tickets_hyperledger$aggregate(pipeline_hyperledger_tickets)

# Changelog-Level (1 Zeile pro Item-Änderung)
pipeline_hyperledger_changelog <- '
[
  { "$unwind": { "path": "$changelog.histories", "preserveNullAndEmptyArrays": false } },
  { "$unwind": { "path": "$changelog.histories.items", "preserveNullAndEmptyArrays": false } },
  { "$project": {
      "key": 1,
      "created": "$fields.created",
      "change_created": "$changelog.histories.created",
      "field": "$changelog.histories.items.field",
      "fromString": "$changelog.histories.items.fromString",
      "toString": "$changelog.histories.items.toString",
      "_id": 0
  }}
]
'
hyperledger_changelog_flat <- tickets_hyperledger$aggregate(pipeline_hyperledger_changelog)

# Datumsfelder konvertieren (beide Tabellen!)
library(lubridate)

hyperledger_tickets <- hyperledger_tickets %>%
  mutate(
    created = as.POSIXct(created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
    resolutiondate = as.POSIXct(resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  )

hyperledger_changelog_flat <- hyperledger_changelog_flat %>%
  mutate(
    created = as.POSIXct(created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
    change_created = as.POSIXct(change_created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  )

# Speichern
if (!dir.exists("data")) dir.create("data")
saveRDS(hyperledger_tickets, "data/hyperledger_tickets.rds")
saveRDS(hyperledger_changelog_flat, "data/hyperledger_changelog_flat.rds")
