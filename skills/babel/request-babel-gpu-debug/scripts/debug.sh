#!/usr/bin/env bash
#SBATCH --job-name=debug
#SBATCH --partition=ybisk
#SBATCH --qos=ybisk_qos
#SBATCH --account=ybisk
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00
#SBATCH --output=debug-%j.out

set -euo pipefail

echo "debug job is running on $(hostname)"
echo "Job ID: ${SLURM_JOB_ID}"
nvidia-smi --query-gpu=index,name,memory.total --format=csv,noheader
echo "Enter it from a login node with:"
echo "  srun --jobid=${SLURM_JOB_ID} --overlap --pty bash -l"

# Keep the allocation alive until its time limit or until it is cancelled.
while sleep 3600; do
    :
done
