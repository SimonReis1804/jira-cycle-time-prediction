source("R/00_setup_jira.R")
library(dplyr)

# Ticket-Level (1 Zeile pro Ticket)
pipeline_jira_tickets <- '
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
jira_tickets <- tickets_jira$aggregate(pipeline_jira_tickets)

# Changelog-Level (1 Zeile pro Item-Änderung)
pipeline_jira_changelog <- '
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
jira_changelog_flat <- tickets_jira$aggregate(pipeline_jira_changelog)

# Datumsfelder konvertieren (beide Tabellen!)
library(lubridate)

jira_tickets <- jira_tickets %>%
  mutate(
    created = as.POSIXct(created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
    resolutiondate = as.POSIXct(resolutiondate, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  )

jira_changelog_flat <- jira_changelog_flat %>%
  mutate(
    created = as.POSIXct(created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
    change_created = as.POSIXct(change_created, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
  )

# Speichern
if (!dir.exists("data")) dir.create("data")
saveRDS(jira_tickets, "data/jira_tickets.rds")
saveRDS(jira_changelog_flat, "data/jira_changelog_flat.rds")
