---
name: tool-fast-context
description: Use the local fast-context CLI as the first semantic discovery route for unknown local-code entrypoints, business-intent-to-code mapping, architecture or data-flow analysis, call-path tracing, impact discovery, and candidate-file narrowing before edits. The search sends repository context to an external service, so use it only with authorization and prefer deterministic local tools for exact paths, symbols, config keys, packet names, error text, or narrow paths.
---

# Fast Context CLI

## Routing Role

Use fast-context as the first route for natural-language local-code discovery. It returns likely files, line ranges, and follow-up ripgrep patterns; treat every result as a candidate and verify it with local reads and exact rg before editing or answering.

Do not enter this route for an exact path, symbol, configuration key, packet name, error text, or narrow directory. Use deterministic local tools directly. If the CLI is unavailable, external repository transmission is not authorized, or the search fails, load $tool-codesearch as the local-only semantic fallback.

## Respect The External-Data Boundary

fast-context search sends the query, repository map, and requested restricted-tool results to Windsurf Devstral.

- Run search only when the user has authorized this external repository transmission for the task.
- Exclude sensitive, generated, and irrelevant directories before a search.
- Keep --include-snippets off unless code snippets are authorized and materially reduce follow-up reads.
- Never print API keys, JWTs, tokens, complete credential candidates, or credential-source paths in user-facing output.

## Resolve And Preflight

Locate and inspect the CLI before using it:

~~~powershell
Get-Command fast-context -All
fast-context --version
fast-context doctor --project . --format json
~~~

For doctor --format json, inspect project.exists, ripgrep.ok, ripgrep.source, and credentials.ok without echoing its full credential object. doctor returns exit code 0 even when a check is unavailable, so the JSON fields are the source of truth.

The npm package owns the CLI lifecycle while a runtime manager can own only Node and npm:

~~~text
mise -> Node/npm -> fast-context
~~~

If the command is missing, diagnose with npm prefix --global, npm list --global --depth=0, and command resolution. Do not install globally unless the user authorizes the change. Install @deqiying/fast-context through npm; pin an exact version when reproducibility matters.

## Search, Narrow, Read, And Verify

Write the semantic query primarily in English and add domain terms that match repository identifiers. Start with structured output and a modest result set:

~~~powershell
fast-context search "where user login authentication and JWT validation are handled" --project . --tree-depth 0 --max-results 10 --exclude node_modules --exclude dist --exclude coverage --format json
~~~

Use the returned paths, 1-based inclusive line ranges, and rg_patterns to narrow local inspection. Read the indicated files, then use exact rg, tests, builds, or runtime evidence to verify the conclusion. Do not enable --include-snippets by default.

## Failure And Fallback

If the CLI search fails because of network, TLS, authentication, rate limits, service availability, or protocol drift:

1. Report only the stable error category, not credential details.
2. Load $tool-codesearch when a local-only semantic fallback is needed.
3. Let codesearch create or refresh an index in the background; complete the current task with rg, direct reads, and repository-native checks rather than waiting.

Run fast-context search --help for exact flags and fast-context skills show fast-context --format content for the version-matched embedded guidance.