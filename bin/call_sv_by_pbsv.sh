#!/bin/bash
#SBATCH --account=def-ioannisr
#SBATCH --cpus-per-task=24         # CPU cores/threads
#SBATCH --mem=120000M              # memory per Node
#SBATCH --time=48:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH -o log/03_call_var/03-5_pbsv_%j.out
#SBATCH -e log/03_call_var/03-5_pbsv_%j.err

set -eu -o pipefail
cd ${SLURM_SUBMIT_DIR}


module load singularity bcftools &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Starting analysis at ${now}" &&\
make call.pbsv sample=${SAMPLE} &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Ending analysis at ${now}"

exit


