---
name: create-private-fork
description: Create a private Git repository mirror from a public or upstream repository, clone the private copy locally, and configure the original repository as a fetch-only upstream remote. Use when the user asks to create a private fork, private mirror, or private working copy from two Git repository URLs.
---

# Create Private Fork

Use the bundled `scripts/create-private-fork.sh`. Keep the workflow limited to two required values:

1. Base repository URL.
2. Existing private destination repository URL.

Treat the destination repository as new or disposable. `git push --mirror` replaces its refs and deletes refs absent from the base repository. If the user has not confirmed this is acceptable, stop and ask before running the script.

Before execution, show the user:

1. The complete contents of `scripts/create-private-fork.sh`.
2. The base and private repository URLs.
3. The directory where the private repository will be cloned.

Run the script from the directory that should contain the private clone:

```bash
bash <skill-directory>/scripts/create-private-fork.sh <base-repo-url> <private-repo-url>
```

Do not rewrite or inline the script. Request approval if repository access or network access requires it.

After execution, run `git remote -v` inside the clone. Report the clone path and verify that `origin` fetches and pushes to the private repository while `upstream` fetches from the base repository and has push disabled.
