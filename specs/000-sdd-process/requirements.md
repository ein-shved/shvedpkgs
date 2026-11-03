# Requirements

## REQ-001: Existing SDD process remains authoritative

The human-readable artifact rules define the meaning and boundaries of SDD
artifacts independently of the tools and agents used to produce them.

### Scenario: Artifact meaning is discoverable

- WHEN a developer interprets an SDD artifact
- THEN the artifact rules define its responsibility and content
- AND tooling instructions remain consistent with those rules

### Scenario: Artifact contracts change explicitly

- WHEN an accepted change revises an artifact's responsibility or format
- THEN its rules and dependent authoring instructions are updated together

## REQ-002: SpecD provides machine-readable workflow state

The repository must provide a SpecD project configuration that allows agents
to discover project state, steady-state specs, active changes, lifecycle
blockers, and next artifact instructions through the SpecD CLI.

### Scenario: Agent discovers current project state

- WHEN an agent begins SDD work in the repository
- THEN the SpecD CLI exposes the current project configuration, specs, changes, lifecycle state, and blockers
- AND the agent can determine the next lifecycle action without relying on conversation history

### Scenario: Agent discovers the next artifact instruction

- WHEN a change is ready for its next design or lifecycle artifact
- THEN the SpecD CLI exposes the next artifact identifier, scope, instructions, validation expectations, and target output location
- AND the agent can use that information as the authority for the next artifact write

## REQ-003: Developers can find current SDD process rules

Developers must be able to find the human-readable artifact model and the
instructions for using it. Artifact rules and their Russian translation own
content contracts; operational resources own agent and lifecycle behavior.

### Scenario: Developer finds the artifact model

- WHEN a developer needs an artifact's format or responsibility
- THEN the repository's SDD materials lead to its human-readable rules
- AND those rules can be understood independently of production tooling

### Scenario: Changes update their owners

- WHEN artifact contracts or operational behavior change
- THEN the resources owning the changed meaning are updated
- AND changes to artifact contracts update both language versions of the rules

## REQ-004: SpecD-owned SDD fragments reconstruct readable documents

When the SDD model is split across SpecD-owned artifacts, the repository must
retain a deterministic reconstruction order for each document kind.

Reconstructed documents must follow the same general-to-specific reading order
as the repository's SDD sections. Validation must make ordering mistakes
visible rather than hiding them behind arbitrary filesystem or glob order.

### Scenario: Reconstructed documents are deterministic

- WHEN a document is reconstructed from SpecD-owned fragments
- THEN the fragments appear in a deterministic order for that document kind
- AND repeated reconstruction produces the same reading order from the same inputs

### Scenario: Ordering mistakes are visible

- WHEN a SpecD-owned fragment would appear in an order that breaks the expected general-to-specific reading flow
- THEN validation or review can identify the ordering problem
- AND the problem is not hidden by arbitrary filesystem or glob ordering

## REQ-005: Normative SDD artifacts describe the current architecture

Current needs and satisfaction conditions belong in requirements; current
interfaces, contracts and architecture belong in system. ADRs are created
only on the user's explicit request and preserve the context, alternatives
and rationale of significant decisions.
These artifacts must suffice for the affected work without conversation history.

### Scenario: Current architecture is understandable

- WHEN a developer changes a covered capability
- THEN its requirements and system explain the needs and relevant current design
- AND temporary notes do not replace those contracts

### Scenario: User controls decision records

- WHEN an architectural choice is made during a change
- THEN an ADR is created only on the user's explicit request

### Scenario: Code documentation references durable truth

- WHEN code or its permanent documentation links to a specification
- THEN the target document and any referenced heading exist in durable specs
- AND the link remains meaningful after the change is archived

## REQ-006: Changes that modify behavior pass through SpecD artifacts

A change starts with a short proposal containing high-level work items and
an explicit allocation of the change's content among artifacts. After proposal
review and the user's involvement choice, requirements and an external-interface
skeleton precede architecture and implementation developed together by item.
Reviewed items can proceed to code while later design remains open.
Discoveries may also require revising the proposal or requirements.

### Scenario: Creating a change produces its proposal

- WHEN the user asks an agent to create a change
- THEN the agent prepares its short proposal with work items and concrete artifact allocation
- AND presents the proposal for review before preparing requirements or system

### Scenario: Proposal allocates actual change content

