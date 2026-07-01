---
name: workflows-guidelines
description: Karpathy-style engineering guardrails to reduce common LLM coding mistakes. Use for non-trivial implementation, bug fixes, code review, refactoring, config/scripts/CI/plugin/tooling edits, or feature work where an agent must avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.
---

# Guidelines Workflow

Karpathy-style behavioral guidelines to reduce common LLM coding mistakes.

This skill is adapted from the public `karpathy-guidelines` pattern. Keep its four core principles intact: think before coding, simplicity first, surgical changes, and goal-driven execution.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## Use

- Use for non-trivial code changes, bug fixes, feature implementation, refactors, and code review.
- Use for engineering-adjacent edits that behave like code: config, scripts, CI workflows, agent plugins, skills, local tooling, and generated glue.
- Use when the request is easy to overbuild, touches existing behavior, risks unrelated churn, or needs a clear verification boundary.

## Avoid

- Do not use for one-line factual answers, simple command output, pure writing/editing with no engineering behavior, or tiny known-file edits with obvious success criteria.
- Do not use as an architecture process. For broad design, tradeoff analysis, repeated failures, or evidence-driven diagnostics, use `$workflows-sequential-thinking` first.
- Do not override project-specific rules, user instructions, or specialized skills. Apply the stricter and more specific instruction when rules overlap.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- Read the relevant source, config, logs, docs, or command output before treating a guess as fact.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
- Prefer existing project helpers, patterns, and dependencies over introducing new ones.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.
- Preserve user changes and unrelated worktree state. Work with unexpected changes instead of reverting them.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"
- "Update a plugin skill" -> "Update source and installed cache, then compare hashes or diff"
- "Fix a config issue" -> "Read the active config, apply the smallest change, then run the command that proves it is loaded"

For multi-step tasks, state a brief plan:
```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Reader-Facing Output

When a user-facing update or answer includes multiple decisions, files, risks, verification steps, or implementation details, apply `$workflows-output-formatting`. Keep simple answers simple, but make dense answers easy to scan without dropping important facts.
