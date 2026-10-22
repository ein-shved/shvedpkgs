# Authorship, involvement and independent review

The main agent holds the overall change context and authors initial artifacts.
It never writes code. For architectural changes it also delegates detailed
item design. Use actual independent subagent contexts, not role labels within
one conversation. If unavailable, report the limit and preserve continuation.

## Proposal and involvement

Before writing proposal, the main agent reads only the task and SDD artifacts.
When they are insufficient, a research subagent gathers the necessary context;
the main agent does not inspect code, browse or investigate details itself.
Classify by architectural decisions, not code volume. Follow live proposal
instructions for format; allocation rows are destinations, not a task plan.
Only architectural changes have a short system outline serving as the plan.
Its points describe solution parts. Ordinary tests and usage docs belong with
the related part's implementation, not standalone outline/system sections.
A request to write or run tests alone does not request special-check prose in
system; that description needs an explicit request of its own.

After writing proposal, ask the user for one of these levels unless they have
already selected it MAXIMALLY EXPLICITLY. Do not infer a choice from behaviour,
approvals, prior collaboration style or a generic instruction to continue.
Do not prepare downstream work while a required choice is missing.

- **Full involvement:** present successive artifacts and wait for approval;
  discuss and obtain approval of every design/code stage and transition,
  including returns from code to design.
- **Partial involvement:** independently prepare initial artifacts/design:
  external API and skeleton/plan for architectural change; necessary design
  edits for Update. Obtain user review, then independently implement and return
  the implementation. Do not impose per-item user design/code gates afterward.
- **Full delegation:** independently develop artifacts/code and deliver a result
  ready for archiving, after all applicable checks and independent reviews.

Record the explicit choice and its source in continuation; reuse it on resume.
The user can switch at any time. Apply the latest explicit choice immediately
and pause running work as needed; do not finish a now-unapproved stage under an
old level. Preserve useful work and ask only about an actually unclear choice.
Scope-specific explicit user instructions continue to control that scope.

## Independent arbitration

Before any SDD artifact is submitted for review, an independent nonauthor
arbiter checks the actual artifact (merged preview for deltas):

- Formal artifact requirements, simplicity and readability for the owner.
- Consistency with other artifacts and the user's requests.
- Correct content boundaries: reject ordinary tests/docs promoted into outline
  points or system sections without an explicit special-check-description request.

The original author resolves findings before submission. Agent review does
not substitute for required user approval or human-only CLI approvals.

Use the SAME independent nonauthor arbiters for design and code, in order:

1. Review new or updated design before implementation for consistency with
   other subsystems' requirements and design; resolve findings before coding.
2. Review implementation for preservation of those requirements and design.
3. Check cleanliness against the language and project's conventions.

Resolve code findings before implementation review. Arbiters read actual
sources; retain only architecturally material answers in system. Re-review
materially revised design before continuing code.

## Execution and original authors

- **Architectural change:** assign a separate executor to each plan point.
  It develops that point's detailed design, clears arbitration and applicable
  user approvals, then implements it with checks. Later detailed design waits
  until needed; do not turn allocation table rows into executor assignments.
- **Update:** after proposal, the main agent may edit design if it already
  knows what and where to change. Otherwise a subagent researches and updates
  design; that same subagent may implement. Delegate code in either case.
  Necessary artifact edits may be absent; sufficient contracts use no-op deltas.

Give executors exact scope, sources, applicable contracts and expected checks.
Record artifact/item-to-author sessions and arbiter sessions in continuation.
Keep original authors available/resumable through user review and corrections.
User feedback MUST return to the original author: the same code/design
subagent, or the main agent for its own artifact. The coordinator forwards
feedback and never silently edits another author's work or replaces them.
If an author is unavailable, tell the user and preserve continuation.

At EVERY involvement level, stop for a serious inconsistency, explain it and
ask the user how to proceed. This includes blockers and issues requiring a hack
or workaround even when progress is technically possible. Do not implement a
workaround to avoid escalation. Resume only after the user's decision.

Integration aligns affected owners; correct upstream artifacts through their
original authors. Pass all applicable checks from the project, change artifacts,
SpecD processes and user; these sources accumulate obligations. Deliver actual
evidence, preserving process-test artifacts. Archive only on user command.
