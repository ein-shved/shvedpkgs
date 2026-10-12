# Requirements

## REQ-001: Existing SDD process remains authoritative

The repository must continue to treat `specs/000-sdd-process/rules.md` as
the normative definition of the SDD process unless a future accepted process
change says otherwise.

SpecD artifacts may restate, index, or operationalize SDD content for agent
workflow purposes, but they must not silently redefine the responsibilities
of Requirements, System Specification, Plans, Implementation, Verification,
Context, or `adrs.md`.

### Scenario: Process rules govern SDD meaning

- WHEN an agent or human interprets the repository SDD process
- THEN `specs/000-sdd-process/rules.md` provides the normative process meaning
- AND SpecD artifacts may only restate or operationalize that meaning without silently changing it

### Scenario: Process changes are explicit

- WHEN the repository needs to change the responsibilities of an SDD artifact type
- THEN the change is represented as an accepted process change
- AND dependent SpecD artifacts are updated to match the new process meaning

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

A developer working on the repository must have access to a complete
human-readable SDD process description and must be able to find it easily
from the repository's SDD materials.

The process description must explain artifact responsibilities, dependency
direction, lifecycle expectations, artifact boundaries, and examples needed
for humans and agents to apply the schema consistently.

When the schema changes, the human-readable process description must be
updated so it does not preserve obsolete artifact formats, terminology, or
workflow rules.

### Scenario: Developer finds the current process description

- WHEN a developer needs to understand the repository's SDD process
- THEN the developer can find the human-readable process description from the repository's SDD materials
- AND the description explains the current SpecD schema artifact responsibilities, dependency direction, lifecycle expectations, artifact boundaries, and useful examples

### Scenario: Process description is updated with schema changes

- WHEN a change modifies the SpecD schema, accepted artifact format, artifact terminology, or lifecycle workflow
- THEN the human-readable SDD process description is updated as part of that change
- AND obsolete process text is removed or rewritten so the description matches the current schema

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

The repository's normative SDD artifacts must fully describe the current
project architecture at the level needed for agents and humans to make changes
without relying on stale inventory, manual notes, or conversation history.

Current requirements must live in `requirements.md`, current system contracts
must live in `system.md`, validation expectations must live in `validate.md`,
and significant decisions and rationale must live in `adrs.md`.

Temporary inventory and TODO documents may exist while the project is still
migrating to the SDD process, but they must not be required to understand the
current architecture once the migration is complete.

### Scenario: Current architecture is understandable from normative artifacts

- WHEN an agent or human needs to understand the current project architecture
- THEN the normative SDD artifacts describe the requirements, system contracts, validation expectations, and durable decisions needed for the work
- AND stale inventory, manual notes, or conversation history are not required to recover current architectural truth

### Scenario: Temporary notes do not become hidden authority

- WHEN temporary inventory or TODO documents remain in the repository
- THEN they may provide orientation during migration
- AND they must not override or replace the owning normative SDD artifacts

## REQ-006: Changes that modify behavior pass through SpecD artifacts

Future repository changes that modify expected behavior should be represented
as SpecD changes with requirements, system, validation, and plan artifacts
before implementation proceeds.

The plan artifact must contain the implementation strategy, validation
strategy, and top-level plan items needed to execute the transition. Top-level
plan items are the task-bearing units for implementation; there is no separate
steady process artifact for tasks.

If an existing steady-state SpecD spec already covers the behavior, the change
should attach that spec and use deltas or no-op deltas as appropriate. If no
SpecD spec covers the behavior, the change should introduce one.

### Scenario: Behavior change starts from SpecD artifacts

- WHEN a repository change modifies expected behavior
- THEN the change is represented with requirements, system, validation, and plan artifacts before implementation proceeds
- AND implementation work can trace back to the expected behavior described by those artifacts

### Scenario: Existing specs are reused when they own the behavior

- WHEN an existing steady-state SpecD spec already covers the behavior being changed
- THEN the change attaches that spec
- AND the change uses a delta or no-op delta according to whether that artifact needs to change

### Scenario: New specs are introduced for uncovered behavior

- WHEN no existing SpecD spec covers the behavior being changed
- THEN the change introduces a spec for that behavior
- AND the new spec carries the required SDD artifacts for future work

## REQ-007: Validation checks remain distinct from acceptance scenarios

Requirement-owned acceptance scenarios are the repository's requirements
acceptance format. Technical validation artifacts may reference those
scenarios and may describe checks in a scenario-like form, but they must not
redefine acceptance conditions outside the owning requirement.

### Scenario: Acceptance conditions stay in requirements

- WHEN an acceptance condition defines whether a requirement is satisfied
- THEN that condition is expressed as an acceptance scenario inside the owning requirement
- AND validation artifacts may reference it without replacing it

### Scenario: Validation describes evidence

- WHEN a validation artifact describes how requirement conformance is checked
- THEN it describes the technical evidence, check, command, inspection, or fixture used for validation
- AND it does not introduce a separate acceptance-criteria model outside requirements
