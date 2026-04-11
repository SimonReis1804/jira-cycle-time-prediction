# 05) DATENQUALITÄT & ML-EIGNUNG------------------------------------------------

library(dplyr)
library(tibble)
library(stringr)

# Missing-Definition
is_missing_vec <- function(x) {
  # Missing = NA, NaN, "" oder Strings wie "NA", "NaN", "null", "none"
  if (is.numeric(x)) {
    return(is.na(x) | is.nan(x))
  } else {
    x_chr <- as.character(x)
    return(
      is.na(x_chr) |
        str_trim(x_chr) == "" |
        tolower(str_trim(x_chr)) %in% c("na", "nan", "null", "none")
    )
  }
}

# Missing-Report für beliebige Dataframes
missing_report_df <- function(df, must_have = NULL, df_name = "df") {
  
  report <- tibble(
    column = names(df),
    missing_n = sapply(df, function(x) sum(is_missing_vec(x))),
    total_n = nrow(df)
  ) %>%
    mutate(
      has_missing = missing_n > 0,
      missing_pct = ifelse(total_n > 0, 100 * missing_n / total_n, NA_real_)
    ) %>%
    arrange(desc(missing_n))
  
  cat("\n========================\n")
  cat("Missing Report für:", df_name, "\n")
  cat("========================\n")
  print(report)
  
  cat("\nSpalten mit Missing:\n")
  print(report %>% filter(has_missing))
  
  if (!is.null(must_have)) {
    bad_must_have <- report %>% filter(column %in% must_have, has_missing)
    if (nrow(bad_must_have) > 0) {
      cat("\n WARNUNG: Missing in Pflichtspalten gefunden:\n")
      print(bad_must_have)
    } else {
      cat("\n Keine Missing in Pflichtspalten:", paste(must_have, collapse = ", "), "\n")
    }
  }
  
  invisible(report)
}

must_have_tickets <- c("key", "created", "issue_type", "priority", "resolutiondate")

report_jira_tickets <- missing_report_df(
  df = jira_tickets,
  must_have = must_have_tickets,
  df_name = "jira_tickets (Ticket-Level)"
)

must_have_changelog <- c("key", "change_created", "field")

report_jira_changelog <- missing_report_df(
  df = jira_changelog_flat,
  must_have = must_have_changelog,
  df_name = "jira_changelog_flat (Changelog-Level)"
)

# 05.1) DATEN IN EXCEL SPEICHERN------------------------------------------------
# Optional: Nur Spalten mit Missing
jira_tickets_missing_only <- report_jira_tickets %>%
  filter(has_missing)

jira_changelog_missing_only <- report_jira_changelog %>%
  filter(has_missing)

# Alle Tabellen bündeln
data_quality_tables <- list(
  jira_tickets_missing          = report_jira_tickets
)

# Excel schreiben
write_xlsx(
  data_quality_tables,
  path = "tables/jira_data_quality_analysis.xlsx"
)

cat("\n01 Datenqualität & ML-Eignung für Jira Collection abgeschlossen. Tabellen liegen im Ordner 'tables'.\n")