# Open A Pull Request And Announce It

Shared by `push` and `create pr`. The calling workflow supplies `SOURCE` (head)
and `TARGET` (base); `push` uses `CURRENT_BRANCH` and `BASE`.

## Title

Use the PR Title section of `references/style.md`. When `SOURCE` is exactly
`develop` and `TARGET` is exactly `qa`, the title is `Sync Dev to QA`.

## Reuse Or Create

Check for an open pull request with the same head and base first:

```bash
gh pr list --head SOURCE --base TARGET --state open --json url -q '.[0].url'
```

If it returns a URL, use it and do not create a second pull request.
Otherwise create one, filling the body per the PR Body section of `style.md`.
Do NOT add tool attribution to the title or body.

```bash
gh pr create --base TARGET --head SOURCE --title "STYLE_PR_TITLE" --body "..."
```

Capture the PR URL from the command output.

## Google Chat Announcement

Output the announcement in English. The `*text*` markers are Google Chat bold
syntax, NOT markdown italic. Print the whole block inside a fenced code block so
the terminal shows the asterisks literally instead of rendering them as italic.
Use plain URLs, never markdown links.

For every branch combination except `develop` to `qa`, fill each field and use
the literal asterisks:

````
```
*Repo:* REPO_NAME
*PR:* PR_URL
*Summary:* one-line summary of the change
*Ticket:* TICKET_URL or N/A
```
````

- `REPO_NAME` comes from `style.md`.
- `TICKET_URL` is the primary ticket built per the Ticket URL section of
  `style.md`. If no ticket is known, set `*Ticket:* N/A`.
- Keep the summary to one line.

When `SOURCE` is exactly `develop` and `TARGET` is exactly `qa`, use this
template instead. Keep the summary exactly as shown and omit the Ticket field:

````
```
*Repo:* REPO_NAME
*PR:* PR_URL
*Summary:* Sync Dev to QA
```
````
