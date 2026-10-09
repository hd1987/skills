# Workflow: review

Process the latest unresolved code review comments on the target pull request
in one pass. Evaluate every comment, apply reasonable and safe changes, resolve
only the threads whose fixes were pushed successfully, then request a Copilot
review when the pass completes without risky comments.

## Parameters

```text
review
review <pr-url-or-number>
```

- No parameter: the target is the pull request for the current branch.
- A pull request URL or number: the target is that pull request. A URL selects
  its repository; a bare number uses the current repository. Work in the local
  checkout of that repository: the current git repository when its name
  matches, otherwise the directory with that exact name next to the current
  git toplevel, otherwise `$MASHI_REPORTS_ROOT/<repo>` when that variable is
  set. The checkout's current branch must be the pull request's head branch.
  If no checkout matches or the branch differs, stop and report `Failed` with
  the reason. Run every git and gh command from that checkout.

## Scope And Authorization

- Operate only on the target pull request.
- Selecting this workflow authorizes, as one continuous procedure: a standard
  push of only the review-fix commit created during this invocation to the
  target pull request branch, resolving the applied threads, and one Copilot
  review request on that pull request (Step 5). The Copilot request is the
  final step of this workflow, not a separate action, and needs no further
  confirmation.
- Never force-push or push unrelated or pre-existing commits.
- Do not post replies, comments, reviews, or any other text on GitHub. The only
  permitted GitHub writes are the authorized push, resolving applied review
  threads, and requesting Copilot as a reviewer.
- Run one processing pass only. After requesting Copilot review, do not poll,
  wait for its result, or process the new round automatically. The user will
  select the `review` workflow again.

## Step 1 — Verify The Working State

1. Read the project's repository instructions and follow its verification and
   repository rules.
2. Resolve the repository, current branch, and target pull request.
3. Fetch the current upstream state.
4. Require a clean working tree, a configured upstream branch, and no local
   commits ahead of or behind upstream. If any requirement fails, stop without
   modifying files and report `Failed` with the specific reason.

Use these commands as the starting point:

```bash
git status --short
git rev-parse --abbrev-ref HEAD
git fetch origin
git rev-list --left-right --count HEAD...@{upstream}
gh repo view --json owner,name -q '.owner.login + " " + .name'
gh pr view [PR] --json number,url,headRefName
```

## Step 2 — Fetch Open Review Threads

Fetch unresolved review threads with their comments, using the owner, repo, and
pull request number resolved above:

```bash
gh api graphql -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){
      reviewThreads(first:100){
        nodes{
          id
          isResolved
          isOutdated
          comments(first:20){
            nodes{ author{login} body path line }
          }
        }
      }
    }
  }
}' -F owner=OWNER -F repo=REPO -F pr=PR
```

Keep only threads where `isResolved` is `false`. If none remain, skip Steps 3
and 4 and continue to Step 5.

## Step 3 — Evaluate Every Comment

Classify every open thread into exactly one bucket:

- **Reasonable and safe**: technically correct, within scope, low risk, and
  implementable without crossing a red line other than the narrowly authorized
  standard push.
- **Unreasonable or risky**: technically incorrect, based on a misunderstanding,
  out of scope, ambiguous, or requiring user judgment. Treat schema changes,
  data migrations, file deletion, secrets, tokens, CI/CD changes, destructive
  Git operations, force pushes, and uncertain public behavior changes as risky.

When unsure, classify the thread as risky. Do not guess.

## Step 4 — Apply Safe Comments

If one or more comments are reasonable and safe:

1. Apply the smallest correct fixes locally. Do not modify code for risky
   comments.
2. Run the project's required verification commands. If verification fails,
   do not commit or push; output `Failed` with the failing check and stop.
3. Review the diff and confirm it contains only the safe review fixes.
4. Create one commit with a short English message describing the fixes.
5. Push the current branch with a standard push. Do not ask for another
   confirmation; selecting this workflow is the authorization.
6. Resolve each applied thread only after the push succeeds:

```bash
gh api graphql -f query='
mutation($id:ID!){
  resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } }
}' -F id=THREAD_ID
```

Verify that every mutation returns `isResolved: true`. If the commit or push
fails, do not resolve any applied thread. If resolving a thread fails, leave it
open and report `Failed` with its location.

## Step 5 — Request Copilot Review

Run this step only when no risky comments remain and every required validation,
commit, push, and thread resolution from the current pass succeeded. If any
risky comment or earlier failure remains, skip the Copilot request and continue
to Step 6.

GitHub omits Copilot from `reviewRequests` while its review is in progress, so
never use `reviewRequests` to detect or verify a Copilot request. Use the
timeline events below. Copilot appears as login `copilot-pull-request-reviewer`
in both review request events and reviews.

1. Read the pull request node ID, current head, and Copilot-related timeline:

```bash
gh api graphql -f query='
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
}' -F owner=OWNER -F repo=REPO -F pr=PR
```

   Store `id` as `PR_ID`. Keep only nodes whose reviewer or author login is
   `copilot-pull-request-reviewer`, and store the latest Copilot
   `ReviewRequestedEvent.createdAt` as `LAST_COPILOT_REQUEST` (empty if none).

2. Do not request a duplicate, and continue to Step 6, when either holds:
   - A Copilot review has `commit.oid` equal to `headRefOid`.
   - Copilot has a pending request: `LAST_COPILOT_REQUEST` is newer than the
     latest Copilot review `submittedAt` and the latest Copilot
     `ReviewRequestRemovedEvent.createdAt`.
3. Otherwise, request one Copilot review with the login-based GraphQL
   mutation. Use `union: true` so existing review requests remain unchanged.
   The mutation returns the latest review request events for verification:

```bash
gh api graphql -f query='
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
}' -F pullRequestId=PR_ID \
   -f 'botLogins[]=copilot-pull-request-reviewer[bot]' \
   -F union=true
```

Do not use `gh pr edit --add-reviewer`; it may fetch deprecated Projects
Classic data before requesting the review and fail without adding Copilot.

4. Verify the mutation result: the response has no `errors`, and it contains a
   `ReviewRequestedEvent` for `copilot-pull-request-reviewer` whose `createdAt`
   is newer than `LAST_COPILOT_REQUEST` (any such event when it is empty). If
   the request or verification fails, output `Failed` with the specific reason
   and stop. Do not retry with another reviewer identifier.
5. Do not wait for Copilot to finish and do not start another processing pass.

## Step 6 — Report Only What Needs Attention

- If all open comments were safe and processed successfully, output only
  `Passed`.
- If no open comments exist, output only `Passed`.
- For each unreasonable or risky comment, leave its code and thread untouched
  and report only:
  - Location: `path:line`.
  - Comment: a concise summary.
  - Rationale: the technical reason it requires confirmation.
- If safe and risky comments are mixed, process the safe comments completely,
  skip the Copilot review request, then report only the risky comments.
- Do not emit progress narration, a triage summary, applied-comment details, a
  push prompt, or any unnecessary conversational text.
