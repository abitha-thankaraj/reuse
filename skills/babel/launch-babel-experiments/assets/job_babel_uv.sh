#!/usr/bin/env bash
#SBATCH --job-name=CHANGE_ME-job
#SBATCH --time=12:00:00
#SBATCH --output=/CHANGE_ME_PROJECT_ROOT/logs/job_%j.out
#SBATCH --error=/CHANGE_ME_PROJECT_ROOT/logs/job_%j.err
#SBATCH --partition=general
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --chdir=/CHANGE_ME_PROJECT_ROOT

set -euo pipefail

UV_BIN=/CHANGE_ME_ABSOLUTE_PATH_TO_UV

export WANDB_ENTITY="${WANDB_ENTITY:-CHANGE_ME_ENTITY}"
export WANDB_PROJECT="${WANDB_PROJECT:-CHANGE_ME_PROJECT}"

"$UV_BIN" run --frozen python -u -m CHANGE_ME_PACKAGE.module "$@"
