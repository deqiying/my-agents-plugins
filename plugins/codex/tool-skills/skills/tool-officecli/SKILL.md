---
name: tool-officecli
description: Use the local officecli CLI when the user wants to create, inspect, validate, render, or modify Microsoft Office documents, including Word `.docx`, Excel `.xlsx`, and PowerPoint `.pptx` files. Use for agent-friendly Office document workflows that benefit from structured JSON output, path-based document edits, batch operations, or render-and-fix verification.
---

# OfficeCLI CLI

## Routing Role

Use `officecli` as a CLI-first Office document tool for `.docx`, `.xlsx`, and `.pptx` work. It is best when Codex needs to read structure, extract text, make targeted edits, create documents, run batch mutations, validate OpenXML output, or render documents to HTML/PNG for visual verification.

This skill intentionally favors `skill + CLI` over ad hoc Python libraries. OfficeCLI is designed for AI agents: commands can return `--json`, elements have stable paths, and edits can be verified with `validate`, `view issues`, and rendered previews.

## Operating Strategy

Use the progressive model:

1. L1 read and inspect: `create`, `view`, `get`, `query`, `validate`
2. L2 DOM edit: `set`, `add`, `remove`, `move`, `swap`, `batch`
3. L3 raw XML fallback: `raw`, `raw-set`, `add-part`

Prefer L1/L2. Use L3 only when the high-level document model cannot express the required edit.

Before changing a user document:

1. Confirm the file path and format.
2. Inspect structure with `view`, `get`, or `query`.
3. Make the smallest targeted edit.
4. Verify with `validate` and/or `view issues`.
5. For visual outputs, render with `view html`, `view screenshot`, or `watch` and inspect the result when possible.

## Use Automatically When

- The user asks to create, inspect, validate, proofread, render, or modify Office files.
- The task involves `.docx`, `.xlsx`, or `.pptx` and a CLI workflow is more direct than writing custom document-processing code.
- The user needs structured extraction from Word, Excel, or PowerPoint.
- The user wants layout-aware Office work such as slide generation, chart placement, screenshots, live preview, issue detection, or render-and-fix loops.
- The workflow benefits from stable path addressing such as `/body/p[3]`, `/slide[1]/shape[@id=...]`, or `/Sheet1/A1`.

## Prefer Other Tools When

- The user explicitly asks to use another document pipeline or library.
- The task is ordinary spreadsheet cell/range editing in an existing `.xlsx` and `excelTools` MCP is available and sufficient.
- The task is a polished Word/PPT/spreadsheet deliverable that must follow a higher-level artifact workflow already provided by a specialized skill.
- `officecli` is not installed and the user has not approved installing or downloading binaries.
- The document is open in Office/WPS/another editor and the edit may conflict with a file lock. Ask the user to close it or work on a copy.

## Command Patterns

Verify install:

```powershell
Get-Command officecli -All
officecli --version
officecli help
```

Create and inspect:

```powershell
officecli create report.docx
officecli view report.docx outline
officecli view data.xlsx text --max-lines 50
officecli get deck.pptx '/slide[1]' --depth 1 --json
officecli query report.docx 'paragraph[style=Heading1]' --json
```

Modify with path-based commands:

```powershell
officecli set report.docx '/body/p[1]/r[1]' --prop text="New title"
officecli add deck.pptx / --type slide --prop title="Q4 Report"
officecli add data.xlsx / --type sheet --prop name="Q2 Data"
officecli remove report.docx '/body/p[4]'
```

Batch related edits into one open/save cycle:

```powershell
officecli batch deck.pptx --commands '[{"op":"set","path":"/slide[1]/shape[1]","props":{"text":"Hello"}}]' --json
```

Validate and render:

```powershell
officecli validate report.docx
officecli view report.docx issues --json
officecli view deck.pptx screenshot -o deck.png
officecli view deck.pptx html -o deck.html
```

Use live preview for iterative visual editing:

```powershell
officecli watch deck.pptx
officecli get deck.pptx selected --json
officecli unwatch deck.pptx
```

## Help And Schema Discovery

When unsure about property names, element types, value formats, or selector syntax, run OfficeCLI help instead of guessing:

```powershell
officecli help docx
officecli help docx paragraph
officecli help docx set paragraph
officecli help pptx shape --json
officecli help xlsx pivottable
```

Format aliases may exist, but prefer explicit `docx`, `xlsx`, and `pptx` in commands and examples.

## Specialized OfficeCLI Skills

OfficeCLI can print embedded specialized skills:

```powershell
officecli load_skill word
officecli load_skill pptx
officecli load_skill excel
officecli load_skill pitch-deck
officecli load_skill financial-model
officecli load_skill data-dashboard
```

Load one specialized skill when the task clearly matches it, then follow the printed rules for that artifact. Do not stack multiple OfficeCLI subskills for a single artifact unless the printed instructions explicitly say to do so.

## Safety And Verification

- Do not treat command output as proof of a good document until you inspect the resulting file with `validate`, `view issues`, or a rendered preview.
- Prefer `--json` for programmatic handling. Avoid parsing human text output when a structured mode exists.
- Quote paths that contain brackets, for example `'/slide[1]/shape[2]'`.
- Paths are generally 1-based. `--index` is generally 0-based, except OfficeCLI may define format-specific exceptions; check help before relying on index behavior.
- Stable IDs such as `shape[@id=...]` are safer than positional paths during multi-step edits because positions can shift after inserts or deletes.
- For large files, limit output with command flags such as `--max-lines`, `--start`, `--end`, `--depth`, or targeted paths/selectors.
- If a command returns a structured error such as `not_found`, `invalid_value`, or `unsupported_property`, use the suggestion and run `help`, `get`, or `query` to self-correct before retrying.
- Do not install or update OfficeCLI from the network unless the user asked for it or approved it. If installation is required, explain the download source and request approval first.

## Failure And Fallback

If `officecli` fails, is missing, or returns irrelevant output:

1. Run `Get-Command officecli -All` and `officecli --version` when setup is the likely issue.
2. Run `officecli help` or format-specific help when syntax or property names are uncertain.
3. Use specialized Codex document/spreadsheet/presentation skills or MCP tools when they better match the task.
4. In the final answer, distinguish `officecli CLI succeeded`, `officecli was attempted but failed`, or `officecli was not used because another tool was more direct`.
