# Workflow: pr <source> to <target>

Open a pull request between two existing branches, using the team's title style,
then output a Google Chat announcement. Both branches are expected to already
exist on `origin`; this workflow does not commit or push code.

## Step 0 — Parse Branches

The parameters have the form `<source> to <target>`, for example
`pr develop to qa` means head `develop`, base `qa`.

- `source` (head): the branch whose changes are merged.
- `target` (base): the branch that receives the changes.

If the parameters are missing or do not contain `to`, state the expected form
`pr <source> to <target>` and stop. Do not guess branches.

Verify both branches exist on `origin`:

```bash
git ls-remote --heads origin SOURCE TARGET
```

If either is missing, report which one and stop.

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
