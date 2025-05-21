#!/bin/bash
#SBATCH --account=def-ioannisr
#SBATCH --cpus-per-task=8         # CPU cores/threads
#SBATCH --mem=4000M              # memory per Node
#SBATCH --time=8:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH -o log/01_guppy_basecall_gpu/01-3_merge_pass_fastq_%j.out
#SBATCH -e log/01_guppy_basecall_gpu/01-3_merge_pass_fastq_%j.err

set -eu -o pipefail
cd ${SLURM_SUBMIT_DIR}


#module purge &&\
module load apptainer &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Starting analysis at ${now}" &&\
make merge.pass.fastq.and.fastq.qc sample=${SAMPLE} run=${RUN} &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Ending analysis at ${now}"

exit


