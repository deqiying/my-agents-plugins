---
name: grill-with-docs
description: 'Interview the user to sharpen a plan or design at an adaptive pace: deeply probe dependent decisions one at a time and batch independent decisions with recommendations, then capture resolved domain terminology and durable architectural decisions in the target repository. Use when a user explicitly asks to grill with docs, wants a plan stress-tested with a lasting record, or needs a design interview that creates a glossary and ADRs as decisions crystallize.'
---

# Grill With Docs Workflow

Use this workflow only for an explicit, stateful design session in a repository where writing documentation is in scope. It does not enact the implementation plan.

## Reference Routing

1. Read [grilling.md](./references/grilling.md) before asking the first question. It defines the interview protocol.
2. Read [domain-modeling.md](./references/domain-modeling.md) before resolving or recording domain terms, choosing a document location, or considering an ADR.
3. Read only the reference needed for the current step; these are supporting workflows, not separately discoverable skills.

## Session Contract

- Inspect repository code, configuration, and existing documentation for facts before asking the user about them.
- Use the adaptive pacing rules in `grilling.md`: resolve dependent, high-risk, or conflicting decisions one at a time; batch three to five independent decisions with numbered recommendations.
- Let the user request strict one-at-a-time or batch-first pacing, but default to adaptive pacing without adding a mode-selection question.
- Record a resolved term or accepted ADR inline, at the point it crystallizes. Create no glossary or ADR directory until there is content worth recording.
- Keep glossary entries to project-specific language and ADRs to durable, non-obvious trade-offs. Do not turn either artifact into an implementation spec or scratchpad.
- Before every write, name the target file and the conclusion being recorded. Preserve existing project documentation conventions when they conflict with the default reference layout.
- Close by summarizing settled decisions, files created or updated, deferred questions, and the point at which implementation may begin. Do not enact the plan until the user confirms shared understanding.
