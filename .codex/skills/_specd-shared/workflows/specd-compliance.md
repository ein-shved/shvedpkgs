# specd-compliance — focused or project audit

Read [shared notes](../shared.md). Audit directly; do not edit code or specs.
Load binding project context first, or relevant change context when auditing
an active change. Only the requested report is writable.

## Scope

- No argument: audit the project's specs.
- Qualified spec ID/path: resolve it through the CLI and audit that spec.
- `--changed`: use tracked diffs and untracked files to identify affected specs.
- `--pr <number-or-url>`: read the PR's changed files, then resolve affected specs.

Discover specs/workspaces with CLI output. Map affected files to actual code
roots and owning requirements using current contracts and code references.
Include applicable cross-cutting constraints and relevant dependencies; do not
assume a `packages/` layout or fixed spec names. Report uncertain ownership or
uncovered scope explicitly. Use exact sources before broader searches; graph
queries are useful when they answer a concrete navigation question.

## Audit and report

Read relevant full contracts (merged previews for active-change artifacts).
For each requirement/scenario, inspect implementation, affected callers and
tests. Check interface signatures, errors, invariants, actual execution paths,
dependency consistency and durable documentation links where relevant. Scenarios
live in requirements; only user-requested special checks may be in system.
Separate observed failures, missing implementation, insufficient test coverage
and unresolved ambiguity. Cite concrete source paths/lines and check evidence.
Do not assume code or spec is automatically correct when they disagree.

For a large authorized audit, independent read-only workers may inspect bounded
slices with exact spec IDs/source pointers. They return concise findings or write
assigned report sections. The main session integrates all findings and retains
their evidence.

Write the requested report, by default under `.specd/reports/spec-compliance/`
with a scope-specific timestamped name. Include scope, per-requirement findings,
scenario/test coverage, dependency contradictions, evidence and material limits.
Return important findings and report path. Do not fix findings or change
lifecycle state unless the user's request also authorizes that work; later item
feedback/fixes go to the original executor.
