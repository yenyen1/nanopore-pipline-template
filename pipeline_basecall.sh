#!/bin/bash
### Usage: bash pipeline_basecall.sh input/dcm_sample_all.txt 

set -eu -o pipefail

### ARGUMENTS
SAMPLE_LIST=$1

while IFS=$'\t' read -r s r fc k rd
do
	echo "${s} ${r}"
	JOBID1=$(sbatch --job-name=guppy_bc_${s}_${r} \
			--export=ALL,SAMPLE=${s},RUN=${r},FLOWCELL=${fc},KIT=${k},FILE=${rd} \
			bin/base_call_gpu.sh | sed 's/[^0-9]*//g')
	echo "${s}_${r} basecalling by Guppy: ${JOBID1}" 
	sbatch --job-name=nanoplot_qc_${s}_${r} \
		--dependency=afterok:${JOBID1} \
		--export=ALL,SAMPLE=${s},RUN=${r} \
		bin/nanoplot_summary.sh 
	sbatch --job-name=merge_pass_${s}_${r} \
		--dependency=afterok:${JOBID1} \
		--export=ALL,SAMPLE=${s},RUN=${r} \
		bin/merge_pass_fastq.sh
done < ${SAMPLE_LIST}

