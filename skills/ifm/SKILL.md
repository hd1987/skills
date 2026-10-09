---
name: ifm
description: Dispatch a personal work workflow by name. Use when the user selects the IFM Skill with a workflow such as `root cause [ticket]` to identify a related Jira ticket and record its root cause, `review [pr][, repo]` to process pull request review comments and request the next Copilot review, `commit [, repo]` to commit locally, `push [, repo]` to push and open a pull request, or `create pr [source to target][, repo]` to open a pull request between existing branches.
---

# IFM

## Purpose

A dispatcher for repository work workflows. The argument after the skill name
selects which workflow to run. Each workflow is defined in its own file under
`references/`. Load only the matched file and the files in its **Also load**
column, and execute them exactly. Deterministic steps are implemented by the
scripts in `scripts/`; run them instead of re-deriving their logic.

## Route Workflows

Read the argument, lowercase it, and match its leading keyword against the table
below. Matching is case-insensitive and ignores surrounding whitespace. Any
tokens after the matched keyword are parameters passed to the workflow.

| Leading keyword | Parameters | Workflow file | Also load |
| --- | --- | --- | --- |
| `root cause` | optional `[<ticket>]` | `references/root-cause.md` | `references/repo.md`, `references/style.md` |
| `review` | optional `[<pr-url-or-number>][, <repo>]` | `references/review.md` | `references/repo.md`, `references/style.md` |
| `commit` | optional `[, <repo>]` | `references/commit.md` | `references/repo.md`, `references/style.md` |
| `push` | optional `[squad=<NAME>][, <repo>]` | `references/push.md` | `references/repo.md`, `references/style.md`, `references/pr.md` |
| `create pr` | optional `[<source> to <target>] [squad=<NAME>][, <repo>]` | `references/create-pr.md` | `references/repo.md`, `references/style.md`, `references/pr.md` |

Steps:

1. If the argument matches a row, read that workflow file and every file in
   **Also load**, then follow them literally. Do not improvise beyond what
   those files specify. Do not probe git/GitHub history to learn commit or
   PR-title style; `references/style.md` is the source.
2. If the argument is empty, list the available workflows from the table and
   stop.
3. If the argument does not match any row, state that no workflow matched, list
   the available workflows, and stop. Do not guess.

## Conventions

- `SKILL_DIR` is the directory containing this file. Scripts live in
  `SKILL_DIR/scripts/`. Run `resolve-repo.sh` from the current working
  directory; run every other script from the resolved repository root.
- Every workflow runs a single pass. To process a later review round, the user
  re-invokes the command. Never poll or wait for another round.
- Respect the global red lines. Selecting the `review` or `push` workflow
  authorizes only the narrowly scoped standard push defined in the matched
  workflow file; every other push and all destructive or sensitive actions
  still require explicit confirmation. No workflow pushes a protected branch
  (see `references/style.md`).
- Selecting the `root cause` workflow authorizes only the Jira field update and
  comment defined in that workflow. Complete it without asking the user to
  choose a ticket, field value, or wording.
