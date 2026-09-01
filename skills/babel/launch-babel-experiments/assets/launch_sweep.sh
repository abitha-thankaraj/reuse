#!/usr/bin/env bash

set -euo pipefail

ROOT=/CHANGE_ME_PROJECT_ROOT
TRAIN_SCRIPT="$ROOT/CHANGE_ME_SCRIPT_DIR/submit_babel.sh"
EVAL_SCRIPT="$ROOT/CHANGE_ME_SCRIPT_DIR/eval_babel.sh"
PRETRAIN="$ROOT/CHANGE_ME_CHECKPOINT.pt"
CKPT_DIR="$ROOT/checkpoints/CHANGE_ME_EXPERIMENT"
EVAL_DIR="$ROOT/logs/CHANGE_ME_EXPERIMENT/eval_results"
LOG_DIR="$ROOT/logs/CHANGE_ME_EXPERIMENT"

PARAM_A_VALUES=(0.10 0.20)
PARAM_B_VALUES=(0.5 1.0)
SEEDS=(0 1 2)

LEARNING_RATE=1e-4
N_STEPS=5000
WANDB_GROUP=CHANGE_ME_GROUP

mkdir -p "$CKPT_DIR" "$EVAL_DIR" "$LOG_DIR"

for required_file in "$TRAIN_SCRIPT" "$EVAL_SCRIPT" "$PRETRAIN"; do
    if [[ ! -r "$required_file" ]]; then
        echo "Missing required file: $required_file" >&2
        exit 1
    fi
done

manifest="$LOG_DIR/sweep_jobs_$(date +%Y%m%d_%H%M%S).tsv"
printf 'run_id\tparam_a\tparam_b\tseed\ttrain_job_id\teval_job_id\tcheckpoint\n' > "$manifest"

n_train=0
n_eval=0
n_planned=$(( ${#PARAM_A_VALUES[@]} * ${#PARAM_B_VALUES[@]} * ${#SEEDS[@]} ))

echo "Submitting $n_planned training jobs and $n_planned dependent evaluation jobs."

for param_a in "${PARAM_A_VALUES[@]}"; do
    for param_b in "${PARAM_B_VALUES[@]}"; do
        for seed in "${SEEDS[@]}"; do
            param_a_tag=${param_a/./p}
            param_b_tag=${param_b/./p}
            run_id="CHANGE_ME_a${param_a_tag}_b${param_b_tag}_seed${seed}"
            ckpt_path="$CKPT_DIR/${run_id}.pt"

            train_submission=$(sbatch --parsable "$TRAIN_SCRIPT" \
                --param-a "$param_a" \
                --param-b "$param_b" \
                --learning-rate "$LEARNING_RATE" \
                --n-steps "$N_STEPS" \
                --seed "$seed" \
                --pretrain-path "$PRETRAIN" \
                --checkpoint-path "$ckpt_path" \
                --wandb-group "$WANDB_GROUP" \
                --wandb-run-name "$run_id")
            train_job_id=${train_submission%%;*}
            n_train=$((n_train + 1))

            eval_submission=$(sbatch --parsable \
                --dependency="afterok:${train_job_id}" \
                "$EVAL_SCRIPT" \
                --checkpoint "$ckpt_path" \
                --out-dir "$EVAL_DIR")
            eval_job_id=${eval_submission%%;*}
            n_eval=$((n_eval + 1))

            printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                "$run_id" "$param_a" "$param_b" "$seed" \
                "$train_job_id" "$eval_job_id" "$ckpt_path" \
                | tee -a "$manifest"
        done
    done
done

echo "Submitted $n_train training jobs and $n_eval dependent evaluation jobs."
echo "Manifest: $manifest"
