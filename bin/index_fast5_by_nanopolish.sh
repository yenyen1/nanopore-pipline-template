#!/bin/bash
#SBATCH --account=def-ioannisr
##SBATCH --gpus-per-node=1         # Number of GPU(s) per node
#SBATCH --cpus-per-task=2      # CPU cores/threads
#SBATCH --mem=120000M
#SBATCH --time=24:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH -o log/02_mapping/02-5_nanopolish_index_%j.out
#SBATCH -e log/02_mapping/02-5_nanopolish_index_%j.err

set -eu -o pipefail
cd ${SLURM_SUBMIT_DIR}

echo "${SLURM_SUBMIT_DIR}"
echo "pwd: `pwd`"
module load singularity &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Starting analysis at ${now}" &&\
make index.fast5.by.nanopolish.with.seq.summary sample=${SAMPLE} &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Ending analysis at ${now}"

exit


