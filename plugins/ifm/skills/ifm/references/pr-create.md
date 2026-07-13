# Workflow: pr create [<source> to <target>]

Open a pull request between two branches that already exist on `origin`, using
the team's title style, then output a Google Chat announcement. This workflow
does not commit or push code.

## Step 0 — Resolve Branches

Read the optional parameters.

- No parameters: default to `source` = the current branch, `target` = `develop`.
- `<source> to <target>` (for example `develop to qa`): use the given branches,
  `source` as head, `target` as base.

If parameters are present but do not contain `to`, state the expected form
`pr create <source> to <target>` and stop. Do not guess branches.

Resolve the current branch when defaulting:

```bash
git rev-parse --abbrev-ref HEAD
```

Verify both branches exist on `origin`:

```bash
git ls-remote --heads origin SOURCE TARGET
```

If `source` is the current branch and is not yet on `origin`, it has unpushed
work: stop and tell the user to run `/ifm push` first (that workflow
pushes and opens the PR). If any other branch is missing, report which one and
stop.

## Step 1 — Learn The Team Title Style (never skip)

Inspect recent titles on the target branch before writing the PR title. Never
assume Conventional Commits; match what the team actually does.

```bash
git log --oneline origin/TARGET -10
gh pr list --base TARGET --state merged --limit 10 --json title -q '.[].title'
```

## Step 2 — Create The PR

Create the PR from `source` into `target` with a title in the observed team
style. Do NOT add tool attribution to the title or body.

```bash
gh pr create --base TARGET --head SOURCE --title "TEAM_STYLE_TITLE" --body "..."
```

Capture the PR URL from the command output.

## Step 3 — Google Chat Announcement

Output the announcement in English. The `*text*` markers are Google Chat bold
syntax, NOT markdown italic. Print the whole block inside a fenced code block so
the terminal shows the asterisks literally instead of rendering them as italic.
Use plain URLs, never markdown links.

Template (fill each field; use the literal asterisks):

````
```
*Repo:* REPO_NAME
*PR:* PR_URL
*Summary:* one-line summary of SOURCE into TARGET
*Ticket:* TICKET_URL or N/A
```
````

Derive `REPO_NAME` from `gh repo view --json name -q .name`. If no ticket is
known, set `*Ticket:* N/A`. Keep the summary to one line.
