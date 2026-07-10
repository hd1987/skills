---
name: my-workflow
description: Dispatch a personal work workflow by name. The first argument selects the workflow to run. Use when the user invokes `/my-workflow <name>`, for example `/my-workflow copilot review` or `/my-workflow cr` to triage, fix, commit, and resolve pull request code review comments.
---

# My Workflow

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
| `copilot review`, `cr` | none | `references/copilot-review.md` |
| `commit` | none | `references/commit.md` |
| `push` | none | `references/push.md` |
| `pr` | `<source> to <target>` | `references/pr.md` |

Steps:

1. If the argument matches a row, read that workflow file and follow it
   literally. Do not improvise beyond what the file specifies.
2. If the argument is empty, list the available workflows from the table and
   stop.
3. If the argument does not match any row, state that no workflow matched, list
   the available workflows, and stop. Do not guess.

## Conventions

- Every workflow runs a single pass. To advance multiple rounds, the user
  re-invokes the command; a re-invocation is the only loop trigger.
- Respect the global red lines. Never `git push`, delete history, or touch
  secrets and CI config without explicit confirmation, even inside a workflow.
