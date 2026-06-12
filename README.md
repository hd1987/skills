# Skills

这是一个可复用的 Agent Skill 集合。每个 Skill 保持独立、可移植，并尽量避免依赖特定机器、用户或运行平台。

## Skill 列表

| Skill | 描述 | 使用方式 |
| --- | --- | --- |
| [English Coach](./english-coach/SKILL.md) | 中英翻译、英文查词与发音说明。 | 输入 `$english-coach`，然后提供需要翻译或解释的内容，例如：`$english-coach explain "idempotent"`。 |
| [English Coach Ollama Qwen2.5 7B](./english-coach-ollama-qwen2-5-7b/Modelfile.english-coach) | 基于 `qwen2.5:7b`，通过少样本对话强化中英技术文本翻译。 | 运行 `ollama create english-coach -f english-coach-ollama-qwen2-5-7b/Modelfile.english-coach` 创建模型。 |
