---
name: runtime-judge
description: >-
  Use when a design or change affects how work executes: threads, processes, workers, queues, async
  loops, locks, rate limits, long or slow external calls, long-lived in-memory objects, timeouts,
  cancellation, or fallbacks. Checks that slow calls stay outside locks, shared pools are not starved,
  long-lived memory is bounded, timeout meanings are distinct, and failures stay visible. Proportionate:
  answers only the questions the change actually triggers. Complements state-judge, which covers
  persistence correctness and data-access cost.
  Part of the dev-loop skill pack (entry: dev-loop).
---
# Runtime judge

A proportionate review of execution and resources: who holds what, who waits on what, what grows without bound, and what happens when something is slow or fails. These defects show up far from their cause (a timeout in one feature caused by a pool drained by another), so they are cheaper to settle in design than to debug in production.

Pairs with `state-judge`: that skill owns transactions, idempotency, and query cost; this one owns locks, pools, long-lived memory, timeouts, and failure visibility.

## Size it first

| Level | Typical change | What to do |
| --- | --- | --- |
| **Light** | Touches a slow call, a cache, or a timeout in one place without changing how work is scheduled | Answer only the questions the diff triggers, in a few lines. "No material issue" is a valid result |
| **Standard** | Adds or changes a pool, queue, lock, worker, retry, or cancellation path | Applicable questions with evidence; targeted verification for real findings |
| **Full** | Changes the execution model (inline to background, thread to process, new worker type, moved cache, new lock granularity), or symptoms already appeared under load | All applicable questions, a before/after picture of resource use, a rollback path, and entries for the constraint document |

## Scope discipline

Review only paths that actually run concurrently, actually call slow dependencies, or actually live long. Do not add locks, pools, circuit breakers, or retry layers for imagined load. Name the concrete trigger (code, configuration, observed incident) before recommending anything, and prefer the smallest local fix.

## Questions (only where applicable)

1. **Locks**: Which locks are on this path and what does each protect? Is any slow call (network, external service, file transfer, long query, heavy computation) made while holding one? Only the lines that mutate shared state belong inside.
2. **Shared pools**: Which thread pools, event loops, connection pools, or rate-limit slots does this path occupy, and for how long? Does a blocking call occupy a pool that unrelated work depends on? Can one class of work starve another (for example, batch work delaying interactive requests)?
3. **Queue states**: Are waiting, running, and finished distinct, with separate counts? One counter that means all three gives wrong progress and wrong limits.
4. **Long-lived memory**: What lives for the process lifetime (clients, indexes, caches, loaded data)? Is each bounded, and how is it released or reloaded? A reload that reuses the same long-lived object reloads nothing.
5. **Timeouts**: Which applies, with what value: idle (no progress for N seconds), total budget, queue wait? Is the timeout owned by the calling layer rather than pushed into the callee's protocol or payload?
6. **Failure visibility**: When a dependency fails or is unavailable, does the caller get an error or a distinguishable "unknown" state? Flag any silent fallback (empty collection, null, swallowed exception, default to success) that makes failure look like normal output.
7. **Batch isolation**: Does one bad item fail only itself, with the rest completing and the failure reported?
8. **Cancellation**: On cancel or disconnect, is queued work removed, running work stopped or ignored, and held slots released?
9. **Observability**: Can a stuck or slow task be diagnosed from logs alone: an ID, stage timings, queue wait, and resource counters where relevant?

Skip a question with a short reason when it does not apply.

## Fallbacks

A temporary degradation can be the right emergency move. It then carries, in the same change: a note naming the real fix, a tracked issue, an expiry date, and a log or metric when the fallback runs. A fallback without these is a known failure shipped silently.

## Verification menu (only for established risks)

| Check | Catches |
| --- | --- |
| Run several tasks of different kinds at once | Starvation, lock waits, pool exhaustion |
| Make a dependency slow or hang | Wrong timeout layer, missing idle timeout, slots never released |
| Make a dependency fail | Silent fallback, batch contamination |
| Long run or many items, memory sampled | Unbounded long-lived memory |
| Cancel mid-run | Orphaned queue entries, held slots |
| Restart mid-run | Stuck statuses, tasks never marked interrupted |

## Constraint document (Full level)

When findings concern shared resources, record them in a constraint document in the repository so later changes, by people or agents, read them first:

| Category | Content |
| --- | --- |
| Locks | What each protects; no slow calls inside |
| Pools and lanes | Name, size, users, priority |
| Long-lived objects | What, size bound, release or reload |
| Slow dependencies | Each one's timeouts and retries |
| Timeout meanings | Idle, total budget, queue wait |
| Status machines | Main objects, their states, the authoritative source |

## Output format

1. Size level and a short summary: material risks found, or none.
2. Findings with evidence, trigger, consequence, and the smallest fix.
3. Focused verification for those findings, if any.
4. Constraint-document entries (Full level).
5. If a merge decision is asked: block only on evidenced violations; list optional hardening separately.
