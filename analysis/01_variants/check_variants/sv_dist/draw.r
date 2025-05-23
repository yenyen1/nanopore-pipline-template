
par(mfrow=c(2,3))
del <- read.table("tmp_sample.cuteSV.sr6.vcf_DEL_len.txt", header = FALSE)
ins <- read.table("tmp_sample.cuteSV.sr6.vcf_INS_len.txt", header = FALSE)
inv <- read.table("tmp_sample.cuteSV.sr6.vcf_INV_len.txt", header = FALSE)
h_del <- hist(log10(-del$V1), 
              breaks=seq(0,8,0.1),
              main=paste("CuteSV DEL (N=", nrow(del),")", sep=""),
              xlab="log10(SV size)",
              ylab="count",
              xlim=c(0,8),
              ylim=c(0,4000),
              col="darkmagenta") 
h_ins <- hist(log10(ins$V1), 
              breaks=seq(0,5,0.1),
              main=paste("CuteSV INS (N=", nrow(ins),")", sep=""),
              xlab="log10(SV size)",
              ylab="count",
              xlim=c(0,5),
              ylim=c(0,3000),
              col="brown") 
h_inv <- hist(log10(inv$V1), 
              breaks=seq(0,10,0.1),
              main=paste("CuteSV INV (N=", nrow(inv),")", sep=""),
              xlab="log10(SV size)",
              ylab="count",
              xlim=c(0,10),
              ylim=c(0,20),
              col="blue") 

del <- read.table("tmp_sample.svim.vcf_DEL_len.txt", header = FALSE)
ins <- read.table("tmp_sample.svim.vcf_INS_len.txt", header = FALSE)
inv <- read.table("tmp_sample.svim.vcf_INV_len.txt", header = FALSE)
h_del <- hist(log10(-del$V1), 
              breaks=seq(0,8,0.1),
              main=paste("SVIM DEL (N=", nrow(del),")", sep=""),
              xlab="log10(SV size)",
              ylab="count",
              xlim=c(0,8),
              ylim=c(0,4000),
              col="darkmagenta") 
h_ins <- hist(log10(ins$V1), 
              breaks=seq(0,5,0.1),
              main=paste("SVIM DEL (N=", nrow(ins),")", sep=""),
              xlab="log10(SV size)",
              ylab="count",
              xlim=c(0,5),
              ylim=c(0,3000),
              col="brown") 
# no INV size

del <- read.table("tmp_sample.sniffles.sr6.vcf_DEL_len.txt", header = FALSE)
ins <- read.table("tmp_sample.sniffles.sr6.vcf_INS_len.txt", header = FALSE)
inv <- read.table("tmp_sample.sniffles.sr6.vcf_INV_len.txt", header = FALSE)
h_del <- hist(log10(-del$V1), 
              breaks=seq(0,8,0.1),
              main=paste("Sniffles DEL (N=", nrow(del),")", sep=""),
              xlab="log10(SV size)",
              ylab="count",
              xlim=c(0,8),
              ylim=c(0,4000),
              col="darkmagenta") 
h_ins <- hist(log10(ins$V1), 
              breaks=seq(0,5,0.1),
              main=paste("Sniffles INS (N=", nrow(ins),")", sep=""),
              xlab="log10(SV size)",
              ylab="count",
              xlim=c(0,5),
              ylim=c(0,3000),
              col="brown") 
h_inv <- hist(log10(inv$V1), 
              breaks=seq(0,10,0.1),
              main=paste("Sniffles INV (N=", nrow(inv),")", sep=""),
              xlab= "log10(SV size)",
              ylab="count",
              xlim=c(0,10),
              ylim=c(0,20),
              col="blue") 

del <- read.table("tmp_sample.sniffles2.vcf_DEL_len.txt", header = FALSE)
ins <- read.table("tmp_sample.sniffles2.vcf_INS_len.txt", header = FALSE)
inv <- read.table("tmp_sample.sniffles2.vcf_INV_len.txt", header = FALSE)
h_del <- hist(log10(-del$V1), 
              breaks=seq(0,8,0.1),
              main=paste("Sniffles2 DEL (N=", nrow(del),")", sep=""),
              xlab= "log10(SV size)",
              ylab="count",
              xlim=c(0,8),
              ylim=c(0,4000),
              col="darkmagenta") 
h_ins <- hist(log10(ins$V1), 
              breaks=seq(0,5,0.1),
              main=paste("Sniffles2 INS (N=", nrow(ins),")", sep=""),
              xlab= "log10(SV size)",
              ylab="count",
              xlim=c(0,5),
              ylim=c(0,3000),
              col="brown") 
h_inv <- hist(log10(inv$V1), 
              breaks=seq(0,10,0.1),
              main=paste("Sniffles2 INV (N=", nrow(inv),")", sep=""),
              xlab= "log10(SV size)",
              ylab="count",
              xlim=c(0,10),
              ylim=c(0,20),
              col="blue") 


