# Adi Skills

个人 Agent Skill 集合，支持 Codex 和 Claude Code。

## Skills

| Skill | 功能 |
| --- | --- |
| [English Coach](./plugins/english-coach/) | 中英翻译、英文查词、发音说明、措辞修正与文本/文档英语学习分析 |
| [My Workflow](./plugins/my-workflow/) | 按名称分发个人工作流：Copilot review 分流、团队风格 commit、push 建 PR、指定分支建 PR |

## 安装

### Codex
```bash
codex plugin marketplace add hd1987/skills
codex plugin add english-coach@adi-skills
codex plugin add my-workflow@adi-skills
```

### Claude Code
```bash
claude plugin marketplace add hd1987/skills
claude plugin install english-coach@adi-skills
claude plugin install my-workflow@adi-skills
```

安装后通过以下命令调用：

```text
/english-coach:english-coach
/my-workflow cr                 # Copilot review 分流
/my-workflow commit             # 团队风格本地 commit
/my-workflow push               # 当前分支 → develop，push + 建 PR + Google Chat
/my-workflow pr develop to qa   # 指定分支建 PR
```

## 本地 Ollama

本地模型使用独立的 [Modelfile](./ollama/Modelfile.english-coach)，不属于
Codex 或 Claude Code Skill。跨机器使用前，将其中的 `FROM` 改为可用的基础模型：

```text
FROM qwen2.5:7b
```

```bash
ollama create english-coach -f ollama/Modelfile.english-coach
ollama run english-coach
```
