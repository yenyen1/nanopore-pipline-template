### This script is used to generate PCA plot for DCM samples and 1000G

# Set working dir
setwd("work dir")
pname <- "project name"

# read in the eigenvectors, produced in PLINK
eigenval <- read.table('plink_results/plink.eigenval', header = FALSE, skip=0, sep = ' ')
eigenvec <- read.table('plink_results/plink.eigenvec', header = FALSE, skip=0, sep = ' ')
rownames(eigenvec) <- eigenvec[,2]
eigenvec <- eigenvec[,3:ncol(eigenvec)]
colnames(eigenvec) <- paste('Principal Component ', c(1:20), sep = '')

# read in the PED data
PED <- read.table('plink_results/ID_POP.txt', header = TRUE, skip = 0, sep = ' ')
PED <- PED[which(PED$Individual_ID %in% rownames(eigenvec)), ]
PED <- PED[match(rownames(eigenvec), PED$Individual_ID),]
all(PED$Individual.ID == rownames(eigenvec)) == TRUE

# set colours
# from: http://www.internationalgenome.org/category/population/
PED$Population <- factor(PED$Population, levels=c(
  pname,
  "ACB","ASW","ESN","GWD","LWK","MSL","YRI",
  "CLM","MXL","PEL","PUR",
  "CDX","CHB","CHS","JPT","KHV",
  "CEU","FIN","GBR","IBS","TSI",
  "BEB","GIH","ITU","PJL","STU"))

col <- colorRampPalette(c(
  "pink",
  "yellow","yellow","yellow","yellow","yellow","yellow","yellow",
  "forestgreen","forestgreen","forestgreen","forestgreen",
  "grey","grey","grey","grey","grey",
  "royalblue","royalblue","royalblue","royalblue","royalblue",
  "black","black","black","black","black"))(length(unique(PED$Population)))[factor(PED$Population)]

# generate PCA bi-plots
project.pca <- eigenvec
summary(project.pca)


### plot 1000G with our project ====================
plot(project.pca[,1], project.pca[,2],
     type = 'n',
     main = paste0("PCA (1000G and ", pname,")"),
     adj = 0.5,
     xlab = 'PC1(50.7%)',
     ylab = 'PC2(24.37%)',
     font = 2,
     font.lab = 2)

points(project.pca[,1], project.pca[,2], col = col, pch = 20, cex = 2.25)
legend('bottomright',
       bty = 'n',
       cex = 1.0,
       title = '',
       c(pname,'AFR', 'AMR',
         'EAS', 'EUR','SAS'),
       fill = c('pink','yellow', 'forestgreen', 'grey', 'royalblue', 'black'))

#### plot EUR with our project ====================
is.EUR <- PED$Population %in% c(pname,"CEU","FIN","GBR","IBS","TSI")

# pname GBR FIN IBS CEU TSI
col_EUR <- colorRampPalette(c(
  "pink", "yellow", "forestgreen","grey","royalblue",
  "purple"))(length(unique(PED$Population[is.EUR])))[factor(PED$Population[is.EUR])]

plot(project.pca[is.EUR,1], project.pca[is.EUR,2],
     type = 'n',
     main = paste0("PCA (EUR and ",pname")"),
     adj = 0.5,
     xlab = 'PC1(50.7%)',
     ylab = 'PC2(24.37%)',
     font = 2,
     font.lab = 2)

points(project.pca[is.EUR,1], project.pca[is.EUR,2], col = col_EUR, pch = 20, cex = 2.25)
legend('bottomright',
       bty = 'n',
       cex = 1.0,
       title = '',
       c(pname,'GBR', 'FIN','IBS', 'CEU','TSI'),
       fill = c('pink','yellow', 'forestgreen', 'grey', 'royalblue', 'purple'))



### plot our project ====================
library(ggplot2)

draw <- function(eigval, eigvec, ethnic, family) {
  total <- sum(eigval[eigval>0])
  pc1_proportion <- paste0(round(100.*eigval[1,1]/total,2),"%")
  pc2_proportion <- paste0(round(100.*eigval[2,1]/total,2),"%")
  
  data <- eigvec[,-1] 
  colnames(data) <- c("Sample", paste0("PC", 1:(ncol(data)-1)))
  data$Ethnic <- ethnic
  data$Family <- family
  p_pca <- ggplot(data,aes(PC1,PC2))+
    geom_point(aes(color=Family, shape=Ethnic), size=2.5)+
    scale_shape_manual(values=c(15, 16, 17,18,4))+
    theme(panel.grid = element_blank(),
          panel.background = element_blank(),
          panel.border = element_rect(fill = NA, colour = "black"),
          legend.title = element_blank(),
          legend.key = element_blank(),
          axis.text = element_text(colour = "black", size=12, family = "Times New Roman"),
          axis.title = element_text(color="black",size = 15, family = "Times New Roman"),
          legend.text = element_text(colour = "black", size=12, family = "Times New Roman"))+
    labs(x=paste0("PC1(",pc1_proportion,")"),
         y=paste0("PC2(",pc2_proportion,")"))
  return(p_pca)
}

### If you're working with a large dataset, consider reading the data directly instead.
project.data <- PED[PED$Population==pname,]
project.data$Ethnicity <- c("Ethnic1", "Ethnic2", "Ethnic3", "Ethnic4", "Ethnic5")
project.data$Family_ID <- c("sample1","sample2","sample3","sample4","sample5")
draw(eigenval,project.pca[PED$Population==pname,],project.data$Ethnicity,project.data$Family_ID)



