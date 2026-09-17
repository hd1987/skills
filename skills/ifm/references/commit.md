# Workflow: commit

Commit the current changes locally using `references/style.md`. Do not push.
This workflow ends at a local commit.

## Step 0 — Apply Style.md

Read `references/style.md` and resolve `REPO_NAME`, `CURRENT_BRANCH`, `BASE`,
ticket keys, and commit `type` from that file. Do not inspect base-branch
history or merged PR titles.

## Step 1 — Commit

1. Review the working tree (`git status`, `git diff`) and stage the changes that
   belong in this commit.
2. Run the project's required verification commands from its repository
   instructions when they exist; do not commit if any fail.
3. Commit with a message that matches the Commit Message section of
   `references/style.md`.

Constraints:

- Use the frozen formula in `style.md`, not a guessed or historically sampled
  convention.
- Do NOT add AI, agent, or tool attribution or co-author trailers.
- Do NOT push. Pushing belongs to the `push` workflow.

## Output

State the commit hash and the message used, one line. Nothing else.
