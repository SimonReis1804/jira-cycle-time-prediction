created_by_ticket <- hyperledger_tickets %>%
  select(key, ticket_created = created) %>%
  distinct()

hyperledger_histories_joined <- hyperledger_changelog_flat %>%
  left_join(created_by_ticket, by = "key") %>%
  filter(!is.na(ticket_created), !is.na(change_created)) %>%
  filter(change_created >= ticket_created)
