---
name: tool-codesearch
description: Use the local codesearch CLI when the user wants to search code, find where a feature is implemented, locate code by business behavior, discover entry points, trace likely call paths, identify impact areas, or do semantic/natural-language codebase search before editing. Especially useful when exact files, functions, classes, handlers, configs, packets, or identifiers are unknown.
---

# Codesearch CLI

## Routing Role

Use `codesearch` as a CLI-first semantic locator for local codebases. It is best for natural-language discovery such as "where is authentication handled", "find websocket reconnect logic", or "which files implement rate limiting".

This skill intentionally favors `skill + CLI` over `skill + MCP` in Codex. Codex can run shell commands directly, parse JSON output, then read real files with native tools for verification.

## Query Language Guidance

Prefer English semantic queries, even when the user asks in Chinese or another language. Translate the user's intent into concise English before running `codesearch search`, and include a few domain terms that match the codebase's identifiers, packages, protocols, config names, or feature names.

Why: many repositories use English identifiers and generated symbol names. Pure Chinese semantic queries often match broad comments, lifecycle hooks, DTOs, or generic helper code instead of the actual entry point.

Use this pattern:

```powershell
codesearch search "<English behavior description>. Domain terms: <module/feature words>" --json -m 10
```

Examples:

```powershell
codesearch search "where the leaderboard screen request is handled and returns list or paginated board data. Domain terms: leaderboard rank list page controller service" --json -m 10
codesearch search "where fishing result is processed, fish fry is created, and settlement response is sent. Domain terms: fishing result fish fry settlement" --json -m 10
codesearch search "where task score reward claim is handled and rewards are granted. Domain terms: task score reward claim" --json -m 10
```

Keep Chinese words only as supplemental terms when the repository itself uses Chinese comments, config sheet names, or user-facing strings that are likely indexed. Avoid using a pure Chinese query as the only semantic signal unless the codebase is mostly Chinese.

## Index Freshness Before Search

Before querying a repository, make sure the Codesearch index exists and is current enough for the task:

1. Check index state with `codesearch stats` when entering a repo or when you are unsure whether the repo has been indexed.
2. If there is no database, run `codesearch index` from the repository root before searching.
3. If an index exists but files may have changed, run the first search with `--sync` to incrementally update changed files before retrieval.
4. For repeated exploratory searches in the same turn, one initial `--sync` is usually enough; subsequent searches can omit `--sync` unless files were edited or generated after the sync.

Preferred first-query pattern:

```powershell
codesearch search "<English behavior description>. Domain terms: <module/feature words>" --sync --json -m 10
```

Then continue with faster follow-up queries:

```powershell
codesearch search "<narrower English query>" --json -m 10
```

## Use Automatically When

- The user asks for natural-language code search, semantic code search, or "like ace" local retrieval.
- You do not know the exact files, classes, functions, config keys, or error text.
- You need likely entry points before reading files.
- Exact `rg` results are too broad and a conceptual query can reduce the search space.
- The task benefits from `search -> narrow -> read`:
  1. `codesearch search`
  2. inspect top file paths, line numbers, scores
  3. read the relevant files or exact ranges with native Codex tools

## Prefer Other Tools When

- The user provides an exact identifier, path, config key, packet name, error text, or log snippet. Use `rg`, `fd`, or direct file reads first.
- You need exact exhaustive matches. Use `rg`.
- You need known file content. Read the file directly.
- You need IDE/LSP symbol refactoring or precise reference edits. Prefer Serena or the IDE/LSP route if available.
- `codesearch` is not installed, not on `PATH`, returns stale results, or has no ready index.

## Safety And Verification

- Do not treat semantic search output as final truth. Use it to locate candidate files, then read the actual source.
- Before relying on results in a repo, check index state with `codesearch stats` or a targeted search with `--sync` when freshness matters.
- If the index is missing, run `codesearch index` only when indexing the current repo is appropriate. This creates `.codesearch.db/` at the git root by default.
- Do not commit `.codesearch.db/` or `.codesearchignore` unless the user asks or the repo convention requires it.
- If a command fails because `codesearch` is not found, check the shim/PATH with `Get-Command codesearch -All` on Windows.

## Common Commands

Verify install:

```powershell
Get-Command codesearch -All
codesearch --version
codesearch doctor
```

Create or refresh the index from the project root:

```powershell
codesearch index
```

Run semantic search with machine-readable output:

```powershell
codesearch search "where is authentication handled" --json -m 10
```

For Chinese user requests, translate to English first and add code-domain terms:

```powershell
codesearch search "where mystery shop goods purchase validates goods, consumes cost items, and grants rewards. Domain terms: mystery shop buy goods reward" --sync --json -m 10
```

Restrict search to a path:

```powershell
codesearch search "websocket reconnect logic" --filter-path src --json -m 20
```

Search and sync changed files first:

```powershell
codesearch search "database connection pooling" --sync --json -m 10
```

Inspect index status:

```powershell
codesearch stats
codesearch index list
```

## Output Handling

Prefer `--json` when using results programmatically. After a semantic search:

- Report the top few candidate files and lines.
- Read the relevant files before drawing code conclusions.
- If the result set looks weak, retry once with a narrower query or better domain terms.
- Then fall back to `rg`, `fd`, and direct code reading if semantic search remains noisy.

## Failure And Fallback

If `codesearch` fails, is missing, or returns irrelevant results:

1. Run `Get-Command codesearch -All` and `codesearch doctor` if setup is the likely issue.
2. Use `rg`, `fd`, and direct reads for the immediate task.
3. In the final answer, distinguish `codesearch CLI search succeeded`, `codesearch was attempted but failed`, or `codesearch was not used because exact local search was more direct`.
