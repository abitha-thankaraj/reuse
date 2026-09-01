#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 BASE_REPO_URL PRIVATE_REPO_URL" >&2
    exit 1
fi

base_repo_url=$1
private_repo_url=$2
private_repo_name=$(basename "$private_repo_url" .git)
mirror_dir=$(mktemp -d)
trap 'rm -rf "$mirror_dir"' EXIT

git clone --mirror "$base_repo_url" "$mirror_dir/repo.git"
git -C "$mirror_dir/repo.git" push --mirror "$private_repo_url"
git clone "$private_repo_url" "$private_repo_name"
git -C "$private_repo_name" remote add upstream "$base_repo_url"
git -C "$private_repo_name" remote set-url --push upstream DISABLE

git -C "$private_repo_name" remote -v
