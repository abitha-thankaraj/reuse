# Babel Slurm Reference

## Resource routing

- GPU jobs commonly use `--partition=general` with an explicit GPU request such as `--gres=gpu:1`.
- For a user associated with the `ybisk` account, the lab route does not replace ordinary cluster access. When the live association includes `normal` and `general` allows it, ordinary GPU jobs may still use `--partition=general --qos=normal --account=ybisk`; use `ybisk`/`ybisk_qos` only when the user wants that lab-specific route.
- Do not assume legacy `debug` or `cpu` partitions still exist. Query live Slurm configuration before recommending either interactive or CPU-only routing.
- A QoS appearing in `sacctmgr show qos` does not mean the user may select it. Confirm both the user's association and the partition's `AllowQos` value. For example, `debug_qos` may exist even when it is unavailable to the user or disallowed by every suitable partition.
- Babel's normal QoS on `general` requires a GPU. Determine current CPU-only routing from the live partitions and the user's allowed QoS rather than relying on a fixed `cpu` partition.
- Derive CPU, memory, GPU count, and wall time from the workload or nearby successful scripts. Avoid copying oversized resources without evidence.
- Treat node exclusions as temporary operational knowledge. Preserve an existing exclusion only when it is still intentional; do not introduce one as boilerplate.

Check current cluster state or accepted directives when uncertain:

```bash
sinfo -o '%P|%a|%l|%D|%G|%m|%C'
scontrol show partition
sacctmgr show assoc where user="$USER" \
  format=Cluster,Account,User,Partition,QOS,DefaultQOS -P
```

## Interactive GPU debugging

When the user's association includes `ybisk_qos` and the `ybisk` partition allows it, this is the validated shape for a small one-GPU debug shell:

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

Do not generalize this lab-specific route to users whose associations differ. Validate the resource request without submitting by using the same scheduler options with a harmless batch wrapper:

```bash
sbatch --test-only \
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
  --wrap='nvidia-smi'
```

Inspect the target node's `AllocTRES` and jobs when start time matters. A high-priority lab QoS can be valid even if all GPUs appear allocated because Slurm may preempt jobs from the `preempt` partition; rely on `--test-only` output rather than promising immediate start.

An interactive `srun` must remain attached to the invoking terminal. If the user asks only for the command, provide the validated direct `srun` command above.

If the user explicitly asks Codex to launch an allocation that they will enter later, submit one attachable holding job rather than leaving an inaccessible `srun` process owned by Codex:

```bash
sbatch --parsable \
  --partition=ybisk \
  --qos=ybisk_qos \
  --account=ybisk \
  --nodes=1 \
  --ntasks=1 \
  --cpus-per-task=4 \
  --mem=32G \
  --gres=gpu:1 \
  --time=02:00:00 \
  --job-name=debug-2h \
  --output=/dev/null \
  --error=/dev/null \
  --wrap='sleep infinity'
```

Keep the requested wall time authoritative; two hours above is only an example. Run `sbatch --test-only` with the same scheduler options first, submit exactly once, record the returned job ID, and inspect it until it is running or a concrete pending reason is known. A pending job is not a failed submission and must not be resubmitted automatically.

Once it is running, verify that a step can enter the allocation and see the GPU:

```bash
srun --jobid=JOB_ID --overlap \
  nvidia-smi --query-gpu=index,name,memory.total --format=csv,noheader
```

Give the user this command to enter the allocation from a Babel login shell:

```bash
srun --jobid=JOB_ID --overlap --pty bash -l
```

`--overlap` is required here because the holding batch step remains active. Report the job ID, state, assigned node and end time, plus `scancel JOB_ID` for early release. Do not cancel the holding job unless the user asks or its requested time limit expires.

## Wrapper boundary

Keep scheduler/environment concerns in a stable wrapper:

```bash
python -u -m package.module "$@"
```

This lets launchers, one-off runs, and resumed experiments share the same resources and activation logic while supplying different application flags.

