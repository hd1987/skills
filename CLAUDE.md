# Skill Repository Rules

## Purpose

This repository stores reusable agent skills. Each skill should be
self-contained, portable, and independent of a specific machine, user, agent
runtime, or distribution platform unless the skill explicitly targets one.

## Structure

Use a flat directory layout:

```text
skills/
├── CLAUDE.md
└── <skill-name>/
    ├── SKILL.md
    ├── scripts/
    ├── references/
    ├── assets/
    └── <platform-metadata>/
```

Each direct child directory represents one skill. Use lowercase hyphen-case
names matching the `name` field in its `SKILL.md`.

## Skill Contents

- `SKILL.md` is required.
- Add `scripts/`, `references/`, or `assets/` only when required.
- Add platform-specific metadata only when needed by a supported runtime.
- Keep platform-specific instructions isolated from the portable core of the
  skill.
- Do not add per-skill README, installation guide, changelog, or duplicate
  repository rules.

## Maintenance

- Keep each skill focused on one reusable capability.
- Keep paths, commands, and examples portable. Do not depend on user-specific
  absolute paths.
- Write skill instructions, metadata, scripts, and code comments in English.
- Keep generated system files out of source control.
- Update this file before changing repository structure or conventions.

## Validation

Validate every modified skill before considering the work complete.

1. Use the repository's validation command when one exists.
2. Otherwise, verify the `SKILL.md` frontmatter, required files, referenced
   paths, and executable scripts with the tools available in the environment.
3. Record any validation that could not be performed and the reason.
