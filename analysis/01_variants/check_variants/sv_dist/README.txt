Place all VCF files in the same directory. Then, use the make command to count structural variants and generate length files for each variant type in each sample. Finally, visualize the results using the R script.

Makefile:
1. extract.chr: Count each type of structure variant (INS, DEL, INV) for every chromosome (chr1-22,X,Y,M,Un) and save in the file sv_count_per_chr.txt.
2. extract.size: Generate SV length files for each variant type in each sample.
3. extract.size and stat.filter: print the statistics for either the raw data or the extracted data. 

