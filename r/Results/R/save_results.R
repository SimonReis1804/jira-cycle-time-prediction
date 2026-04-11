library(openxlsx)

wb <- createWorkbook()

addWorksheet(wb, "ML prediction 80 20 (RQ1)")
writeData(wb, "ML prediction 80 20 (RQ1)", view_a_1)

addWorksheet(wb, "ML prediction 70 15 15 (RQ1)")
writeData(wb, "ML prediction 70 15 15 (RQ1)", view_a_2)

addWorksheet(wb, "Avg Feature Improvement (RQ2)")
writeData(wb, "Avg Feature Improvement (RQ2)", view_b_1)

addWorksheet(wb, "Feature Improvement (RQ2)")
writeData(wb, "Feature Improvement (RQ2)", view_b_2)

addWorksheet(wb, "Modell-Ranking (RQ3)")
writeData(wb, "Modell-Ranking (RQ3)", view_c_1)

addWorksheet(wb, "Hyperopt influence (RQ3)")
writeData(wb, "Hyperopt influence (RQ3)", view_c_2)

addWorksheet(wb, "Hyperopt influence E2 (RQ3)")
writeData(wb, "Hyperopt influence E2 (RQ3)", view_c_3)

addWorksheet(wb, "Gener. per Project (RQ4)")
writeData(wb, "Gener. per Project (RQ4)", view_d_1)

addWorksheet(wb, "Performancce Drop (RQ4)")
writeData(wb, "Performancce Drop (RQ4)", view_d_2)

addWorksheet(wb, "Hyperopt influence (RQ4)")
writeData(wb, "Hyperopt influence (RQ4)", view_d_3)

saveWorkbook(
  wb,
  "C:/Users/srRei/OneDrive/Desktop/Uni/WS 25-26/Bachelorarbeit/Results/BA_Ergebnisse.xlsx",
  overwrite = TRUE
)
