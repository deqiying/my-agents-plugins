---
name: workflows-output-formatting
description: Automatically use when any user-facing response needs clearer layout, hierarchy, spacing, grouping, or scanability because it is multi-part, evidence-heavy, tool-heavy, technical, diagnostic, a design/architecture plan, an implementation summary, a review, or otherwise dense.
---

# Output Formatting Workflow

Use this skill as a response-shaping layer for any user-facing message. It improves structure, hierarchy, spacing, and scanability after the facts are known.

This is not a compression skill. Do not remove decision-critical details just to make the answer shorter.

## Goal

Make the response easier to read and navigate while preserving the facts, evidence, paths, risks, and next steps the user needs.

## Apply Automatically

Apply this skill before writing a user-facing response when layout affects readability:

- The response has multiple findings, recommendations, steps, files, commands, risks, or validation results.
- The response is a diagnostic summary, implementation report, architecture/design plan, code review, comparison, research result, or long technical explanation.
- The response includes dense evidence from files, logs, configs, command output, web sources, or tool calls.
- The draft feels visually noisy: long unbroken paragraphs, chronology-by-tool, repeated phrasing, mixed levels of detail, deep nesting, or too many code blocks.
- Another workflow produced a long plan or analysis that needs a reader-facing shape.

Do not force visible structure onto simple answers. If one or two natural sentences are enough, leave them that way.

## Formatting Strength

- L0 simple: answer directly in one short paragraph. No heading, table, or list unless it genuinely helps.
- L1 light: use one or two short paragraphs, inline paths/commands, and a clear verification sentence if useful.
- L2 standard: use a short conclusion first, then a few semantic sections such as evidence, changes, validation, risks, or next steps.
- L3 deep: use an executive summary plus layered sections. Tables, lists, and code blocks are allowed when they improve comparison, precision, or implementation readiness.

## Workflow

1. Choose the answer shape before writing:
   - Tiny task: one short paragraph, optionally one verification sentence.
   - Diagnostic or implementation task: outcome first, then changes/evidence, then verification and boundaries.
   - Comparison or recommendation: conclusion first, then a criteria table or grouped bullets when they improve scanning.
   - Architecture or design task: recommendation first, then layered rationale, model/API/data shapes, tradeoffs, rollout, and validation.
   - Failure or blocker: current state first, then exact blocker, evidence, and the smallest useful next step.
2. Put the highest-value conclusion in the first 1-2 sentences.
3. Preserve important information, but remove duplicate wording, transcript noise, and low-value process narration.
4. Collapse raw tool output into meaning. Report commands, paths, exit status, and key lines only when they support the decision.
5. Group information by reader intent, not by the order tools were called.
6. Keep lists flat where possible. If a list becomes long, split it into named groups instead of nesting deeply.
7. Use tables for comparisons, status matrices, option selection, and compact field mappings. Avoid tables when prose is clearer.
8. End with verification status and any remaining unverified boundary when the task involves implementation, diagnostics, or factual claims.

## Chinese Technical Style

- Default to Simplified Chinese when the user writes Chinese.
- Keep code identifiers, commands, paths, config keys, package names, and raw error fragments unchanged.
- Prefer direct verbs: "已新增", "已验证", "未验证", "建议保留", "可以移除".
- Avoid long opening context. The first sentence should tell the user what changed or what the conclusion is.
- For Windows paths, use inline code and full paths when useful.

## Formatting Rules

- Use short `**Title Case**` headings only when the answer has multiple parts.
- Do not stack many headings with one sentence under each; merge or remove headings that do not create useful hierarchy.
- Do not paste full logs, full JSON, long config files, or raw command output into a user-facing response unless the user explicitly asks.
- Use clickable file links for local files when reporting changed files.
- Keep paragraphs short enough to scan. Preserve detail by moving it into well-labeled bullets, tables, or code blocks instead of dropping it.
- Avoid over-formatting simple replies. A clean sentence is better than a decorative heading.
- Do not end with a vague "if you want" sentence. Suggest a concrete follow-up only when it naturally extends the task.

## Response Checklist

Before sending any user-facing response, check:

- The first sentence answers the user's actual latest request.
- The answer names the created/changed files or the conclusion.
- Important evidence is preserved and summarized, not dumped.
- Verification or uncertainty is stated clearly when relevant.
- Markdown is visually calm: no deep nesting, no oversized undifferentiated list, no noisy transcript.
- The formatting level matches the complexity of the answer.
