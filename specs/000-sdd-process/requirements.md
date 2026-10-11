# Requirements

## REQ-001: Existing SDD process remains authoritative

The repository must continue to treat `specs/000-sdd-process/rules.md` as
the normative definition of the SDD process unless a future accepted process
change says otherwise.

SpecD artifacts may restate, index, or operationalize SDD content for agent
workflow purposes, but they must not silently redefine the responsibilities
of Requirements, System Specification, Plans, Implementation, Verification,
Context, or `adrs.md`.


### Scenario: TBD

- THEN TBD: define acceptance scenarios for this requirement during requirements migration.

## REQ-002: SpecD provides machine-readable workflow state

The repository must provide a SpecD project configuration that allows agents
to discover project state, steady-state specs, active changes, lifecycle
blockers, and next artifact instructions through the SpecD CLI.


### Scenario: TBD

- THEN TBD: define acceptance scenarios for this requirement during requirements migration.

## REQ-003: SpecD specs may mirror current SDD contracts

SpecD steady-state specs may mirror existing SDD requirements and system
specification contracts when doing so improves context delivery or validation.

When mirrored content conflicts with the normative SDD process or a more
specific owning SpecD artifact, the owning artifact must be corrected and
dependent mirrors must be updated or removed.

Manual project notes may stop being active guidance only after their durable
requirements, system contracts, ADR decisions, and verification expectations
are represented in the owning SDD artifacts or explicitly treated as
non-normative orientation.


### Scenario: TBD

- THEN TBD: define acceptance scenarios for this requirement during requirements migration.

## REQ-004: SpecD-owned SDD fragments reconstruct readable documents

When the SDD model is split across SpecD-owned artifacts, the repository must
retain a deterministic reconstruction order for each document kind.

Reconstructed documents must follow the same general-to-specific reading order
as the repository's SDD sections. Validation must make ordering mistakes
visible rather than hiding them behind arbitrary filesystem or glob order.


### Scenario: TBD

- THEN TBD: define acceptance scenarios for this requirement during requirements migration.

## REQ-005: Normative SDD artifacts describe the current architecture

The repository's normative SDD artifacts must fully describe the current
project architecture at the level needed for agents and humans to make changes
without relying on stale inventory, manual notes, or conversation history.

Current requirements must live in `requirements.md`, current system contracts
must live in `system.md`, verification expectations must live in `verify.md`,
and significant decisions and rationale must live in `adrs.md`.

Temporary inventory and TODO documents may exist while the project is still
migrating to the SDD process, but they must not be required to understand the
current architecture once the migration is complete.


### Scenario: TBD

- THEN TBD: define acceptance scenarios for this requirement during requirements migration.

## REQ-006: Changes that modify behavior pass through SpecD artifacts

Future repository changes that modify expected behavior should be represented
as SpecD changes with requirements, system, verification, and plan artifacts
before implementation proceeds.

The plan artifact must contain the implementation strategy, validation
strategy, and top-level plan items needed to execute the transition. Top-level
plan items are the task-bearing units for implementation; there is no separate
steady process artifact for tasks.

If an existing steady-state SpecD spec already covers the behavior, the change
should attach that spec and use deltas or no-op deltas as appropriate. If no
SpecD spec covers the behavior, the change should introduce one.


### Scenario: TBD

- THEN TBD: define acceptance scenarios for this requirement during requirements migration.

## REQ-007: Requirement validation may use scenario-style checks

SpecD verification artifacts may use scenario-style checks to describe how a
requirement is validated. This does not by itself replace the acceptance
criteria model in the normative SDD process.


### Scenario: TBD

- THEN TBD: define acceptance scenarios for this requirement during requirements migration.
