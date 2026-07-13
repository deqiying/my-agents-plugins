# Grilling Reference

## Adaptive Interview Protocol

- Start from the user's plan or design goal, then walk its dependency tree in decision order.
- Inspect the codebase first, then classify open items as facts, blocking decisions, or independent decisions. Resolve facts without asking the user.
- Use adaptive pacing by default. Do not ask the user to select a pace before starting.
- Honor a request for **strict** pacing by asking every decision separately. Honor a request for **batch** or **fast** pacing by batching every safe independent decision.

### One-at-a-time decisions

Ask one decision per turn when it is a prerequisite for later choices, has material risk, changes a compatibility policy, contains fuzzy terminology, or conflicts with repository evidence or another answer. Give a concise recommendation and the trade-off it optimizes, then wait for the answer.

### Batched independent decisions

Group three to five related, independent decisions in one turn. For each numbered item, state the decision, recommended option, and the minimum context needed to answer it. Tell the user they may reply with compact answers such as `1A, 2B, 3A`.

- Do not hide prerequisites, alternatives, or unresolved risks inside a batch.
- Treat unanswered items as unresolved; never silently accept a recommendation.
- After a batch reply, resolve the accepted items. Return only non-default, conflicting, or ambiguous answers to one-at-a-time questioning before proceeding.
- Use concrete scenarios and edge cases only where they expose an unclear boundary; do not turn a batch into a questionnaire.

## Facts And Decisions

- Treat code, configuration, tests, existing documentation, and observable behavior as facts to investigate yourself.
- Treat product scope, priorities, compatibility policy, risk tolerance, and architecture trade-offs as user decisions. Present the decision and wait for the user.
- When repository evidence and the user's description conflict, show the specific contradiction and ask which behavior should become the intended one.

## Exit Condition

Do not implement the plan during the grilling session. Finish only after scope, terminology, ownership, behavior, constraints, and unresolved risks are either decided or explicitly deferred, and the user confirms shared understanding.
