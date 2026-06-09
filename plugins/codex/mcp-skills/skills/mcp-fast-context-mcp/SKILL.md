---
name: mcp-fast-context-mcp
description: 'Use the fast-context-mcp MCP for semantic/natural-language codebase discovery and code location in local repositories: implementation lookup, feature entrypoint discovery, plan/design-to-code mapping, call-path tracing, impact-area discovery, and narrowing unknown files before editing. Use when exact files, symbols, config keys, or error text are unknown and a conceptual query can reduce noisy local scans.'
---

# MCP: fast-context-mcp

## Routing Role

fast-context-mcp is the MCP-backed semantic locator for local codebases. It is best for natural-language discovery such as "where is authentication handled", "find websocket reconnect logic", "which files implement rate limiting", or similar code-positioning tasks where the entrypoint is unknown.

Use it for `semantic locate -> narrow -> read -> verify`:

1. Translate the user's intent into a concise English behavior query with a few domain terms.
2. Run `fast_context_search` to get candidate files, line ranges, and follow-up grep keywords.
3. Read the actual source files with local tools.
4. Verify conclusions with exact `rg`, tests, builds, or command output.

## Use Automatically When

- The user asks for semantic code search, natural-language code search, code location, implementation lookup, or "where is this implemented".
- You do not know the exact files, classes, functions, config keys, packet names, error text, or log lines.
- You need likely entrypoints before reading files or making edits.
- You are analyzing architecture, request flow, data flow, call paths, or cross-module implementation shape from a natural-language prompt.
- The task is driven by a plan, design doc, summary, PR note, or implementation idea and you need to map it to code entrypoints.
- Broad `rg` results would be noisy and a conceptual query can reduce the search space.
- The task benefits from `search -> narrow -> read`: semantic results first, real file inspection second.

## Prefer Other Tools When

- You already know the exact file, symbol, config key, packet name, error text, log message, or one narrow directory; use local deterministic tools such as `rg`, `rg --files`, or direct reads first.
- You need exact exhaustive matches rather than semantic candidates; use `rg`.
- You need known file content; read the file directly.
- The task is about public GitHub repository architecture and the repo is not local; use `mcp-deepwiki`.
- The task needs current public web or documentation lookup; use `mcp-tavily`, `mcp-exa`, `mcp-context7`, or the official OpenAI docs route as appropriate.
- The repository contains secrets, customer data, or private material that should not be sent to a remote semantic-search service; stay with local-only tools unless the user explicitly accepts that risk.

## Communication Discipline

Do not claim or imply that fast-context-mcp was used unless one of its MCP tools actually ran and returned or failed.

If fast-context-mcp is skipped, attempted, or unavailable, state the status briefly:

- `fast-context semantic search succeeded`
- `fast-context was attempted but failed; using fallback`
- `fast-context was not used because local deterministic search was more direct`

## MCP Tools

### `fast_context_search`

- Purpose: Run AI-driven semantic code search over a local project directory and return relevant file paths, line ranges, and follow-up grep keywords.
- Use when: You need feature discovery, entrypoint lookup, call-path tracing, impact mapping, or repo orientation from a natural-language query.
- Parameters: Provide an absolute `project_path`; write the `query` primarily in English and add domain terms only when useful; tune `max_results`, `max_turns`, and `tree_depth` for the size and ambiguity of the task.
- Notes: Keep `include_code_snippets` false for lightweight orientation. Turn it on only when snippets are needed to avoid extra file reads and the code is safe to send through the service. Use `exclude_paths` for noisy directories such as `node_modules`, `dist`, `.git`, `build`, `coverage`, or generated assets.

### `extract_windsurf_key`

- Purpose: Extract the Windsurf API key from a local Windsurf installation and set it as `WINDSURF_API_KEY`.
- Use when: `fast_context_search` cannot authenticate and the user wants to use the local Windsurf-backed MCP.
- Avoid when: The key is already configured, the task can be completed with local tools, or exposing/changing local credential state is outside the user's request.
- Notes: Do not print the extracted key. Report only whether extraction succeeded.

## Failure And Fallback

If semantic search returns broad or irrelevant results, narrow the natural-language query once with module names, domain terms, or suspected file areas. Then switch to local deterministic inspection with `rg`, direct reads, and tests or build commands. If authentication fails, use `extract_windsurf_key` only when it is appropriate for the current task and report credential status without revealing secrets.
