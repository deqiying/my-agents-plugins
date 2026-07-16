# Task Group: Alpha
scope: stable local workflow
applies_to: cwd=/workspace; reuse_rule=re-check generated state before current claims.

## Task 1: Verified behavior

rollout_summary_files:
- rollout_summaries/2026-07-16-alpha.md (updated_at=2026-07-16T08:00:00+00:00, thread_id=11111111-1111-4111-8111-111111111111)

## User preferences

- The current path must be verified before use.

# Task Group: Beta
scope: another stable local workflow
applies_to: cwd=/another; reuse_rule=re-check generated state before current claims.

## Task 1: Another behavior

## User preferences

- Prefer concise evidence-backed summaries.
