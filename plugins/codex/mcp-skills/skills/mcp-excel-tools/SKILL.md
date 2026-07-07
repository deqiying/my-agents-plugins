---
name: mcp-excel-tools
description: Use this skill and the excelTools MCP for Excel-native workbook operations on `.xlsx` or `.xls` files after deciding `$tool-officecli` is not the better first route for ordinary Excel reading or extraction. Use for targeted sheet/range/cell edits, row/column operations, formatting preservation, formulas, data validation, tables, charts, pivots, merged cells, and workbook metadata. Prefer `$tool-officecli` for read-only inspection, config or workbook extraction, large ranges, bounded output, path-addressed JSON, validation, rendering, or cross-Office workflows.
---

# MCP: excelTools

## Routing Role

excelTools is the native workbook MCP route for Excel files when worksheet/range/formula semantics matter and the operation can be targeted cleanly. Use it for compact workbook metadata, focused range/cell edits, and Excel-specific structure operations after considering whether `$tool-officecli` should handle ordinary read/extract work first.

Do not treat excelTools as automatically better than OfficeCLI for every Excel task, and do not choose it solely because a file has an `.xlsx` or `.xls` extension. If the task is read-only workbook inspection, config/key-value extraction, or sheet text/range extraction, use `$tool-officecli` first unless native workbook semantics are the main requirement. If metadata inspection succeeds but reading a full range would produce output that is too long for precise extraction, or if the workflow needs bounded CLI output, stable path/query addressing, validation, rendering, or cross-Office handling, switch to `$tool-officecli` early.

## Use Automatically When

- The user asks to create, edit, validate, format, compare, clean up, or analyze `.xlsx` or `.xls` files and workbook-native semantics matter more than generic extraction.
- The user asks to add, insert, delete, copy, move, resize, merge, unmerge, rename, or otherwise adjust cells, ranges, rows, columns, or worksheets in an Excel workbook.
- The task needs targeted workbook metadata, ranges, validation rules, merged cells, formulas, worksheets, tables, charts, or pivot tables, and the expected MCP output will stay compact.
- The task should preserve Excel-native workbook semantics, formatting, formulas, validation, tables, charts, or layout instead of treating the file as plain tabular data.
- The task is a lightweight or targeted Excel question/edit where expected MCP output will stay compact and using a full spreadsheet artifact build/render/export workflow would be unnecessary.

## Prefer Other Tools When

- The task is ordinary read-only Excel inspection or extraction, especially a local resource/config workbook or key/value lookup; use `$tool-officecli` first.
- The user clearly asks for a full new spreadsheet artifact workflow with presentation polish, dashboard/model construction, rendered previews, or final `.xlsx` export; use the Spreadsheets plugin skill as the primary route.
- The user needs precise extraction from a large workbook/range, bounded output, path-addressed JSON, batch document edits, Office validation/rendering, or cross-Office workflows; use `$tool-officecli`.
- excelTools metadata is useful but the next full range read would be too verbose to inspect accurately; use `$tool-officecli` for narrower extraction instead of repeatedly dumping large ranges.
- The data is CSV/TSV only and no workbook-native semantics are needed; local tools or the Spreadsheets plugin may be enough.
- The file is not available locally; ask for the file or locate it before using workbook tools.

## Communication Discipline

Do not claim or imply that excelTools was used unless an excelTools MCP tool actually ran and returned or failed.

Before writing, confirm or infer the target file, sheet, and range from local context. Read-only inspection usually does not require an extra question when the file path is clear.

If this skill loads for an ordinary read-only Excel task, consider `$tool-officecli` before calling excelTools MCP tools. Use excelTools only when it is clearly the better native workbook operation or when OfficeCLI is unavailable or insufficient.

If excelTools is skipped, attempted, or unavailable, state the status briefly:

- `Excel read/extraction was routed to OfficeCLI first`
- `excelTools workbook operation succeeded`
- `excelTools was attempted but failed; using fallback`
- `excelTools metadata succeeded, but OfficeCLI was better for bounded extraction`
- `excelTools was not used because OfficeCLI or local tabular processing was more direct`

## MCP Tools

### Workbook And Worksheet Tools

- `create_workbook`: Create a new Excel workbook.
- `get_workbook_metadata`: Inspect workbook sheets, dimensions, and optional ranges.
- `create_worksheet`: Add a worksheet.
- `delete_worksheet`: Delete a worksheet.
- `rename_worksheet`: Rename a worksheet.
- `copy_worksheet`: Duplicate a worksheet.

Use these when changing workbook structure or confirming workbook layout. Treat large dimensions as a signal to target the next read carefully or switch to OfficeCLI for bounded extraction.

### Data Read And Write Tools

- `read_data_from_excel`: Read cells with metadata and validation info.
- `write_data_to_excel`: Write tabular values starting at a cell.
- `copy_range`: Copy a cell range to another location.
- `delete_range`: Delete cells and shift remaining cells.
- `validate_excel_range`: Confirm a range exists and is properly formatted.

Use these for direct cell/range data operations.

### Row And Column Tools

- `insert_rows`: Insert rows.
- `delete_sheet_rows`: Delete rows.
- `insert_columns`: Insert columns.
- `delete_sheet_columns`: Delete columns.

Use these when preserving workbook structure matters more than overwriting a block.

### Default Row And Column Style Behavior

When inserting rows or columns and the user has not specified how styles should be handled, default to preserving the surrounding workbook presentation and semantics. Inspect adjacent rows or columns and copy the nearest appropriate existing style, including cell formatting, table borders, number formats, data validation, and conditional formatting where applicable.

This is a default rule, not a hard requirement. Follow any explicit user instruction about raw insertion, custom formatting, or skipping style propagation.

### Formula Tools

- `validate_formula_syntax`: Check formula syntax without applying it.
- `apply_formula`: Write and verify a formula in a cell.

Use these for formulas, especially before changing calculated workbooks.

### Formatting And Layout Tools

- `format_range`: Apply formatting, number formats, alignment, borders, protection, and conditional formatting.
- `merge_cells`: Merge a cell range.
- `unmerge_cells`: Unmerge a cell range.
- `get_merged_cells`: Inspect merged ranges.
- `get_data_validation_info`: Inspect validation rules in a worksheet.

Use these for presentation, layout, and validation-sensitive edits.

### Analysis And Visualization Tools

- `create_table`: Create a native Excel table from a range.
- `create_chart`: Create a chart in a worksheet.
- `create_pivot_table`: Create a pivot table.

Use these when the user wants workbook-native analysis rather than only raw data.

## Failure And Fallback

If a workbook operation fails because the file, sheet, or range is invalid, inspect workbook metadata and validation rules before retrying. If metadata succeeds but the precise data read would require a noisy full-range dump, use `$tool-officecli` for bounded inspection/extraction. If excelTools is unavailable, use OfficeCLI, the Spreadsheet plugin, or local libraries only after saying the MCP path was not used.
