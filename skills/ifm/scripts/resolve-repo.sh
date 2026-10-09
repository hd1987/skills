#!/usr/bin/env bash
# Usage: resolve-repo.sh [<repo>]
# Prints the absolute root of the target git repository. Without <repo>, prints
# the current repository root. <repo> is an exact directory name.
set -euo pipefail

repo="${1:-}"
current_top="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo" ]]; then
  if [[ -z "$current_top" ]]; then
    echo "not inside a git repository" >&2
    exit 1
  fi
  echo "$current_top"
  exit 0
fi

if [[ "$repo" == */* || "$repo" == .* ]]; then
  echo "repo must be a single directory name: $repo" >&2
  exit 1
fi

candidates=()
if [[ -n "$current_top" ]]; then
  if [[ "$(basename "$current_top")" == "$repo" ]]; then
    candidates+=("$current_top")
  fi
  candidates+=("$(dirname "$current_top")/$repo")
else
  # A workspace opened at the parent of several repositories is not a repo.
  candidates+=("$PWD/$repo")
fi
if [[ -n "${MASHI_REPORTS_ROOT:-}" ]]; then
  candidates+=("${MASHI_REPORTS_ROOT%/}/$repo")
fi

# The basename check rejects plain directories nested inside another repository.
for candidate in "${candidates[@]}"; do
  if top="$(git -C "$candidate" rev-parse --show-toplevel 2>/dev/null)" \
    && [[ "$(basename "$top")" == "$repo" ]]; then
    echo "$top"
    exit 0
  fi
done

echo "repository '$repo' not found; checked: ${candidates[*]}" >&2
exit 1
