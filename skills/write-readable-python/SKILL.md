---
name: write-readable-python
description: Refactor existing Python code for exceptional readability, educational value, and reproducibility after its behavior is understood. Use when the user explicitly asks to refactor, clean up, reorganize, simplify, improve names, make code educational, or clarify Python libraries, prototypes, research code, ML and data pipelines, and training or evaluation systems. Favor obvious names, focused modules, explicit control flow, useful why-comments, minimal indirection, and verified behavior. When explicitly invoked during development, allow an exploration phase before cleanup. Always use OmegaConf rather than argparse for project-owned configuration and commit a small set of purpose-named YAML examples.
---

# Write Readable Python

Make the code read like a carefully edited explanation of the system. Preserve
correctness and rigor while minimizing the effort required to understand the
main path.

Treat this primarily as a behavior-preserving refactoring skill. Do not impose a
full structural cleanup on unrelated feature work unless the user invokes this
skill or explicitly asks for a readability refactor.

## Invocation boundary

- Never invoke this skill implicitly.
- At a natural checkpoint where working Python code is visibly rough, offer a
  cleanup and refactor once.
- Do not begin the refactor until the user confirms.
- Do not repeatedly recommend the skill or create a cleanup loop. If the user
  declines, continues feature work, or prefers to refactor personally, leave
  the code as-is unless asked later.

## Work in two phases

### Explore until the result is understood

Tolerate temporary local mess and avoid premature architecture. During active
discovery:

- Keep experiments direct and close to the question being answered.
- Allow temporary duplication or rough organization when it makes iteration
  faster and the correct concepts are not known yet.
- Do not create base classes, factories, registries, generic helpers, or a deep
  package structure for patterns that may disappear after the next experiment.
- Use the shortest realistic execution path to test the hypothesis.
- Keep temporary outputs, debug artifacts, and local configurations ignored by
  Git.
- Still use clear names for important domain concepts, explicit control flow,
  and loud failures; those habits make experiments easier to debug.

Exploration is not the final public surface. Do not mistake a working prototype
for a finished implementation.

### Consolidate after the behavior works

Once the result and important concepts are understood:

1. Capture the working behavior with a realistic command, test, artifact, hash,
   or metric before moving code.
2. Refactor in small behavior-preserving steps.
3. Rename concepts in domain language and remove disposable intermediates.
4. Split code only at responsibilities that are now demonstrably distinct.
5. Remove dead branches, debug paths, temporary files, duplicated entry points,
   and speculative compatibility code.
6. Move stable behavior-changing settings into OmegaConf YAML configurations.
7. Rerun the realistic path after each meaningful structural change.

Apply inexpensive readability habits throughout development, but schedule the
full structural pass at natural checkpoints. Do not interrupt a useful
experiment merely to perfect abstractions that are still changing.

## Start from the reader's mental model

1. Identify the domain concepts, inputs, outputs, invariants, and main execution
   sequence before choosing files or abstractions.
2. Inspect existing behavior and compatibility constraints before refactoring.
3. Design the smallest structure in which a reader can predict where each
   responsibility lives.
4. Keep the happy path visible from the entry point. A reader should not need to
   traverse several generic wrappers to understand one operation.

Prefer a few focused modules over either a monolith or a deep architecture. A
typical computational project might separate data loading and validation,
domain math, model definitions, runtime concerns, training, sampling,
evaluation, and visualization. Adapt those boundaries to the domain; do not
copy a directory tree mechanically.

## Name things so comments are rarely needed

- Use domain language and complete words. Prefer `target_covariance` over
  `tgt_cov`, and `validation_paths` over `val_stuff`.
- Avoid one-letter, throwaway, and generic temporary names such as `x`, `tmp`,
  `obj`, `res`, or `value` outside tiny mathematical scopes where the notation
  is conventional.
- Do not introduce a variable merely to use it once on the next line. Inline a
  short, obvious expression. Keep a one-use variable only when its domain name
  explains a non-obvious concept, breaks up a genuinely complex expression, or
  materially improves debugging.
- Name modules after one recognizable responsibility: `data`, `model`,
  `diffusion`, `evaluation`, or an equally clear domain concept.
- Make functions describe their result or action: `validate_dataset`,
  `project_moments`, `render_trajectory`.
- Name booleans as predicates or decisions: `refresh_sources`, `is_valid`,
  `should_project`.
- Include units or representation when ambiguity matters.
- Avoid vague containers such as `utils`, `helpers`, `manager`, `processor`,
  `misc`, or `common` unless the contents genuinely share that role.
- Rename unclear existing symbols when compatibility permits. If public
  compatibility matters, keep a small explicit alias rather than spreading the
  old name through new code.

Use the import line as a naming test: a new reader should be able to infer why a
dependency is present from its package, module, and symbol names.

## Keep implementation explicit

- Write important algorithms and lifecycle steps directly. Do not hide a
  training step, state transition, equation, or acceptance rule behind a
  generic framework wrapper merely to reduce line count.
- Extract a function or type when it creates a meaningful concept, isolates an
  invariant, removes substantial duplication, or makes the main flow easier to
  scan.
- Prefer pure functions for transformations and calculations. Keep filesystem,
  network, device, serialization, and plotting effects at clear boundaries.
- Keep data shapes, randomness, precision, and device movement explicit where
  they affect correctness.
- Use lightweight typed structures such as dataclasses for stable domain
  configuration. Avoid inheritance hierarchies and registries without a real
  extension need.
- Choose ordinary Python over metaprogramming, clever comprehensions, and
  premature generalization.

