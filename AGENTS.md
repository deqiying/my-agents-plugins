# Repository Instructions

> Scope: this entire repository.

## Plugin And Skill Assets

- Use lowercase hyphen-case for plugin and skill names, and keep directory names, manifest names, `SKILL.md` frontmatter `name`, and `agents/openai.yaml` `$skill-name` prompts aligned.
- Name plugin folders and `.codex-plugin/plugin.json` `name` by the capability family they expose, such as `tool-skills`, `mcp-skills`, `agent-workflows`, or `agent-utilities`; do not mix unrelated skill categories into an existing plugin just because it is nearby.
- Name skills by the plugin's routing domain:
  - `tool-skills` skills wrap ordinary local CLI tools and must use `tool-<tool-id>` names, such as `tool-codesearch` or `tool-officecli`.
  - `onesearch` owns Onesearch CLI web research, provider bridge, and workflow bridge usage. Maintain only the `onesearch` main router skill in this plugin; route-specific guidance must be loaded from the CLI with commands such as `onesearch skills list --format json` and `onesearch skills show <route-id> --format content`.
  - `mcp-skills` skills route MCP servers and must use `mcp-<server-id>` names, such as `mcp-context7`.
  - `agent-workflows` skills describe reusable agent workflows and must use `workflows-<workflow-id>` names.
  - Utility skills should use clear verb-led names that match their plugin domain, such as `setup-*`, `manage-*`, or `maintain-*`.
- Do not add bare upstream skill names to a categorized plugin when the repository wrapper needs a category prefix. Keep upstream or CLI-native skill names only inside the skill body or references when describing commands such as `onesearch skills show onesearch-cli`.
- Do not place Onesearch bridge skills under `tool-skills`, name them `tool-onesearch*`, or maintain static `onesearch-<route-id>` skill copies after the standalone `onesearch` plugin exists. Keep route-specific guidance in the Onesearch CLI unless the user explicitly asks for a compatibility shim.
- Write `SKILL.md` frontmatter `description` and trigger-facing metadata as agent-neutral routing text by default. This repository is a reusable multi-agent plugin and skill set, so prefer phrases like "Use when an agent needs", "Use when the task involves", or "Use for" instead of product-bound phrasing like "when <product> needs".
- Mention `Codex`, `Claude Code`, OpenAI, or another product in a skill description only when the skill actually operates on that product, config, marketplace, app, CLI, or product-specific UI metadata. Do not use `Codex` as a synonym for the consuming agent.
- Keep trigger descriptions concrete and capability-oriented: state what the skill does, the task contexts that should activate it, important file/tool/data cues, and key exclusions when useful. Do not rely on a body-only "when to use" section for routing, because the body is loaded only after the skill triggers.
- When updating trigger descriptions, keep `SKILL.md` frontmatter, `agents/openai.yaml` prompts, and relevant plugin interface metadata consistent. Edit `plugins/codex` as the maintained source first, then regenerate `plugins/claude-code` with the sync script instead of hand-editing the mirror.
- Quote long YAML frontmatter descriptions when they contain `:` or other YAML-sensitive punctuation.
- When adding or materially updating a plugin or any skill inside a plugin, bump the owning `.codex-plugin/plugin.json` `version` in the same change and verify the package/marketplace entry still points at the intended plugin. Use the smallest appropriate semver increment: patch for skill docs, metadata, assets, or compatible command guidance; minor for new skills, new plugin capabilities, or compatibility-affecting workflow changes; major only for intentional breaking changes.
- When adding or materially updating a plugin or skill, update its user-facing metadata and visual assets in the same change unless the user explicitly narrows the task.
- For skills, default to adding or refreshing `agents/openai.yaml` and `assets/icon.png`; keep an editable `assets/icon.svg` source when the icon is deterministic/vector-friendly.
- For plugins, default to checking `.codex-plugin/plugin.json` references and keeping `assets/icon.png`, `assets/logo.png`, and editable SVG sources in sync when applicable.
- Prefer deterministic repo-native SVG/PNG assets for small UI icons. Use AI image generation only when the asset genuinely needs a raster illustration, texture, or visual concept that cannot be cleanly represented as vector.
- After asset changes, verify referenced paths exist and scan for machine-specific absolute paths before finishing.
