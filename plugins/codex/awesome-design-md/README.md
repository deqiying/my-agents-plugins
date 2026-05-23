# Awesome DESIGN.md Plugin

This local Codex plugin packages the `VoltAgent/awesome-design-md` catalogue as a reusable skill.

What it includes:

- an English `awesome-design-md` skill
- a vendored copy of the upstream repository catalogue under `skills/awesome-design-md/references/`
- a local PowerShell helper that fetches the real `DESIGN.md` for a chosen brand with `getdesign`

Important distinction:

- the upstream repository is a catalogue of brands and links
- the real design document for a brand is best materialized with `npx getdesign@latest add <slug>`

Verified upstream sources:

- Repository: `https://github.com/VoltAgent/awesome-design-md`
- Brand site pattern: `https://getdesign.md/<slug>/design-md`
- Package used for local fetches: `getdesign`
