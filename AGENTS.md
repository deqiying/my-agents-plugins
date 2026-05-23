# Repository Instructions

> Scope: this entire repository.

## Plugin And Skill Assets

- When adding or materially updating a Codex plugin or skill, update its user-facing metadata and visual assets in the same change unless the user explicitly narrows the task.
- For skills, default to adding or refreshing `agents/openai.yaml` and `assets/icon.png`; keep an editable `assets/icon.svg` source when the icon is deterministic/vector-friendly.
- For plugins, default to checking `.codex-plugin/plugin.json` references and keeping `assets/icon.png`, `assets/logo.png`, and editable SVG sources in sync when applicable.
- Prefer deterministic repo-native SVG/PNG assets for small UI icons. Use AI image generation only when the asset genuinely needs a raster illustration, texture, or visual concept that cannot be cleanly represented as vector.
- After asset changes, verify referenced paths exist and scan for machine-specific absolute paths before finishing.
