# specd-metadata — generate and improve retrieval metadata

Read [shared notes](../shared.md). Run directly in the main session; independent
optimization workers are optional for an authorized large batch. Load binding
project context, or relevant change context, before writes/instructions.

## Select and generate

Use supplied spec IDs/paths or clearly stated scope. Resolve paths with
`specd specs resolve-path <path> --format toon`; do not invent qualified IDs.
If scope is unclear, ask which specs. For all-spec scope, discover stale,
missing or invalid metadata with
`specd specs list --metadata-status stale,missing,invalid --format toon`.

For each spec, read current metadata and save curated `dependsOn` before
regeneration. If metadata is fresh and semantically sufficient, leave it
unchanged. Otherwise generate the deterministic baseline with
`specd specs generate-metadata <specId> --write` (or the corresponding scoped
`--all --write --status stale,missing,invalid` batch).

Read results before dependent operations. Preserve curated dependencies;
reconcile detected differences against durable contracts and authorized scope
before writing final metadata. Do not silently drop existing entries. A
substantive unresolved dependency decision needs the user; routine metadata
cleanup does not. Inspect actual errors rather than blindly using `--force`.

## Improve semantic fields

Read generated metadata and only relevant spec context. The deterministic
extractor owns structural fields and content hashes. Improve retrieval quality:

- `description`: explain what the spec covers and when it matters concisely.
- `rules`: plain normative statements preserving named interfaces and states;
  remove copied Markdown scaffolding and duplication.
- `constraints`: keep their ownership, separate from requirement rules.
- `scenarios`: preserve requirement/name and given/when/then from requirements.
- `keywords`: four to eight concrete lowercase domain tags without generic filler.

Preserve `title`, reconciled `dependsOn` and exact `contentHashes`. Use stored
hash-map format, not the expanded freshness display from `specs metadata`;
`specs generate-metadata <specId> --format json` exposes the deterministic
metadata/hash map. Set `generatedBy` to `agent` after semantic optimization.
If workers are useful, give each exact inputs and ask for complete JSON without
source-file edits; the main session checks and writes their results.

If the schema has no deterministic extraction, derive metadata from actual spec
content, resolve declared dependencies through the CLI, and compute exact
SHA-256 hashes of artifact contents. Do not fabricate structural fields or
pretend extraction succeeded.

## Validate and write

Check valid JSON, required schema fields, useful nonempty keywords, preserved
meaning/dependencies and exact hashes. Reject formatting fragments, invented
requirements and dropped obligations. Write with
`specd specs write-metadata <specId> --input <json-file>` and inspect with
`specd specs metadata <specId> --format toon`. Preserve readOnly ownership and
use temporary files only where writable. Report updated/unchanged specs,
errors and limits; do not launch unrelated lifecycle work.
