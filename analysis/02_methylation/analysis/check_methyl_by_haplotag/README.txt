This analysis was used to plot methylation patterns at the allele-specific level. 

Long-read sequencing provides reads long enough to phase haplotypes, although phasing entire chromosomes remains challenging. WhatsHap assigns 'haplotags' to identify the haplotype origin of each read, allowing us to analyze methylation patterns separately for each haplotype. Our results show that methylation can be significantly different between haplotypes.

[Note] Haplotags are assigned based on the order of haplotypes within each phased block, and each block is independent. As a result, the same haplotag number in different blocks does not necessarily represent the same allele. To avoid this limitation, we performed our analysis at the gene level, ensuring that each gene was fully contained within a single phased block in all samples.

