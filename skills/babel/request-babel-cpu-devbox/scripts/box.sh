#!/usr/bin/env bash
#SBATCH --job-name=box
# CPU-only devboxes use Babel's preemptible CPU route.
#SBATCH --partition=preempt
#SBATCH --qos=preempt_cpu_qos
#SBATCH --account=ybisk
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=24G
#SBATCH --time=2-00:00:00
#SBATCH --output=box-%j.out

set -euo pipefail

echo "box is running on $(hostname)"
echo "Job ID: ${SLURM_JOB_ID}"
echo "Enter it from a login node with:"
echo "  srun --jobid=${SLURM_JOB_ID} --overlap --pty bash -l"

# Keep the allocation alive until its time limit or until it is cancelled.
while sleep 3600; do
    :
done
