---
name: mcp-freecrawl
description: Use the freecrawl MCP for lightweight public web search, simple page scraping, small bounded crawls, and compact research when local or low-friction crawling is enough and Firecrawl's structured extraction, JavaScript handling, document parsing, or agent workflow would be overkill.
---

# MCP: freecrawl

## Routing Role

freecrawl is the lightweight crawl/scrape route when the task is public, bounded, and does not need Firecrawl's heavier extraction or interaction workflow.

## Use Automatically When

- The task needs simple public page scraping or a small bounded crawl.
- The user wants lightweight search plus optional scraped results.
- The research pass is compact and does not need Tavily's recency/search controls or Firecrawl's robust extraction.
- A low-friction crawler is enough for the page/site.

## Prefer Other Tools When

- Scraping reliability, JavaScript rendering, structured extraction, document parsing, interaction, or deep autonomous research matters; use `mcp-firecrawl`.
- Current facts, news, prices, policies, schedules, or multi-source verification matters; use `mcp-tavily`.
- Best-page semantic discovery matters; use `mcp-exa`.
- Only quick fallback link discovery is needed; use `mcp-ddg-search`.

## Communication Discipline

Do not claim or imply that freecrawl was used unless a freecrawl MCP tool actually ran and returned or failed.

If freecrawl is skipped, attempted, or unavailable, state the status briefly:

- `freecrawl search/scrape/crawl succeeded`
- `freecrawl was attempted but failed; using fallback`
- `freecrawl was not used because another web tool was more appropriate`

## MCP Tools

### `mcp__freecrawl__search`

- Purpose: Search the web and optionally scrape result URLs.
- Use when: You need lightweight search results and maybe quick scraped content.

### `mcp__freecrawl__scrape`

- Purpose: Scrape one URL with optional JavaScript rendering, anti-bot mode, caching, headers, cookies, and output formats.
- Use when: You know the page URL and need its content.

### `mcp__freecrawl__crawl`

- Purpose: Crawl a website from a start URL with include/exclude patterns, max depth, and max pages.
- Use when: You need a small bounded crawl within a site.

### `mcp__freecrawl__deep_research`

- Purpose: Research a topic across multiple sources with optional academic sources.
- Use when: You need a compact research pass without Firecrawl/Tavily complexity.

## Failure And Fallback

If freecrawl cannot retrieve the page or crawl enough content, use `mcp-firecrawl` for robust extraction, `mcp-tavily` for broad/current research, or `mcp-exa` for best-page discovery, and label the fallback path.
