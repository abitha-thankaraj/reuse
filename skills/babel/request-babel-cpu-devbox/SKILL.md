---
name: request-babel-cpu-devbox
description: Request, monitor, enter, verify, and stop a persistent CPU development box on the Babel Slurm cluster. Use when the user asks Codex to launch or manage a Babel CPU devbox, interactive CPU development node, long-lived shell allocation, or the recognizable Slurm job named "box".
---

# Request a Babel CPU Devbox

Use `scripts/box.sh` as the canonical submission script. Its defaults are one node, one task, 12 CPU cores, 24 GiB RAM, a two-day limit, and job name `box`.

## Cluster rules

- Submit CPU-only jobs to partition `preempt` with QoS `preempt_cpu_qos` and account `ybisk`. This route is preemptible, so tell the user the devbox may be requeued or interrupted by higher-priority work.
- Do not move a CPU-only request to `general`: Babel's `normal` QoS requires at least one GPU.
- Confirm the user's association and current partition policy when routing changes are suspected; do not assume a legacy `cpu` partition is still usable for CPU-only jobs.
- Treat job submission, mutation, and cancellation as external state changes. Perform the action when the user clearly asks for it; otherwise only inspect or validate.
- Do not reduce cores, memory, or time silently. Use different resources only when the user specifies them or approves an adaptive change.

## Launch and verify

1. Run a non-submitting validation when the script or requested resources have changed:

   ```bash
   bash -n scripts/box.sh
   sbatch --test-only scripts/box.sh
   ```

2. Submit from the directory where `box-%j.out` should be written. Capture the returned job ID:

   ```bash
   sbatch --parsable /absolute/path/to/scripts/box.sh
   ```

3. Monitor the exact job until it reaches `RUNNING` or a genuine blocker appears:

   ```bash
   squeue --jobs=JOB_ID --noheader --format='%i|%T|%R|%N|%M|%l|%C|%m'
   scontrol show job JOB_ID
   ```

   Slurm's pending reason about nodes being down, drained, or reserved can refer to projected higher-priority work rather than an explicit reservation. Check `scontrol show reservations`, the planned node, and its jobs before interpreting it.

4. Read the assigned node from `squeue`, then verify direct SSH. Use `accept-new` so a first connection records the host key while changed keys still fail:

   ```bash
   ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 NODE \
     'printf "host=%s\\nuser=%s\\n" "$(hostname)" "$(id -un)"; nproc'
   ```

5. Report the job ID, node, requested resources, SSH result, connection command, and cancellation command:

   ```bash
   ssh NODE
   srun --jobid=JOB_ID --overlap --pty bash -l
   scancel JOB_ID
   ```

## Resource overrides

Prefer `sbatch` command-line overrides for a one-off user-approved change so the canonical script remains stable:

```bash
sbatch --parsable --cpus-per-task=CORES --mem=MEMORY --time=TIME /absolute/path/to/scripts/box.sh
```

Use `sbatch --test-only` with the same overrides to compare scheduling predictions without creating jobs. Explain that predictions may change at the next scheduler cycle.

For an already-pending job, update memory in MiB because Babel's `scontrol` rejects a `G` suffix for `MinMemoryNode`:

```bash
scontrol update JobId=JOB_ID MinMemoryNode=24576
```

Only use that example for 24 GiB; calculate the correct MiB value for other approved memory sizes and verify `ReqTRES` afterward.
