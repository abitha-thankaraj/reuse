---
name: launch-babel-experiments
description: Create, adapt, validate, and launch readable Slurm experiment jobs, parameter sweeps, and interactive GPU debug sessions on the Babel cluster across Conda, uv, virtualenv, plain Python, and project-specific runtimes. Use when Codex needs to write or improve Babel sbatch wrappers, schedule training or evaluation runs, request an interactive allocation, build Cartesian-product sweeps, chain dependent jobs, create job manifests, or turn an experiment command into reusable project-local shell scripts.
---

# Launch Babel Experiments

Build project-local Slurm scripts that keep cluster setup separate from experiment configuration. Prefer a thin job wrapper plus a readable launcher over a single metaprogrammed script.

## Inspect before editing

1. Read the target Python or shell entry point and its CLI flags.
2. Find nearby Slurm scripts and project conventions with `rg` or `rg --files`.
3. Identify the project root, runtime command, log/checkpoint paths, resource needs, and whether evaluation depends on training artifacts.
4. Read [references/babel-slurm.md](references/babel-slurm.md) when choosing partitions or QoS, requesting an interactive session, structuring dependencies or sweeps, or validating a request.

Do not silently invent environment names, checkpoint prerequisites, entry points, or unusually large resources. Infer them from the repository when possible; ask only when a material choice cannot be discovered safely.

If the requested project or entry point does not exist yet, create a clearly marked scaffold only when that is useful to the user. Leave `CHANGE_ME` markers for unknown CLI contracts, make preflight fail closed, and state that the scripts are syntax-validated but not launch-ready. If the user requested immediately runnable or submitted jobs, stop for the missing contract instead of guessing flags.

## Choose the script shape

Use one or more thin job wrappers and one launcher:

```text
submit_babel.sh      # Slurm resources + environment + `python ... "$@"`
eval_babel.sh        # optional evaluation wrapper
launch_sweep.sh      # experiment grid + paths + validation + submissions
```

Start from the files in `assets/` when creating new scripts:

- Copy `assets/job_babel_conda.sh`, `assets/job_babel_uv.sh`, or `assets/job_babel_python.sh` according to the project's existing runtime. Use the same template again for evaluation when it needs different resources or an entry point.
- Copy `assets/launch_sweep.sh` for a train-then-evaluate Cartesian sweep.

Replace every `CHANGE_ME` marker and remove unused options. Preserve the visible configuration block at the top; readability is a feature.

Prefer an ordinary launcher loop when runs need descriptive IDs, separate checkpoint paths, dependent evaluations, or a line-per-run manifest. Consider a Slurm array only for a large homogeneous grid whose index mapping remains easy to inspect.

## Author job wrappers

- Put static scheduler settings in `#SBATCH` directives and application flags after the wrapper boundary.
- Use absolute paths in `#SBATCH --output`, `--error`, and `--chdir`; Slurm does not perform normal shell-variable expansion in directive values.
- Forward application arguments exactly with `"$@"`.
- Run Python unbuffered with `python -u` so logs arrive promptly.
- Prefer a direct, reproducible runtime command: `uv run --frozen`, an absolute virtual-environment Python path, or the repository's established equivalent.
- For Conda, use `set -eo pipefail` before sourcing its initialization script, then enable `set -u` after activation. Conda activation scripts can legitimately reference unset variables.
- Do not add Conda, uv, modules, containers, or another environment layer when the repository already has a working runtime convention.
- Create log directories in the launcher before calling `sbatch`; Slurm must be able to open output paths when the job starts.
- Keep machine exclusions and unusual QoS values out of generic defaults. Add them only when current Babel/project evidence requires them.

## Author sweep launchers

Keep the launcher in this order:

1. Strict shell mode.
2. Absolute project and script paths.
3. Sweep arrays and shared scalar settings.
4. Output-directory creation and prerequisite checks.
5. Timestamped manifest creation.
6. Clearly nested loops with deterministic run IDs.
7. `sbatch --parsable` submission and job-ID extraction.
8. Optional evaluation submission with `--dependency=afterok:JOB_ID`.
9. One manifest row per run, including explicit sweep coordinates, and a computed final count.

Quote every path and substituted value. Make run IDs filesystem-safe and encode only variables useful for identifying a run. Do not duplicate sweep logic in the job wrapper.

Use `afterok` when a downstream job must consume a successful upstream artifact. Record both job IDs and the expected artifact path so a user can audit or resume the sweep.

## Validate and launch safely

Always validate edits without submitting:

```bash
bash -n submit_babel.sh eval_babel.sh launch_sweep.sh
rg -n 'CHANGE_ME|TODO' submit_babel.sh eval_babel.sh launch_sweep.sh
```

When connected to Babel and the configured paths exist, also validate wrappers with `sbatch --test-only`. Do not submit jobs merely because the user asked to create scripts.

When the user explicitly requests submission:

1. Run the non-submitting checks first.
2. State the grid size and number of downstream jobs.
3. Launch the sweep once.
4. Report the manifest path, submitted job IDs or range, and useful monitoring/cancellation commands.

Treat `sbatch`, `srun`, `salloc`, `scancel`, and `scontrol update` as external state changes. Never resubmit automatically after an ambiguous client-side failure; inspect the queue and manifest first.
