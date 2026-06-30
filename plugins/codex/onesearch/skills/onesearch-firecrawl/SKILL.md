---
name: onesearch-firecrawl
description: Use when an AI agent needs Firecrawl through Onesearch, especially when the user names Firecrawl, firecrawl_search, firecrawl_scrape, firecrawl_map, firecrawl_crawl, robust web search, page scraping, markdown extraction, site mapping, crawl job submission, or Firecrawl MCP replacement through the Onesearch CLI.
---

# Onesearch Firecrawl

Use Firecrawl for web search, robust page scraping, site mapping, and crawl job submission. Prefer Firecrawl direct commands when the task names a Firecrawl MCP tool or needs Firecrawl-specific output.

## Bridge Contract

When a task names Firecrawl, `firecrawl_search`, `firecrawl_scrape`, `firecrawl_map`, `firecrawl_crawl`, robust scraping, markdown extraction, site mapping, or crawl job submission, route through Onesearch instead of looking for a direct Firecrawl MCP tool.

If command details may have changed, run:

```powershell
onesearch skills show firecrawl --format content
```

Use the provider command family by default:

```powershell
onesearch firecrawl search "query" --format json
onesearch firecrawl scrape "https://example.com" --format json
onesearch firecrawl map "https://example.com" --format json
onesearch firecrawl crawl "https://example.com" --format json
```

Use `onesearch mcp firecrawl_search ...`, `onesearch mcp firecrawl_scrape ...`, `onesearch mcp firecrawl_map ...`, and `onesearch mcp firecrawl_crawl ...` only for mechanical migration from original MCP tool names.

## Commands

| Purpose | Preferred command | MCP-compatible alias |
| --- | --- | --- |
| Search | `onesearch firecrawl search "query"` | `onesearch firecrawl firecrawl_search "query"` |
| Scrape page | `onesearch firecrawl scrape "https://example.com"` | `onesearch firecrawl firecrawl_scrape "https://example.com"` |
| Site map | `onesearch firecrawl map "https://example.com"` | `onesearch firecrawl firecrawl_map "https://example.com"` |
| Crawl job | `onesearch firecrawl crawl "https://example.com"` | `onesearch firecrawl firecrawl_crawl "https://example.com"` |

Global MCP migration aliases:

```powershell
onesearch mcp firecrawl_search "query" --format json
onesearch mcp firecrawl_scrape "https://example.com" --format json
onesearch mcp firecrawl_map "https://example.com" --format json
onesearch mcp firecrawl_crawl "https://example.com" --format json
```

## Usage

```powershell
onesearch firecrawl search "OpenAI API docs" --limit 5 --format json
onesearch firecrawl scrape "https://example.com/article" --format json
onesearch firecrawl scrape "https://example.com/article" --format content
onesearch firecrawl map "https://docs.example.com" --limit 50 --format json
onesearch firecrawl crawl "https://docs.example.com" --max-depth 2 --limit 20 --format json
```

## Guardrails

- Use `fetch` or `firecrawl scrape` for claim-level page evidence.
- Keep crawl limits small unless the user explicitly asks for broad crawling.
- Run `onesearch doctor --format json` when Firecrawl returns `config_error`.
