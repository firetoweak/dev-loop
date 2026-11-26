---
name: dev-loop
description: >-
  Entry point of the dev-loop skill pack. Use at the start of a development task, or when unsure which
  step comes next: identifies the current stage and size of the work, then names the one pack skill to
  apply (spec-gate, runtime-judge, state-judge, change-discipline, delivery-gate).
  Keeps small work light and selects applicable checks for larger or riskier work.
---
# Dev loop

A router, not a procedure. Decide where the work is and how big it is, then apply only the skill that fits the current stage (usually one; pair `runtime-judge` and `state-judge` when a design touches both execution and persistence). Do not run every skill on every task.

## 0. Mode boundary

Stay read-only before the user explicitly authorizes implementation: do not create branches, edit repository files, or open PRs while discussing an idea, reviewing an issue, or shaping an unsettled requirement. Only trivial edits with an agreed target skip this gate.

If implementation reveals that an agreed premise no longer holds, stop and realign instead of silently changing requirements or loosening acceptance criteria.

## 1. Size the work

| Size | Signals | Effect |
| --- | --- | --- |
| **Light** | Local, reversible, behavior well understood; no shared state, permissions, data model, or other people's decisions | Essential checks and a brief result |
| **Standard** | A user-visible feature or a change across several modules, with some ambiguity | Applicable steps; about one screen of output |
| **Full** | New project or takeover; rules across several roles or states; architecture, data, or platform change; migration; several stakeholders | All applicable checks |

Start light when unsure and expand only when the actual scope or risk calls for it. Trivial edits (typos, copy, agreed config values) need no skill.

## 2. Find the stage

| Situation | Skill |
| --- | --- |
| New request, new project, unclear requirement, or taking over unfinished work | `spec-gate` |
| Changing how work executes: threads, processes, queues, workers, locks, caches, timeouts, long-running or slow calls, cancellation | `runtime-judge` |
| Changing persistence, transactions, retries, or hot read/write paths | `state-judge` |
| Implementing a cleared brief, fixing a defect, or changing existing behavior | `change-discipline` |
| About to hand work to a reviewer, QA, or requester; or feedback came back | `delivery-gate` |

Loops back:

- Feedback that is a rule gap → `spec-gate`; an architecture issue → `runtime-judge` or `state-judge`; a defect → `change-discipline`.

## 3. Use the project's local files

Before applying a skill, read what the repository already records: its agent instruction file, spec, decision log, constraint notes, and conventions. Project-specific rules live there, never in these skills. If a Standard or Full task finds none, say so and propose only the minimal repo files actually needed; do not invent unused template docs.

## Output

One line: size, stage, and the skill being applied, with the reason. Then follow that skill.
