---
name: spec-gate
description: >-
  Use before building something whose requirements are unclear, inherited, or spread across people:
  a new feature or project, taking over half-finished work, or a request that could be read two ways.
  Scaled to size: for small work it is a one-line deliverable check and a question or two; for large
  work it inventories what already exists and produces a short list of blocking decisions with
  recommendations. Moves requirement gaps before implementation instead of into review or testing.
  Part of the dev-loop skill pack (entry: dev-loop).
---
# Spec gate

Move requirement discovery left. A gap raised before building looks like diligence; the same gap found in review or testing looks like a defect. The aim is that the builder, the reviewer, and the decision-maker read the same truth, and that only the decisions that actually block work are surfaced.

This is a gate, not a design document. Do only what the size of the work calls for.

## Size it first

State the level in one line with the reason. Move up a level if signals appear while working. Never pad output to look thorough.

| Level | Typical work | What to do |
| --- | --- | --- |
| **Light** | Small, local, reversible; behavior well understood; no shared state, permissions, data model, or other people's decisions involved | Step 0 only. Raise a question only if two reasonable readings lead to different results. No tables, no log |
| **Standard** | A user-visible feature, or a change spanning several modules, with some ambiguity | Step 0; Step 1 items that apply (usually 1, 3, 5); a questions table with at most 3 P0 |
| **Full** | New project or takeover; rules involving several roles or states; architecture, data, or platform change; migration; several stakeholders; or repeated rework in this area | All steps |

Skip the skill entirely for trivial edits (typos, copy changes, config values with an agreed target).

## Step 0: Confirm the deliverable

One sentence: what does the requester want, and what does "done" mean?

- Code, a document, a plan, or a discussion?
- An output for this piece of work, or a reusable method?
- Who judges it, and how?

If it is ambiguous between forms, ask before producing anything. If you cannot ask, write the question you would ask, proceed under the most reasonable reading, state that assumption at the top, and treat the ambiguity as a P0 question.

## Step 1: Inventory what exists

Facts with references (file and line, commit, document). No design proposals here. Go in order; stop when the remaining items cannot change a blocking decision.

1. **Already done?** Existing implementations, prototypes, experiments, and documents for this area. Finding working pieces changes the work from "build" to "finish", "productize", or "merge".
2. **Parallel lines of work.** Other branches, forks, or versions that touch the area: where they diverged, what changed on each side, and whether one side depends on something the other removed or replaced.
3. **Confirmed conventions.** Design notes, decision logs, handover notes, and agent instruction files. A convention that conflicts with the literal request is a P0 question, not something to resolve silently.
4. **Riskiest assumption.** The dependency the plan relies on most (a library, service, platform capability, data source, environment). Check its maturity and whether every target environment can support it. If uncertain, it becomes a probe in the gate.
5. **Walk the existing flows.** Run them end to end where possible. Otherwise trace statically: for each entry point (screen action, command, endpoint, job), find what it calls and whether that target exists and is wired. Mark each as real, simulated, dead, or contradicting its own description. Unwalked paths become late defects.
6. **Hidden rules in old behavior.** If existing behavior is being replaced, list the rules embedded in it: preconditions, limits, reuse or deduplication, what counts as success on empty input, ordering.
7. **Actors and systems.** Who uses or operates it (including people with more than one role), upstream and downstream systems, and environments.

Keep apart what you found and what you must ask. Who decides rules, who decides details, and when the spec is frozen are questions for the requester unless the sources answer them.

If the inventory cannot be finished, say what was and was not covered.

## Step 2: Pick the primary type and its artifacts

Choose one primary type and produce its artifacts as compact tables (key rows only). For secondary types, produce no artifacts; turn their "usually missed" items into questions where they apply.

| Type | Signal | Artifacts (primary only) | Usually missed |
| --- | --- | --- | --- |
| Rules and permissions | Several roles, states, or permissions | Role × state × action table; lifecycle states; data shown in more than one place | The end of the lifecycle (archive, delete, undo, restart); one person in two roles |
| Technical change or migration | New technology, platform, or architecture; replacing old behavior | Reuse-or-rewrite table; migration steps, each with rollback | Support in every environment; rules hidden in old behavior; a baseline to compare against |
| Interaction | Many screens, commands, or small operations | Mock or annotated flow; interaction conventions | Empty, error, in-progress, cancelled, and extreme-input states |
| Quality by metric | Success measured by a number | Evaluation set; baseline; acceptance threshold | No baseline, so "better" cannot be judged |
| Integration | Another system on the other side | Contract, errors, timeout and retry policy | Behavior when the other side fails or is slow |

Write artifacts so that non-builders who judge the result can read them.

If the design will touch concurrency, long-running work, caches, timeouts, or persistence, note `runtime-judge` and `state-judge` as follow-ups for the design stage. They are not gate conditions.

## Step 3: Blocking questions

Each material ambiguity becomes a row with a recommendation, so the reviewer chooses rather than designs.

| ID | Priority | Question | Context (with reference) | Recommendation | Alternative | Decider |
| --- | --- | --- | --- | --- | --- | --- |

- **P0** blocks starting; **P1** blocks one part. Leave lower-priority items out.
- At most 5 P0 and 5 P1. More than that means the scope should be split.
- Each question needs a concrete case where two reasonable readings lead to different behavior.
- Never settle a business question by silently choosing an implementation.

Question families that often matter:

- **Rules and permissions**: inheritance from a parent; where a revoked right goes; default view for a person in two roles; what happens to rights, messages, and data at the end of the lifecycle; who is notified and where; which side wins when external data conflicts.
- **Technical change**: what "all" or "everything" covers; which line of work is the base; which old behavior stays; how success is measured against the old behavior; environments that cannot support the change; cost per run.
- **Any type**: cost and quotas, audit, permission checks, behavior when a dependency fails.

## Step 4: Decision log

For Standard work, a few lines in the task or the spec is enough. For Full work, keep a table next to the spec:

| Date | Question | Decision | Reason | Decider | Section affected |
| --- | --- | --- | --- | --- | --- |

Seed it with conventions already confirmed (Step 1.3), citing their source. A decided question that returns is answered from the log; reversing it needs a new reason in a new row.

## Gate

Light: pass when the deliverable is clear.

Standard and Full: pass when the deliverable is confirmed, every P0 has a recorded decision, and the riskiest assumption is probed or explicitly accepted as a risk. For Full work, also: primary artifacts reviewed with the decider, and the repository's agent instruction file points to the spec and the decision log.

## Output format

Light: one or two lines.

Standard and Full, about one screen, ordered by value:

1. Size level and deliverable (with any assumption made).
2. Facts that change the work: the few findings that change its nature, scope, or base, with references.
3. Other facts, brief; what was not covered.
4. Primary type and artifacts (Full only, compact).
5. Blocking questions, P0 first.
6. Gate status, including any probe to run.
