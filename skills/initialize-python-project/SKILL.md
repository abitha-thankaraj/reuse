---
name: initialize-python-project
description: Initialize a new Python, research, or data-science project from abitha-thankaraj/python-cookiecutter. Use when the user asks to start, bootstrap, scaffold, or initialize a project from their standard template. Ask whether to create a uv environment, require OmegaConf instead of argparse, and apply simple fail-fast Python design conventions.
---

# Initialize Python Project

Create the smallest useful project from the user's standard Cookiecutter. Preserve the template and add only what the user requests or this skill requires.

## Workflow

1. Ask: "Do you want me to set up a uv environment after creating the project?"
2. Use the requested destination directory, or the current directory when none is given. Run the generator from the destination's parent directory.
3. Run this command in an interactive terminal so the user can answer the template prompts:

   ```bash
   uvx cookiecutter gh:abitha-thankaraj/python-cookiecutter
   ```

   Do not pass Cookiecutter overrides unless the user explicitly supplies them.
4. Use the accepted `repo_name` as the generated project directory. Assert that directory and its `pyproject.toml` exist. Never overwrite an existing project.
5. Add OmegaConf as a project dependency:

   - If the user chose a uv environment, run `uv add omegaconf` from the project root. This creates `.venv`, updates the project metadata and lockfile, and installs the project.
   - If the user declined a uv environment, add `"omegaconf"` to `[project].dependencies` in `pyproject.toml`. Do not create `.venv` or `uv.lock`.

6. If uv was selected, verify the environment with:

   ```bash
   uv run python -c "from omegaconf import OmegaConf; print(OmegaConf.__name__)"
   ```

7. Report the generated path, whether `.venv` was created, and that OmegaConf is a dependency. Do not initialize other tools, publish the repository, or add unrelated boilerplate unless requested.

## Python Conventions

- Use OmegaConf for every application configuration surface. Never use `argparse`.
- Keep configuration in YAML. Mark required values with `???`; do not invent fallback values.
- For command-line overrides, merge `OmegaConf.from_cli()` into the loaded configuration. Enable struct mode before merging so unknown keys fail.
- Resolve and validate configuration at startup with `OmegaConf.to_container(config, resolve=True, throw_on_missing=True)`. Do not catch configuration errors.
- Fail loudly and early. Use direct access and assertions for required loaded data. Do not use broad `try`/`except`, silent recovery, default values, or optional parameters for required inputs.
- Keep state narrow. Use required arguments and discriminated unions for genuine variants. Handle every variant explicitly and fail on unknown variants.
- Prefer early returns and straightforward control flow.
- Create modules only at clear domain boundaries. Do not add factories, wrapper layers, base classes, generic helpers, or extension points without a current concrete need.
- Extract shared code only after real reuse exists. Keep functions short, explicit, and independently useful.
- Put behavior-changing values in configuration and keep business logic in Python.
- Implement only the requested behavior and bias toward fewer readable lines.

Use this loading pattern when a project needs an entry point:

```python
from omegaconf import OmegaConf

config = OmegaConf.load("configs/config.yaml")
OmegaConf.set_struct(config, True)
config = OmegaConf.merge(config, OmegaConf.from_cli())
OmegaConf.to_container(config, resolve=True, throw_on_missing=True)
```
