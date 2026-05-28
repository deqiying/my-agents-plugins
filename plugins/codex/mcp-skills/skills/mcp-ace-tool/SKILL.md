---
name: mcp-ace-tool
description: Use the ace-tool MCP skill for semantic codebase discovery when exact files or identifiers are unknown, especially behavior-based feature location, workflow/call-chain discovery, plan-or-design guided implementation, ownership or impact analysis, and noisy local keyword searches.
---

# MCP: ace-tool

## Compatibility Notes

This skill covers the configured `ace-tool` MCP server even when the command behind it is `ace-tool-rs`.

- Keep the skill name as `mcp-ace-tool` while the Codex server id remains `[mcp_servers.ace-tool]`.
- `ace-tool-rs` still exposes `search_context` and `enhance_prompt`; it also maps the alias `codebase-retrieval` to `search_context`.

## Routing Decision

Use `search_context` when:

- The user asks for semantic location, behavior-based discovery, workflow discovery, or impact analysis.
- You do not know the exact files, classes, methods, config keys, or error text.
- Exact search returns too many disconnected hits and you need likely ownership or surrounding context.
- The task spans hidden calling chains, generated entrypoints, event handlers, or cross-module responsibilities.
- The task is driven by a plan, design doc, summary, or repo artifact and you need to map intent to likely code areas.

Prefer `rg`, `fd`, or direct reads when:

- The user provides exact identifiers, paths, error text, config keys, packet names, class names, or symbols.
- The target files are already known and the task is local verification or implementation.
- The repository is too large or noisy for semantic indexing and the relevant scope is already narrow.
- The MCP is unavailable, slow, unstable, or previously produced irrelevant results for the current project.

If both apply, use ace-tool for initial discovery only when it can reduce uncertainty. Otherwise, use local tools first and mention that semantic lookup was skipped because the path or symbol evidence was already exact.

This skill is "skill-first for unclear semantic location", not "MCP-first for every task". For trivial exact lookups, local commands are the faster and more reliable path. For unfamiliar cross-module behavior, use ace-tool before broad keyword scans.

## Artifact Context

If the user references a plan, design, summary, implementation note, PR note, or repo-local artifact, first read the likely artifact when it can be located cheaply. Then query ace-tool with the artifact's behavior and responsibilities, not just its raw keywords.

Do not turn this into an unconditional hidden-directory crawl. Use bounded local discovery only when the task wording implies artifact-driven work.

## Communication Discipline

Do not claim or imply that ace-tool was used unless an ace-tool MCP call actually ran and returned or failed.

If you announce that you will use `mcp-ace-tool` but then decide local search is better, explicitly pivot before continuing. Example:

```text
The symbols and files are already exact enough, so I am skipping ace-tool and using rg/direct reads for verification.
```

Distinguish these states in summaries:

- `ace-tool semantic lookup succeeded`
- `ace-tool was attempted but failed; using local fallback`
- `ace-tool was not used because exact local search was more direct`

Checking or creating `.aceignore` is not a semantic lookup. It only prepares or verifies index hygiene.

## Index Hygiene

Run `.aceignore` preflight only after deciding to call `search_context` for that project root, or when the user explicitly asks to prepare ace-tool indexing.

- Check only the selected project root, not the Codex home directory and not parent directories.
- If `<project_root>/.aceignore` already exists, do not overwrite or merge it silently.
- If `<project_root>/.gitignore` exists, create `<project_root>/.aceignore` from the exact current `.gitignore` content.
- If `<project_root>/.gitignore` does not exist, create a conservative `.aceignore` template that excludes dependency folders, build outputs, generated files, logs, binaries, media, archives, and `.ace-tool/`.
- If the user explicitly asks not to write files, skip initialization and mention that `ace-tool-rs` will still use built-in excludes plus `.gitignore` if present.

Use the bundled script instead of embedding initialization logic in the prompt. The script path is relative to this skill directory, so the skill can be moved without rewriting user-specific paths.

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\init-aceignore.ps1 -ProjectRoot <project-root>
```

```bash
bash ./scripts/init-aceignore.sh <project-root>
```

Run these commands from the `mcp-ace-tool` skill directory, or resolve `scripts/init-aceignore.*` relative to the directory containing this `SKILL.md`.

## MCP Tools

### `search_context`

- Purpose: Semantic retrieval over the current codebase index.
- Use when: You need likely code snippets and file locations for a natural-language description such as "where is user authentication handled" or "how does config hot reload apply changes".
- Avoid when: You already know the exact identifier or path and only need all literal references; use exact search instead.
- Notes: Always provide the absolute project root path as `project_root_path`. Query by feature, behavior, workflow, or responsibility, and include a few known keywords only as anchors.

### `enhance_prompt`

- Purpose: Enhance a user prompt with project context and conversation history, then open a Web UI for user review and confirmation.
- Use when: The user explicitly includes `-enhance`, `-enhancer`, `-Enhance`, `-Enhancer`, asks to "enhance my prompt", or asks to use the enhance prompt tool.
- Avoid when: The user asks to optimize code, improve an implementation, or make normal code changes. Those are engineering tasks, not prompt-enhancement tasks.

## Query Patterns

Good semantic queries:

- `Find where the gateway topology upload plan maps into SDK server selection and game server registration. Keywords: gateway topology, serverInfo, SDK login, route, publicWsAddress`
- `Find the UI workflow that handles hero level-up and star-up success effects. Keywords: hero upgrade, star up, VFX, Spine_Hero, button effect`
- `Find where backend validates and consumes materials for hero star-up. Keywords: HeroStarUpReq, cost item, consume hero`
- `Find config loading and cache refresh flow for fishing pity config. Keywords: FishingPityConfig, config registry, manager cache`

Avoid semantic queries that are just exact grep:

- `class UI_HeroDetailsViewController`
- `Vfx233`
- `PACKET_ID_HeroStarUpReq`

## Failure And Fallback

If `search_context` fails, times out, returns HTTP 499, or gives irrelevant results:

- Do not keep retrying blindly.
- Retry at most once with a narrower query if semantic lookup can still reduce uncertainty.
- Then use `rg`, `fd`, and direct reads.
- State that the result is based on local fallback, not successful ace-tool semantic retrieval.
