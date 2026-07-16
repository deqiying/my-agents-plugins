# Memory Quality Rubric

## Remember

- Stable user preferences that affect future responses or tool choice.
- Repeated local paths, config files, log files, and verification commands.
- Verified project boundaries, module responsibilities, deployment shapes, or workflow decisions.
- Confirmed gotchas, historical misdiagnoses, and their fixes.
- High-risk operation order when the order prevents data loss or repeated failures.
- Dated public or version snapshots only when the entry says what must be rechecked.
- Minimal evidence pointers such as file paths, commands, config keys, rollout summaries, or exact error text.

## Do Not Remember

- One-off conversation flow, greetings, or temporary preferences.
- Unverified guesses, theories, or speculative diagnoses.
- Long raw logs or pasted command output without a durable conclusion.
- Temporary plans that were not approved or executed.
- Raw tokens, API keys, passwords, cookies, bearer values, private connection strings, personal identifiers, or private account data.
- Superseded conclusions with no useful historical gotcha.
- Full documentation copies that should be fetched from the source when needed.

## Standard Candidate Shape

```text
trigger:
- ...

stable conclusion:
- ...

evidence:
- ...

revalidation:
- durable | snapshot YYYY-MM-DD | re-check before use

gotchas:
- ...
```

## Revalidation Labels

- `durable`: local preference, stable path, verified project boundary, or repeated workflow.
- `snapshot YYYY-MM-DD`: public web, product state, pricing, release, package status, or external docs observed on a date.
- `re-check before use`: config keys, official docs, latest versions, upstream behavior, generated files, branch state, or likely-to-drift facts.

## Classification

- `keep`: stable, reusable, triggerable, and evidence-backed.
- `rewrite`: useful but verbose, duplicated, missing trigger/evidence/revalidation, or mixed with process noise.
- `drop`: one-off detail, unverified speculation, sensitive content, or an obsolete conclusion without historical value.
- `needs-verification`: potentially useful but dependent on current external or generated state.

## Review Checklist

- Can a future session tell exactly when to use the memory?
- Is the conclusion useful without rereading the full rollout?
- Is the evidence small enough to verify quickly?
- Is the entry safe to reuse as current fact, or does it need a date?
- Does it prevent a likely repeated mistake?
- Is a similar entry actually redundant, or only topically related?