- WHEN a proposal describes a change
- THEN it briefly identifies what content belongs in each affected artifact
- AND that allocation accompanies the short high-level work items

### Scenario: Begin implementation incrementally

- WHEN the initial requirements and external-interface skeleton are available
- AND a work item's brief design passes independent review
- THEN that item's implementation can start without completing later items' design

### Scenario: Revisit earlier artifacts when needed

- WHEN joint architecture and implementation work reveals a needed change in intent or requirements
- THEN the proposal or requirements are revised as appropriate
- AND affected architecture and implementation are aligned with that revision

### Scenario: Small changes stay small

- WHEN a narrow fix is already covered by current requirements and architecture
- THEN it uses one work item and may leave those contracts unchanged
- AND a requested regression check can be its only spec addition

### Scenario: Existing behavior reuses its owners

- WHEN an existing spec covers the changed behavior
- THEN the change attaches it and revises only the affected contracts
- AND uncovered behavior receives an owning spec

## REQ-007: Validation checks remain distinct from acceptance scenarios

Acceptance scenarios remain inside their requirements. Special technical
check descriptions belong in system only when explicitly requested by the user.
Implementation receives appropriate tests and independent code review.

### Scenario: Record a requested special check

- WHEN the user asks to preserve an unusual check or regression case
- THEN system describes that case briefly
- AND its acceptance meaning remains with the owning requirement

### Scenario: Routine implementation checks

- WHEN an implementation is checked against its requirements and design
- THEN appropriate tests and independent code review establish conformance
- AND special check descriptions in system reflect explicit user requests

## REQ-008: Each work item receives focused design and code review

Work items share the system's external interface and receive focused design,
implementation, and independent review. Architecture records the key roles,
participants and dependencies needed to understand the solution concisely.

### Scenario: Review and implement one item

- WHEN an executor develops a work item
- THEN an independent reviewer checks its brief design and can ask implementation questions
- AND the same executor implements it after design review
- AND a separate reviewer checks the resulting code

### Scenario: Keep architecture sufficient and brief

- WHEN a design question is resolved
- THEN system retains only the architectural decision needed to understand the solution
- AND familiar idioms, rejected alternatives and routine implementation detail do not inflate it

### Scenario: Original executor handles user feedback

- WHEN the user questions or requests changes to an item's code or design
- THEN the coordinating session routes that feedback to the item's original executor
- AND the original executor handles the response and corrections through user review
- AND an unavailable original executor is reported rather than silently replaced

### Scenario: Resolve findings proportionately

- WHEN implementation reveals a minor issue in an earlier item
- THEN the executor may correct it and align the affected design

### Scenario: Significant inconsistency needs a decision

- WHEN a significant inconsistency requires a design decision
- THEN work pauses for the user's decision

### Scenario: Resume focused work

- WHEN a new participant resumes an item
- THEN current artifacts and concise continuation identify its inputs, progress and unresolved questions

## REQ-009: Users choose review involvement

Every change's proposal is reviewed with the user before the agent asks for
their level of involvement. The agent waits for the answer before preparing
requirements or system. The three levels are full involvement, delegation of
code only, and full delegation. Independent agents review work in every mode;
any result presented for user review has already passed agent review and
corrections. Significant inconsistencies reach the user in every mode.

### Scenario: Ask after proposal review

- WHEN the user has finished reviewing the proposal and its comments are resolved
- THEN the agent explicitly asks the user to choose one of the three involvement levels
- AND waits for the answer before preparing requirements or system

### Scenario: Ask for each new change

- GIVEN an involvement preference was supplied earlier
- WHEN proposal review for a new change finishes
- THEN the agent still asks for the user's involvement choice for that change

### Scenario: Full involvement

- WHEN the user chooses full involvement
- THEN requirements, each item's design and its implemented code receive user review
- AND each presented result has passed independent agent review and corrections first

### Scenario: Delegate code only

- WHEN the user delegates code only
- THEN the user reviews agent-reviewed requirements and item designs
- AND agents implement, review and accept code autonomously within the agreed design

### Scenario: Full delegation

- WHEN the user chooses full delegation after proposal review
- THEN agents prepare and review requirements, architecture and code autonomously
- AND the user receives a change ready for closure

### Scenario: Arbiters participate in every mode

- WHEN a work item proceeds in any involvement mode
- THEN an independent design arbiter reviews its design before implementation
- AND a separate code arbiter reviews its implementation
