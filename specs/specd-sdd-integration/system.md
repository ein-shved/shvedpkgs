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

## Codex Skills

Project-local Codex skills are installed under:

```text
.codex/skills/
```

In this Codex environment skills are invoked with `$skill-name` syntax, for
example `$specd-new`, not slash-command syntax.

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

- `specs/sdd-process.md` remains the normative SDD process definition.
- SpecD artifacts are allowed to provide machine-readable tracking and context
  without silently replacing the SDD process.
- `specs/project-inventory/inventory.md` is optional non-normative orientation
  and must not become a parallel current-system specification.
- Runtime/generated SpecD graph and log files are not tracked as durable
  artifacts.
