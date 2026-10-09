# Workflow: commit [, <repo>]

Commit the current changes locally using `references/style.md`. Do not push.
This workflow ends at a local commit.

## Step 0 — Resolve Context

1. Resolve `REPO_ROOT` per `references/repo.md` and work from it. The part
   before the comma must be empty; otherwise state the accepted forms and stop:

```text
commit
commit, <repo>
```

2. Read `references/style.md` and resolve `REPO_NAME`, `CURRENT_BRANCH`,
   `BASE`, ticket keys, and commit `type` from that file. Do not inspect
   base-branch history or merged PR titles.

## Step 1 — Commit

1. Review the working tree (`git status --short`, `git diff`) and stage the
   changes that belong in this commit per the Staging section of `style.md`.
2. Run the verification commands chosen per the Repository Instructions
   section of `references/repo.md`; do not commit if any fail.
3. Commit with a message that matches the Commit Message section of
   `style.md`.

Constraints:

- Use the frozen formula in `style.md`, not a guessed or historically sampled
  convention.
- Do NOT add AI, agent, or tool attribution or co-author trailers.
- Do NOT push. Pushing belongs to the `push` workflow.

## Output

State the commit hash and the message used, one line. Nothing else. If the
Staging rules stopped the commit, list only the unclear untracked files.
