#!/bin/bash
#SBATCH --account=def-ioannisr
#SBATCH --cpus-per-task=8         # CPU cores/threads
#SBATCH --mem=4000M              # memory per Node
#SBATCH --time=4:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH -o log/01_guppy_basecall_gpu/01-2_raw_fastq_qc_%j.out
#SBATCH -e log/01_guppy_basecall_gpu/01-2_raw_fastq_qc_%j.err

set -eu -o pipefail
cd ${SLURM_SUBMIT_DIR}

mkdir -p log/01_guppy_basecall_gpu &&\
module load apptainer &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Starting analysis at ${now}" &&\
make fastq.qc.with.nanoplot.seq.summary sample=${SAMPLE} run=${RUN} &&\
now=`date "+%Y/%m/%d-%H:%M:%S"` &&\
echo "Ending analysis at ${now}"

exit


