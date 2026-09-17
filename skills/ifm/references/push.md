# Workflow: push

Push the current branch and open a pull request against the default base
branch, using `references/style.md` for the title, then output a Google Chat
announcement. Invoking this workflow authorizes the push.

## Step 0 — Apply Style.md

Read `references/style.md` and resolve `REPO_NAME`, `CURRENT_BRANCH`, `BASE`,
ticket keys, and the PR title from that file. Do not inspect base-branch
history or merged PR titles.

## Step 1 — Push

Push the current branch to `origin`, setting upstream if needed:

```bash
git push -u origin HEAD
```

## Step 2 — Create The PR

Create the PR against `BASE` with the title from `style.md`. Fill the body per
the PR Body section of `style.md`. Do NOT add tool attribution to the title or
body.

```bash
gh pr create --base BASE --title "STYLE_PR_TITLE" --body "..."
```

If a PR for this head and base already exists, use that URL instead of creating
a second one.

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

Use `REPO_NAME` from `style.md`. If no ticket is known, set `*Ticket:* N/A`.
Keep the summary to one line.

## Notes

- This workflow pushes without a separate confirmation; selecting it is the
  authorization.
- Run the `commit` workflow first if there are uncommitted changes.
