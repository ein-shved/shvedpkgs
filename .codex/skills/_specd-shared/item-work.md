# Work-item protocol

The main session owns the initial proposal/requirements, external-interface
and item skeleton in system, involvement checkpoints, integration and lifecycle
routing. Optional research workers return compact verified context.

## Proposal review and involvement

For every new change, prepare the short proposal with its concrete artifact
allocation and high-level work items. An independent proposal arbiter reviews
it; the original author resolves findings before the main session presents it
to the user. Resolve user comments through that author and clear affected agent
review findings before presenting the corrected proposal again.

After user proposal review is complete, always ask the actual user to choose:

- **Full involvement:** user review of agent-reviewed requirements, item designs
  and implemented code.
- **Delegate code only:** user review of agent-reviewed requirements and item
  designs; agents implement, review and accept code autonomously.
- **Full delegation:** agents prepare, review and accept requirements, item
  designs and code autonomously after this proposal review and answer.

Wait for the answer before preparing requirements or system. Ask after proposal
review for each new change even when an earlier preference was supplied. Record
the reviewed proposal revision, resolved user review and actual question/answer
in change-local continuation. Resume that answered gate for the same unchanged
reviewed proposal without asking again; recording the answer and task progress
marks do not reopen it. Changed proposal meaning receives renewed review and
its involvement question before dependent requirements/system work proceeds.

In every mode, requirements receive independent agent review and corrections.
Each item has an independent design arbiter and a separate code arbiter. Every
result presented for user review has already passed its applicable agent review
and corrections. Full involvement and code-only delegation wait for user review
of requirements and item design before implementation; full involvement also
waits for user review of agent-reviewed code before completing the item.
Significant inconsistencies reach the user in every mode. Full delegation
returns a change ready for closure.

## Authorship

Assign an executor to each item, with exact source pointers, scope, applicable
requirements, relevant system section, dependencies and expected checks. Record
the item-to-executor session mapping in change-local continuation, alongside
progress, review outcomes and unresolved questions. Keep/resume these original
executor sessions through user feedback and closure.

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
2. **Independent design arbiter:** read actual requirements, the system section
   and relevant sources. Check sufficiency and consistency; ask implementation
   questions where they expose architectural risk. Decide which answers matter
   to system and which can be resolved in code. Answers do not automatically
   become architecture prose. Return concrete findings or approval. The original
   executor clears findings before required user design review; wait for that
   user review in full involvement and code-only delegation.
3. **Same executor:** implement immediately after the applicable design reviews
   clear. Develop system and code together, carrying architectural decisions
   between them as work progresses. Revisit proposal/requirements through their
   original authors when scope or needs evolve, applying the affected reviews
   and involvement checkpoint. Run appropriate tests and required checks. Minor
   corrections stay autonomous; significant inconsistencies need the user's
   decision. Re-review materially changed item design before continuing.
4. **Separate code arbiter:** use a context distinct from both executor and design
   arbiter. Inspect the actual diff, affected callers/contracts and check results.
   Check code/documentation spec links: the durable document and any referenced
   anchor must exist and remain meaningful after archive. Report concrete bugs,
   omissions or inconsistencies.
5. **Original executor:** fix findings and clear code re-review as needed before
   any required user code review. Mark the proposal item done after required
   checks, agent review and the selected level's user reviews pass. Preserve
   concise evidence outside proposal/system; later feedback returns here.

Use supported independent-agent tools and actual available capacity. Reviewers
read sources directly and do not author reviewed code/artifacts. Do not
impersonate independent review by relabeling one context. If independent contexts
are unavailable, report the limitation and keep the item resumable.

After all items, the main session checks integration and completeness, routing
needed corrections to original executors. Validate the complete system, perform
authorized final verification and deliver the reviewed result with actual check
evidence. Archive only when authorized.
