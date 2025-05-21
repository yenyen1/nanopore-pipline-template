#!/bin/bash
#SBATCH --account=def-ioannisr
#SBATCH --cpus-per-task=48         # CPU cores/threads
#SBATCH --mem=60000M              # memory per Node
#SBATCH --time=48:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH -o log/02_mapping/02-2_qualimap_qc_bam_%j.out
#SBATCH -e log/02_mapping/02-2_qualimap_qc_bam_%j.err

set -eu -o pipefail
cd ${SLURM_SUBMIT_DIR}


#module purge &&\
module load apptainer &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Starting analysis at ${now}" &&\
# qualimap.bam:   # sample=, pre=, faname=, bamdir=
make qualimap.bam sample=${SAMPLE} run=${RUN} &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Ending analysis at ${now}"

exit


