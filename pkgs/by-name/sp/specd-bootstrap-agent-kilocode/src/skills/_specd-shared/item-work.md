# Work-item protocol

Use this protocol for each proposal item. The main session owns initial
proposal/requirements, the external-interface and item skeleton in system,
participation, integration and lifecycle routing. Optional research workers
return compact verified context.

## Participation and authorship

Before implementation, reuse the user's clear involvement choice or ask once:
review completed items individually, review the completed change together, or
delegate routine review. Record it concisely in proposal/continuation. Batch
review means the finished architecture and code after implementation.
With item review, present the
completed reviewed item before moving to the next. With delegated review,
deliver a change ready for closure. Significant inconsistencies reach the user
in every mode.

Assign an executor to each item, with exact source pointers, scope, applicable
requirements, relevant system section, dependencies and expected checks. Record
the item-to-executor session mapping in change-local continuation, alongside
progress, review outcomes and unresolved questions. Keep/resume these original
executor sessions through user review, including batch review.

All later user questions and corrections concerning an item's code or artifact
return to its original executor. The main session forwards feedback and
coordinates affected owners; it does not edit that item itself or launch a
replacement author. If the original session is unavailable, explicitly report
the limitation and preserve continuation rather than silently substituting.
The original executor handles minor necessary corrections to earlier items and
informs their owners; substantive inconsistencies pause for the user.

## One item, from design to code

1. **Executor:** read relevant current sources directly. Add the shortest
   sufficient system description: key role, named participants, module
   relationships and significant external dependencies. Reuse shared contracts.
   Omit familiar idioms, rejected alternatives and routine implementation detail.
2. **Independent design reviewer:** read actual requirements, the system section
   and relevant sources. Check sufficiency and consistency; ask implementation
   questions where they expose architectural risk. Decide which answers matter
   to system and which can be resolved in code. Answers do not automatically
   become architecture prose. Return concrete findings or approval.
3. **Same executor:** resolve findings, then implement immediately after design
   approval. Do not wait for later items' design. Develop system and code
   together, carrying architectural decisions between them as work progresses.
   Revisit proposal/requirements through their original authors when scope or
   needs evolve. Run appropriate tests and required checks. Minor
   corrections stay autonomous; significant inconsistencies need the user's
   decision. Re-review materially changed item design before continuing.
4. **Separate code reviewer:** use a context distinct from both the executor and
   design reviewer. Inspect the actual diff, affected callers/contracts and
   check results. Check code/documentation spec links: the durable document and
   any referenced anchor must exist and remain meaningful after archive. Report concrete
   bugs, omissions or inconsistencies.
5. **Original executor:** fix findings, obtain code re-review as needed, and mark
   the proposal item done only after code review and required checks pass.
   Preserve concise evidence outside proposal/system. Apply the chosen user
   review schedule and route subsequent feedback back to this executor.

Use supported independent-agent tools and actual available capacity. Reviewers
read sources directly and do not author reviewed code/artifacts. Do not
impersonate independent review by relabeling one context. If independent contexts
are unavailable, report the limitation and keep the item resumable.

After all items, the main session checks integration and completeness, routing
needed corrections to the original executors. Validate the complete system,
then perform authorized final verification. Present the completed change and
actual check evidence at the chosen user-review boundary. Do not auto-archive.
