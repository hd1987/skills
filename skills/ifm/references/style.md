# Style Registry

This skill's commit and PR-title conventions; these do not describe every
repository's historical team style. Do not run `git log` on the base branch
or `gh pr list` to learn style. Apply this file as written.

Resolve the current repo. When `create pr` resolved a `<repo>` parameter, run
these commands from that repository so they describe it, not the original
working directory:

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$REPO_ROOT")"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
```

Unknown repos still use this file. Never fall back to git history for format.

## Default Base Branch

Use an explicit PR base branch from the repository instructions when present.
Otherwise use `develop` if it exists on `origin`; if it does not, use the
default branch reported by `git ls-remote --symref origin HEAD`. Check remote
branch existence with `git ls-remote --heads origin` rather than treating a
missing local remote-tracking ref as evidence that the branch does not exist.
If the base cannot be resolved or does not exist on `origin`, stop and report
the failure.

Call the result `BASE`. `push` always uses `BASE`. `create pr` uses `BASE`
only when the user did not pass `<source> to <target>`.

## Ticket Keys

Extract keys matching `[A-Z][A-Z0-9]+-[0-9]+`.

Choose the ticket sources by workflow:

- `commit`: use `CURRENT_BRANCH`, then subjects from
  `git log origin/BASE..HEAD --format=%s` when that range exists. Only if
  neither yields a key, inspect the diff selected for this commit.
- `push`: use `CURRENT_BRANCH`, then subjects from
  `git log origin/BASE..HEAD --format=%s`. Use only committed changes when
  preparing PR metadata; exclude staged and unstaged work.
- `create pr`: use the resolved `source` branch name, then subjects from
  `git log origin/TARGET..origin/SOURCE --format=%s`, after refreshing those
  remote-tracking refs. Use this range for the PR summary and body too.
  Do not use `CURRENT_BRANCH`, local `HEAD`, or working-tree changes as
  substitutes for the resolved remote source. If the refs cannot be read,
  stop and report the failure.

Keep keys in first-seen order. The first key is the primary ticket. Do not
invent a ticket. Work without a ticket is valid.

Do not fetch Jira to choose a format or a commit type.

## Commit Message

For commits created by this workflow, use one formula:

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
| 1 | Branch starts with `bugfix/` or `hotfix/` | `fix` |
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

Use an optional squad explicitly provided by the user or repository
instructions. An absent or empty value, or `none` / `skip` / `n/a`, means no
squad. Do not invent a squad name or guess a release number.

```text
With tickets and squad:    [TICKET1][TICKET2][SQUAD]: {Summary}
With tickets, no squad:    [TICKET1][TICKET2]: {Summary}
No tickets, with squad:    [SQUAD]: {Summary}
No tickets, no squad:      {Summary}
```

One bracket per ticket, no spaces between brackets. Summary is sentence case
after the colon. No tool attribution.

Examples:

```text
[PROJ-1234]: Scope list filter to the selected org
[PROJ-123][PROJ-456]: Scope list filter and add export
[PROJ-1234][SQUAD]: Scope list filter to the selected org
```

When `create pr` is `develop` to `qa`, use `Sync Dev to QA` for both the GitHub
PR title and the Chat announcement summary.

## PR Body

If `<REPO_ROOT>/.github/pull_request_template.md` exists, fill that template.
Otherwise use `## Summary` and `## Test plan`. No tool attribution.

## Repo Name For Chat

Use `REPO_NAME` from the git toplevel basename. Do not call `gh repo view` only
to learn the name.
