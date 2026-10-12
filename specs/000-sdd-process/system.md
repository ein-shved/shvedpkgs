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
requirements, system specification, validation, and optional ADR artifacts
managed by SpecD.

Active and archived SpecD changes under `.specd/` hold change-scoped proposal,
plan, and context artifacts. Spec-scoped `adrs.md` artifacts hold significant
architecture decisions for their owning specs.

The human-readable SDD process rules live at:

```text
specs/000-sdd-process/rules.md
```

The Russian translation of the same process rules lives at:

```text
specs/000-sdd-process/rules.ru.md
```

## SDD Process Discoverability

The repository root `CONTRIBUTING.md` file is the developer-facing entry
point for contribution and process guidance.

`CONTRIBUTING.md` must link to the authoritative English SDD process rules
at `specs/000-sdd-process/rules.md`. It may also link to the Russian
translation at `specs/000-sdd-process/rules.ru.md` for reader convenience,
while preserving the English process document as authoritative when the two
versions diverge.

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

This ordering supports readable generated views of the SDD model without
making agents depend on arbitrary filesystem or glob order.

## SDD Schema

The local SDD schema defines first-class artifacts for:

- requirements with requirement-owned acceptance scenarios
- system specification
- validation design
- implementation plan with top-level plan items
- optional context
- optional spec-scoped ADRs

## Transitional Orientation Documents

The repository is still migrating from manually maintained project knowledge to
the SDD process and its normative artifact set.

During this transition, the project keeps two non-normative documents under
`specs/001-project-architecture/`:

- [`inventory.md`](../001-project-architecture/inventory.md): temporary
  project inventory and repository map.
- [`todo.md`](../001-project-architecture/todo.md): temporary open questions,
  cleanup candidates, and SDD preparation tasks.

These documents help humans and agents navigate the transition, but they are
not SpecD schema artifacts and they do not own current requirements, current
system contracts, validation expectations, or architecture decisions.
Durable knowledge discovered in them must move to the owning `requirements.md`,
`system.md`, `validate.md`, or `adrs.md` artifact.

## Constraints

- `specs/000-sdd-process/rules.md` remains the authoritative English SDD
  process definition.
- `specs/000-sdd-process/rules.ru.md` is the Russian translation and must
  stay aligned with the English process definition.
- SpecD artifacts are allowed to provide machine-readable tracking and context
  without silently replacing the SDD process.
- Runtime/generated SpecD graph and log files are not tracked as durable
  artifacts.
- Temporary manual notes must not become parallel normative sources for current
  requirements, system contracts, validation expectations, or ADR decisions.
- Reconstructed SDD document views must follow deterministic numeric fragment
  order.
