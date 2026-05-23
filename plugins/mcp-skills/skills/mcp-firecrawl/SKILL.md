---
name: mcp-firecrawl
description: Use the firecrawl MCP for robust webpage and document extraction, structured JSON extraction, JavaScript-rendered pages, site mapping or crawling, local PDF or Office parsing, browser interaction, and autonomous web research when simple search or fetch is not enough.
---

# MCP: firecrawl

## Routing Role

Firecrawl is the robust extraction route for pages, sites, and documents when simple search/fetch is not enough.

## Use Automatically When

- The user provides a URL and asks for page content, structured fields, screenshots, links, summaries, or brand/page extraction.
- The page may be JavaScript-rendered, paginated, sparse on simple fetch, or requires browser interaction.
- The task needs structured JSON extraction from one or more pages.
- The task needs site mapping, crawling, local PDF/Office parsing, or autonomous web research.

## Prefer Other Tools When

- The task is simple quick search or low-overhead link discovery; use `mcp-ddg-search`.
- The task is broad current research, news, policy, price, or multi-source verification; use `mcp-tavily`.
- The task is semantic discovery of the most relevant public page; use `mcp-exa`.
- The content is already local source code; use local tools or `mcp-ace-tool` depending on the lookup type.

## Communication Discipline

Do not claim or imply that Firecrawl was used unless a Firecrawl MCP tool actually ran and returned or failed.

If Firecrawl is skipped, attempted, or unavailable, state the status briefly:

- `Firecrawl scrape/extract/crawl succeeded`
- `Firecrawl was attempted but failed; using fallback`
- `Firecrawl was not used because search, local files, or another MCP was more direct`

## MCP Tools

### Search, Scrape, Extract

- `firecrawl_search`: Search the web, optionally with domain filters, news/images sources, and scraped result content.
- `firecrawl_scrape`: Scrape one known URL with formats such as markdown, JSON, links, screenshot, summary, branding, query, or audio.
- `firecrawl_extract`: Extract structured information from one or more URLs using a prompt and optional JSON schema.

Use `firecrawl_scrape` for a known page, JSON format for specific fields, and markdown for reading or summarizing full content.

### Site Discovery And Crawling

- `firecrawl_map`: Discover indexed URLs on a site, optionally filtered by a search phrase.
- `firecrawl_crawl`: Start a crawl job for multiple related pages.
- `firecrawl_check_crawl_status`: Poll a crawl job until complete or failed.

Use `map` before agent workflows when scraping returns sparse or wrong content.

### Documents

- `firecrawl_parse`: Parse a local file such as PDF, Word, Excel, HTML, RTF, or ODT into markdown, HTML, JSON, summary, links, or query output.

Use JSON format with a schema for specific data points. Use markdown when the user needs the document content.

### Browser Interaction

- `firecrawl_interact`: Interact with a previously scraped page using a scrape id, natural-language prompt, or code.
- `firecrawl_interact_stop`: Stop the interaction session.

Use these for multi-step page workflows after an initial scrape.

### Autonomous Agent

- `firecrawl_agent`: Start an async research agent that searches, navigates, and extracts results.
- `firecrawl_agent_status`: Poll the agent job and retrieve results.

Use this as a last resort or for complex multi-source research where exact URLs are unknown. Poll patiently.

### Legacy Browser Session Tools

- `firecrawl_browser_create`: Create a browser session.
- `firecrawl_browser_execute`: Execute commands in that browser session.
- `firecrawl_browser_list`: List browser sessions.
- `firecrawl_browser_delete`: Destroy a browser session.

Use these only when the newer scrape plus interact workflow is not enough.

## Failure And Fallback

If scraping returns empty, navigation, or irrelevant content, add wait time, use `firecrawl_map` to find the right page, then scrape the specific URL. Use `firecrawl_agent` only after map plus scrape is insufficient. If Firecrawl fails, use Tavily/Exa/ddg-search or a local parser when appropriate, and label the fallback path.
