### 01 draw DP distribution png ====================================================
# input data
file <- paste("input/", sample, "_FORMAT_", type, ".txt", sep = "")
format_data <- read.table(file, header = FALSE, sep = " ")
colnames(format_data) <- c("CHR", "POS", "QUAL", "GT", "GQ", "DP", "AF")
# select gt
tmp <- format_data
outname <- paste("output/", sample, "_DP_", type, ".png", sep = "")
tmp <- format_data[format_data$GT == "1/1", ]
outname <- paste("output/", sample, "_DP_", type, "_11.png", sep = "")
tmp <- format_data[format_data$GT == "0/1", ]
outname <- paste("output/", sample, "_DP_", type, "_01.png", sep = "")
tmp <- format_data[format_data$GQ >= 20, ]
outname <- paste("output/", sample, "_DP_", type, "_GQ20.png", sep = "")
# draw
png(
  filename = outname,
  width = 4000, height = 6000,
  units = "px"
)
par(
  mfrow = c(6, 4),
  cex = 5, cex.axis = 0.5, cex.main = 1
)
par(mai = c(2, 2, 1.5, 1.5))
for (i in c(1:22, "X", "Y")) {
  c <- paste("chr", i, sep = "")
  print(c)
  draw_DP_hist(tmp, c)
}
dev.off()

### 02 gatk vs ont ================================================================
# variables
SAMPLES_LIST <- c("sample1", "sample2")
TYPES <- c("snp", "indel")
type <- ""

# 02-1 output recall precise stats for raw, pass, and ont_qc_filter files
out <- c()
for (s in SAMPLES_LIST) {
  type <- "gencode43_gene_indels"
  print(paste(s, "raw", type, sep = " "))
  out <- rbind(out, get_file_stats(s, "raw", type))
  out <- rbind(out, get_qc_stats(s, type))
  type <- "gencode43_exon_indels"
  print(paste(s, "raw", type, sep = " "))
  out <- rbind(out, get_file_stats(s, "raw", type))
  out <- rbind(out, get_qc_stats(s, type))
  type <- "NCBI_Refseq_gene_indels"
  print(paste(s, "raw", type, sep = " "))
  out <- rbind(out, get_file_stats(s, "raw", type))
  out <- rbind(out, get_qc_stats(s, type))
  type <- "NCBI_Refseq_exon_indels"
  print(paste(s, "raw", type, sep = " "))
  out <- rbind(out, get_file_stats(s, "raw", type))
  out <- rbind(out, get_qc_stats(s, type))
}
df <- data.frame(out)
colnames(df) <- get_header()
outname <- "cal_precise_recall_gene_exon_snps.csv"
write.csv(df, file = outname, row.names = FALSE, col.names = TRUE)

### 03  ================================================================
### 01 function ------------------------------------------------------------
draw_DP_hist <- function(format_data, chr) {
  # remove outliers if no qc filter
  target <- format_data$DP[which(format_data$CHR == chr)]
  target_rm_outliner <- target[which(target < mean(target) + 2 * sd(target))]

  # target_rm_outliner <- format_data$DP[which(format_data$CHR==chr)]

  hist(target_rm_outliner,
    xlim = c(0, 60),
    ylim = c(0, 0.1),
    xlab = "", ylab = "",
    breaks = seq(1, max(target_rm_outliner), 1),
    main = chr,
    probability = TRUE
  )
  abline(v = mean(target_rm_outliner), lty = 3, col = "red")
  text(
    30, 0.08,
    sprintf("Mean=%.2f (%.2f)", mean(target_rm_outliner), sd(target_rm_outliner))
  )
  text(
    20, 0.04,
    sprintf(
      "N=%d [%d,%d]", length(target_rm_outliner),
      min(target_rm_outliner), max(target_rm_outliner)
    )
  )
}

