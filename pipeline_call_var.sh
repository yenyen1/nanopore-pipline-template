#!/bin/bash
### Usage: bash pipeline_call_var.sh input/run_sample.txt 


set -eu -o pipefail


### ARGUMENTS
SAMPLE_LIST=$1

while IFS=$'\t' read -r s 
do
	echo "${s}"
	sbatch --job-name=clair3_${s} --export=SAMPLE=${s} bin/call_snv_by_clair3.sh 
	sbatch --job-name=svim_${s} --export=SAMPLE=${s} bin/call_sv_by_svim.sh 
	sbatch --job-name=cutesv_${s} --export=SAMPLE=${s} bin/call_sv_by_cutesv.sh 
	sbatch --job-name=sniffles_${s} --export=SAMPLE=${s} bin/call_sv_by_sniffles2.sh 
	sbatch --job-name=pbsv_${s} --export=SAMPLE=${s} bin/call_sv_by_pbsv.sh 
done < ${SAMPLE_LIST}



exit

