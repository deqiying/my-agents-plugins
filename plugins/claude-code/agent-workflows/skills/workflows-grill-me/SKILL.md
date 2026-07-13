---
name: workflows-grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree without writing design records. Use when a user wants to stress-test a plan, get grilled on their design, or explicitly asks for a no-docs grilling session.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time and wait for each answer before continuing.

If a factual question can be answered by exploring the codebase, explore the codebase instead. Decisions remain the user's to make.

Do not enact the plan until the user confirms that shared understanding has been reached.

When the user wants settled terminology or durable decisions captured in the target repository, use `$workflows-grill-with-docs` instead.
