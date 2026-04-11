# 00_setup_Jira.R

# 1. Pakete laden
library(mongolite)
library(tidyverse)

# 2. Verbindungsparameter definieren
mongo_url  <- "mongodb://localhost:27017"
mongo_db   <- "JiraReposAnon"                 
collection <- "Jira"                      

# 3. Verbindung
tickets_jira <- mongo(
  collection = collection,
  db         = mongo_db,
  url        = mongo_url
)

# 5. Kurzer Test
tickets_jira$count()