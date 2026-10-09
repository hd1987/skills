# Workflow: create pr [<source> to <target>] [squad=<NAME>][, <repo>]

Open a pull request between two branches that already exist on `origin`, then
output a Google Chat announcement. This workflow does not commit or push code.

## Step 0 — Resolve The Repository

Resolve `REPO_ROOT` per `references/repo.md` and work from it. The part before
the comma is the branch part.

## Step 1 — Apply Style.md And Resolve Branches

Read `references/style.md` first. Resolve `REPO_NAME`, the default `BASE`, and
any `squad=<NAME>` token from that file. Do not inspect base-branch history or
merged PR titles to learn style.

Read and normalize the branch part after removing the squad token.

- Empty branch part: default to `source` = the current branch of the resolved
  repository and `target` = `BASE`.
- `<source> to <target>`: use the given branches, with `source` as head and
  `target` as base. For example, `create pr develop to qa` means `source` =
  `develop` and `target` = `qa`.

For any other parameter shape, state the accepted forms and stop:

```text
create pr
create pr <source> to <target>
create pr, <repo>
create pr <source> to <target>, <repo>
```

Any form may also carry `squad=<NAME>` before the comma. Do not guess branches
or repositories.

Resolve the current branch when defaulting:

```bash
git rev-parse --abbrev-ref HEAD
```

If `source` equals `target`, for example when the resolved repository is
checked out on its base branch, report both values and stop.

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

## Step 2 — Open The PR And Announce

Follow `references/pr.md` with `SOURCE` = `source` and `TARGET` = `target`.
The Chat summary is a one-line summary of `source` into `target`.
