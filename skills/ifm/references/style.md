# Style Registry

This skill's commit and PR conventions; these do not describe every
repository's historical team style. Do not run `git log` on the base branch
or `gh pr list` to learn style. Apply this file as written.

Resolve the repository context from `REPO_ROOT` (see `references/repo.md`):

```bash
cd "$REPO_ROOT"
REPO_NAME="$(basename "$REPO_ROOT")"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
```

Unknown repos still use this file. Never fall back to git history for format.

## Default Base Branch

Use an explicit PR base branch from the target repository's instructions
(see `references/repo.md`) when present; never take it from the workspace's
instructions.
Otherwise use `develop` if it exists on `origin`; if it does not, use the
default branch reported by `git ls-remote --symref origin HEAD`. Check remote
branch existence with `git ls-remote --heads origin` rather than treating a
missing local remote-tracking ref as evidence that the branch does not exist.
If the base cannot be resolved or does not exist on `origin`, stop and report
the failure.

Call the result `BASE`. `push` always uses `BASE`. `create pr` uses `BASE`
only when the user did not pass `<source> to <target>`.

## Protected Branches

`BASE`, `develop`, `qa`, `staging`, `main`, `master`, and any branch matching
`release/*` are protected. No workflow in this skill pushes or commits review
fixes onto a protected branch. When a workflow would do so, report `Failed`
with the branch name and stop. `create pr` may still use a protected branch as
`source` because it never pushes.

## Ticket Keys

Extract keys with the script, from `REPO_ROOT`:

```bash
SKILL_DIR/scripts/ticket-keys.sh BRANCH [LOG_RANGE]
SKILL_DIR/scripts/ticket-keys.sh --text < FILE
```

It prints uppercase keys in first-seen order: the branch name first, then the
commit subjects in `LOG_RANGE`, oldest first. `--text` applies the same rules
to any text on stdin, such as a diff or a pull request title and body; use it
whenever keys come from anything other than the branch and commit subjects.
Only keys of known Jira projects
count, in any case (`IFME`, `JSD`; override with `IFM_TICKET_PROJECTS`), so
sprint tags such as `Ferrari-SP-2` and report numbers such as `REPORT-44` are
not tickets. Numbers starting with `0` are dropped (`IFME-0000`). Empty output
with exit 0 means no ticket. Use its output as the key list; do not add keys
it dropped.

Choose the arguments by workflow:

- `commit` and `review`: `CURRENT_BRANCH` and `origin/BASE..HEAD` when that
  range exists, otherwise only `CURRENT_BRANCH`. For `commit` only, if neither
  yields a key, pipe the staged diff to `ticket-keys.sh --text`
  (`git diff --cached | SKILL_DIR/scripts/ticket-keys.sh --text`).
- `push`: `CURRENT_BRANCH` and `origin/BASE..HEAD`. Use only committed changes
  when preparing PR metadata; exclude staged and unstaged work.
- `create pr`: the resolved `source` branch name and
  `origin/TARGET..origin/SOURCE`, after refreshing those remote-tracking refs.
  Use this range for the PR summary and body too. Do not use
  `CURRENT_BRANCH`, local `HEAD`, or working-tree changes as substitutes for
  the resolved remote source. If the refs cannot be read, stop and report the
  failure.

The first key is the primary ticket. Do not invent a ticket. Work without a
ticket is valid.

Do not fetch Jira to choose a format or a commit type.

## Ticket URL

Build a ticket URL as `${JIRA_BASE_URL%/}/browse/<KEY>`. `JIRA_BASE_URL` comes
from the workspace environment (for example `init-agent-env.sh`). If it is unset, use the bare key instead of a URL. Never
guess a Jira host.

## Staging

Applies to every commit created by this skill (`commit` and `review`).

- Stage explicit paths only. Never run `git add -A`, `git add .`,
  `git add -u`, or `git commit -a`.
- Stage modifications to tracked files that belong to this commit.
- Stage an untracked file when it belongs to the same change: the agent
  created it during the current session for this change; it is imported or
  referenced by a modified or staged file; or it is the test of a modified or
  staged file. Sharing a directory is not enough. Files that take effect by
  convention, such as Next.js route files (`app/**/page.tsx`, `layout.tsx`,
  `route.ts`), database migrations, and config YAML, usually have no importer;
  when the agent did not create them in this session, treat them as unclear.
