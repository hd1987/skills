# Workflow: commit

Commit the current changes locally using the team's real commit message style.
Do not push. This workflow ends at a local commit.

## Step 0 — Learn The Team Commit Style (never skip)

Inspect recent commits on the base branch BEFORE writing any message. Never
assume Conventional Commits or any other convention; match what the team
actually does.

```bash
git log --oneline origin/develop -10
```

Read the sample and match it exactly: casing, prefixes or their absence, tense,
scope format, ticket-ID placement, length. This step has been skipped before and
is the main failure mode — do not skip it.

## Step 1 — Commit

1. Review the working tree (`git status`, `git diff`) and stage the changes that
   belong in this commit.
2. Run the project's required verification commands from its repository
   instructions when they exist; do not commit if any fail.
3. Commit with a message that matches the observed team style.

Constraints:

- Write the message in the team's style, not a generic convention.
- Do NOT add AI, agent, or tool attribution or co-author trailers.
- Do NOT push. Pushing belongs to the `push` workflow.

## Output

State the commit hash and the message used, one line. Nothing else.
