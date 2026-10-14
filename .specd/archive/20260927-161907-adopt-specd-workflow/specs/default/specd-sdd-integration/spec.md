# SpecD SDD Integration

## Purpose

This spec defines how SpecD is used in this repository while the existing SDD
process remains authoritative. SpecD is a tracking, validation, and context
delivery layer around the SDD artifacts, not a replacement for the process
defined in `spec/sdd-process.md`.

## Spec Dependencies

_none_

## Requirements

### Requirement: Existing SDD process remains authoritative

The repository MUST continue to treat `spec/sdd-process.md` as the normative
definition of the SDD process unless a future accepted process change says
otherwise.

SpecD artifacts MAY restate, index, or operationalize SDD content for agent
workflow purposes, but they MUST NOT silently redefine the responsibilities of
Requirements, System Specification, Plans, Tasks, Implementation, Verification,
Context, or ADRs.

### Requirement: SpecD provides machine-readable workflow state

The repository MUST provide a SpecD project configuration that allows agents to
discover project state, steady-state specs, active changes, lifecycle blockers,
and next artifact instructions through the SpecD CLI.

### Requirement: SpecD specs may mirror current SDD contracts

SpecD steady-state specs MAY mirror existing SDD requirements and system
specification contracts when doing so improves context delivery or validation.

When mirrored content conflicts with normative SDD artifacts, the normative SDD
artifact owns the correction and the SpecD mirror MUST be updated or removed.

### Requirement: Changes that modify behavior pass through SpecD artifacts

Future repository changes that modify expected behavior SHOULD be represented as
SpecD changes with proposal, spec, verification, design, and task artifacts
before implementation proceeds.

If an existing steady-state SpecD spec already covers the behavior, the change
SHOULD attach that spec and use deltas or no-op deltas as appropriate. If no
SpecD spec covers the behavior, the change SHOULD introduce one.

### Requirement: Requirement validation may use scenario-style checks

SpecD verification artifacts MAY use scenario-style checks to describe how a
requirement is validated. This does not by itself replace the acceptance
criteria model in the normative SDD process.

## Constraints

- The default SpecD workspace path is `specs/`.
- Active SpecD changes are stored under `.specd/changes/`.
- SpecD adoption must not require committing private values or generated build
  outputs.
