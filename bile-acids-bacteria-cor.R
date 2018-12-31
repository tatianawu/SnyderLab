# Correlations

# library(openxlsx)
bile_acids_processed <- read.xlsx("bile_acids_processed.xlsx")
bugs_processed <- read.xlsx("bugs_list_genus_processed.xlsx")

cols <- intersect(colnames(bile_acids_processed), colnames(bugs_processed))
bugs_and_bile_acids <- rbind(bile_acids_processed[,cols], bugs_processed[,cols])
rownames(bugs_and_bile_acids) <- bugs_and_bile_acids$ID
bugs_and_bile_acids <- bugs_and_bile_acids[-1]

bugs_and_bile_acids[] <- lapply(bugs_and_bile_acids, function(x) {
  as.numeric(as.character(x))
})

correlation_matrix <- cor(bugs_and_bile_acids, use="complete")
# write.xlsx(correlation_matrix, "correlation_matrix.xlsx")
