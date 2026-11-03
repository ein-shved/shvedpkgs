# specd-implement — review and implement each item

Read [shared notes](../shared.md) and the [item protocol](../item-work.md).

1. Read live status and load implementing context before hooks or writes.
   Obtain workspace ownership/codeRoot, inspect blockers/review reasons and
   follow the actual readiness route. Proposal and requirements must be complete
   before entering implementation. Handle routine upstream repairs within the
   authorized work. Assess review/nextAction by the affected artifact;
   ongoing system work continues in implementing.
   Confirm the proposal's recorded user review and answered involvement gate;
   if unfinished, complete that gate before further requirements/system or code.
2. Read proposal's task-bearing items, merged relevant requirements, the system
   interface/skeleton and real dependency contracts. Use schema/status paths;
   load relevant artifacts and continuation. Confirm independent requirements
   review and required user requirements review have cleared. Run entry hooks
   and transition to implementing using the shared protocol, or resume the phase.
3. Work through ordered proposal items, respecting dependencies. For each,
   assign/retain its executor and record the author mapping in continuation.
   Apply the item protocol: brief system section → independent design review →
   same executor's implementation and tests → separate code review → fixes and
   checkbox completion. System and implementation evolve together throughout
   the item; revisit proposal/requirements through their original authors when
   scope or needs evolve. A reviewed item reaches code before later item design.
   In full involvement and code-only delegation, clear user design review after
   agent corrections and before coding. Full involvement also clears user code
   review after the separate code arbiter's findings are resolved. Full
   delegation proceeds through agent reviews within scope.
4. Keep original executor sessions available through required user reviews and
   later feedback. Forward questions/corrections to them; do not
   edit their work as orchestrator or silently replace authors. Record any
   unavailable-session limitation explicitly.
5. After the last reviewed item, check system/code integration and route
   corrections to their original executors. Validate the now-complete system
   and any explicitly requested ADR changes, then run implementing
   post-hooks/instructions. Repair actual drift or missing dependencies within
   scope; do not claim completion prematurely.
6. Continue authorized `/specd-verify` work and present completed architecture,
   code and real check evidence according to the recorded involvement level.
   When implementation alone was requested, stop at that requested boundary.
   Default full delivery is ready for closure, with no automatic archive.

The executor may make minor necessary fixes in earlier items and notify their
owners. Significant design inconsistencies pause for the user's decision.
Commit only when project rules or the user authorize it. Code/docs links must
resolve to existing durable spec documents and any referenced anchors, remaining
meaningful after archive. Check them during authoring and code review.
