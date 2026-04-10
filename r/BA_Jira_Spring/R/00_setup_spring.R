# 00_setup_spring.R

# 1. Pakete laden
library(mongolite)
library(tidyverse)

# 2. Verbindungsparameter definieren
mongo_url  <- "mongodb://localhost:27017"
mongo_db   <- "JiraReposAnon"                 
collection <- "Spring"                      

# 3. Verbindung als Objekt anlegen
tickets_spring <- mongo(
  collection = collection,
  db         = mongo_db,
  url        = mongo_url
)

# 5. Kurzer Test: Anzahl Dokumente in der Collection
tickets_spring$count()