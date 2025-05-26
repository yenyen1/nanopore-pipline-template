
This analysis used to compare the methylation differences between sequencing data from two individuals, or from the same individual processed in different batches. The comparison can be performed across the whole genome or restricted to specific regions, such as a gene. This code was originally designed to process a single gene using a region-specific BAM file. For whole-genome analysis, the same program can be applied to a complete BAM file.
 
1. Run make calc.methyl.freq.from.calls.tsv or make calc.methyl.from.bam to get methyl freq TSV	data you want to compare.
2. Run make compare.methyl to merge methylation data from two samples.
3. Perform R script to draw a comparison graph. (Need to change the dir in the script)
