# Adi Skills

这是 Adi 的个人 Agent Skill 集合，通过仓库级插件市场同时分发给 Codex
和 Claude Code。每个 Skill 对应一个独立插件，两端共用同一份 `SKILL.md`。

目前仅包含 `english-coach`。

## Codex

```bash
codex plugin marketplace add hd1987/skills
codex plugin add english-coach@adi-skills
```

本地开发时可以直接添加仓库路径：

```bash
codex plugin marketplace add /path/to/skills
codex plugin add english-coach@adi-skills
```

调用：

```text
/english-coach:english-coach
```

## Claude Code

```bash
claude plugin marketplace add hd1987/skills
claude plugin install english-coach@adi-skills
```

本地开发时可以直接添加仓库路径：

```bash
claude plugin marketplace add /path/to/skills
claude plugin install english-coach@adi-skills
```

调用：

```text
/english-coach:english-coach
```

## Skill 列表

| Skill | 描述 | 使用方式 |
| --- | --- | --- |
| [English Coach](./plugins/english-coach/) | 中英翻译、英文查词、发音说明与措辞修正。 | 输入 `/english-coach:english-coach explain "idempotent"`。 |
