
### check log likelihood ratio
# input data
sample <- "sample1"
file <- paste(sample,"_methylation_TTN_calls.tsv",sep="")
nanopolish_data <- read.table(file, header = TRUE, sep = "\t")
# draw log likelihood ratio hist
pass_rate <- length(which(abs(nanopolish_data$log_lik_ratio)>2))/nrow(nanopolish_data)
title <- sprintf("%s (%1.2f%%, N = %d)", sample, pass_rate*100,nrow(nanopolish_data))
hist(nanopolish_data$log_lik_ratio, 
     xlab="log likelihood ratio", main=title, 
     breaks = seq(round(min(nanopolish_data$log_lik_ratio))-1,
                  round(max(nanopolish_data$log_lik_ratio))+1,1),
     xlim = c(-20,20))
abline(v=2.0, col="blue")
abline(v=-2.0, col="blue")

### check 
# input data
file <- paste(sample,"_methylation_TTN_freq.tsv",sep="")
nanopolish_data <- read.table(file, header = TRUE, sep = "\t")
# draw methylated frequency hist
smean <- mean(nanopolish_data$methylated_frequency)
title <- sprintf("%s (N = %d, mean = %.2f)", sample, nrow(nanopolish_data), smean)
hist(nanopolish_data$methylated_frequency, 
     xlab="methylated frequency", main=title, 
     breaks = seq(0,1,0.05))
# draw methylated frequency hist
smean <- mean(nanopolish_data$called_sites_methylated)
title <- sprintf("%s (N = %d, mean = %.2f)", sample, nrow(nanopolish_data), smean)
hist(nanopolish_data$called_sites_methylated, 
     xlab="called sites methylated", main=title, 
     breaks = seq(min(nanopolish_data$called_sites_methylated),
                  max(nanopolish_data$called_sites_methylated),1))



