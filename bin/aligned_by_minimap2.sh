#!/bin/bash
#SBATCH --account=def-ioannisr
#SBATCH --cpus-per-task=24         # CPU cores/threads
#SBATCH --mem=120000M              # memory per Node
#SBATCH --time=48:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH -o log/02_mapping/02-1_map_by_minimap2_%j.out
#SBATCH -e log/02_mapping/02-1_map_by_minimap2_%j.err

set -eu -o pipefail
cd ${SLURM_SUBMIT_DIR}


module load singularity &&\
module load samtools/1.12 &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Starting analysis at ${now}" &&\
make align.ont.minimap2 sample=${SAMPLE} run=${RUN} &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Ending analysis at ${now}"

exit


