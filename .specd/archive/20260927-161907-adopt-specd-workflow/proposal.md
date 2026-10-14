# Proposal: adopt-specd-workflow

## Motivation

The repository already has an SDD process, but agents must repeatedly rediscover
which artifacts matter for the current phase and which document should be edited
next. SpecD can be evaluated as a lightweight tracking and context layer around
the existing SDD model.

## Current behaviour

The normative process lives in `spec/sdd-process.md`, and the current artifacts
live under `spec/`. There is no `specd.yaml`, no SpecD workspace, and no SpecD
change lifecycle state for active SDD work.

## Proposed solution

Initialize SpecD for the repository and add a SpecD specification that describes
how the tool is allowed to interact with the current SDD process. Preserve the
existing SDD documents as normative source material, and use SpecD for
machine-readable specs, change artifacts, context compilation, validation, and
agent-facing workflow commands.

## Specs affected

### New specs

- `default:specd-sdd-integration`: SpecD usage as a tracking and context layer
  around the repository SDD process.
  - Depends on: none

### Modified specs

_none_

## Impact

The change adds `specd.yaml`, a `specs/` workspace, and SpecD-managed change
artifacts under `.specd/changes/`. It does not change Nix code, package
outputs, host configurations, or the normative SDD artifact dependency model.

## Technical context

The experiment should use `@specd/schema-std` first, because it is available
locally and validates the core workflow. The repository SDD model remains
authoritative; if the standard schema creates friction, that is evidence for a
future local SDD-oriented schema rather than a reason to rewrite the SDD process
around SpecD.

## Open questions

_none_
