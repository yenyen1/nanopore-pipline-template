#!/bin/bash
### Usage: bash pipeline_call_var.sh input/run_sample.txt 


set -eu -o pipefail


### ARGUMENTS
SAMPLE_LIST=$1

while IFS=$'\t' read -r s 
do
	echo "${s}"
	JOBID1=$(sbatch --job-name=clair3_${s} --export=SAMPLE=${s} bin/call_snv_by_clair3.sh | sed 's/[^0-9]*//g') 
	echo "job submit: ${JOBID1}"
	JOBID2=$(sbatch --job-name=phase_${s} --export=SAMPLE=${s} --dependency=afterok:${JOBID1} bin/phase_by_whatshap.sh | sed 's/[^0-9]*//g')
	echo "job submit: ${JOBID2}"
	sbatch --job-name=haplotag_${s} --export=SAMPLE=${s} --dependency=afterok:${JOBID2} bin/haplotag_by_whatshap.sh 
	sbatch --job-name=svim_${s} --export=SAMPLE=${s} bin/call_sv_by_svim.sh 
	sbatch --job-name=cutesv_${s} --export=SAMPLE=${s} bin/call_sv_by_cutesv.sh 
	sbatch --job-name=sniffles_${s} --export=SAMPLE=${s} bin/call_sv_by_sniffles2.sh 
	sbatch --job-name=pbsv_${s} --export=SAMPLE=${s} bin/call_sv_by_pbsv.sh 
done < ${SAMPLE_LIST}



exit

