
1. Place VCF files from ONT data into the ont directory and VCF files from NGS data into the ngs directory.
2. extract.format.txt: Extract the necessary columns ('CHR', 'POS', 'QUAL', 'GT', 'GQ', 'DP', 'AF') into a text file for the R script 'qc_ont.R' to generate the DP distribution plot.
3. qc.ont and qc.ngs: Get filtered variants. We define filtered variants as those labeled 'PASS' for ONT data, and those with GQ ≥ 20 and DP ≥ 10 for NGS data.
4. merge and check.merge: SNVs and small Indels called from NGS data are used as the ground truth in this comparison. Therefore, we separately merge the raw VCF with the filtered NGS VCF and the filtered VCF with the filtered NGS VCF, and then save the files into the merged_vcf directory. The check.merge command can be used to verify that the files have been correctly merged.
5. gen.tsv and check.tsv: Generate TSV files from merged VCF and save the files into the merged_tsv directory. The check.tsv command can be used to verify that the files have been correctly merged.
6. extract.whole.gene.exon.vcf and gen.tsv.by.whole.gene: Extract SNVs and indels that fall within whole-gene or whole-exon regions specified in the BED files and generate TSV files for the R script 'qc_ont.R' to produce CSV files containing recall and precision statistics.
7. extract.gene.exon.list.vcf and gen.tsv.by.gene.list: Extract SNVs and indels that fall within a specific regions specified in the BED files and generate TSV files for the R script 'qc_ont.R' to produce CSV files containing recall and precision statistics.
 
