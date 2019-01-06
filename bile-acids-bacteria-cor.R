# library(openxlsx)
bile_acids_processed <- read.xlsx("bile_acids_processed.xlsx")
bugs_processed <- read.xlsx("bugs_list_genus_processed.xlsx")

# Inner join data frames
cols <- intersect(colnames(bile_acids_processed), colnames(bugs_processed))
bugs_and_bile_acids <- rbind(bile_acids_processed[,cols], bugs_processed[,cols])
# Index new data frame properly
rownames(bugs_and_bile_acids) <- bugs_and_bile_acids$ID
bugs_and_bile_acids <- bugs_and_bile_acids[-1]

# Convert to numeric
bugs_and_bile_acids[] <- lapply(bugs_and_bile_acids, function(x) {
  as.numeric(as.character(x))
})
bugs_and_bile_acids <- na.omit(bugs_and_bile_acids)


# install.packages("Hmisc")
# library(Hmisc)
cor <- rcorr(format(t(bugs_and_bile_acids), digits=20), type="spearman")
cor.data <- cor$r
cor.data[upper.tri(cor.data, diag=T)] <- 0
pval.data <- cor$P
pval.data[upper.tri(pval.data, diag=T)] <- NA
FDR.data <- apply(pval.data, 2, p.adjust, method="fdr")
pdf(paste("./lognormlipids", "fdr", "pval_hist.pdf", sep="_"))
hist(pval.data, breaks=100, col="darkblue")
dev.off()
pdf(paste("./lognormlipids", "fdr", "FDR_hist.pdf", sep="_"))
hist(FDR.data, breaks=100, col="darkblue")
dev.off()
pdf(paste("./lognormlipids", "fdr", "cor_hist.pdf", sep="_"))
hist(cor.data, breaks=10, col="red")
dev.off()
cor.data[FDR.data > 0.05] = 0
write.table(FDR.data, file=paste("./lognormlipids", "fdr", "FDR_data.txt", sep="_"), sep="\t", col.names=NA)
write.table(cor.data, file=paste("./lognormlipids", "fdr", "cor_data.txt", sep="_"), sep="\t", col.names=NA)
