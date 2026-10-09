# Repository Target

Shared by `review`, `commit`, `push`, and `create pr`; `root cause` reuses the
candidate rules below.

## Split The Parameters

Split the parameters after the workflow keyword at the first comma. The part
before the comma is the workflow's own parameters; the part after it, trimmed,
is the optional `<repo>`. Without a comma, no `<repo>` is given. A comma with
an empty `<repo>` is invalid: state the workflow's accepted forms and stop.

## Choose The Repository

The workspace is often a coordination repository (such as
`agent-modernization-bus`) while the work happens in sibling repositories, so
do not default to the current directory blindly. Choose `REPO` in this order:

1. An explicit `<repo>`, or the repository of a pull request URL in `review`.
2. Otherwise infer it from the current conversation:
   1. **Candidates** are the repositories in which this conversation edited
      or created files, created commits, pushed, or opened or processed a
      pull request. Reading files and read-only git commands (`status`,
      `log`, `diff`, `fetch`, `ls-remote`) do not make a candidate.
   2. When at least one candidate is on a non-protected branch, drop the
      candidates whose current branch is protected per `style.md`; such a
      checkout is a coordination or base checkout, not the change. If every
      candidate is protected, keep them so the workflow's own protected-branch
      rule reports the real reason. This step does not apply to
      `create pr <source> to <target>`, where the current branch is
      irrelevant.
   3. Keep only candidates with work for this workflow:
      - `commit`: uncommitted changes to tracked files, or files created in
        this conversation.
      - `push`: commits not yet on the branch's upstream, or no upstream.
      - `review`: an open pull request for the current branch.
      - `create pr` without branches: the current branch exists on `origin`.
      - `create pr <source> to <target>`: both branches exist on `origin`.
   4. **Group by ticket.** Extract keys from each remaining candidate's branch
      (`source` for `create pr <source> to <target>`) with `ticket-keys.sh`.
      - If some candidates yield keys and all of those share at least one
        key, the target set is those candidates; drop the keyless ones.
      - If candidates with keys share no common key, report `Failed`.
      - If no candidate yields a key, the target set is all remaining
        candidates.
   5. If the target set has one repository, use its directory name as
      `REPO`. If it has several and they share a key, run the workflow once
      per repository (see Multiple Repositories). If it has several without
      a shared key, report `Failed`.
   6. If step 2.1 found candidates but none has work for this workflow,
      report that there is nothing to do, list the candidates with their
      branches and state (for example "already pushed, no new commits"), and
      stop. Do not fall back to the current repository.

   Every `Failed` here lists the candidates with their branches and shows the
   `<workflow>, <repo>` form; never pick one arbitrarily.
3. Only when step 2.1 found no candidate at all, use the current git
   repository (no `REPO` argument).

When `REPO` was inferred in step 2 and the workflow's output does not already
name the repository, prefix that output with `REPO_NAME: `.

## Multiple Repositories

For a target set that shares a ticket key, such as `fix/IFME-22165-x` in both
`infodrive-cx-api` and `infomedia-edp-admin-portal-ui`, run the whole workflow
for each repository in turn, ordered by directory name, each with its own
`REPO_ROOT`, branch, and output (for example one commit line, or one PR and
Chat block, per repository). A failure in one repository does not stop the
others; report each repository's result. Selecting the workflow authorizes
the same scoped actions in every repository of the target set; nothing
outside that set.

## Resolve The Repository

Run the resolver from the current working directory:

```bash
REPO_ROOT="$(SKILL_DIR/scripts/resolve-repo.sh [REPO])"
```

- No `REPO`: it prints the current git repository root.
- `REPO` given: it must be an exact directory name, such as
  `infodrive-cx-ui`. The resolver checks, in order, the current git toplevel
  when its basename matches, the directory with that name next to the current
  git toplevel, `$PWD/<repo>` when the current directory is not inside a git
  repository, and `$MASHI_REPORTS_ROOT/<repo>` when that variable is set.
  A wrong inferred name fails here instead of falling back to another repo.

If the resolver exits non-zero, report its message and stop. Do not guess
similar names, aliases, or partial matches.

Run every git, gh, and script command of the workflow from `REPO_ROOT`
(`cd "$REPO_ROOT"` first). `style.md` describes this repository.

## Repository Instructions

"Repository instructions" in this skill means the instruction files inside
`REPO_ROOT` (`CLAUDE.md`, `AGENTS.md`, `.cursor/rules/`,
`.github/copilot-instructions.md`). The workspace's own instructions still
govern agent behavior and guardrails, but they do not define the target
repository's base branch or verification commands.

Verification commands: use the ones the repository instructions name. If
there are none, run the narrowest checks the target repository itself defines
for the changed files: matching test or lint scripts in its `package.json`,
`Makefile`, `pyproject.toml`, or `tox.ini`. If it defines none, continue
without verification.
