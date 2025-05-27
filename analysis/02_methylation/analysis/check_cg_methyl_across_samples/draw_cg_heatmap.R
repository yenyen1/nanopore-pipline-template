library(RColorBrewer)
library(pheatmap)
library(NMF)
library(RColorBrewer)

### Draw CG island heatmap with multiple genes
file <- "data/example_CG_island.tsv"
nanopolish_data <- read.table(file, header = TRUE, sep = "\t")

G1 <- c("TXNRD2","ZBTB17","EYA4","PRDM16","RBM20","TTN")
png("example_CG_island.png", width = 840, height = 480)
gene_subset <- nanopolish_data[nanopolish_data$GENE %in% G1,]
aheatmap(t(as.matrix(gene_subset[3:16])), color = "-RdBu", 
         Colv=NA, scale="none", annCol = gene_subset$GENE, 
         annColors = "Paired")
dev.off()



