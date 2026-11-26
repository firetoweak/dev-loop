---
name: delivery-gate
description: >-
  Use before handing work to a reviewer, QA, a requester, or a decision-maker, and when their feedback
  comes back. Scaled to size: a quick self-check and a short note for small work; invariants,
  end-to-end scenarios, a delivery note with evidence, feedback triage, and a freeze point for large
  work. Aims for handoffs where reviewers find missing features, not defects.
  Part of the dev-loop skill pack (entry: dev-loop).
---
# Delivery gate

The standard: what reaches the reviewer has no implementation defects, only things nobody discussed. The reviewer judges whether the result is right; the reviewer should not be the first to exercise it end to end.

## Size it first

| Level | Typical handoff | What to do |
| --- | --- | --- |
| **Light** | A small fix or local change | Exercise the change and its nearest neighbors the way a user would; run the relevant tests; a two- or three-line note |
| **Standard** | A feature or a batch of changes | Step 2 invariants the batch can affect; the delivery note |
| **Full** | A release, a first handoff of a large piece of work, or a round of reviewer feedback | All steps |

## Step 1: Batch (Standard and Full)

Hand over in batches rather than one fix at a time. Each batch lists the items it covers, mapped to the spec, the decision record, or the reviewer's tracking list.

## Step 2: Self-verify

Exercise the real thing the way its user does: the interface, command, API, or job. Use whatever scripted driver the project has (end-to-end tests, a verification skill, a scripted session). If none exists and the work is Full size, create one; otherwise a written manual script is acceptable.

### General invariants (check those the change can affect)

- **Reload**: after any write, reading again shows the same result.
- **One truth**: the same data shown in two places matches.
- **Permission**: an action unavailable to a role is unavailable in the interface and refused by the backend.
- **Restart**: after delete, cancel, stop, or undo, the flow can start again without leftovers.
- **Visible failure**: failures show an error or explicit status, never a silent empty or "normal" result.
- **Recovery**: a failed save, lost connection, or process restart leaves nothing in a wrong state.
- **Concurrency**: two users or clients acting together each get correct results.
- **Resources**: long runs or large batches do not grow memory, connections, or threads without bound.
- **No regression**: the full regression suite passes, not only tests for this change.

### Work-specific checks

Verify the observable acceptance checks from the Handoff Brief (`spec-gate`) and any targeted checks identified during `runtime-judge` or `state-judge`, stated as checkable facts.

### End-to-end scenarios (Full)

Run a few scenarios that go from creation through the end of the lifecycle and back to a restart. At each step: switch role where roles exist, reload, check invariants. Keep evidence (screenshots, transcripts, resulting state).

### Existing conventions (if any)

Check changed parts against the repository's written conventions if any exist. Do not invent a new conventions file during delivery.

If a check fails, fix it with `change-discipline` before handing over, or list it in the note with a reason.

## Step 3: Delivery note

Light: what changed, how it was checked, anything open.

Standard and Full:

```
Version and date
1. Contents: items covered (tracking IDs, brief items, or spec sections)
2. Self-verification: scenarios run/passed; invariants and work-specific checks (exceptions); evidence location
3. Rules or constraints changed: updated decisions and new conclusions
4. Open questions for the reviewer or decider, each with a recommendation
5. Suggested focus for review
```

## Step 4: Triage feedback (Full)

Classify each item before changing anything:

| Class | Action |
| --- | --- |
| Implementation defect | Fix with `change-discipline`; run the relevant regression checks and add a focused check when existing coverage is insufficient |
| Rule gap | Decide first (`spec-gate`); update existing spec/decision docs if the repo keeps them, otherwise record in the task/PR, then change |
| Architecture issue | Assess impact with `runtime-judge` or `state-judge`, update existing constraint notes if the repo keeps them, then fix |
| Preference | Collect and handle in one batch |
| New feature | Estimate and schedule later |

If the reviewer keeps a tracking list, suggest columns for class, decider, and regression check.

## Step 5: Freeze point (Full)

Agree a freeze point with the decider, for example after two full review rounds. After it, preference items go to a post-release list and do not block the handoff.

## Output format

Light: the short note.

Standard and Full: batch contents, self-verification results with evidence, the delivery note, and for feedback rounds the triage table with what each class led to.
