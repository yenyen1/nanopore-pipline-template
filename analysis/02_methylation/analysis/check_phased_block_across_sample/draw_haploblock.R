library("karyoploteR")

length <- function(data){
  return(data$V5-data$V4)
} 
get_data <- function(case, type, chr){
  file <- paste("result/", case ,".",type,".",chr,".phased.block.tsv", sep = "")
  da <- read.table(file=file, header = FALSE, sep = "\t")
  print(paste("[raw data] records:", nrow(da),"; max: ",max(length(da)),"; min: ", min(length(da)),sep=""))
  print("remove:")
  print(da[c(da$V4,10e12)-c(0,da$V5)<0,])
  da <- da[(c(da$V4,10e12)-c(0,da$V5)>0)[-nrow(da)],]
  da <- da[length(da)>1e3,]
  print(paste("[output data] records:", nrow(da),"; max: ",max(length(da)),"; min: ", min(length(da)),sep=""))
  return(da) 
}
draw_sample <- function(sample, type, chr, y0, y1){
  da <- get_data(sample,type, chr)
  da <- da[length(da)<1e7,]
  da_loc <- paste(da$V2,paste(da$V4,da$V5,sep="-"),sep=":")
  kpPlotRegions(kp, data=da_loc, r0=y0, r1=y1, col = "brown3",border="brown4")
  da <- get_data(sample,type, chr)
  da <- da[length(da)>1e7,]
  da_loc <- paste(da$V2,paste(da$V4,da$V5,sep="-"),sep=":")
  kpPlotRegions(kp, data=da_loc, r0=y0, r1=y1, col = "brown1",border="brown4")
  kpAddLabels(kp, labels=sample, r0=y0, r1=y1)
}

type <- "ont"
chr <- "chr1"
kp <- plotKaryotype(genome="hg38", chromosomes = c(chr))
draw_sample("sample1-1",type,chr,0.0,0.195)
draw_sample("sample1-2",type,chr,0.2,0.395)
draw_sample("sampel2-1",type,chr,0.4,0.595)
draw_sample("sample2-2",type,chr,0.6,0.795)
draw_sample("sample2-3",type,chr,0.8,0.995)
kpAddBaseNumbers(kp)

type <- "ngs"
kp <- plotKaryotype(genome="hg38", chromosomes = c(chr))
draw_sample("sample1-1",type,chr,0.0,0.195)
draw_sample("sample1-2",type,chr,0.2,0.395)
draw_sample("sampel2-1",type,chr,0.4,0.595)
draw_sample("sample2-2",type,chr,0.6,0.795)
draw_sample("sample2-3",type,chr,0.8,0.995)
kpAddBaseNumbers(kp)

