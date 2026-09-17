---
name: ifm
description: Dispatch a personal work workflow by name. Use when the user selects the IFM Skill with a workflow such as `root cause [ticket]` to identify a related Jira ticket and record its root cause, `review` to process pull request review comments and request the next Copilot review, or `create pr [source to target]` to open a pull request.
---

# IFM

## Purpose

A dispatcher for repository work workflows. The
argument after the skill name selects which workflow to run. Each workflow is
defined in its own file under `references/`. Load only the matched file — and
`references/style.md` when the table below requires it — and execute it
exactly.

## Route Workflows

Read the argument, lowercase it, and match its leading keyword against the table
below. Matching is case-insensitive and ignores surrounding whitespace. Any
tokens after the matched keyword are parameters passed to the workflow.

| Leading keyword (aliases) | Parameters | Workflow file | Also load |
| --- | --- | --- | --- |
| `root cause` | optional `[<ticket>]` | `references/root-cause.md` | — |
| `review` | none | `references/review.md` | — |
| `commit` | none | `references/commit.md` | `references/style.md` |
| `push` | none | `references/push.md` | `references/style.md` |
| `create pr` | optional `[<source> to <target>]` | `references/create-pr.md` | `references/style.md` |

Steps:

1. If the argument matches a row, read that workflow file and any file in
   **Also load**, then follow them literally. Do not improvise beyond what
   those files specify. Do not probe git/GitHub history to learn commit or
   PR-title style; `references/style.md` is the source.
2. If the argument is empty, list the available workflows from the table and
   stop.
3. If the argument does not match any row, state that no workflow matched, list
   the available workflows, and stop. Do not guess.

## Conventions

- Every workflow runs a single pass. To process a later review round, the user
  re-invokes the command. Never poll or wait for another round.
- Respect the global red lines. Selecting the `review` or `push` workflow
  authorizes only the narrowly scoped standard push defined in the matched
  workflow file; every other push and all destructive or sensitive actions
  still require explicit confirmation.
- Selecting the `root cause` workflow authorizes only the Jira field update and
  comment defined in that workflow. Complete it without asking the user to
  choose a ticket, field value, or wording.
