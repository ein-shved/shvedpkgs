# specd-design — proposal gate and item architecture

Read [shared notes](../shared.md) and the [item protocol](../item-work.md).
The main session prepares initial artifacts and develops system alongside code.

1. Read live status, exact continuation/discovery paths and relevant sources.
   Load designing context before hooks/instructions. Obtain workspace ownership
   and use the shared hook/transition protocol. Inspect drift/review reasons
   against current intent; preserve unaffected content when repairing state.
2. Get `changes artifact-instruction <name> <id>`. Use its scope, output paths,
   template and pre/post rules; request schema or outlines only for missing
   necessary metadata. Register specs before writing deltas and inspect merged
   results. Author ADR content only on explicit user request, preserving history.
3. Prepare a short proposal with numbered high-level checkbox items, each with a
   short name and purpose sentence, plus concise allocation of this change's
   actual content to its affected artifacts. Obtain independent proposal review
   and corrections before user proposal review. Resolve user comments through
   the original author and clear affected agent-review findings before another
   user presentation.
4. Once user proposal review is complete, explicitly ask the three-level
   involvement question and wait before requirements or system. Earlier
   preferences do not skip this new-change question. Record the reviewed
   proposal and actual answer in continuation. Reuse an answered gate for the
   same unchanged reviewed proposal on resume, as the item protocol defines.
5. After that answer, prepare requirements in the existing requirement/scenario
   format. Obtain independent requirements review and corrections; full
   involvement and code-only delegation also require user requirements review
   before dependent implementation. Prepare system's external interface and
   matching work-item skeleton. A narrow covered fix may use sufficient existing
   requirements/system through `no-op`; present/review that actual base as needed.
6. Validate proposal and requirements with correctly scoped commands. Use live
   readiness diagnostics, distinguishing partial system flags from upstream
   blockers. System may remain incomplete for `ready`/`implementing`; CLI spec
   approval remains human-only.
7. Continue authorized `/specd-implement` work directly: each executor develops
   an item's brief design, clears independent design review and the selected
   level's user design review, then immediately codes that item. A design-only
   request ends at its requested scope with concise continuation.

Item executors evolve system and implementation together; original authors
update proposal/requirements when scope or needs evolve, applying affected
reviews and checkpoints. After item reviews, the main session checks integration,
routes corrections to original authors and validates complete system before
final verification. Record special checks in system only on explicit user
request; ordinary tests and code review run during implementation.
