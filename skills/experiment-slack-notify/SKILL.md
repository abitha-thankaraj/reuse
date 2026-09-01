---
name: experiment-slack-notify
description: Send concise, readable Slack notifications for long-running experiments, training runs, evaluation sweeps, failures, or completed results using the configured SHOWER_THOUGHTS_SLACK_WEBHOOK_URL environment variable.
---

# Experiment Slack Notify

Use this skill when a task involves long-running experiments, multi-GPU runs,
training, benchmark sweeps, or status updates the user should see outside the
Codex UI.

## Workflow

1. Read the webhook only from `SHOWER_THOUGHTS_SLACK_WEBHOOK_URL`.
2. Send short, factual updates:
   - experiment started,
   - major milestone completed,
   - failure or interruption,
   - final result summary.
3. Do not include secrets, full commands with tokens, or large logs.
4. Keep detailed reproducibility logs in the project; Slack is only for concise
   notification.

## Helper Script

Use `scripts/notify_slack.py`:

```bash
python <skill-directory>/scripts/notify_slack.py \
  "Addition eval started on GPU 0. Run: 20260526_icl_baseline."
```

The script exits nonzero if the webhook env var is missing or Slack rejects the
message. The helper expands `\n` sequences into real line breaks before
sending, so multiline shell messages render correctly in Slack.

## Message Style

Optimize every update for quick reading on mobile. Use short Slack `mrkdwn`
sections instead of a dense paragraph:

- `:test_tube: *Experiment launched — name*`
- `*Question*`: the logical hypothesis being tested
- `*Protocol*`: model, variant, data, reward, and important controls
- `*Baseline*` or `*Results*`: compact aligned values in a code block
- `*Failure modes*`: length caps, stalls, replay rejection, sparse reward, or
  regressions, when present
- `*Decision*`: what the evidence implies and what runs next

Lead result messages with the outcome. Always identify the tested variant and
objective. Put the relevant baseline beside the new result, using the same
metrics and denominators. Show the component metrics needed to explain the
top-line score; never report only an aggregate when its parts can reveal the
failure mode. Use counts with denominators for finite eval sets and percentages
or units where they improve interpretation. Label deltas clearly.

Use Slack bullets and fenced code blocks for small, aligned score matrices.
Keep tables narrow enough for a phone screen, normally one label column plus no
more than three value columns. Avoid Markdown tables because Slack renders them
poorly. Follow a score block with one to three plain-English interpretation
bullets. Do not send large logs, long prose, cryptic run identifiers without
context, or unexplained metrics.

For launch messages, explicitly say that no result is available yet. For
failures, state what failed, its impact on validity, and how it was resolved or
what remains blocked. End completed-result messages with the decision or next
experiment implied by the evidence.

### Progress updates

Format in-progress work like a compact `tqdm` display. Always include:

- a descriptive unit such as `rollouts generated`, `training steps`, or
  `evaluation cases scored`;
- a visual progress bar;
- percent complete;
- completed and total counts;
- elapsed time and ETA when known.

Use this shape:

```text
*Progress*
`rollouts generated  [████░░░░░░] 42% • 160/384 • 22m elapsed • ETA 31m`
```

Never present an unlabeled fraction such as `64/384`; it can be mistaken for a
score. Never mix progress and accuracy in the same compact line. Label partial
metrics as provisional when they are intentionally reported; otherwise wait
for the complete result before reporting accuracy.

Preferred launch example:

````text
:test_tube: *Experiment launched — reranker B*

*Question*
Does the new reranker improve retrieval quality without unacceptable latency?

*Protocol*
• Variant: reranker B
• Data: held-out search set, n=500
• Primary metric: recall@10
• Guardrail: p95 latency

*Baseline*
```
recall@10      72.1%
p95 latency    48 ms
```

*Status*
Evaluation is running. No result is available yet.
````

Preferred failure example:

```text
:warning: *Run interrupted — reranker B evaluation*

*Failure*
The final shard timed out, so 80/500 examples are missing. Current metrics are
not directly comparable with the full baseline.

*Resolution*
The failed shard is being rerun with the same seed and configuration.
```

Preferred result example:

````text
:white_check_mark: *Result — reranker B improves recall with a latency cost*

*Results*
```
Metric          Baseline    New       Delta
recall@10         72.1%     75.4%     +3.3 pp
exact match      318/500   329/500      +11
p95 latency        48 ms     55 ms      +7 ms
```

*Failure modes*
• Most remaining misses are short or ambiguous queries.
• No timeouts or incomplete records.

*Decision*
Keep reranker B for the quality-focused path; test a smaller batch for the
latency-sensitive path.
````
