# Workflow: pr review

Process the latest code review comments on the current pull request in one pass:
triage each comment, apply the safe ones, and resolve their threads silently.
Report only the comments that need a human decision.

## Scope And Silence

- Operate only on the pull request for the current branch.
- Do not post any reply, comment, or text on GitHub. The only GitHub write
  actions allowed are code pushes and resolving review threads.
- Keep local output minimal. Emit a short triage summary and, when needed, the
  decision requests. No filler, no progress narration.

## Step 1 — Locate The PR And Fetch Threads

Resolve the repository and PR, then fetch unresolved review threads.

```bash
gh repo view --json owner,name -q '.owner.login + " " + .name'
gh pr view --json number,url -q '.number'
```

Fetch unresolved threads with their comments (owner, repo, PR from above):

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

Keep only threads where `isResolved` is `false`. If none, report "No open review
comments" and stop.

## Step 2 — Triage Each Comment

Classify every open thread into exactly one bucket.

- **Reasonable and safe**: technically correct and low risk. It fixes a real
  bug, typo, style issue, missing edge case, or clear improvement, and applying
  it does not cross a red line.
- **Unreasonable or risky**: technically wrong, based on a misunderstanding of
  the code, out of scope, or safe-looking but touching something that requires
  the user's judgment (schema changes, secrets, CI config, deletes, public
  behavior changes, or anything ambiguous).

When unsure, treat it as risky. Do not guess.

## Step 3 — Apply Reasonable Comments

For each reasonable-and-safe thread:

1. Fix the code locally with the smallest correct change.
2. After all such fixes are made, run the project's verification command (see
   the project `CLAUDE.md`); do not commit if verification fails.
3. Commit with one short English message describing the change.

Then stop before pushing and ask the user to confirm the push, listing the
commits to be pushed. Pushing is a red line; never push without confirmation.

After the user confirms and the push succeeds, resolve each applied thread:

```bash
gh api graphql -f query='
mutation($id:ID!){
  resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } }
}' -F id=THREAD_ID
```

Do not resolve a thread before its fix is pushed.

## Step 4 — Report Risky Comments

For each unreasonable-or-risky thread, do not modify code and do not resolve it.
Report to the user, one entry per thread:

- Location: `path:line`.
- The comment, condensed.
- Your technical rationale for holding it.

Wait for the user's decision. Apply only what the user approves, then resolve
those threads as in Step 3.

## Step 5 — Loop By Re-Invocation

Run only this single pass. Copilot re-reviews asynchronously after a push and
posts a new batch of comments. When it does, the user re-invokes
`/my-workflow pr review` to process the next round. Do not poll or wait for Copilot.

## Output Shape

```
Triage: N open threads — A applied, B awaiting your decision.

Applied (committed, awaiting push):
- path:line — one-line summary
...

Awaiting decision:
- path:line — comment condensed
  Rationale: why held
...

Confirm push? (lists commits)
```

If there are no risky threads, omit the "Awaiting decision" block. If nothing
was applied, omit the push prompt.
