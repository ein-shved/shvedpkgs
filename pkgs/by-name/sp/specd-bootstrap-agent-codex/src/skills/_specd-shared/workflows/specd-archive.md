# specd-archive — merge reviewed deltas

Read [shared notes](../shared.md). Archive only on the user's command; reuse
existing explicit archive authorization without asking again. Readiness or an
involvement level alone does not authorize archiving.

1. Read status and load archiving context. Confirm reviewed implementation,
   complete validated contracts, all applicable project/change/SpecD/user
   checks, and actual human-only approvals. Route corrections to original
   authors; serious inconsistencies stop for the user's decision.
2. Inspect actual merged artifacts and code alignment. Preserve existing ADR
   history, test artifacts and durable links. Raw deltas do not establish the
   merged contract. Do not create ADR content without explicit user request.
3. Run archiving pre-hooks/instructions and
   `specd changes archive <name> --skip-hooks all --format toon`.
   Resolve overlap from actual scope; --allow-overlap needs explicit acceptance
   of that risk. Never delete proposal before native archive succeeds.
4. Read the exact returned archivePath, resolving a relative path against the
   project root used by that command. Run post-hooks/instructions, then delete
   only proposal.md in that verified archive directory. Preserve every other
   archived file and retained test root. This cleanup applies to this successful
   archive, not historical proposals in unrelated archives. Report any failure.
5. Generate stale/missing metadata under its contract. If configured, continue
   `$specd-metadata` semantic optimization within this authorized archive task.
   Report the result and remaining limits without inventing follow-up work.
