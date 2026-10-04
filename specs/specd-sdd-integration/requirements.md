# Requirements

## Requirement: Existing SDD process remains authoritative

The repository must continue to treat `spec/sdd-process.md` as the normative
definition of the SDD process unless a future accepted process change says
otherwise.

SpecD artifacts may restate, index, or operationalize SDD content for agent
workflow purposes, but they must not silently redefine the responsibilities of
Requirements, System Specification, Plans, Implementation, Verification,
Context, or ADRs.

## Requirement: SpecD provides machine-readable workflow state

The repository must provide a SpecD project configuration that allows agents to
discover project state, steady-state specs, active changes, lifecycle blockers,
and next artifact instructions through the SpecD CLI.

## Requirement: SpecD specs may mirror current SDD contracts

SpecD steady-state specs may mirror existing SDD requirements and system
specification contracts when doing so improves context delivery or validation.

When mirrored content conflicts with normative SDD artifacts, the normative SDD
artifact owns the correction and the SpecD mirror must be updated or removed.

## Requirement: Changes that modify behavior pass through SpecD artifacts

Future repository changes that modify expected behavior should be represented as
SpecD changes with requirements, system, verification, and plan artifacts before
implementation proceeds.

The plan artifact must contain the implementation strategy, validation strategy,
and top-level plan items needed to execute the transition. Top-level plan items
are the task-bearing units for implementation; there is no separate steady
process artifact for tasks.

If an existing steady-state SpecD spec already covers the behavior, the change
should attach that spec and use deltas or no-op deltas as appropriate. If no
SpecD spec covers the behavior, the change should introduce one.

## Requirement: Requirement validation may use scenario-style checks

SpecD verification artifacts may use scenario-style checks to describe how a
requirement is validated. This does not by itself replace the acceptance
criteria model in the normative SDD process.
