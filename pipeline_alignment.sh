#!/bin/bash
### Usage: bash pipeline_alignment.sh input/dcm_sample_all.txt 

set -eu -o pipefail

### ARGUMENTS
SAMPLE_LIST=$1

cur_sample=""
jobid_list=""
while IFS=$'\t' read -r s r fc k rd
do
	JOBID1=$(sbatch --job-name=minimap2_${s}_${r} \
		--export=ALL,SAMPLE=${s},RUN=${r} \
		bin/aligned_by_minimap2.sh | sed 's/[^0-9]*//g')
	echo "Submitted batch job ${JOBID1} "
	sbatch --job-name=qc_bam_${s}_${r} \
		--export=ALL,SAMPLE=${s},RUN=${r} \
		--dependency=afterok:${JOBID1} \
		bin/qualimap_qc_bam.sh
	if [[ "${cur_sample}" == "" ]]; then
		cur_sample=${s}
		jobid_list="${JOBID1}"
	elif [[ "$s" != "${cur_sample}" ]]; then
		echo "${cur_sample}: ${jobid_list}"
		sbatch --job-name=merge_bam_${cur_sample} \
			--dependency=afterok:${jobid_list} \
			--export=SAMPLE=${cur_sample} \
			bin/merge_bam_by_sample.sh 
		cur_sample=${s}
		jobid_list="${JOBID1}"
	else
		jobid_list="${jobid_list},${JOBID1}"
	fi
done < ${SAMPLE_LIST}
echo "${cur_sample}: ${jobid_list}"
sbatch --job-name=merge_bam_${cur_sample} \
	--dependency=afterok:${jobid_list} \
	--export=SAMPLE=${cur_sample} \
	bin/merge_bam_by_sample.sh 

exit

