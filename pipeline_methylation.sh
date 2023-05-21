#!/bin/bash
### Usage: bash pipeline_methylation.sh input/run_sample.txt input/dcm_gene.txt  

set -eu -o pipefail

### ARGUMENTS
SAMPLE_LIST=$1
GENE_LIST=$2


while IFS=$'\t' read -r s 
do
	JOBID1=$(sbatch --job-name=merge_fq_${s} \
		--export=SAMPLE=${s} \
		bin/merge_fastq_by_sample.sh | sed 's/[^0-9]*//g')
	echo "Submitted batch job ${JOBID1} "
	JOBID2=$(sbatch --job-name=index_f5_${s} \
		--export=SAMPLE=${s} \
		--dependency=afterok:"${JOBID1}" \
		bin/index_fast5_by_nanopolish.sh | sed 's/[^0-9]*//g') 
	while IFS=$'\t' read -r g m
	do
		echo "    ${s} ${g} ${m}"
		sbatch --job-name=${g}_${s} \
			--export=ALL,SAMPLE=${s},GENE=${g},RANGE=${m} \
			--dependency=afterok:"${JOBID2}" \
			bin/nanopolish_methylation.sh
	done < ${GENE_LIST}
done < ${SAMPLE_LIST}



exit

