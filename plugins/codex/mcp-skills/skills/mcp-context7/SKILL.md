---
name: mcp-context7
description: Use the context7 MCP for current third-party library, framework, SDK, and package documentation when answers depend on API signatures, options, examples, version-specific behavior, setup, migration, or configuration. Use automatically for non-OpenAI developer documentation questions where local code or memory may be stale.
---

# MCP: context7

## Routing Role

Context7 is the primary route for current third-party developer documentation. Use it to replace guesswork with docs-grounded answers when library behavior, API shape, or configuration may have changed.

## Use Automatically When

- The user asks how to use a third-party library, framework, SDK, package, or platform.
- The answer depends on current API signatures, options, configuration keys, setup, migration, or examples.
- The task mentions React, Next.js, Vite, Supabase, MongoDB, Prisma, Playwright, or similar non-OpenAI developer tools.
- Local code, memory, or model knowledge may be stale and official or documentation-grounded usage matters.

## Prefer Other Tools When

- The task is about OpenAI, Codex, ChatGPT, Responses API, or OpenAI SDK documentation; use the official `openai-docs` skill or OpenAI docs MCP.
- The user asks about local project behavior rather than third-party docs; inspect local code first.
- The task needs public web research, news, pricing, or policies; use `mcp-tavily`.
- The task needs a public page found by semantic intent rather than library docs; use `mcp-exa`.

## Communication Discipline

Do not claim or imply that Context7 was used unless a Context7 MCP tool actually ran and returned or failed.

When testing Context7 availability, do not stop at resources/templates enumeration. Use a minimal real path: `resolve_library_id`, then `query_docs`.

If Context7 is skipped, attempted, or unavailable, state the status briefly:

- `Context7 docs lookup succeeded`
- `Context7 was attempted but failed; using fallback`
- `Context7 was not used because local code or another docs source was more direct`

## MCP Tools

### `resolve_library_id`

- Purpose: Resolve a package or product name to a Context7-compatible library id.
- Use when: You do not already have an exact `/org/project` or `/org/project/version` library id.
- Notes: Select based on name match, documentation coverage, source reputation, benchmark score, and the user's version if provided.

### `query_docs`

- Purpose: Query the resolved documentation set for focused guidance and examples.
- Use when: You have a valid library id and need official or documentation-grounded answers.
- Notes: Ask specific questions. Do not include secrets or proprietary code in the query.

## Failure And Fallback

If `resolve_library_id` cannot find a suitable library, try one refined official package/product name. If it still fails, use official project docs, primary repositories, or another web research tool and state that Context7 did not provide the answer.
