# Personal Skill Repository Rules

## Purpose

This repository stores Adi's personal Agent Skills and distributes them through
repository-level marketplaces for Codex and Claude Code. Each Skill should be
self-contained, installable, and independent of a specific machine unless it
explicitly targets one.

## Structure

Use this marketplace layout:

```text
skills/
├── .agents/
│   └── plugins/
│       └── marketplace.json
├── .claude-plugin/
│   └── marketplace.json
├── CLAUDE.md
├── README.md
├── ollama/
│   └── Modelfile.<model-name>
└── plugins/
    └── <plugin-name>/
        ├── .codex-plugin/
        │   └── plugin.json
        ├── .claude-plugin/
        │   └── plugin.json
        ├── skills/
        │   └── <skill-name>/
        │       ├── SKILL.md
        │       ├── scripts/
        │       ├── references/
        │       └── assets/
```

Each direct child of `plugins/` represents one plugin. Use lowercase hyphen-case
names matching the `name` fields in both plugin manifests. Marketplace entries
must use the same name and the source path `./plugins/<plugin-name>`.

Use one plugin per Skill. The plugin name, Skill directory name, and `name`
field in `SKILL.md` must match.

Store standalone local Ollama model definitions under `ollama/`. They are
alternative local usage assets and are not part of any Skill or plugin.

## Plugin Contents

- `.codex-plugin/plugin.json` and `.claude-plugin/plugin.json` are required.
- Put reusable agent skills under `skills/<skill-name>/`.
- Each skill requires `SKILL.md`. Add `scripts/`, `references/`, or `assets/`
  only when required.
- Keep one shared `SKILL.md` for both platforms. Do not duplicate Skill content
  into platform-specific directories.
- Do not place standalone Ollama Modelfiles inside plugin or Skill directories.
- Keep platform-specific instructions isolated from portable Skill content.
- Do not add per-plugin or per-Skill README files, installation guides,
  changelogs, or duplicate repository rules.

## Marketplace

- Keep the Codex catalog at `.agents/plugins/marketplace.json`.
- Keep the Claude Code catalog at `.claude-plugin/marketplace.json`.
- Preserve plugin order because it controls display order.
- Codex entries must include `policy.installation`,
  `policy.authentication`, and `category`.
- Claude Code entries must include `name` and `source`.
- Add a plugin to the catalog only after its manifest and referenced files are
  complete.

## Maintenance

- Keep each Skill focused on one reusable behavior.
- Keep each plugin limited to its matching Skill and required metadata.
- Keep paths, commands, and examples portable. Do not depend on user-specific
  absolute paths.
- Write Skill instructions, metadata, scripts, and code comments in English.
- Keep generated system files out of source control.
- Update this file before changing repository structure or conventions.

## Workflow Authorization

- Invoking `/ifm review` explicitly authorizes that invocation to push only the
  review-fix commit it creates to the current pull request branch after project
  validation succeeds.
- This authorization permits only a standard push. Never force-push, push
  unrelated or pre-existing commits, or push when the branch or pull request is
  uncertain.
- Every other `git push` requires separate explicit confirmation.

## Validation

Validate every modified plugin before considering the work complete.

1. Validate both marketplace files as JSON.
2. Validate every modified Codex plugin manifest with the Codex validator.
3. Run `claude plugin validate --strict` on the Claude marketplace and plugins.
4. Validate each modified Skill's frontmatter, required files, referenced
   paths, and executable scripts.
5. Record any validation that could not be performed and the reason.
