---
name: draft-advisor-slack-updates
description: Draft short, mobile-readable Slack updates for a research advisor. Use for meaningful findings, changes in direction, blockers, decisions, and requests for guidance. Do not use for routine experiment monitoring or message delivery.
---

# Draft Advisor Slack Updates

Return a draft for the user to review. Never send it.

## Model the Advisor's Perspective

Infer conservatively from the available context:

- what the advisor already knows;
- what has changed since the last update;
- why it matters to the research;
- what question the advisor is likely to ask;
- whether the user needs advice, a decision, or awareness.

Do not invent the advisor's knowledge, beliefs, or preferences. Ask for context only when its absence would materially change the message.

## Follow Grice's Maxims

- **Quantity:** Give enough context to understand and act. Remove everything else.
- **Quality:** State supported facts. Separate results, interpretations, plans, and unknowns. Include limitations that affect the conclusion.
- **Relation:** Include only information relevant to the research direction or the advisor's role.
- **Manner:** Lead with the main point. Use short sentences, concrete language, and terms already shared with the advisor. Do not introduce jargon.

## Choose the Content

Include only what is useful to the advisor:

- what was learned or changed;
- why it matters;
- a blocker that changes the conclusion or timeline;
- the next step;
- a clear request for input, when needed.

Omit routine runs, logs, implementation details, and unexplained run names.

## Keep It Mobile-Readable

- Usually write three to five short lines and fewer than 80 words.
- Avoid tables. State the one or two comparisons that support the point.
- Link to supporting material instead of reproducing it.
- Use headings or bullets only when they improve scanning.
- Match the user's ordinary Slack voice: short, simple sentences with one thought each.
- Prefer natural contractions and direct phrasing over polished or corporate prose.
- Do not pack several ideas into one dense sentence to meet the word limit.
- Preserve harmless roughness in the user's source text, but do not manufacture typos or errors.

If an available plot explains the result better than text, include it with the draft. Use plots that are legible on a phone, have clear labels, and support one main claim. Add one short sentence stating what the advisor should notice. Omit decorative or redundant plots.
