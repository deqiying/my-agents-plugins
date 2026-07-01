---
name: awesome-design-md
description: >
  Select, fetch, and apply brand-inspired DESIGN.md templates from VoltAgent/awesome-design-md and
  getdesign.md. Use when an agent needs to choose a visual direction, recommend a brand aesthetic,
  install a real DESIGN.md into a project, or implement frontend changes that must follow a chosen
  DESIGN.md.
---

Use this skill to turn the `awesome-design-md` catalogue into concrete implementation constraints.

## Start With The Right Local Source

- Read `references/catalog.md` first when you need a quick shortlist by product type.
- Read `references/upstream-repo/README.md` when you need the full upstream catalogue wording.
- Treat `references/design-md/<slug>/README.md` as catalogue entries only. Many of them are redirect stubs, not the full design document.
- Materialize the real `DESIGN.md` for a chosen brand with `scripts/fetch-design.ps1` or `npx -y getdesign@latest add <slug>` from the target project root.

## Workflow

1. Identify whether the user already named a brand or only described the desired tone.
2. If the brand is not fixed, shortlist two or three slugs from `references/catalog.md` and explain why they fit the product.
3. Fetch the real `DESIGN.md` into the target project before major frontend work:
   - Preferred local helper on this machine:
     - `powershell -ExecutionPolicy Bypass -File <skill-root>\\scripts\\fetch-design.ps1 -Slug <slug> -Destination <project-root>`
   - Direct fallback:
     - `npx -y getdesign@latest add <slug>`
4. Read the generated `DESIGN.md` and translate it into implementation decisions:
   - color palette and semantic roles
   - typography stack, sizing, tracking, and hierarchy
   - spacing, layout rhythm, and density
   - component shape, borders, elevation, and motion
   - responsive behavior and explicit do/don't rules
5. If the user wants the style to remain durable, keep or update `DESIGN.md` in the project root.
6. When implementing UI, preserve the existing design system unless the user explicitly asked for a re-theme.

## Practical Selection Heuristics

- Pick `vercel`, `voltagent`, `cursor`, `warp`, or `supabase` for developer tools, infra products, and AI engineering surfaces.
- Pick `notion`, `linear.app`, `mintlify`, or `cal` for calm, productivity-oriented SaaS.
- Pick `stripe`, `coinbase`, `revolut`, or `wise` for fintech.
- Pick `framer`, `figma`, `clay`, or `webflow` for design-forward marketing sites.
- Pick `apple`, `tesla`, `ferrari`, `lamborghini`, or `spacex` for premium launch-style storytelling.

## Implementation Rules

- Do not stop at “inspired by X.” Carry the chosen design into actual code.
- Do not claim the vendored repo stubs are the full design spec. Fetch the real `DESIGN.md` before relying on brand details.
- Do not add a `DESIGN.md` blindly when the project already has a living design system and the user did not ask to replace it.
- Do convert the design file into explicit frontend choices for color, typography, spacing, component treatment, and responsive behavior.
- Do call out which slug was chosen and which sections of the fetched `DESIGN.md` drove the implementation.
- Do preserve constraints from the user’s existing stack or design system when they conflict with “brand cosplay.”

## Validation

- Confirm that the target project contains `DESIGN.md` after fetching.
- Confirm the chosen brand slug explicitly in the final summary.
- When UI code changed, verify at least one concrete change in each relevant area:
  - colors
  - typography
  - spacing/layout
  - component styling
  - responsive behavior
- If the work stayed at recommendation level only, return a shortlist plus reasons and stop there.

## Local Notes

- The upstream repository is already vendored locally inside this plugin under `references/`.
- The real design body is best fetched through `getdesign`, not by scraping the redirect stubs in the repo clone.
- On this machine, `git clone` for the upstream repository is available, and `npx -y getdesign@latest add <slug>` is also working.

## Useful Paths

- Skill root: `<CODEX_HOME>/plugins/awesome-design-md/skills/awesome-design-md`
- Catalogue: `<CODEX_HOME>/plugins/awesome-design-md/skills/awesome-design-md/references/catalog.md`
- Upstream README: `<CODEX_HOME>/plugins/awesome-design-md/skills/awesome-design-md/references/upstream-repo/README.md`
- Fetch helper: `<CODEX_HOME>/plugins/awesome-design-md/skills/awesome-design-md/scripts/fetch-design.ps1`
