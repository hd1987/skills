# Workflow: push [squad=<NAME>][, <repo>]

Push the current branch and open a pull request against the default base
branch, then output a Google Chat announcement. Invoking this workflow
authorizes the push.

## Step 0 — Resolve Context

1. Resolve `REPO_ROOT` per `references/repo.md` and work from it. Apart from an
   optional `squad=<NAME>` token, the part before the comma must be empty;
   otherwise state the accepted forms and stop:

```text
push
push squad=<NAME>
push, <repo>
push squad=<NAME>, <repo>
```

2. Read `references/style.md` and resolve `REPO_NAME`, `CURRENT_BRANCH`,
   `BASE`, ticket keys, and the PR title from that file. Do not inspect
   base-branch history or merged PR titles.
3. If `CURRENT_BRANCH` is protected per `style.md`, report `Failed` with the
   branch name and stop. Never push a protected branch.
4. If `git status --short` shows uncommitted changes, continue: they are not
   pushed and are excluded from PR metadata. Mention them in one line at the
   end so the user can run `commit` first next time.

## Step 1 — Push

Push the current branch to `origin`, setting upstream if needed:

```bash
git push -u origin HEAD
```

If the push is rejected, report `Failed` with the reason and stop. Never
force-push.

## Step 2 — Open The PR And Announce

Follow `references/pr.md` with `SOURCE` = `CURRENT_BRANCH` and `TARGET` =
`BASE`.
