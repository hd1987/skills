---
name: steelman
description: Analyze a decision, proposal, belief, or disputed question through the strongest cases for and against the user's current position, then ask one decisive question before giving a verdict. Use when the user requests steelmanning, bilateral steelmanning, a two-sided decision analysis, or the strongest opposing case. Do not use for ordinary pros-and-cons lists that do not require a paused two-stage judgment.
---

# Steelman

Help the user reach a decision, not merely see two balanced lists. Represent both sides in forms that their strongest informed advocates could accept.

Respond in the user's language unless they request another language.

## Determine the Decision

Extract the following from the user's message:

- the underlying problem and desired outcome;
- the user's current idea or leaning;
- constraints, stakes, time horizon, and relevant alternatives;
- assumptions that materially affect the analysis.

If the current position is implicit, use the most plausible interpretation and label it as an assumption. If the user has not supplied a substantive question, ask exactly one question requesting it and stop.

## First Response: Analyze, Ask, and Stop

Use this sequence:

1. **The real problem** — Restate what the user is actually trying to solve in its strongest and most complete form. Preserve their objective, constraints, stakes, and success criteria. Surface hidden tensions without changing the question.
2. **Strongest case for the current idea** — Present the most compelling causal argument, relevant evidence, favorable conditions, and advantages over realistic alternatives. Include the best answer to the opposition's strongest objection.
3. **Strongest case against the current idea** — Challenge the idea under the same goals and constraints. Present the most credible failure modes, opportunity costs, adverse conditions, and a stronger alternative when one exists. Include the best answer to the supporting side's strongest claim.
4. **The crux** — Separate genuine disagreements about facts, values, risk tolerance, implementation, and time horizon. Identify the few variables with the highest expected impact on the conclusion, and state what observation or evidence would move the decision.
5. **One decisive question** — Ask only the single question whose answer has the highest probability of changing the verdict.

Do not give a verdict, recommendation, or action plan in the first response. Do not ask follow-up questions, offer a menu of questions, or hide extra questions in bullets or parentheticals. End immediately after the one decisive question.

## Steelman Standard

- Argue for the user's actual position, not an easier adjacent claim.
- Make the opposing case strong enough that accepting it would be rational, not merely cautious.
- Use the same objective and constraints for both sides.
- Distinguish known facts from assumptions and predictions.
- Prefer causal reasoning and decision-relevant evidence over rhetorical symmetry.
- Account for reversibility, downside magnitude, probability, opportunity cost, and the cost of waiting when they matter.
- Do not force balance when evidence is asymmetric; steelmanning concerns argument quality, not equal confidence.
- Do not invent evidence. State uncertainty precisely when the available information cannot resolve it.

## Second Response: Decide

When the user answers the decisive question, treat the answer as continuation of the same analysis. Do not repeat the full first response unless necessary.

Provide:

1. **Verdict** — Give a clear judgment: support, oppose, or support only under explicit conditions.
2. **Why** — Explain which side now dominates, which crux the answer resolved, and what uncertainty remains.
3. **Next action** — Give the smallest concrete next step that tests the key assumption or advances the decision. Include a stop condition or reassessment trigger when downside risk is material.

If the user's answer reveals that the original framing was wrong, say so directly and revise the judgment around the real decision.
