---
name: workflows-sequential-thinking
description: Use when Codex needs structured evidence-driven planning for complex, ambiguous, high-risk, multi-step work, debugging, local environment/config/plugin diagnostics, architecture decisions, tradeoff analysis, repeated failures, source/cache/runtime mismatches, or plan revision without requiring the SequentialThinking MCP.
---

# Sequential Thinking Workflow

Use this skill as a lightweight workflow replacement for routine SequentialThinking MCP usage. It is a planning and execution discipline, not a tool server.

## Use

- Use for complex tasks where the goal, constraints, evidence, impact area, or verification path must be clarified before action.
- Use for evidence-driven debugging and diagnostics: local environment issues, PATH/CLI mismatches, MCP or plugin behavior, config loading, network layers, build failures, or runtime-vs-source discrepancies.
- Use when a plan may need revision after reading files, logs, configs, docs, test output, command results, browser state, or other tool evidence.
- Use when repeated attempts fail and the next step should be chosen from observed evidence rather than momentum.
- Use before risky edits, broad refactors, migrations, plugin/config/cache changes, automation changes, cross-repo work, or changes with rollback cost.
- Use when source, installed cache, generated output, and runtime state may differ and must be checked separately.

## Avoid

- Do not use for one-line factual answers, exact `rg`/`fd` lookups, known-file edits, simple formatting, or commands with obvious success criteria.
- Do not use to replace specialized capabilities. If the task needs current docs, code semantic retrieval, web research, browser automation, spreadsheet handling, or MCP-only resources, route to the appropriate skill or MCP after this workflow identifies that need.
- Do not turn every task into a ceremony. If `workflows-guidelines` plus a direct edit is enough, use that lighter workflow.

## Workflow

1. State the root goal, hard constraints, likely risk, and the minimum evidence needed.
2. Split the work into 3-7 ordered steps with one concrete outcome per step.
3. Start with evidence gathering when facts are local or current: read relevant files, configs, logs, docs, command output, or tool results before making claims.
4. Separate similar-looking states when they can diverge: source vs generated files, source vs installed cache, config file vs loaded config, TCP vs TLS vs HTTP, test failure vs build failure.
5. Revise the plan when evidence contradicts assumptions. Keep the revised plan smaller, not broader.
6. Before file edits, state the intended edit boundary and why it is sufficient.
7. After edits, inspect the diff and run the smallest useful validation.
8. In the final answer, report the outcome, verification, and any remaining unverified boundary.

## Handoff

- If the task becomes a concrete code/config/script/plugin edit, apply `$workflows-guidelines` for the implementation discipline.
- If the task needs current official docs, third-party APIs, web research, browser automation, spreadsheet/document handling, or semantic code search, route to the relevant skill or MCP after naming why.
- If the user-facing response becomes multi-part, evidence-heavy, diagnostic, architectural, or otherwise dense, apply `$workflows-output-formatting`.

## Output

- Keep user-visible reasoning concise: expose decisions, assumptions, evidence, and plan updates, not long private scratch work.
- Prefer short Chinese status updates for Chinese users.
- Use headings only when the task is substantial.
- Report the plan as operational steps and verification checks, not private chain-of-thought.
- For any user-facing response that becomes multi-part, evidence-heavy, diagnostic, architectural, or otherwise dense, apply `$workflows-output-formatting` so the result is readable without losing important details.
- If no action is needed, answer directly with the decision and verification basis.
