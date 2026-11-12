---
name: dev-loop
description: >-
  Entry point of the dev-loop skill pack. Use at the start of a development task, or when unsure which
  step comes next: identifies the current stage and size of the work, then names the one pack skill to
  apply (spec-gate, runtime-judge, state-judge, change-discipline, delivery-gate, retro-to-rules).
  Keeps small work light and routes large or risky work through the full loop.
---
# Dev loop

A router, not a procedure. Decide where the work is and how big it is, then apply exactly the skill that fits. Do not run every skill on every task.

## 1. Size the work

| Size | Signals | Effect |
| --- | --- | --- |
| **Light** | Local, reversible, behavior well understood; no shared state, permissions, data model, or other people's decisions | Each skill does only its first one or two steps; a few lines of output |
| **Standard** | A user-visible feature or a change across several modules, with some ambiguity | Applicable steps; about one screen of output |
| **Full** | New project or takeover; rules across several roles or states; architecture, data, or platform change; migration; several stakeholders; repeated rework in the area | The whole skill |

Start light when unsure and move up when a signal appears. Trivial edits (typos, copy, agreed config values) need no skill.

## 2. Find the stage

| Situation | Skill |
| --- | --- |
| New request, new project, unclear requirement, or taking over unfinished work | `spec-gate` |
| Changing how work executes: threads, processes, queues, workers, locks, caches, timeouts, long-running or slow calls, cancellation | `runtime-judge` |
| Changing persistence, transactions, retries, or hot read/write paths | `state-judge` |
| Fixing a defect or changing existing behavior | `change-discipline` |
| About to hand work to a reviewer, QA, or requester; or feedback came back | `delivery-gate` |
| An incident, a burst of fixes or reverts, or the end of a piece of work | `retro-to-rules` |

Loops back:

- Feedback that is a rule gap → `spec-gate`; an architecture issue → `runtime-judge` or `state-judge`; a defect → `change-discipline`.
- The same behavior changed for the third time, many fixes in a short time, or any revert → stop patching; `change-discipline` warning signs, then `spec-gate` or `runtime-judge`.

## 3. Use the project's local files

Before applying a skill, read what the repository already records: its agent instruction file, spec, decision log, constraint notes, and conventions. Project-specific rules live there, never in these skills. If a Standard or Full task finds none, say so and propose the minimal set (see the pack's MAP.md, section 五).

## Output

One line: size, stage, and the skill being applied, with the reason. Then follow that skill.
