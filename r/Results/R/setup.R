library(readxl) 

Master_Tabelle <- read_excel("C:/Users/srRei/OneDrive/Desktop/Uni/WS 25-26/Bachelorarbeit/jira-ml-cycle-time/Master-Tabelle.xlsx", sheet = "Master") 

cat("Anzahl Zeilen:", nrow(Master_Tabelle), "\n\n")