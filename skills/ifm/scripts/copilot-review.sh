#!/usr/bin/env bash
# Usage: copilot-review.sh <pr-number> [--check]
# Run from the repository checkout. Requests one Copilot review unless Copilot
# already reviewed the current head or has a pending request. --check only
# reports the state and never writes.
# Prints one line and exits 0: "reviewed-head", "pending", "needed" (--check),
# or "requested <createdAt>". On failure prints "failed <reason>" and exits 1.
#
# GitHub omits Copilot from reviewRequests while its review is in progress, so
# this script reads timeline events instead.
set -euo pipefail

pr="${1:?pull request number required}"
mode="${2:-}"
copilot="copilot-pull-request-reviewer"
# A request older than this without a review is treated as stalled, not pending.
pending_window_seconds=1800

err_file="$(mktemp)"
trap 'rm -f "$err_file"' EXIT

fail() {
  echo "failed $*"
  exit 1
}

last_error() {
  tr '\n' ' ' <"$err_file"
}

repo_line="$(gh repo view --json owner,name -q '.owner.login + " " + .name' 2>"$err_file")" \
  || fail "cannot resolve repository: $(last_error)"
owner="${repo_line%% *}"
name="${repo_line#* }"

state="$(gh api graphql -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){
      id
      headRefOid
      timelineItems(last:100,itemTypes:[REVIEW_REQUESTED_EVENT,REVIEW_REQUEST_REMOVED_EVENT,PULL_REQUEST_REVIEW]){
        nodes{
          __typename
          ... on ReviewRequestedEvent{ createdAt requestedReviewer{ ... on Bot{ login } } }
          ... on ReviewRequestRemovedEvent{ createdAt requestedReviewer{ ... on Bot{ login } } }
          ... on PullRequestReview{ submittedAt author{ login } commit{ oid } }
        }
      }
    }
  }
}' -F owner="$owner" -F repo="$name" -F pr="$pr" --jq '
  .data.repository.pullRequest as $p
  | [$p.timelineItems.nodes[]
     | select((.requestedReviewer.login // .author.login // "") == "'"$copilot"'")] as $c
  | [ $p.id,
      (any($c[]; .__typename == "PullRequestReview" and .commit.oid == $p.headRefOid) | tostring),
      ([$c[] | select(.__typename == "ReviewRequestedEvent") | .createdAt] | max // "-"),
      ([$c[] | select(.__typename == "PullRequestReview") | .submittedAt // empty] | max // "-"),
      ([$c[] | select(.__typename == "ReviewRequestRemovedEvent") | .createdAt] | max // "-"),
      (now - '"$pending_window_seconds"' | floor | todateiso8601) ]
  | join(" ")' 2>"$err_file")" || fail "cannot read pull request ${pr}: $(last_error)"

# All six fields are space-free tokens, so plain word splitting is safe here.
# shellcheck disable=SC2086
set -- $state
[[ $# -eq 6 ]] || fail "unexpected pull request state: $state"
pr_id="$1" reviewed_head="$2" last_request="$3" last_review="$4" last_removed="$5" pending_cutoff="$6"

if [[ "$reviewed_head" == "true" ]]; then
  echo "reviewed-head"
  exit 0
fi
# ISO-8601 UTC timestamps compare correctly as strings; "-" sorts before any date.
if [[ "$last_request" != "-" && "$last_request" > "$last_review" \
  && "$last_request" > "$last_removed" && "$last_request" > "$pending_cutoff" ]]; then
  echo "pending"
  exit 0
fi
if [[ "$mode" == "--check" ]]; then
  echo "needed"
  exit 0
fi

new_request="$(gh api graphql -f query='
mutation($pullRequestId:ID!,$botLogins:[String!]!,$union:Boolean!){
  requestReviewsByLogin(input:{
    pullRequestId:$pullRequestId
    botLogins:$botLogins
    union:$union
  }){
    pullRequest{
      timelineItems(last:5,itemTypes:[REVIEW_REQUESTED_EVENT]){
        nodes{
          ... on ReviewRequestedEvent{ createdAt requestedReviewer{ ... on Bot{ login } } }
        }
      }
    }
  }
}' -F pullRequestId="$pr_id" \
  -f "botLogins[]=${copilot}[bot]" \
  -F union=true --jq '
  [.data.requestReviewsByLogin.pullRequest.timelineItems.nodes[]
   | select(.requestedReviewer.login == "'"$copilot"'") | .createdAt] | max // "-"' 2>"$err_file")" \
  || fail "request mutation error: $(last_error)"

if [[ "$new_request" != "-" && "$new_request" > "$last_request" ]]; then
  echo "requested $new_request"
  exit 0
fi
fail "no new Copilot review request event after the mutation"
