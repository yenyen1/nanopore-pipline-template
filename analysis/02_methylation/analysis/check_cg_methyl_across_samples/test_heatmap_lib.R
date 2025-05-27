library(RColorBrewer)
library(pheatmap)

### create gene info
gene <- c("TTN")
ID <- c("NSG00000155657")
chrom <- c("chr2")
start <- c(178425989)
end <- c(178907423)
genes_info <- data.frame(gene,ID,chrom,start,end)


# 01 Parse GENE exon bed
geneName <- "TTN"
ENSGID <- "ENSG00000155657"
NMID <- "NM_001256850.1"

file <- paste(geneName, "_", NMID, ".txt", sep="")
exonbar <- getExonMat(geneName, file, genes_info)
print(length(exonbar))

# 02 gen heatmap matrix
samples <- c("sample1","sample2","sample3","sample4")
input_samples <- c("sample1","sample2","sample3")

nanopolish_bars <- c(exonbar,rep(0.,length(exonbar)))
for( s in samples){
  if (s %in% input_samples){
    file <- paste(s, "_methylation_TTN_freq.tsv", sep="")
    nanopolish_data <- read.table(file, header = TRUE, sep = "\t")
    idx <- which(genes_info$gene==geneName)
    nanopolish_bar <- getfreqMat(genes_info$start[idx], genes_info$end[idx], nanopolish_data)
    nanopolish_bars <- c(nanopolish_bars,nanopolish_bar)
    print(length(nanopolish_bar))
  }else{
    nanopolish_bars <-c(nanopolish_bars,rep(0.,length(exonbar)))
    print(s)
  }
}

mat <- matrix(nanopolish_bars, nrow=16, byrow=TRUE)
colnames(mat) <- rep("",length(exonbar))
rownames(mat) <- c("TTN_exon","",samples)

# 03-1 draw heatmap 
png(file="TTN_methy_heatmap_1.png", width = 680, height = 650, res = 300)
heatmap(mat, Colv = NA, Rowv = NA, main="TTN (±100K)", col = brewer.pal(9,"Reds"))
dev.off()

# 03-2 draw heatmap (pheatmap)
png(file="TTN_methy_heatmap_2.png", width = 1800, height = 600, pointsize = 12)
bk <- c(seq(0,1,by=0.01))
pheatmap(mat, cluster_cols = F, cluster_rows = F, scale = "none",
         treeheight_col = 0, treeheight_row = 0, display_numbers = F, 
         color = colorRampPalette(c("white","red","purple","blue"))(length(bk)))
dev.off()


### function
getExonMat <- function(geneName, file, genes_info){
  exon_data <- read.table(file, header = FALSE, sep = " ")
  colnames(exon_data) <- c("chrom","region","start","end")

  idx <- which(genes_info$gene==geneName)
  mat_len <- genes_info$end[idx] - genes_info$start[idx] + 1
  
  bar <- rep(0, mat_len)
  for( i in 1:nrow(exon_data)){
    for(j in exon_data$start[i]:exon_data$end[i]){
      bar[j-genes_info$start[idx]+1] <- 0.999
    }
  }
  return (as.numeric(bar))
}

getfreqMat <- function(start, end, block_data){
  mat_len <- end - start + 1
  bar <- rep(0.0 ,mat_len)
  for( i in 1:nrow(block_data)){
    for(j in block_data$start[i]:block_data$end[i]){
      bar[j-start+1] <- block_data$methylated_frequency[i]
    }
  }
  return (bar)
}





