# Requirements

## REQ-001: Existing SDD process remains authoritative

The repository must continue to treat `specs/000-sdd-process/rules.md` as
the normative definition of the SDD process unless a future accepted process
change says otherwise.

SpecD artifacts may restate, index, or operationalize SDD content for agent
workflow purposes, but they must not silently redefine the responsibilities
of Requirements, System Specification, Plans, Implementation, Verification,
Context, or `adrs.md`.

## REQ-002: SpecD provides machine-readable workflow state

The repository must provide a SpecD project configuration that allows agents
to discover project state, steady-state specs, active changes, lifecycle
blockers, and next artifact instructions through the SpecD CLI.

## REQ-003: SpecD specs may mirror current SDD contracts

SpecD steady-state specs may mirror existing SDD requirements and system
specification contracts when doing so improves context delivery or validation.

When mirrored content conflicts with the normative SDD process or a more
specific owning SpecD artifact, the owning artifact must be corrected and
dependent mirrors must be updated or removed.

A legacy `spec/` source may stop being a live normative reference only after
its durable requirements, system contracts, ADR decisions, and coverage
treatment are represented in SpecD-owned artifacts or explicitly documented as
historical, stale, duplicate, or non-normative.

## REQ-004: Legacy SDD retirement is coverage-gated

Legacy SDD files under `spec/` must not be deleted merely because new SpecD
specs exist.

Before deleting a legacy requirements, system, agent, task, plan, todo, or ADR
file, the repository must be able to show whether each durable item was
migrated to an owning SpecD artifact, retained as historical material, replaced
by fresher content, or intentionally discarded as stale or duplicate.

Live project context and agent guidance must stop pointing at deleted legacy
files as normative inputs.

## REQ-005: SpecD-owned SDD fragments reconstruct readable documents

When legacy SDD documents are split across SpecD-owned artifacts, the
repository must retain a deterministic reconstruction order for each document
kind.

Reconstructed documents must follow the same general-to-specific reading order
as the legacy documents. The comparison may differ where content was already
represented by a steady-state SpecD artifact before the migration, where SpecD
artifact format changes headings, where acceptance criteria are represented as
verification scenarios, or where intentionally added SpecD-only material has no
legacy source. Validation must make ordering mistakes visible rather than
hiding them behind arbitrary filesystem or glob order.

## REQ-006: SpecD preserves inventory lifecycle

SpecD must represent repository inventory as optional, non-normative
orientation rather than as requirements or system guarantees.

Before a SpecD change is archived, agents must check whether the work made
repository inventory materially stale when the work changed repository
structure, entry points, hosts, module responsibilities, package inventory,
validation support, or other orientation material.

If inventory became stale, still-useful orientation must be refreshed, durable
knowledge must migrate to the owning artifact, or stale material must be
removed.

## REQ-007: Changes that modify behavior pass through SpecD artifacts

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

## REQ-008: Requirement validation may use scenario-style checks

SpecD verification artifacts may use scenario-style checks to describe how a
requirement is validated. This does not by itself replace the acceptance
criteria model in the normative SDD process.
