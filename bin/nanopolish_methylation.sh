#!/bin/bash
#SBATCH --account=def-ioannisr
##SBATCH --gpus-per-node=1         # Number of GPU(s) per node
#SBATCH --cpus-per-task=24     # CPU cores/threads
#SBATCH --mem=120000M
#SBATCH --time=120:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH --output=log/04_methylation/04-1_nanopolish_call_%j.out
#SBATCH --error=/dev/null

set -eu -o pipefail
cd "${SLURM_SUBMIT_DIR}"

echo "${SLURM_SUBMIT_DIR}"
echo "pwd: $(pwd)"
now=$(date "+%Y/%m/%d-%H:%M:%S") &&
	echo "Starting analysis at ${now}" &&
	module load apptainer python/3.11.2 &&
	make nanopolish sample="$SAMPLE" gene="$GENE" t=24 range="$RANGE" &&
	now=$(date "+%Y/%m/%d-%H:%M:%S") &&
	echo "Ending analysis at ${now}"

exit
