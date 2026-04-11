source("R/00_setup_jiraecosystem.R")
library(dplyr)

# Ticket-Level (1 Zeile pro Ticket)
pipeline_jiraecosystem_tickets <- '
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
jiraecosystem_tickets <- tickets_jiraecosystem$aggregate(pipeline_jiraecosystem_tickets)

# Changelog-Level (1 Zeile pro Item-Änderung)
pipeline_jiraecosystem_changelog <- '
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
jiraecosystem_changelog_flat <- tickets_jiraecosystem$aggregate(pipeline_jiraecosystem_changelog)

# Datumsfelder konvertieren (beide Tabellen!)
library(lubridate)

jiraecosystem_tickets <- jiraecosystem_tickets %>%
  mutate(
    created = as.POSIXct(created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
    resolutiondate = as.POSIXct(resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  )

jiraecosystem_changelog_flat <- jiraecosystem_changelog_flat %>%
  mutate(
    created = as.POSIXct(created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
    change_created = as.POSIXct(change_created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  )

# Speichern
if (!dir.exists("data")) dir.create("data")
saveRDS(jiraecosystem_tickets, "data/jiraecosystem_tickets.rds")
saveRDS(jiraecosystem_changelog_flat, "data/jiraecosystem_changelog_flat.rds")
