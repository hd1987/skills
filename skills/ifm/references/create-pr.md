# Workflow: create pr [<source> to <target>]

Open a pull request between two branches that already exist on `origin`, using
`references/style.md` for the title, then output a Google Chat announcement.
This workflow does not commit or push code.

## Step 0 — Apply Style.md And Resolve Branches

Read `references/style.md` first. Resolve `REPO_NAME` and the default `BASE`
from that file. Do not inspect base-branch history or merged PR titles to learn
style.

Read and normalize the optional parameters.

- No parameters after `create pr`: default to `source` = the
  current branch and `target` = `BASE`.
- `<source> to <target>`: use the given branches, with `source` as head and
  `target` as base. For example, `create pr develop to qa` means `source` =
  `develop` and `target` = `qa`.

For any other parameter shape, state the accepted forms and stop:

```text
create pr
create pr <source> to <target>
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
work: stop and tell the user to run the `push` workflow first because it pushes
and opens the PR. If any other branch is missing, report which one and stop.

Refresh the selected remote-tracking refs before reading the PR changes:

```bash
git fetch origin "refs/heads/SOURCE:refs/remotes/origin/SOURCE" "refs/heads/TARGET:refs/remotes/origin/TARGET"
```

If the fetch fails, stop and report the failure. Resolve ticket keys and PR
metadata using the `create pr` rule in `style.md`: the `source` branch name
and `origin/TARGET..origin/SOURCE`, regardless of the current checkout.
When opening `develop` to `qa`, use `Sync Dev to QA` as the PR title; the Chat
summary is fixed below.

## Step 1 — Create The PR

Create the PR from `source` into `target` with the title from `style.md`. Fill
the body per the PR Body section of `style.md`. Do NOT add tool attribution to
the title or body.

```bash
gh pr create --base TARGET --head SOURCE --title "STYLE_PR_TITLE" --body "..."
```

If a PR for this head and base already exists, use that URL instead of creating
a second one.

Capture the PR URL from the command output.

## Step 2 — Google Chat Announcement

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

Use `REPO_NAME` from `style.md`. If no ticket is known, set `*Ticket:* N/A`.
Keep the summary to one line.

When `source` is exactly `develop` and `target` is exactly `qa`, use this
template instead. Keep the summary exactly as shown and omit the Ticket field:

````
```
*Repo:* REPO_NAME
*PR:* PR_URL
*Summary:* Sync Dev to QA
```
````
