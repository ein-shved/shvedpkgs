# specd-archive — merge reviewed deltas

Read [shared notes](../shared.md). Archive only when the user has authorized
archiving; implementing or preparing for closure does not imply archive.
Reuse explicit archive authorization instead of asking again.

1. Read status, load archiving context and confirm live archive prerequisites:
   completed proposal items, reviewed implementation, complete validated system,
   successful verification and any human approval gates. Repair routine blockers
   within authorized scope; surface significant inconsistencies to the user and
   forward item corrections to their original executors.
2. Review merged affected spec artifacts, using fresh full previews or
   `changes spec-preview <name> <specId> --artifact <id>`. Review proposal directly.
   Confirm the durable result matches code and preserves required existing
   contracts. Raw deltas alone do not establish the merged result.
   Preserve existing ADR history and review requested ADR changes when present.
3. Run archiving pre-hooks and instructions, then
   `specd changes archive <name> --skip-hooks all --format toon`.
   If overlap blocks archive, show conflicting changes/specs and ask for a
   decision unless that exact risk was already accepted. Use `--allow-overlap`
   only with that authority.
4. Run archiving post-hooks/instructions. Generate stale/missing metadata for
   affected specs, respecting their dependency contracts. If configuration
   requires semantic optimization, continue through `$specd-metadata` as part of
   the authorized archive task. Reuse fresh project status for that setting.
5. Report the archive result and relevant remaining limits. Do not create
   follow-up work outside the user's request.
