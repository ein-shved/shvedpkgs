# specd-implement — delegate design and code

Read [shared notes](../shared.md) and [item protocol](../item-work.md).

1. Read live status, workspace ownership and relevant continuation/contracts.
   Load implementing context before hooks/writes. Follow native readiness with
   validated proposal/requirements and actual state transitions. Resolve
   upstream drift through original authors; partial later system work is normal.
2. Confirm the latest explicit involvement choice and required reviews. Do not
   infer one from an instruction to proceed. Honor scope-specific authorization
   and switches at any time, pausing work as required by the new checkpoints.
3. The main agent coordinates and never writes code. For architectural change,
   assign a separate executor per outline/plan point for its design and code.
   Only needed design precedes coding that point; later detailed design waits.
   For Update, delegate necessary code without inventing outline/tasks; the main
   agent may have updated sufficient design, or a researcher may design and code.
4. The same independent nonauthor arbiters first review new/updated design
   against other subsystems' requirements/design, then code preservation of
   those contracts, then cleanliness for the language/project. Resolve design
   findings before coding and code findings before implementation review.
   Full involvement also requires user approval of each stage and transitions
   in either direction. Partial involvement autonomously implements after
   initial-design user review; full delegation works independently throughout.
5. Keep original author/arbiter sessions and ownership in continuation. Return
   user corrections to that same author, never silently substitute or edit
   another author's work; report unavailable authors. Re-review changed design.
   Serious inconsistencies, including required hacks/workarounds, stop for the
   user's decision even when technically unblocked.
6. Run applicable checks and inspect integration. Process changes also require
   [retained blind scenario tests](../process-development.md). Validate complete
   system/requested ADR changes after reviewed implementation, complete hooks,
   and continue authorized `/specd-verify`. No checkbox tracking is required.

Return actual implementation/check evidence under the current involvement level.
Archive only on user command; commit only when authorized by user/project rules.