- Never stage dependency or build output (`node_modules/`, `dist/`, `build/`,
  `coverage/`, `.next/`), caches, working documents (`PR_DETAILS.md`), scratch
  files (`*.log`, `*.orig`, `*.rej`, `*.tmp`, `.DS_Store`), or anything that
  looks like a secret (`.env*`, `*secret*`, `*token*`, `*.pem`, `*.key`). If
  such a file appears to belong to the change, stop and report it instead of
  staging it.
- Leave clearly unrelated untracked files unstaged without stopping: files in
  a different feature area whose names and contents do not touch the change.
- If an untracked file may belong to the change but none of the relations
  above can be shown, do not commit. List those files and stop so the user
  can decide; a commit that silently omits a new route or migration is worse
  than no commit.
- After staging, check `git diff --cached --name-only` and unstage anything
  outside the intended change before committing.

## Commit Message

For commits created by this skill, use one formula:

```text
{type}({ticket}): {imperative summary}
```

When no ticket exists:

```text
{type}({scope}): {imperative summary}
```

`scope` is a short area name such as `skills`, `cursor`, or `wiki`. If no
meaningful scope exists, omit the parentheses: `{type}: {imperative summary}`.

Rules:

- Exactly one short English sentence on one line, with no body or trailers.
  No trailing period or AI, agent, or tool attribution.
- Imperative, lowercase after the colon, subject ≤72 characters.
- Do not put `[SQUAD]`, `[Release-n]`, report numbers as a prefix, repo
  names, or component-as-scope into the subject. Those belong in the PR title
  or the PR body, not the commit.
- Put extra tickets and any supporting explanation in the PR body.

Examples:

```text
fix(PROJ-1234): scope list filter to the selected org
feat(PROJ-5678): dismiss dirty create sheet with Escape
fix(PROJ-9012): pre-populate amount on review
chore(skills): drop git-log style probing from commit workflow
```

### Commit type

Choose `type` from the current branch and the current diff only:

| Priority | Signal | type |
| --- | --- | --- |
| 1 | Branch starts with `bugfix/`, `hotfix/`, or `fix/` | `fix` |
| 2 | Branch starts with `feature/` | `feat` |
| 3 | Branch starts with `chore/`, `docs/`, or `ci/` | matching `chore` / `docs` / `ci` |
| 4 | Diff is almost entirely tests | `test` |
| 5 | Diff is version, lockfile, CI, or config-only | `chore` |
| 6 | Refactor with no behavior change | `refactor` |
| 7 | New user-facing capability (API, page, field, pipeline) | `feat` |
| 8 | Still ambiguous | `fix` |

Allowed types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `ci`, `revert`.

## PR Title

Build from the ticket list and a short imperative summary of the change.

The squad comes only from an explicit `squad=<NAME>` token in the `push` or
`create pr` parameters, or from the repository instructions; the token wins.
An absent value, or `squad=none` / `squad=skip` / `squad=n/a`, means no squad.
Remove the token before parsing the remaining parameters. Do not invent a
squad name or guess a release number.

```text
With tickets and squad:    [TICKET1][TICKET2][SQUAD]: {Summary}
With tickets, no squad:    [TICKET1][TICKET2]: {Summary}
No tickets, with squad:    [SQUAD]: {Summary}
No tickets, no squad:      {Summary}
```

One bracket per ticket, no spaces between brackets. Summary is sentence case
after the colon. No tool attribution. The `develop` to `qa` title is fixed in
`references/pr.md`.

Examples:

```text
[PROJ-1234]: Scope list filter to the selected org
[PROJ-123][PROJ-456]: Scope list filter and add export
[PROJ-1234][SQUAD]: Scope list filter to the selected org
```

## PR Body

If `<REPO_ROOT>/.github/pull_request_template.md` exists, fill that template.
Otherwise use `## Summary` and `## Test plan`. No tool attribution.

## Repo Name For Chat

Use `REPO_NAME` from the git toplevel basename. Do not call `gh repo view` only
to learn the name.
