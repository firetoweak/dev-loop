---
name: change-discipline
description: >-
  Use when fixing a defect or changing existing behavior, scaled to risk: a light pass for small local
  fixes, a fuller pass when the change reaches shared code, decided rules, or an area that keeps being
  patched. Before editing: search history, check decided rules, count prior patches, map who is
  affected. After editing: show old paths still work, update docs in the same change, and record why.
  Prevents regressions from local fixes, patch stacking, duplicate fixes, and revert churn.
  Part of the dev-loop skill pack (entry: dev-loop).
---
# Change discipline

Agents make each change cheap and locally correct. The cost moves elsewhere: a fix for one symptom breaks a path nobody looked at, one area collects patch after patch, and the same defect is fixed twice in separate sessions. A few checks around each change keep speed from turning into rework.

## Size it first

| Level | Typical change | What to do |
| --- | --- | --- |
| **Light** | Local fix, few lines, clear cause, no shared code or decided rule involved | Search history for the symptom; run the relevant tests; one-topic commit with the reason |
| **Standard** | Touches shared code, user-visible behavior, permissions, or several callers | All of "Before" and "After" below |
| **Full** | A warning sign is present (see below), or the change reverses a decided rule | Stop patching; follow "Warning signs" first, then Standard |

Move up a level as soon as the change turns out to reach further than expected.

## Before editing

1. **Classify.** Defect against an agreed rule, rule gap, rule change, convention or style item, or new feature? Rule gaps and rule changes update the spec or decision record first, then the code. If nothing decides it, say so and record the decision rather than silently picking a behavior.
2. **Search history** for the symptom and the area. If it was fixed before, find out why it came back.
3. **Check decided rules** and constraint notes for the area. A change that contradicts one is surfaced, not made quietly.
4. **Count patches.** How many earlier changes touched this same behavior? At the third, stop adding conditions: restate the rule or redraw the state flow, confirm it, then replace the patches with one change. Report the count.
5. **Map who is affected**: callers, other places showing the same data, other roles or clients reaching the same path.
6. **Fix the scope**: which files and layers may change. Crossing into another layer (a shared protocol, a common client, a base template) is called out for separate review.

## While editing

- One source of truth: derive state from the authoritative store; do not add a local flag that must be kept in sync.
- No silent fallback: never hide failure behind an empty or default value. A temporary fallback follows the fallback rule in `runtime-judge`.
- One place per permission rule: the interface hides or disables, the backend refuses.
- Third copy: if the same logic would now exist a third time, extract it first, then change it once.
- Remove dead entries and placeholders instead of leaving them visible.

## After editing

1. **Show the fix and the old paths.** Run the check for the symptom plus the tests or scripts covering the affected paths from step 5. Done means previously working paths are shown to still work, not that the symptom disappeared.
2. **Add a regression check** for the defect at the cheapest level that catches it, when one does not already exist.
3. **Update docs in the same change** when behavior, permissions, or business meaning changed; correct any doc that still states the old rule.
4. **Commit one topic.** The message says what was broken, why, why this fix, and what was deliberately not done. Check recent history for an identical fix first.

## Reverts and shared branches

- Revert through the same review path as the original change; never revert in review and then re-add the same change outside it.
- Record who decided the revert and why; an undecided revert gets reverted again.
- Shared main lines take accepted work, not experiments.

## Warning signs: stop and find the root cause

- Many fixes in a short time on the same area
- The same file or behavior changed again and again
- Any revert
- A fix that needs a new special case for one role, one state, or one screen

When one appears, pause fixing. Write down the suspected root cause and the design question behind it, and use `spec-gate`, `runtime-judge`, or `state-judge` as fits before continuing.

## Output format

Light: one line each for history found, tests run, and commit message.

Standard and Full:

1. Classification and the rule or decision it maps to.
2. History found, patch count, and who is affected.
3. The change, files touched, any layer crossing.
4. Evidence: symptom check, regression run, added check.
5. Docs updated and the commit message.
