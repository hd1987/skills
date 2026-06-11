# English Coach Redesign

## Goal

Refocus `english-coach` on two immediate-use capabilities:

1. Translate between Chinese and English.
2. Explain English words and phrases.

The skill should support real development and workplace communication without
turning each request into a lesson, exercise, review session, or proficiency
assessment.

## User Profile

- Primary contexts: technical discussions, meetings, project updates, pull
  requests, issues, and code review.
- Main difficulty: weak grammar foundations.
- Preferred learning method: understand grammar and usage through translation
  and vocabulary lookup in real contexts.
- Preferred English variant: natural American English.
- Explanation language: Chinese.

## Input Routing

The skill should infer the request from the input without requiring a mode
command:

- A single English word or phrase is a vocabulary lookup.
- English sentences or paragraphs are translated into Chinese.
- Chinese sentences or paragraphs are translated into English.
- An explicit user instruction overrides automatic routing.

For a standalone word or phrase, explain the common meanings directly. Do not
ask for context first. Mention context sensitivity only when it materially
changes the meaning.

## Vocabulary Lookup

Vocabulary explanations should include, when useful:

- Chinese meanings grouped by part of speech;
- IPA pronunciation;
- word stress and relevant connected-speech guidance;
- common collocations;
- examples from everyday, workplace, or software-development contexts;
- distinctions between commonly confused synonyms;
- common inflections or derived forms;
- a concise memory aid.

The response should scale with the word:

- Keep simple, unambiguous words compact.
- Expand polysemous, easily confused, or context-sensitive words.
- Do not include sections that add no useful information.

## English-to-Chinese Translation

- Provide a natural Chinese translation.
- Preserve code, commands, API names, identifiers, and technical terms in their
  original English form.
- Keep simple input concise.
- For complex or ambiguous input, explain important vocabulary, grammar, and
  expression choices.
- Do not translate technical tokens merely to make the output fully Chinese.

## Chinese-to-English Translation

- Provide one natural American English translation.
- Prefer wording suitable for the apparent context, especially software
  development and workplace communication.
- Do not provide multiple stylistic variants unless the user asks.
- Explain important wording or grammar only when the input is complex,
  ambiguous, or likely to produce unnatural English.

## Correction Policy

- Correct only errors that affect understanding or are clearly unnatural.
- Distinguish grammatical correctness from natural usage when that distinction
  matters.
- Do not turn translation requests into unsolicited grammar drills.

## Interaction Rules

- Explain in Chinese.
- Keep English examples, terminology, code, commands, API names, and
  identifiers in English.
- Give the answer first, followed by explanation only when useful.
- Do not ask onboarding questions when the input can be handled directly.
- Do not add praise, motivational filler, exercises, quizzes, or review prompts.

## Removed Behavior

The redesign removes the current defaults and workflows for:

- CET-4 learner assumptions;
- workplace diagnostic conversations;
- lesson objectives and lesson loops;
- proactive role-play and exercises;
- recurring-error tracking;
- vocabulary review and spaced retrieval;
- progress summaries;
- proactive study planning.

These may still be provided when explicitly requested, but they are not part of
the default workflow.

## Skill Structure

Use a single-file implementation:

```text
english-coach/
├── SKILL.md
└── agents/
    └── openai.yaml
```

Keep the behavioral contract in `SKILL.md`. Update `agents/openai.yaml` so its
description and default prompt represent translation and vocabulary lookup
rather than a CET-4 lesson.

## Validation

Validate the redesigned skill with representative prompts:

1. A standalone English word with multiple meanings.
2. An English technical sentence containing code or API names.
3. A Chinese workplace sentence requiring natural American English.
4. A simple sentence that should receive a concise response.
5. A complex sentence that should receive translation plus focused
   explanation.
6. A direct request for a lesson or exercise to confirm explicit requests still
   override the default workflow.

Also verify:

- valid YAML frontmatter;
- matching skill name and directory name;
- consistency between `SKILL.md` and `agents/openai.yaml`;
- no broken references or unnecessary files.
