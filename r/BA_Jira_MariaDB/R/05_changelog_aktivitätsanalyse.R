created_by_ticket <- mariadb_tickets %>%
  select(key, ticket_created = created) %>%
  distinct()

mariadb_histories_joined <- mariadb_changelog_flat %>%
  left_join(created_by_ticket, by = "key") %>%
  filter(!is.na(ticket_created), !is.na(change_created)) %>%
  # optional: nur Events, die nach created liegen (sollte fast immer so sein)
  filter(change_created >= ticket_created)
