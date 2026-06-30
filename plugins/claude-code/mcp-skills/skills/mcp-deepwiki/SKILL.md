---
name: mcp-deepwiki
description: Use the deepwiki MCP for public GitHub repository understanding when Codex needs architecture, module, workflow, API surface, implementation overview, or generated wiki context for an upstream repo. Use automatically when the repo is public and not available locally, or when DeepWiki can provide faster orientation before local/source verification.
---

# MCP: deepwiki

## Routing Role

DeepWiki is the public GitHub repository orientation route. Use it to understand architecture, modules, workflows, and implementation intent before deeper source verification.

## Use Automatically When

- The user asks about architecture, modules, workflows, APIs, or implementation in a public GitHub repository.
- A public upstream repo is referenced and local source is unavailable.
- You need fast orientation before deciding which files or docs to inspect.
- You need generated wiki topics or repo-specific Q&A grounded in a GitHub repo.

## Prefer Other Tools When

- The repository is already cloned locally and the user asks about the current checkout; inspect local code first.
- The task needs current release/news/policy information outside repository architecture; use `mcp-tavily`.
- DeepWiki has no index or returns weak results; use GitHub pages/raw files, local clone, `mcp-exa`, or `mcp-tavily` as fallback.

## Communication Discipline

Do not claim or imply that DeepWiki was used unless a DeepWiki MCP tool actually ran and returned or failed.

If DeepWiki is skipped, attempted, or unavailable, state the status briefly:

- `DeepWiki repository lookup succeeded`
- `DeepWiki was attempted but failed or was not indexed; using fallback`
- `DeepWiki was not used because the local checkout was more authoritative`

## MCP Tools

### `read_wiki_structure`

- Purpose: List DeepWiki documentation topics for a GitHub repository.
- Use when: You need to know what repo docs are available before asking targeted questions.

### `read_wiki_contents`

- Purpose: Read DeepWiki documentation about a GitHub repository.
- Use when: You want the generated wiki content for repository orientation.

### `ask_question`

- Purpose: Ask a grounded question about one or more GitHub repositories.
- Use when: You need an architecture, module, or implementation answer tied to a public repo.

## Failure And Fallback

If DeepWiki is not indexed, unavailable, or too generic, do not keep retrying blindly. Use GitHub raw files, the upstream repository, local clones, `mcp-exa`, or `mcp-tavily`, and label the result as fallback evidence rather than successful DeepWiki output.
