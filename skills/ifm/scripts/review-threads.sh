#!/usr/bin/env bash
# Usage: review-threads.sh <pr-number>
# Run from the repository checkout. Prints one compact JSON object per
# unresolved review thread: id, isOutdated, path, line, comments[{author, body}].
# Prints a "warning:" line on stderr when threads or comments were truncated.
set -euo pipefail

pr="${1:?pull request number required}"
repo_line="$(gh repo view --json owner,name -q '.owner.login + " " + .name')" || {
  echo "cannot resolve repository" >&2
  exit 1
}
owner="${repo_line%% *}"
name="${repo_line#* }"

response="$(gh api graphql -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){
      reviewThreads(first:100){
        pageInfo{ hasNextPage }
        nodes{
          id
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first:20){
            pageInfo{ hasNextPage }
            nodes{ author{ login } body }
          }
        }
      }
    }
  }
}' -F owner="$owner" -F repo="$name" -F pr="$pr")"

threads='.data.repository.pullRequest.reviewThreads'

if [[ "$(printf '%s' "$response" | jq -r "$threads.pageInfo.hasNextPage")" == "true" ]]; then
  echo "warning: more than 100 review threads; only the first 100 were read" >&2
fi
truncated="$(printf '%s' "$response" | jq -r "[$threads.nodes[]
  | select((.isResolved | not) and .comments.pageInfo.hasNextPage) | .path] | join(\", \")")"
if [[ -n "$truncated" ]]; then
  echo "warning: only the first 20 comments were read in threads on: $truncated" >&2
fi

printf '%s' "$response" | jq -c "$threads.nodes[]
  | select(.isResolved | not)
  | {id, isOutdated, path, line: (.line // .originalLine),
     comments: [.comments.nodes[] | {author: .author.login, body}]}"
