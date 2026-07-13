# Workflow: review

Process the latest unresolved code review comments on the pull request for the
current branch in one pass. Evaluate every comment, apply reasonable and safe
changes, and resolve only the threads whose fixes were pushed successfully.

## Scope And Authorization

- Operate only on the pull request for the current branch.
- Invoking `/ifm review` authorizes a standard push of only the review-fix
  commit created during this invocation to the current pull request branch.
- Never force-push or push unrelated or pre-existing commits.
- Do not post replies, comments, reviews, or any other text on GitHub. The only
  permitted GitHub writes are the authorized push and resolving applied review
  threads.
- Run one pass only. Do not poll, wait for another review round, or trigger
  another pass automatically. The user will invoke `/ifm review` again.

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

Keep only threads where `isResolved` is `false`. If none remain, output
`Passed` and stop.

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

## Step 5 — Report Only What Needs Attention

- If all open comments were safe and processed successfully, output only
  `Passed`.
- If no open comments exist, output only `Passed`.
- For each unreasonable or risky comment, leave its code and thread untouched
  and report only:
  - Location: `path:line`.
  - Comment: a concise summary.
  - Rationale: the technical reason it requires confirmation.
- If safe and risky comments are mixed, process the safe comments completely,
  then report only the risky comments.
- Do not emit progress narration, a triage summary, applied-comment details, a
  push prompt, or any unnecessary conversational text.
