# Workflow: review

Process the latest unresolved code review comments on the pull request for the
current branch in one pass. Evaluate every comment, apply reasonable and safe
changes, resolve only the threads whose fixes were pushed successfully, then
request a Copilot review when the pass completes without risky comments.

## Scope And Authorization

- Operate only on the pull request for the current branch.
- Invoking `/ifm review` authorizes a standard push of only the review-fix
  commit created during this invocation to the current pull request branch and
  one Copilot review request on that pull request after successful processing.
- Never force-push or push unrelated or pre-existing commits.
- Do not post replies, comments, reviews, or any other text on GitHub. The only
  permitted GitHub writes are the authorized push, resolving applied review
  threads, and requesting Copilot as a reviewer.
- Run one processing pass only. After requesting Copilot review, do not poll,
  wait for its result, or process the new round automatically. The user will
  invoke `/ifm review` again.

## Step 1 — Verify The Working State

1. Read the project's `CLAUDE.md` and follow its verification and repository
   rules.
2. Resolve the repository, current branch, and pull request.
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
gh pr view --json number,url -q '.number'
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
   confirmation; `/ifm review` is the authorization.
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

1. Read the pull request's current `headRefOid`, `reviewRequests`, and reviews:

```bash
gh pr view PR --json headRefOid,reviewRequests,reviews
```

2. If Copilot already has a pending review request, or its latest review is for
   the current `headRefOid`, do not request a duplicate; continue to Step 6.
3. Otherwise, read the pull request node ID:

```bash
gh pr view PR --json id -q .id
```

4. Store the result as `PR_ID`, then request one Copilot review with the
   login-based GraphQL mutation. Use `union: true` so existing review requests
   remain unchanged:

```bash
gh api graphql -f query='
mutation($pullRequestId:ID!,$botLogins:[String!]!,$union:Boolean!){
  requestReviewsByLogin(input:{
    pullRequestId:$pullRequestId
    botLogins:$botLogins
    union:$union
  }){
    clientMutationId
  }
}' -F pullRequestId=PR_ID \
   -f 'botLogins[]=copilot-pull-request-reviewer[bot]' \
   -F union=true
```

Do not use `gh pr edit --add-reviewer`; it may fetch deprecated Projects
Classic data before requesting the review and fail without adding Copilot.

5. Fetch `reviewRequests` again and verify that Copilot is present. If the
   request or verification fails, output `Failed` with the specific reason and
   stop. Do not retry with another reviewer identifier.
6. Do not wait for Copilot to finish and do not start another processing pass.

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
