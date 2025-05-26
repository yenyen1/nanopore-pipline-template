library(ggplot2)
library(RColorBrewer)

dir="data directory (NEED TO CHANGE)"

### Run pairwise comparisons between all samples 
SAMPLES1 <- c("sample1-b1","sample2-b1",)
SAMPLES2 <- c("sample1-b2","sample2-b2",)
gene <- "BAG3"

par(mfrow=c(2,2))
for(i in 1:length(SAMPLES1)){
  for(j in 1:length(SAMPLES2)){
    print( paste(SAMPLES1[i],SAMPLES2[j], sep=","))
    draw_compare(dir,sample1,sample2,gene)
  }
}

### Run comparison for one pair
sample1 <- "sample1"
sample2 <- "sample2"
draw_compare(dir,sample1,sample2,gene)



### function 
draw_compare <- function(dir,sample1,sample2,gene){
  file <- paste(dir,"/",gene,"_",sample1,"_vs_",sample2,".tsv", sep="")
  data <- read.table(file, header=F)
  colnames(data) <- c("chrom","pos",
                      "f1_methyl_count", "f1_total_count", "f1_methyl_freq",
                      "f2_methyl_count", "f2_total_count", "f2_methyl_freq")
  # Set color palette for 2D heatmap
  rf <- colorRampPalette(rev(brewer.pal(11,'Spectral')))
  r <- rf(32)
  # draw
  c <- cor(data$f1_methyl_freq, data$f2_methyl_freq)
  title <- sprintf("N = %d r = %.3f", nrow(data), c)
  
  ggplot(data, aes(f1_methyl_freq, f2_methyl_freq)) +
    geom_bin2d(bins=25) + scale_fill_gradientn(colors=r, trans="log10") +
    xlab(paste(sample1," Methylation Frequency",sep="")) +
    ylab(paste(sample2," Methylation Frequency",sep="")) +
    theme_bw(base_size=20) +
    ggtitle(title)
}






