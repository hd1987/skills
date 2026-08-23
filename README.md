# Adi Skills

一组可复制到兼容 Agent 中使用的通用 Skills。每个 Skill 均以`SKILL.md` 作为入口。

将所需的 `skills/<skill-name>/` 目录复制到目标 Agent 的 Skills 目录。加载和调用方式取决于目标 Agent。

## 总览

| Skill | 用途 |
| --- | --- |
| [English Coach](./skills/english-coach/) | 中英互译、词汇与发音讲解、措辞修正及文档英语学习 |
| [Steelman](./skills/steelman/) | 双向钢人论证；回答关键问题后给出判断与下一步 |
| [IFM](./skills/ifm/) | 分发 commit、push、PR review、create pr 和 Jira root cause 工作流 |

## [English Coach](./skills/english-coach/)

| 使用方式 | 用途 |
| --- | --- |
| `使用 English Coach 翻译：根据需求制定完成计划` | 中英互译与自然表达 |
| `使用 English Coach 讲解单词：context` | 词义、音标、搭配和易混词讲解 |
| `使用 English Coach 分析文档：meeting-notes.docx` | 从文档中学习语法、词汇和表达 |

## [Steelman](./skills/steelman/)

| 使用方式 | 用途 |
| --- | --- |
| `使用 Steelman 分析：是否应该重构当前系统？` | 双向钢人论证并找出核心分歧 |
| 回答 Skill 提出的关键问题 | 获取明确判断、理由和下一步 |

## [IFM](./skills/ifm/)

| Workflow | 行为 |
| --- | --- |
| `commit` | 学习团队提交风格，验证改动并创建本地 commit |
| `push` | 推送当前分支，创建目标为 `develop` 的 PR，并生成 Google Chat 通知文本 |
| `review` | 处理安全的 review comments，推送修复、解决 threads 并请求 Copilot review |
| `root cause [ticket]` | 定位 Jira ticket，更新 Root Cause 并添加简短评论 |
| `create pr [source to target]` | 创建 PR；默认目标为 `develop`，`develop → qa` 使用固定 Summary |

`push`、`review` 和 `root cause` 包含受限的外部写操作，授权范围由
[IFM SKILL.md](./skills/ifm/SKILL.md) 和对应 workflow 文件定义。
