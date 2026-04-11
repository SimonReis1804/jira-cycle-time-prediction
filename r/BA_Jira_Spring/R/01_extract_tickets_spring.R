source("R/00_setup_spring.R")
library(dplyr)

# Ticket-Level (1 Zeile pro Ticket)
pipeline_spring_tickets <- '
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
spring_tickets <- tickets_spring$aggregate(pipeline_spring_tickets)

# Changelog-Level (1 Zeile pro Item-Änderung)
pipeline_spring_changelog <- '
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
spring_changelog_flat <- tickets_spring$aggregate(pipeline_spring_changelog)

# Datumsfelder konvertieren (beide Tabellen!)
library(lubridate)

spring_tickets <- spring_tickets %>%
  mutate(
    created = as.POSIXct(created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
    resolutiondate = as.POSIXct(resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  )

spring_changelog_flat <- spring_changelog_flat %>%
  mutate(
    created = as.POSIXct(created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
    change_created = as.POSIXct(change_created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  )

# Speichern
if (!dir.exists("data")) dir.create("data")
saveRDS(spring_tickets, "data/spring_tickets.rds")
saveRDS(spring_changelog_flat, "data/spring_changelog_flat.rds")
