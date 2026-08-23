# Adi Skills

个人 Agent Skill 集合，支持 Codex 和 Claude Code。

## Skills

| Skill | 功能 |
| --- | --- |
| [English Coach](./plugins/english-coach/) | 中英翻译、英文查词、发音说明、措辞修正与文本/文档英语学习分析 |
| [IFM](./plugins/ifm/) | 按名称分发个人工作流：填写 Jira root cause、PR review 处理、团队风格 commit、push/create pr 建 PR |
| [Steelman](./plugins/steelman/) | 对决策或观点进行双向钢人论证，在回答一个关键问题后给出明确判断与下一步行动 |

## 安装

### Codex
```bash
codex plugin marketplace add hd1987/skills
codex plugin add english-coach@adi-skills
codex plugin add ifm@adi-skills
codex plugin add steelman@adi-skills
```

### Claude Code
```bash
claude plugin marketplace add hd1987/skills
claude plugin install english-coach@adi-skills
claude plugin install ifm@adi-skills
claude plugin install steelman@adi-skills
```

安装后通过以下命令调用：

```text
# English Coach
/english-coach:english-coach

# Steelman
/steelman:steelman

# IFM
/ifm commit                 # 团队风格本地 commit
/ifm push                   # 当前分支 → develop，push + 建 PR + Google Chat
/ifm review                 # PR review 处理完成后请求 Copilot review
/ifm root cause [ticket]    # 定位 Jira ticket，填写 Root Cause 并添加简短评论
/ifm create pr [source to target] # 建 PR；默认当前 → develop，develop → qa 时固定 Summary、不输出 Ticket
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