#### 02 function ------------------------------------------------------------
# get Raw/qc files stats
get_file_stats <- function(sample, qc, type) {
  # input data
  file <- paste("merged_tsv/by_gene/", sample, "_merge_", qc, "_", type, ".tsv", sep = "")
  comp_data <- read.table(file, header = FALSE, sep = "\t")
  colnames(comp_data) <- c(
    "CHR", "POS", "REF", "ALT",
    "NGS_GT", "NGS_DP", "NGS_GQ",
    "ONT_GT", "ONT_DP", "ONT_GQ"
  )

  ngs_n <- sum(comp_data$NGS_GT != "./.")
  tmp_list <- c(sample, qc, type, "NGS", ngs_n)
  result <- print_ngs_N(comp_data, tmp_list)
  ont_n <- sum(comp_data$ONT_GT != "./.")
  tmp_list <- c(sample, qc, type, "ONT", ont_n)
  result <- rbind(result, print_ont_N(comp_data, tmp_list))

  tmp0 <- comp_data[comp_data$NGS_GT != "./.", ]
  rec <- sum(tmp0$NGS_GT == tmp0$ONT_GT) / nrow(tmp0)
  tmp_list <- c(sample, qc, type, "Recall", rec)
  result <- rbind(result, print_recall(comp_data, tmp_list))

  tmp0 <- comp_data[comp_data$ONT_GT != "./.", ]
  pre <- sum(tmp0$NGS_GT == tmp0$ONT_GT) / nrow(tmp0)
  tmp_list <- c(sample, qc, type, "Precision", pre)
  result <- rbind(result, print_precision(comp_data, tmp_list))
  return(result)
}
# get ONT qc filter  stats
get_qc_stats <- function(sample, type) {
  # input data
  file <- paste("merged_tsv/by_gene/", sample, "_merge_qc_", type, ".tsv", sep = "")
  comp_data <- read.table(file, header = FALSE, sep = "\t")
  colnames(comp_data) <- c(
    "CHR", "POS", "REF", "ALT",
    "NGS_GT", "NGS_DP", "NGS_GQ",
    "ONT_GT", "ONT_DP", "ONT_GQ"
  )

  print(paste(sample, "qc", type, sep = " "))

  ngs_n <- sum(comp_data$NGS_GT != "./.")
  tmp_list <- c(sample, "qc", type, "NGS", ngs_n)
  result <- print_ngs_N(comp_data, tmp_list)
  ont_n <- sum(comp_data$ONT_GT != "./.")
  tmp_list <- c(sample, "qc", type, "ONT", ont_n)
  result <- rbind(result, print_ont_N(comp_data, tmp_list))

  tmp0 <- comp_data[comp_data$NGS_GT != "./.", ]
  rec <- sum(tmp0$NGS_GT == tmp0$ONT_GT) / nrow(tmp0)
  tmp_list <- c(sample, "qc", type, "Recall", rec)
  result <- rbind(result, print_recall(comp_data, tmp_list))

  tmp0 <- comp_data[comp_data$ONT_GT != "./.", ]
  pre <- sum(tmp0$NGS_GT == tmp0$ONT_GT) / nrow(tmp0)
  tmp_list <- c(sample, "qc", type, "Precision", pre)
  result <- rbind(result, print_precision(comp_data, tmp_list))

  # qc filter
  print(paste(sample, "ont_DP10_GQ20", type, sep = " "))
  tmp0 <- comp_data[comp_data$ONT_DP != ".", ]
  tmp1 <- tmp0[((as.integer(tmp0$ONT_DP) >= 10) & (as.integer(tmp0$ONT_GQ) >= 20)), ]
  tmp2 <- tmp0[((as.integer(tmp0$ONT_DP) < 10) | (as.integer(tmp0$ONT_GQ) < 20)), ]
  tmp2$ONT_GT <- rep("./.", length(tmp2$ONT_GT))
  tmp2$ONT_GQ <- rep(".", length(tmp2$ONT_GQ))
  tmp2$ONT_DP <- rep(".", length(tmp2$ONT_DP))
  tmp3 <- rbind(tmp1, tmp2, comp_data[comp_data$ONT_DP == ".", ])

  ngs_n <- sum(tmp3$NGS_GT != "./.")
  tmp_list <- c(sample, "ont_DP10_GQ20", type, "NGS", ngs_n)
  result <- rbind(result, print_ngs_N(tmp3, tmp_list))
  ont_n <- sum(tmp3$ONT_GT != "./.")
  tmp_list <- c(sample, "ont_DP10_GQ20", type, "ONT", ont_n)
  result <- rbind(result, print_ont_N(tmp3, tmp_list))

  tmp4 <- tmp3[tmp3$NGS_GT != "./.", ]
  rec <- sum(tmp4$NGS_GT == tmp4$ONT_GT) / nrow(tmp4)
  tmp_list <- c(sample, "ont_DP10_GQ20", type, "Recall", rec)
  result <- rbind(result, print_recall(tmp4, tmp_list))

  tmp4 <- tmp3[tmp3$ONT_GT != "./.", ]
  pre <- sum(tmp4$NGS_GT == tmp4$ONT_GT) / nrow(tmp4)
  tmp_list <- c(sample, "ont_DP10_GQ20", type, "Precision", pre)
  result <- rbind(result, print_precision(tmp4, tmp_list))
  return(result)
}
get_header <- function() {
  HEADER <- c("SAMPLE", "QC", "Type", "Trial", "All")
  for (i in c(1:22, "X", "Y")) {
    HEADER <- c(HEADER, paste("Chr", i, sep = ""))
  }
  return(HEADER)
}
print_ngs_N <- function(data, n_list) {
  for (i in c(1:22, "X", "Y")) {
    c <- paste("chr", i, sep = "")
    tmp <- data[data$CHR == c, ]
    n <- length(tmp$NGS_GT[tmp$NGS_GT != "./."])
    n_list <- c(n_list, n)
  }
  return(n_list)
}
print_ont_N <- function(data, n_list) {
  for (i in c(1:22, "X", "Y")) {
    c <- paste("chr", i, sep = "")
    tmp <- data[data$CHR == c, ]
    n <- length(tmp$ONT_GT[tmp$ONT_GT != "./."])
    n_list <- c(n_list, n)
  }
  return(n_list)
}
# recall
print_recall <- function(data, recall_list) {
  for (i in c(1:22, "X", "Y")) {
    c <- paste("chr", i, sep = "")
    tmp0 <- data[data$CHR == c, ]
    tmp1 <- tmp0[tmp0$NGS_GT != "./.", ]
    rec <- length(tmp1$NGS_GT[tmp1$NGS_GT == tmp1$ONT_GT]) / nrow(tmp1)
    recall_list <- c(recall_list, rec)
  }
  return(recall_list)
}
# precision
print_precision <- function(data, pre_list) {
  for (i in c(1:22, "X", "Y")) {
    c <- paste("chr", i, sep = "")
    tmp0 <- data[data$CHR == c, ]
    tmp1 <- tmp0[tmp0$ONT_GT != "./.", ]
    pre <- length(tmp1$NGS_GT[tmp1$NGS_GT == tmp1$ONT_GT]) / nrow(tmp1)
    pre_list <- c(pre_list, pre)
  }
  return(pre_list)
}
