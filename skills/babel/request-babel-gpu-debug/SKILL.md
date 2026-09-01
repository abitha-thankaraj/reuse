---
name: request-babel-gpu-debug
description: Request, monitor, enter, verify, and stop a one-GPU interactive debug allocation on the Babel Slurm cluster using the ybisk lab route. Use when the user asks for a Babel GPU debug node, debug shell, short interactive GPU job, or a single-GPU allocation on ybisk_qos. Use launch-babel-experiments instead for training, sweeps, multi-GPU jobs, or non-ybisk routing.
---

# Request a Babel GPU Debug Job

Use `scripts/debug.sh` as the canonical attachable job. Its defaults are one node, one task, one GPU, 4 CPU cores, 32 GiB RAM, a one-hour limit, and job name `debug`.

## Cluster rules

- Use partition `ybisk`, QoS `ybisk_qos`, and account `ybisk`.
- Confirm that the user's association includes `ybisk_qos` and that the partition allows it when cluster routing may have changed. Do not substitute a legacy `debug` partition or `debug_qos` merely because those names exist.
- Keep this skill limited to one GPU. Route multi-GPU, training, evaluation, and sweep requests to a general experiment workflow.
- Treat `sbatch`, `srun`, `scancel`, and job mutations as external state changes. Submit or cancel only when the user clearly requests it.
- Never resubmit after an ambiguous client-side failure. Inspect the queue for the captured job ID or an existing matching job first.

## Give the direct interactive command

When the user asks only for a command they will run in their own Babel login terminal, provide this attached `srun` command rather than submitting a holding job:

```bash
srun \
  --partition=ybisk \
  --qos=ybisk_qos \
  --account=ybisk \
  --nodes=1 \
  --ntasks=1 \
  --cpus-per-task=4 \
  --mem=32G \
  --gres=gpu:1 \
  --time=01:00:00 \
  --job-name=debug \
  --pty bash -l
```

An interactive `srun` must remain attached to the user's terminal. Do not launch this form from a detached Codex process.

## Launch and verify an attachable job

When the user explicitly asks Codex to launch the allocation:

1. Validate without submitting:

   ```bash
   bash -n scripts/debug.sh
   sbatch --test-only scripts/debug.sh
   ```

2. Submit exactly once from the directory where `debug-%j.out` should be written and capture the job ID:

   ```bash
   sbatch --parsable /absolute/path/to/scripts/debug.sh
   ```

3. Monitor that exact job until it is running or a concrete pending reason is known:

   ```bash
   squeue --jobs=JOB_ID --noheader --format='%i|%T|%R|%N|%M|%l|%C|%m|%e'
   scontrol show job JOB_ID
   ```

   A valid `ybisk_qos` request may preempt lower-priority work on the node. Treat a pending job as pending, not as a failed submission, and do not promise an immediate start based only on apparent GPU occupancy.

4. Once running, verify the allocated step can see exactly one GPU:

   ```bash
   srun --jobid=JOB_ID --overlap \
     nvidia-smi --query-gpu=index,name,memory.total --format=csv,noheader
   ```

5. Report the job ID, node, start and end times, resources, log path, verification result, entry command, and early-release command:

   ```bash
   srun --jobid=JOB_ID --overlap --pty bash -l
   scancel JOB_ID
   ```

`--overlap` is required because the holding batch step remains active inside the allocation. Do not cancel the job unless the user asks or its time limit expires.

## Resource overrides

Keep the canonical one-GPU route stable. For a user-requested change to CPU, memory, or wall time, validate and submit with matching command-line overrides:

```bash
sbatch --test-only --cpus-per-task=CORES --mem=MEMORY --time=TIME scripts/debug.sh
sbatch --parsable --cpus-per-task=CORES --mem=MEMORY --time=TIME /absolute/path/to/scripts/debug.sh
```

Do not silently increase the GPU count or change the partition, QoS, or account.
