# Repository Instructions

> Scope: this entire repository.

## Plugin And Skill Assets

- Use lowercase hyphen-case for plugin and skill names, and keep directory names, manifest names, `SKILL.md` frontmatter `name`, and `agents/openai.yaml` `$skill-name` prompts aligned.
- Name plugin folders and `.codex-plugin/plugin.json` `name` by the capability family they expose, such as `tool-skills`, `mcp-skills`, `agent-workflows`, or `agent-utilities`; do not mix unrelated skill categories into an existing plugin just because it is nearby.
- Name skills by the plugin's routing domain:
  - `tool-skills` skills wrap ordinary local CLI tools and must use `tool-<tool-id>` names, such as `tool-codesearch` or `tool-officecli`.
  - `onesearch` owns Onesearch CLI web research, provider bridge, workflow bridge, and original MCP tool-name replacement skills. Use `onesearch` for the main router skill and `onesearch-<route-id>` for bridge/workflow skills, such as `onesearch-context7`, `onesearch-exa`, `onesearch-tavily`, `onesearch-firecrawl`, `onesearch-deepwiki`, `onesearch-mcp-tools`, or `onesearch-docs`.
  - `mcp-skills` skills route MCP servers and must use `mcp-<server-id>` names, such as `mcp-context7`.
  - `agent-workflows` skills describe reusable agent workflows and must use `workflows-<workflow-id>` names.
  - Utility skills should use clear verb-led names that match their plugin domain, such as `setup-*`, `manage-*`, or `maintain-*`.
- Do not add bare upstream skill names to a categorized plugin when the repository wrapper needs a category prefix. Keep upstream or CLI-native skill names only inside the skill body or references when describing commands such as `onesearch skills show onesearch-cli`.
- Do not place Onesearch bridge skills under `tool-skills` or name them `tool-onesearch*` after the standalone `onesearch` plugin exists.
- When adding or materially updating a plugin or any skill inside a plugin, bump the owning `.codex-plugin/plugin.json` `version` in the same change and verify the package/marketplace entry still points at the intended plugin. Use the smallest appropriate semver increment: patch for skill docs, metadata, assets, or compatible command guidance; minor for new skills, new plugin capabilities, or compatibility-affecting workflow changes; major only for intentional breaking changes.
- When adding or materially updating a Codex plugin or skill, update its user-facing metadata and visual assets in the same change unless the user explicitly narrows the task.
- For skills, default to adding or refreshing `agents/openai.yaml` and `assets/icon.png`; keep an editable `assets/icon.svg` source when the icon is deterministic/vector-friendly.
- For plugins, default to checking `.codex-plugin/plugin.json` references and keeping `assets/icon.png`, `assets/logo.png`, and editable SVG sources in sync when applicable.
- Prefer deterministic repo-native SVG/PNG assets for small UI icons. Use AI image generation only when the asset genuinely needs a raster illustration, texture, or visual concept that cannot be cleanly represented as vector.
- After asset changes, verify referenced paths exist and scan for machine-specific absolute paths before finishing.
