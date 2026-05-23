---
name: mcp-excel-tools
description: Use this skill and the excelTools MCP first for Excel workbook work on `.xlsx` or `.xls` files, especially existing workbook inspection or edits, sheet/range/cell operations, row/column insertion or deletion, formatting preservation, formulas, data validation, tables, charts, pivots, merged cells, and workbook metadata. Use it automatically for Excel-native tasks before higher-level spreadsheet artifact workflows unless the user clearly asks to create a polished new workbook deliverable with rendering/export.
---

# MCP: excelTools

## Routing Role

excelTools is the preferred native workbook route for Excel files when worksheet/range/formula semantics matter. Default to this skill first for existing `.xlsx` or `.xls` inspection and edits, then pivot only when another route is clearly better for the requested deliverable.

## Use Automatically When

- The user asks to inspect, read, create, edit, validate, format, compare, clean up, or analyze `.xlsx` or `.xls` files and workbook-native semantics may matter.
- The user asks to add, insert, delete, copy, move, resize, merge, unmerge, rename, or otherwise adjust cells, ranges, rows, columns, or worksheets in an Excel workbook.
- The task needs workbook metadata, ranges, validation rules, merged cells, formulas, worksheets, tables, charts, or pivot tables.
- The task should preserve Excel-native workbook semantics, formatting, formulas, validation, tables, charts, or layout instead of treating the file as plain tabular data.
- The task is a lightweight or targeted Excel question/edit where using a full spreadsheet artifact build/render/export workflow would be unnecessary.

## Prefer Other Tools When

- The user clearly asks for a full new spreadsheet artifact workflow with presentation polish, dashboard/model construction, rendered previews, or final `.xlsx` export; use the Spreadsheets plugin skill as the primary route.
- The data is CSV/TSV only and no workbook-native semantics are needed; local tools or the Spreadsheets plugin may be enough.
- The file is not available locally; ask for the file or locate it before using workbook tools.

## Communication Discipline

Do not claim or imply that excelTools was used unless an excelTools MCP tool actually ran and returned or failed.

Before writing, confirm or infer the target file, sheet, and range from local context. Read-only inspection usually does not require an extra question when the file path is clear.

If excelTools is skipped, attempted, or unavailable, state the status briefly:

- `excelTools workbook operation succeeded`
- `excelTools was attempted but failed; using fallback`
- `excelTools was not used because local tabular processing was sufficient`

## MCP Tools

### Workbook And Worksheet Tools

- `create_workbook`: Create a new Excel workbook.
- `get_workbook_metadata`: Inspect workbook sheets, dimensions, and optional ranges.
- `create_worksheet`: Add a worksheet.
- `delete_worksheet`: Delete a worksheet.
- `rename_worksheet`: Rename a worksheet.
- `copy_worksheet`: Duplicate a worksheet.

Use these when changing workbook structure or confirming workbook layout.

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

If a workbook operation fails because the file, sheet, or range is invalid, inspect workbook metadata and validation rules before retrying. If excelTools is unavailable, use the Spreadsheet plugin or local libraries only after saying the MCP path was not used.
