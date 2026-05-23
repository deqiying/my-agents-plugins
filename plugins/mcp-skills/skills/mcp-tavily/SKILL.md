---
name: mcp-tavily
description: Use the tavily MCP as the primary public web research tool for recency-sensitive facts, news, policies, regulations, product or pricing changes, schedules, multi-source verification, date or domain filtered search, broad research, and site extraction. Use automatically when facts may have changed or source comparison matters.
---

# MCP: tavily

## Routing Role

Tavily is the default route for current public information, broad research, source comparison, and date/domain-filtered web lookup.

## Use Automatically When

- The user asks for latest/current/today/recent facts, news, prices, releases, policies, laws, regulations, schedules, or other unstable information.
- The task needs multiple sources, source comparison, date filters, domain filters, country boost, raw page content, or broad research.
- A website must be mapped, crawled, or extracted and robust JavaScript handling is not the main issue.
- The answer should include source URLs for verification.

## Prefer Other Tools When

- The task is to find the single most relevant page or a semantically similar source; use `mcp-exa`.
- The task is a quick low-stakes lookup or fallback link search; use `mcp-ddg-search`.
- The user asks for official OpenAI or third-party library documentation; use the official docs skill or `mcp-context7`.
- The page needs robust JavaScript rendering, structured JSON extraction, document parsing, or browser interaction; use `mcp-firecrawl`.

## Communication Discipline

Do not claim or imply that Tavily was used unless a Tavily MCP tool actually ran and returned or failed.

If Tavily is skipped, attempted, or unavailable, state the status briefly:

- `Tavily search/research succeeded`
- `Tavily was attempted but failed; using fallback`
- `Tavily was not used because another source was more direct`

## MCP Tools

### `tavily_search`

- Purpose: Search the web for current information with optional depth, domain filters, date filters, country boost, images, and raw content.
- Use when: You need search results and source URLs for current or verifiable facts.

### `tavily_research`

- Purpose: Perform broader research and synthesize findings across sources.
- Use when: The question has multiple subtopics or needs a researched narrative.

### `tavily_extract`

- Purpose: Extract raw page content from URLs in markdown or text.
- Use when: You have known URLs and need page content.

### `tavily_map`

- Purpose: Map a website's URL structure.
- Use when: You need to discover pages before selecting what to read or crawl.

### `tavily_crawl`

- Purpose: Crawl a website with configurable depth, breadth, filters, and extraction depth.
- Use when: You need multiple related pages from a site.

## Failure And Fallback

If Tavily results are too broad or weak, refine the query with date, domain, country, or exact-phrase constraints once. Then use `mcp-exa` for best-page discovery, `mcp-firecrawl` for extraction, or official/primary sources directly, and label the fallback path.
