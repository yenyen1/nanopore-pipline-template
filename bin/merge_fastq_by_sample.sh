#!/bin/bash
#SBATCH --account=def-ioannisr
#SBATCH --cpus-per-task=1         # CPU cores/threads
#SBATCH --mem=4000M              # memory per Node
#SBATCH --time=24:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH -o log/02_mapping/02-3_merge_fastq_by_sample_%j.out
#SBATCH -e log/02_mapping/02-3_merge_fastq_by_sample_%j.err

set -eu -o pipefail
cd "${SLURM_SUBMIT_DIR}"

now=$(date "+%Y/%m/%d-%H:%M:%S") &&
	echo "Starting analysis at ${now}" &&
	make merge.fastq.by.sample sample="$SAMPLE" &&
	now=$(date "+%Y/%m/%d-%H:%M:%S") &&
	echo "Ending analysis at ${now}"

exit
