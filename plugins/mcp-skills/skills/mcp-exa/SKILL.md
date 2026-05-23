---
name: mcp-exa
description: Use the exa MCP for semantic public web discovery and clean markdown fetching when Codex needs the most relevant page, article, company or person profile, project page, documentation page, technical reference, or URL content by intent rather than keyword or recency. Use automatically when relevance and clean reading matter more than broad source coverage.
---

# MCP: exa

## Routing Role

Exa is the best-page and clean-markdown route. Use it when the ideal source can be described semantically and relevance matters more than exhaustive or current coverage.

## Use Automatically When

- The task is to find the most relevant public page, profile, project, product, documentation, article, or technical reference.
- The query can be described as an ideal page rather than a keyword list.
- You already have one or more URLs and need clean markdown for reading, reasoning, or summarization.
- Precision, source relevance, and readable content matter more than recency or source breadth.

## Prefer Other Tools When

- The answer depends on latest news, prices, policies, schedules, regulations, or other fast-changing facts; use `mcp-tavily`.
- The task needs broad cross-source research, date filters, or country boost; use `mcp-tavily`.
- The task only needs a tiny fallback search or quick known-page fetch; use `mcp-ddg-search`.
- The target page is JavaScript-heavy, requires structured extraction, or needs browser interaction; use `mcp-firecrawl`.

## Communication Discipline

Do not claim or imply that Exa was used unless an Exa MCP tool actually ran and returned or failed.

If Exa is skipped, attempted, or unavailable, state the status briefly:

- `Exa semantic discovery/fetch succeeded`
- `Exa was attempted but failed; using fallback`
- `Exa was not used because Tavily, Firecrawl, local code, or a known source was more direct`

## MCP Tools

### `web_search_exa`

- Purpose: Search the web semantically and return clean, ready-to-use content from top results.
- Use when: You need relevant pages for a topic, company, person, project, or concept.
- Notes: Query with a descriptive sentence for the ideal page. Use category hints such as `category:people` or `category:company` when appropriate.

### `web_fetch_exa`

- Purpose: Read one or more URLs as clean markdown.
- Use when: You already have URLs and need the page content for reasoning or summary.

## Failure And Fallback

If Exa returns irrelevant pages, rephrase the query as the ideal page once. Then use `mcp-tavily` for broad/current search, `mcp-ddg-search` for lightweight fallback, or `mcp-firecrawl` for robust extraction, and label the fallback path.
