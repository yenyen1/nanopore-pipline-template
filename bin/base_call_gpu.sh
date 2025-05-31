#!/bin/bash
#SBATCH --account=def-ioannisr
#SBATCH --gpus-per-node=1         # Number of GPU(s) per node
#SBATCH --mem=40000M              # memory per Node
#SBATCH --time=72:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=yen-yen.wang@mail.mcgill.ca
#SBATCH -o log/01_guppy_basecall_gpu/01-1_basecalling_%j.out
#SBATCH -e log/01_guppy_basecall_gpu/01-1_basecalling_%j.err

set -eu -o pipefail
cd "${SLURM_SUBMIT_DIR}"

echo "${SLURM_SUBMIT_DIR}"
echo "pwd: $(pwd)"
module load apptainer &&
	now=$(date "+%Y/%m/%d-%H:%M:%S") &&
	echo "Starting analysis at ${now}" &&
	make besecall.with.guppy.gpu sample="$SAMPLE" run="$RUN" flow_cell="$FLOWCELL" kit="$KIT" run_dir="$FILE" &&
	now=$(date "+%Y/%m/%d-%H:%M:%S") &&
	echo "Ending analysis at ${now}"

exit
