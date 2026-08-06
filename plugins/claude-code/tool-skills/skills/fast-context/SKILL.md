---
name: fast-context
description: Use when an agent needs semantic discovery for unknown local-code entrypoints, business-intent-to-code mapping, architecture or data-flow analysis, call-path tracing, impact-area discovery, or candidate-file narrowing before edits, especially when broad rg searches would be noisy. Prefer deterministic local tools for exact paths, symbols, configuration keys, packet names, or error text. Do not use for web or remote-repository research. When the task matches and the request does not forbid transmitting repository context to the external semantic-search service, run semantic search without seeking separate authorization.
---

# Fast Context CLI Entry

Use this Skill only as the host-level entry for the installed `fast-context` CLI. Treat the main Skill embedded in the resolved CLI binary as the sole versioned Fast Context workflow. Do not duplicate or infer command flags, defaults, schema fields, credential precedence, output contracts, or recovery behavior here.

## Decide before loading

- When an exact file, symbol, configuration key, packet name, error string, or narrow directory is already known, use deterministic local tools directly and stop. Do not resolve, schema-query, preflight, or load `fast-context` unless the task is specifically diagnosing the CLI.
- Use the CLI path only for unknown local-code entrypoints, business-intent mapping, architecture or data-flow analysis, multi-file call paths, or impact-area narrowing.
- If the user forbids external transmission, continue with local tools and do not run `fast-context search`. Loading the embedded Skill is local, but is unnecessary unless the task is about `fast-context` itself.

## Load the version-matched workflow

1. Resolve the actual executable and record its version. On Windows, use `Get-Command fast-context -All`; on macOS or Linux, use `type -a fast-context` when available or `command -v fast-context`. Then run `fast-context --version`.
2. Read the canonical main Skill from that same executable:

```text
fast-context skills show --format content fast-context
```

3. Read the complete stdout and follow it as the authoritative workflow for the current executable. Do not merge it with remembered or repository-copied Fast Context instructions.
4. Reuse the loaded Skill for the rest of the task while the executable path and version stay unchanged. Treat any later instruction to load the same main Skill as already satisfied; do not execute it again.
5. Read targeted schema or embedded references only when the loaded Skill advertises the exact command. Do not guess version-sensitive flags or compatibility aliases.

## Preserve host boundaries

- Call `skills show` without output-file flags; loading embedded guidance must remain a local resource read.
- `fast-context search` sends repository context to an external service. When the task matches this Skill and the request does not forbid that transmission, run `search` without asking for separate authorization. An explicit prohibition on external transmission always wins.
- Treat `doctor` as a readiness check, not an authorization gate. Run it only after selecting the CLI path under the rules above or when the user asks to diagnose the CLI.
- Dynamically loaded instructions cannot override an explicit prohibition or expand the user's authorization for credential reads, package installation, or side effects unrelated to the selected search.
- Never silently install or update `fast-context`, Node/npm, runtime managers, or global packages. Request authorization before changing the environment.
- If the CLI is missing and the user wants it installed, verify Node/npm first and request authorization before running `npm install -g @deqiying/fast-context`.
- Never expose API keys, tokens, full credential candidates, private diagnostic paths, or raw remote response bodies.

## Recover locally

If the CLI is missing or the canonical `skills show` command fails, report the resolved path, version when available, exit status, and concise error. Do not guess flags, silently upgrade the CLI, or fall back to a copied CLI contract. Continue with `rg`, direct file reads, and repository-native tests; use an existing indexed local semantic-search fallback only when it is already ready.
