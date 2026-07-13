# Domain-Modeling Reference

Use this reference when the session resolves project-specific terminology, ownership boundaries, or architectural decisions that deserve a durable record.

## Locate The Documentation Context

1. Read `CONTEXT-MAP.md` first when it exists; use the mapped context that owns the current topic.
2. Otherwise read a root `CONTEXT.md` when it exists. If neither exists, create a root `CONTEXT.md` only after the first term is resolved.
3. Before creating an ADR, inspect the selected context and repository for an existing ADR convention. When no convention exists, use `docs/adr/` below the selected context and create it only for the first accepted ADR.
4. If repository instructions prescribe another stable documentation location or format, use that convention instead of these defaults.

## Glossary Discipline

- Challenge terminology that conflicts with the existing glossary or is vague, overloaded, or ambiguous.
- Propose one canonical term and list misleading alternatives under `_Avoid_` when that prevents future confusion.
- Keep each definition to one or two sentences explaining what the concept is. Exclude implementation detail, open questions, and step-by-step behavior.
- Include only concepts specific to the selected project context, not general software terms.
- Record only terms explicitly settled by the user. After a batch reply, write each settled term separately and leave unanswered, conflicting, or ambiguous items out of the glossary.

Use this shape when creating a new glossary:

```md
# {Context Name}

{One or two sentences describing this context.}

## Language

**{Canonical Term}**:
{One or two sentences defining the concept.}
_Avoid_: {ambiguous or deprecated alternatives}
```

## ADR Discipline

Offer an ADR only when all three conditions hold:

1. Reversing the decision later would be costly.
2. The choice would be surprising without its rationale.
3. A real trade-off existed between credible alternatives.

Number ADRs sequentially after the highest existing file. Use a concise filename such as `0001-event-sourced-orders.md` and keep the default body to a title plus one to three sentences explaining the context, decision, and reason. Add `Status`, `Considered Options`, or `Consequences` only when they preserve non-obvious context.

After a batch reply, evaluate the ADR criteria for each accepted decision independently. Do not combine unrelated decisions into one ADR or record a decision that still needs one-at-a-time clarification.
