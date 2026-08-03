---
name: guidelines
description: Engineering guardrails for non-trivial code, config, script, CI, plugin, or tooling changes. Use when an agent needs to control scope, avoid unsupported complexity, and choose verification proportional to risk; do not use for factual queries or simple known-file edits.
---

# Guidelines Workflow

Use these lightweight guardrails to reduce common engineering mistakes. They are not a mandatory thinking process or an architecture-design workflow.

Keep four principles: verify before deciding, simplicity first, surgical changes, and goal-driven verification.

For small changes with a clear scope and obvious success criteria, act directly.

## Use

- Non-trivial code changes, bug fixes, feature implementation, refactors, and code review.
- Engineering-adjacent changes to config, scripts, CI workflows, agent plugins, skills, local tooling, and generated glue.
- Work that is easy to overbuild, touches existing behavior, risks unrelated churn, or needs a clear verification boundary.

## Avoid

- One-line factual answers, simple command output, writing without engineering behavior, or tiny known-file edits with obvious success criteria.
- Architecture decisions, repeated failures, or evidence-driven diagnostics; use `$evidence-diagnostics` or the appropriate specialized skill instead.
- Do not override project rules, user instructions, or specialized skills. Apply the more specific rule when they overlap.

## 1. Verify Before Deciding

- Read the relevant source, config, logs, docs, or command output before treating a guess as fact.
- For low-risk ambiguity, state the concrete assumption and proceed. Ask the user only when the answer changes scope, compatibility, cost, or reversibility.
- Surface alternatives and tradeoffs only when they materially change the result; do not interrupt execution for irrelevant details.

## 2. Simplicity First

- Implement only the requested behavior. Do not add single-use abstractions, speculative configuration, or unneeded extension points.
- Do not add complex branches for unsupported hypothetical scenarios, but preserve known boundaries and real error handling.
- Prefer existing project helpers, patterns, and dependencies. Explain why a new long-term dependency is necessary.

## 3. Surgical Changes

- Each change must trace to the user goal, a required generated artifact, or verification. Preserve unrelated worktree changes.
- Do not opportunistically refactor, remove pre-existing dead code, or reformat adjacent code. Update formatter output, lockfiles, or generated files only when directly caused by this change.
- Remove unused imports, variables, or functions created by this change; leave pre-existing cleanup alone.

## 4. Goal-Driven Verification

- Define the smallest success criterion proportional to risk, then choose tests, lint, build, runtime checks, diff inspection, or manual review.
- Add or run tests when the behavior risk warrants them and the project has a suitable test foundation. Do not invent a test framework or expand scope for formality.
- When updating a plugin or skill, update the source and declared generated mirror. Do not refresh installed caches or marketplaces unless the user explicitly asks for installation verification.
- Inspect the diff, run the smallest sufficient validation, and report remaining unverified boundaries.

## 5. Reader-Facing Output

When a user-facing update or answer includes multiple decisions, files, risks, verification steps, or implementation details, apply `$output-formatting`. Keep simple answers simple.