`#SBATCH` lines are parsed by Slurm before the shell runs. Do not expect `$ROOT`, `~`, command substitution, or shell parameter expansion to work inside them. Write literal absolute paths or pass a one-off override to `sbatch`.

## Runtime selection and strict shell mode

Match the repository instead of imposing an environment manager. Prefer these patterns in order when the project supports them:

### uv

Use the checked-in lockfile for reproducible jobs:

```bash
set -euo pipefail
/absolute/path/to/uv run --frozen python -u -m package.module "$@"
```

Confirm how `uv` is installed on compute nodes. An absolute executable path is more reliable than assuming a non-login batch shell has the same `PATH` as an interactive shell. Omit `--frozen` only when the project intentionally runs without a lockfile or permits lock updates.

### Virtual environment or plain Python

Invoke the interpreter directly when possible; activation is unnecessary:

```bash
set -euo pipefail
/absolute/path/to/.venv/bin/python -u -m package.module "$@"
```

The same pattern covers a system Python or another managed interpreter by changing the absolute executable path.

### Conda

Use this order for Conda-based wrappers:

```bash
set -eo pipefail
source /absolute/path/to/conda.sh
conda activate ENV_NAME
set -u
```

Enabling nounset before activation can break environment initialization. Launchers that do not activate Conda should use `set -euo pipefail` immediately.

### Modules, containers, and project-specific runtimes

Reuse nearby successful batch scripts. Keep setup commands literal and visible in the wrapper, then finish with one clear application command. For example, a project may use `module load`, `apptainer exec`, or a repository launcher. Do not wrap these in a generic runtime dispatcher unless the project already uses one; explicit wrappers are easier to audit from logs and source control.

## Sweep strategies

Use explicit nested loops when:

- the grid has a modest number of dimensions;
- readable run names matter;
- each training job has its own dependent evaluation;
- each run writes a distinct checkpoint; or
- the manifest is the primary operational record.

Use a Slurm array when the jobs are highly homogeneous and the index-to-configuration mapping can be kept in a simple manifest. Generate the manifest before submission, and have each array task read exactly one row using `SLURM_ARRAY_TASK_ID`. Do not hide a multidimensional mapping in dense shell arithmetic merely to use an array.

Compute the Cartesian job count rather than hard-coding it:

```bash
n_train=$(( ${#SAFE_REWARDS[@]} * ${#ETAS[@]} * ${#SEEDS[@]} ))
```

## Dependencies and manifests

Submit parseable job IDs:

```bash
submission=$(sbatch --parsable "$TRAIN_SCRIPT" --seed "$seed")
train_job_id=${submission%%;*}
```

The suffix removal handles clusters that return `job_id;cluster_name`.

For evaluation that requires a successful checkpoint:

```bash
eval_submission=$(sbatch --parsable \
    --dependency="afterok:${train_job_id}" \
    "$EVAL_SCRIPT" --ckpt "$ckpt_path")
eval_job_id=${eval_submission%%;*}
```

Use a timestamped TSV manifest with stable columns such as:

```text
run_id  train_job_id  eval_job_id  checkpoint
```

Append a row immediately after both submissions. If there is no downstream job, omit that column rather than filling the script with dummy concepts.

## Validation and operations

Validate shell syntax locally:

```bash
bash -n submit_babel.sh eval_babel.sh launch_sweep.sh
```

Ask Slurm to validate a wrapper without submitting when the referenced directories exist:

```bash
sbatch --test-only submit_babel.sh
```

Useful read-only monitoring commands:

```bash
squeue --jobs=JOB_ID --format='%.18i %.12j %.2t %.10M %.6D %R'
scontrol show job JOB_ID
sacct -j JOB_ID --format=JobID,JobName,State,Elapsed,ExitCode
```

Cancellation is destructive external state and must match the user's requested scope:

```bash
scancel JOB_ID
```
