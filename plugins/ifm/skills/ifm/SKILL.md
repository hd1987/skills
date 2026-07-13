---
name: ifm
description: Dispatch a personal work workflow by name. The first argument selects the workflow to run. Use when the user invokes `/ifm` with a workflow name, for example `/ifm review` to triage, fix, commit, push, and resolve pull request review comments, or `/ifm pr create` to open a pull request.
---

# IFM

## Purpose

A dispatcher for Adi's personal work workflows. The argument after the skill
name selects which workflow to run. Each workflow is defined in its own file
under `references/`. Load only the matched file and execute it exactly.

## Route Workflows

Read the argument, lowercase it, and match its leading keyword against the table
below. Matching is case-insensitive and ignores surrounding whitespace. Any
tokens after the matched keyword are parameters passed to the workflow.

| Leading keyword (aliases) | Parameters | Workflow file |
| --- | --- | --- |
| `review` | none | `references/review.md` |
| `commit` | none | `references/commit.md` |
| `push` | none | `references/push.md` |
| `pr create` | optional `<source> to <target>` | `references/pr-create.md` |

Steps:

1. If the argument matches a row, read that workflow file and follow it
   literally. Do not improvise beyond what the file specifies.
2. If the argument is empty, list the available workflows from the table and
   stop.
3. If the argument does not match any row, state that no workflow matched, list
   the available workflows, and stop. Do not guess.

## Conventions

- Every workflow runs a single pass. To process a later review round, the user
  re-invokes the command. Never poll or wait for another round.
- Respect the global red lines. Invoking `/ifm review` authorizes only the
  narrowly scoped push defined in `references/review.md`; every other push and
  all destructive or sensitive actions still require explicit confirmation.
