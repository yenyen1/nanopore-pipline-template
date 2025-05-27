library('corrr')
library(ggcorrplot)
library(factoextra)

file <- "data/example.tsv"
nanopolish_data <- read.table(file, header = TRUE, sep = "\t")

head(nanopolish_data)
corr_matrix <- cor(as.matrix(nanopolish_data[3:16]))
ggcorrplot(corr_matrix)

data.pca <- princomp(corr_matrix)
fviz_eig(data.pca, addlabels = TRUE)
fviz_pca_var(data.pca, col.var = "black")

fviz_pca_ind(data.pca)

fviz_pca_ind(data.pca,
             col.ind = "cos2", # Color by the quality of representation
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
)


G1 <- c("TTN")
gene_subset <- nanopolish_data[nanopolish_data$GENE %in% G1,]
corr_matrix <- cor(as.matrix(gene_subset[3:16]))
ggcorrplot(corr_matrix)
data.pca <- princomp(corr_matrix)
fviz_pca_ind(data.pca)
