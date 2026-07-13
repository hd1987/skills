# Workflow: push

Push the current branch and open a pull request against the base branch, using
the team's title style, then output a Google Chat announcement. Invoking this
workflow authorizes the push.

## Step 0 — Learn The Team Style (never skip)

Inspect recent titles on the base branch before writing the PR title. Never
assume Conventional Commits; match what the team actually does.

```bash
git log --oneline origin/develop -10
gh pr list --base develop --state merged --limit 10 --json title -q '.[].title'
```

## Step 1 — Push

Push the current branch to `origin`, setting upstream if needed:

```bash
git push -u origin HEAD
```

## Step 2 — Create The PR

Create the PR against the base branch with a title in the observed team style.
Do NOT add tool attribution to the title or body.

```bash
gh pr create --base develop --title "TEAM_STYLE_TITLE" --body "..." --fill
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
*Summary:* one-line summary of the change
*Ticket:* TICKET_URL or N/A
```
````

Derive `REPO_NAME` from `gh repo view --json name -q .name`. If no ticket is
known, set `*Ticket:* N/A`. Keep the summary to one line.

## Notes

- This workflow pushes without a separate confirmation; running `/ifm push`
  is the authorization.
- Run `/ifm commit` first if there are uncommitted changes.
