# System Specification

## SpecD Project Configuration

The repository contains a SpecD project configuration at:

```text
specd.yaml
```

The configuration points to a local SDD schema:

```text
./schemas/sdd/schema.yaml
```

The default workspace stores steady-state SpecD specs under:

```text
specs/
```

## SpecD Change Storage

Active and historical change state is stored under `.specd/`:

- active changes: `.specd/changes/`
- drafts: `.specd/drafts/`
- discarded changes: `.specd/discarded/`
- archive: `.specd/archive/`

## SpecD-Owned SDD Locations

Steady-state SpecD specs under `specs/` are the machine-readable location for
requirements, system specification, verification, and optional inventory
artifacts managed by SpecD.

Active and archived SpecD changes under `.specd/` hold change-scoped proposal,
plan, and context artifacts. Spec-scoped `adrs.md` artifacts hold significant
architecture decisions for their owning specs.

## Ordered SpecD SDD Sections

SpecD-owned SDD content is split by capability directories under `specs/`.
Capability directories that participate in SDD document ordering use stable
three-digit numeric prefixes in their directory names.

The numeric prefix is part of the section identifier and records the
human-readable order from general to specific. For example,
`000-sdd-process/` precedes project-level architecture, host classification,
testing, generic host tooling, and development-host tooling sections.

Document-shaped views such as `requirements.md` and `system.md` follow the
numeric section order when presenting split SpecD artifacts for validation or
review.

While legacy source files still exist, reconstruction comparison is allowed to
differ for content that was already represented by steady-state SpecD artifacts
before the migration, heading shape required by SpecD artifacts, acceptance
criteria represented as scenarios, and additions for SpecD-only content that
did not exist in the legacy document. It must not hide arbitrary reordering of
migrated legacy content.

## SDD Schema

The local SDD schema defines first-class artifacts for:

- requirements
- system specification
- verification scenarios
- optional inventory
- implementation plan with top-level plan items
- optional context
- optional spec-scoped ADRs

## Constraints

- `specs/000-sdd-process/rules.md` remains the normative SDD process
  definition.
- SpecD artifacts are allowed to provide machine-readable tracking and context
  without silently replacing the SDD process.
- Inventory under `specs/000-sdd-process/` is optional non-normative
  orientation and must not become a parallel current-system specification.
- Runtime/generated SpecD graph and log files are not tracked as durable
  artifacts.
- Legacy `spec/` files must not be deleted until coverage is documented, specs
  validate, metadata is fresh, and live context no longer depends on those
  files as normative sources.
- Reconstructed SDD document views must follow deterministic numeric fragment
  order.