Educational code must still be production-honest: validate assumptions, reject
bad inputs, preserve numerical contracts, and report failures precisely.

## Fail loudly and trust established contracts

Validate external data and configuration once at the boundary, then write the
internal code against that established contract. Do not scatter speculative
guards throughout the implementation.

- Do not catch broad exceptions, suppress errors, log-and-continue, or return a
  placeholder after failure.
- Do not silently skip malformed records or partially write a result that looks
  successful.
- Do not use `.get`, `getattr`, or fallback defaults for required fields. Access
  them directly so missing data fails at its source.
- Do not accept several historical input shapes, aliases, or guessed encodings
  unless the public contract explicitly requires compatibility.
- Do not add optional-import fallbacks for required dependencies.
- Do not automatically repair, clamp, coerce, or substitute questionable input
  unless that behavior is an explicit domain rule.
- Catch an exception only when adding essential domain context, performing
  required cleanup, or implementing a documented recovery path. Preserve the
  cause with `raise ... from exc`.
- Raise a precise `ValueError`, `TypeError`, or domain exception at an actual
  user/input boundary. Let programmer errors and violated internal assumptions
  surface immediately.

Prefer one decisive validation pass over defensive programming everywhere. A
failure should be unmistakable, close to its cause, and impossible to confuse
with a successful run.

## Comment decisions, invariants, and equations

- Explain why a non-obvious operation is required, what invariant it protects,
  or why an alternative would be incorrect.
- Place equations and representation explanations beside the code that
  implements them.
- Explain architectural omissions when they are meaningful, such as why a
  point-set model intentionally has no positional index embedding.
- Do not narrate syntax or restate a clear function name.
- Use module docstrings to state a module's responsibility or mathematical
  contract, not its history.
- Delete stale comments during refactors.

## Configure with OmegaConf and committed YAML

Treat this as a firm convention for project-owned Python entry points:

- Do not introduce `argparse`.
- Load configuration with OmegaConf from a YAML file.
- Accept optional OmegaConf dot-list overrides for reproducible small changes.
- Keep one resolved configuration as the source of truth; do not mirror options
  across CLI flags, constants, and YAML.
- Group related settings into meaningful sections such as `data`, `model`,
  `training`, `sampling`, or domain equivalents.
- Record the resolved configuration or the config path and overrides in run
  artifacts when reproducibility matters.
- Validate required keys and semantic constraints near startup, with errors that
  name the bad field and expected contract.

A simple entry-point convention is:

```text
python -m package.operation configs/train/baseline.yaml training.steps=1000
```

Reading `sys.argv[1]` as the YAML path and passing the remaining arguments to
`OmegaConf.from_dotlist` is sufficient; do not recreate an argument parser
around it.

Commit only configurations that are useful, runnable examples for another
person:

- Name them by purpose, such as `baseline.yaml`, `five_classes.yaml`, or
  `eight_per_class.yaml`.
- Organize them under a small `configs/` hierarchy when multiple workflows
  exist.
- Avoid names such as `config1.yaml`, `test.yaml`, `tmp.yaml`, and `smoke.yaml`.
- Use temporary overrides for local checks rather than committing throwaway
  configurations.
- Keep enough explicit values in each committed YAML to reproduce its result.

If the repository already uses another configuration system, preserve it only
when migration is outside the requested scope or would break a public contract.
Never add a second competing configuration path.

## Make project boundaries obvious

When a feature is meaningfully separate, give it a self-contained project or
package boundary with its own clear imports, dependency declaration, config
folder, and documentation. Do not leak incidental filesystem namespaces into
application imports.

Prefer a small `pyproject.toml` and lockfile when the repository uses uv. Reuse
an existing environment when requested; do not create or copy large
environments unnecessarily.

Keep generated datasets, checkpoints, diagnostics, manifests, and local smoke
artifacts out of Git unless they are deliberately curated examples. Commit the
smallest artifacts that materially help a reader understand or run the project.

## Verify behavior, not just syntax

After implementation or refactoring:

1. Compile or import every changed module and resolve every committed YAML.
2. Run focused validation for domain invariants and malformed inputs.
3. Exercise the shortest realistic end-to-end path through data, computation,
   serialization, and visualization or evaluation.
4. Check that generated artifacts can be read back and satisfy their contracts.
5. Preserve checkpoint, file-format, API, or CLI compatibility when promised;
   compare outputs directly when deterministic behavior is expected.
6. Run the repository's relevant tests, formatters, and linters.

Use temporary directories and config overrides for fast integration checks.
Do not confuse a one-step or tiny-model execution test with evidence of model
quality; report those conclusions separately.

## Write documentation around outcomes

Lead with what the project produces and show a compelling real example early.
Then document, in order:

1. environment setup;
2. the smallest runnable configuration;
3. data preparation or inputs;
4. the main operation or training command;
5. sampling, evaluation, or visualization;
6. reproducibility and important invariants.

Use commands that can be copied exactly. Clearly distinguish literal example
filenames from placeholders. Keep the public surface small and omit abandoned,
duplicate, or development-only entry points.

## Final readability pass

Before handing off, ask:

- Can a new reader state the system's main flow after reading one entry point?
- Does every file have one obvious reason to exist?
- Are names more informative than the comments around them?
- Do comments explain why rather than what?
- Is important logic explicit without being duplicated?
- Are configuration and randomness reproducible?
- Are the committed YAMLs purposeful and runnable?
- Are temporary files and generated reports excluded from Git?
- Did the realistic end-to-end path actually run?

Simplify again wherever the answer is no.
