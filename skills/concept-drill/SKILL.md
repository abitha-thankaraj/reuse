---
name: concept-drill
description: Teach technical concepts through first-principles decomposition, staged implementation exercises, tests, debugging, edge cases, counterexamples, and explain-back checks. Use when the user wants to master a concept deeply enough to implement, debug, explain, and recognize its failure modes—not when they only want a quick factual explanation or a finished implementation.
---

# Concept Drill

Help the user develop implementation-level understanding rather than memorize a definition. Keep the drill grounded in executable work and observable evidence.

## Set the target

- Infer the target concept, intended use, and the user's starting level from context.
- If the target concept is missing, ask one concise question before building the drill.
- Decompose the concept into prerequisites, core mechanisms, assumptions, interfaces, and failure modes.
- Choose a short sequence of checkpoints in which each step depends on understanding the previous one.

## Run an active drill

For each checkpoint, use the smallest useful combination of:

1. A precise explanation of the mechanism.
2. A minimal concrete or executable example.
3. An implementation task for the user.
4. Tests or invariants that reveal whether it works.
5. A debugging prompt based on a realistic mistake.
6. Mastery questions that require explaining why, not recalling terminology.

Let the user implement each meaningful component. Do not reveal a complete solution immediately unless the user explicitly asks for one. When the user is stuck, escalate help from a targeted question, to a hint, to partial scaffolding, and then to a full solution if requested.

Evaluate answers directly and specifically:

- Identify vague language, missing assumptions, and incorrect causal claims.
- Probe edge cases and construct counterexamples.
- Require concrete mechanisms, data flow, shapes, invariants, or equations when they matter.
- Distinguish a conceptual gap from a syntax or tooling mistake.
- Critique the answer or implementation, never the person.
- Avoid empty praise; say exactly what is correct and what remains unsupported.

Advance when the user demonstrates the checkpoint through a correct implementation, explanation, prediction, or debugging result. If the user asks to move on, change pace, or receive the solution, follow that request.

## Build notebooks when useful

Create a staged `.ipynb` notebook when the user requests one or when executable progression materially improves the lesson. Make it an active workbook rather than passive exposition:

- Keep explanations short and place them next to the relevant code.
- Use small, runnable examples before exercises.
- Leave focused implementation cells for the user.
- Add assertions, tests, edge cases, and debugging prompts that produce useful feedback.
- Keep later cells from silently depending on hidden state or unrevealed solutions.
- Preserve the repository's existing notebook and environment conventions when working in a project.

Do not create a notebook merely because the topic contains code; a conversational drill is often sufficient.

## Finish with transfer

End a substantial drill with a compact task that asks the user to implement the concept from scratch, diagnose a failure, explain the mechanism, and state where the approach breaks down. Summarize demonstrated strengths and remaining gaps using evidence from the drill.
