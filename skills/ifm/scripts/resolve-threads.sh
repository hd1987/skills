#!/usr/bin/env bash
# Usage: resolve-threads.sh <thread-id>...
# Resolves each review thread and prints "<id> true" on success or
# "<id> <error>" on failure. Exits 1 if any thread was not resolved.
set -uo pipefail

if [[ $# -eq 0 ]]; then
  echo "at least one thread id required" >&2
  exit 1
fi

err_file="$(mktemp)"
trap 'rm -f "$err_file"' EXIT

status=0
for id in "$@"; do
  if ! result="$(gh api graphql -f query='
mutation($id:ID!){
  resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } }
}' -F id="$id" --jq '.data.resolveReviewThread.thread.isResolved' 2>"$err_file")"; then
    result="error: $(tr '\n' ' ' <"$err_file")"
  fi
  echo "$id $result"
  [[ "$result" == "true" ]] || status=1
done
exit "$status"
