# Workflow: create [pr [<source> to <target>]]

Open a pull request between two branches that already exist on `origin`, using
the team's title style, then output a Google Chat announcement. This workflow
does not commit or push code.

## Step 0 — Resolve Branches

Read and normalize the optional parameters.

- No parameters (`/ifm create`): default to `source` = the current branch and
  `target` = `develop`.
- `pr` only (`/ifm create pr`): use the same defaults.
- `pr <source> to <target>`: use the given branches, with `source` as head and
  `target` as base. For example, `/ifm create pr develop to qa` means
  `source` = `develop` and `target` = `qa`.

For any other parameter shape, state the accepted forms and stop:

```text
/ifm create
/ifm create pr
/ifm create pr <source> to <target>
```

Do not guess branches.

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

For every branch combination except `develop` to `qa`, fill each field in this
template and use the literal asterisks:

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

When `source` is exactly `develop` and `target` is exactly `qa`, use this
template instead. Keep the summary exactly as shown and omit the Ticket field:

````
```
*Repo:* REPO_NAME
*PR:* PR_URL
*Summary:* Sync Dev to QA
```
````
