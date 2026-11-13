---
name: change-discipline
description: >-
  Use when fixing a defect or changing existing behavior. Preserve agreed rules and working paths,
  check the actual impact, and verify in proportion to risk. Search history only for recurring
  symptoms or unclear causes. Keep clear local fixes lightweight.
  Part of the dev-loop skill pack (entry: dev-loop).
---
# Change discipline

Preserve agreed behavior and working paths. Apply the checks that can change the decision or verify a real risk. A clear local fix needs the relevant check and a brief explanation.

## Before editing

- **Establish the expected behavior.** Read the relevant agreed rules and constraints. Resolve a material rule gap or conflict before implementing it; record a changed business rule in the existing spec or decision record.
- **Check the actual impact.** When shared behavior is touched, identify the affected callers, views, roles, or clients. Keep the investigation local when the change is local.
- **Investigate when needed.** For recurring symptoms or unclear causes, inspect relevant history and trace the current behavior. Reconsider the design when evidence shows it causes the problem.

## While editing

- Stay within the requested scope and use the authoritative state and permission rules. Enforce permissions at the backend as well as in the interface.
- Keep failures visible; do not turn an error into an ordinary empty result or success.
- Reuse shared logic where it helps. Extract an abstraction only when it simplifies the affected code without unnecessary coupling.

## Verify and finish

- Exercise the changed behavior and affected existing paths. Reuse existing tests or checks; add a focused regression check when existing coverage is insufficient for the identified defect.
- Broaden verification only for a concrete remaining risk or a required project gate.
- Update relevant docs in the same change when behavior, permissions, or business meaning changed.
- Follow the project's normal commit and review rules. For a revert, explain the reason and verify the affected behavior.

## Report

Briefly state what changed, how it was verified, and any material issue still open. Include history or decision details only when they explain the change.
