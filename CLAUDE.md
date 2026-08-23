# Personal Skill Repository Rules

## Purpose

This repository stores Adi's portable Agent Skills. Each Skill must be
self-contained, reusable across compatible agents, and independent of a
specific machine or platform unless its task inherently requires one.

## Structure

Use this layout:

```text
skills/
├── CLAUDE.md
├── README.md
└── skills/
    └── <skill-name>/
        ├── SKILL.md
        ├── scripts/
        ├── references/
        └── assets/
```

Each direct child of `skills/` is one Skill. Use lowercase hyphen-case names,
and keep the directory name equal to the `name` field in `SKILL.md`.

## Skill Contents

- Every Skill requires `SKILL.md`.
- Add `scripts/`, `references/`, or `assets/` only when required.
- Keep each Skill self-contained and its internal paths relative.
- Do not add plugin manifests, marketplace catalogs, platform-specific UI
  metadata, per-Skill README files, installation guides, or changelogs.

## Maintenance

- Keep each Skill focused on one reusable behavior.
- Keep paths, commands, and examples portable. Do not depend on user-specific
  absolute paths.
- Write Skill instructions, metadata, scripts, and code comments in English.
- Keep generated system files out of source control.
- Update this file before changing repository structure or conventions.

## Workflow Authorization

- Selecting the `root cause` workflow through the `ifm` Skill explicitly
  authorizes that invocation to update only the `Root Cause (migrated)` field
  and add one concise comment on the single Jira ticket selected by the
  workflow.
- Selecting the `review` workflow through the `ifm` Skill explicitly authorizes
  that invocation to push only the review-fix commit it creates to the current
  pull request branch after project validation succeeds, resolve the applied
  review threads, and request one Copilot review on that pull request after the
  workflow completes successfully.
- Selecting the `push` workflow through the `ifm` Skill explicitly authorizes
  that invocation to push the inspected commits on the current branch as
  defined in `skills/ifm/references/push.md`.
- Both push authorizations permit only a standard push. Never force-push, push
  unrelated commits, or push when the branch or pull request is uncertain.
- The review authorization does not permit requesting other reviewers, posting
  comments or reviews, or waiting for and processing the new Copilot review.
- The root-cause authorization does not permit transitions, assignments, edits
  to other fields, or writes to any other Jira ticket.
- Every other `git push` requires separate explicit confirmation.

## Validation

Validate every modified Skill before considering the work complete.

1. Run the Skill validator on each modified Skill.
2. Validate frontmatter, required files, referenced paths, and executable
   scripts.
3. Confirm that the repository contains no plugin manifests, marketplace
   catalogs, or platform-specific UI metadata.
4. Record any validation that could not be performed and the reason.
