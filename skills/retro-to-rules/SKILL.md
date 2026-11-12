---
name: retro-to-rules
description: >-
  Use after an incident, a burst of fixes or reverts, a painful review cycle, or at the end of a piece
  of work. Scaled to size: one root cause and one rule for a single incident; a measured, stage-by-stage
  retrospective for a longer period. Checks whether earlier retrospective actions actually landed and
  turns each lesson into an executable rule (a skill, an agent instruction file, a check, a test, or a
  constraint note). A lesson that stays only in a report does not count.
  Part of the dev-loop skill pack (entry: dev-loop).
---
# Retro to rules

A retrospective that only produces a report repeats a month later. The output of this skill is changes to what people and agents actually execute, plus a record of where each lesson landed.

## Size it first

| Level | Trigger | What to do |
| --- | --- | --- |
| **Light** | One incident or one surprising defect | Find the root cause, name the stage that should have caught it, land one rule (Step 4). A few lines |
| **Full** | A period with many fixes or reverts, a long review cycle, or the end of a project | All steps |

Do not create rules for one-off events without evidence they recur.

## Step 1: Measure, do not recall (Full)

Collect numbers before discussing causes:

- Changes per day over the period, fix and revert counts, the densest days.
- The most frequently changed files or behaviors; anything changed three or more times.
- Reverts, re-adds of reverted changes, duplicate fixes.
- Reviewer or QA items, if tracked, classified with the `delivery-gate` triage classes, with the share of each.
- Churn in specs or rule documents (high churn means rules were decided during implementation).

Keep measured numbers apart from estimates. When grouping fixes under one cause, state the evidence (timing, same area, change messages naming the cause).

## Step 2: Root causes by stage

Map each cluster to the stage where it was cheapest to catch:

| Stage | Guard | Typical leak |
| --- | --- | --- |
| Deliverable and takeover | `spec-gate` steps 0–1 | Wrong deliverable; unknown existing work; unwalked flows |
| Definition | `spec-gate` | Rule gaps found in review; the same rule changed several times |
| Design | `runtime-judge`, `state-judge` | Concurrency, resources, timeouts, state authority, idempotency |
| Implementation | `change-discipline` | Patch stacking; regressions from local fixes; duplicate fixes; revert churn |
| Self-verification | `delivery-gate` | Reviewers finding defects a scripted run would catch |
| Handoff and feedback | `delivery-gate` | One-item-at-a-time handoffs; no freeze point; unclassified feedback |

For each stage: did the guard exist, was it used, was it sized right, and did it cover this problem? The answer decides whether to add a rule, sharpen an existing one, adjust its size criteria, or make sure it gets invoked.

## Step 3: Check earlier actions (Full)

List the previous retrospective's actions and mark each landed (where), partly landed, or not landed. Match recurring problems against what did not land, and carry unlanded actions forward instead of rediscovering them.

## Step 4: Land each lesson

Put each lesson where it will be read at the moment it matters:

| Place | Use for |
| --- | --- |
| A skill | Stage procedures and review questions |
| The repository's agent instruction file | Rules for changes in that repository, and which skill to use when |
| Global agent instructions | Habits that apply across all work |
| An automated test or check | Anything checkable mechanically |
| A constraint note in the repository | Locks, pools, caches, timeouts, state flows, decided rules |
| Written conventions | Interface or style conventions surfaced by feedback |

Keep rules short and specific. Prefer adding a line to an existing skill over creating a new one. Keep project names out of general skills; project-specific lessons go in that project's files.

## Step 5: Report

Light: root cause, the stage that should have caught it, and the rule added (file and text).

Full:

1. Period, sources, measured profile.
2. Root causes by stage, with evidence.
3. Earlier actions: landed, partly, not landed.
4. Lessons and where each landed (file and the exact rule).
5. Metrics to compare next time: reviewer items, defect share, rule gaps raised before review, reverts, behaviors changed three or more times, time from first handoff to release, earlier actions landed.
