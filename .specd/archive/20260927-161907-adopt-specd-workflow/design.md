# Design: adopt-specd-workflow

## Affected areas

- `specd.yaml`: new project configuration using `@specd/schema-std`.
- `specs/`: new steady-state workspace for SpecD specs.
- `.specd/changes/20260927-161907-adopt-specd-workflow/`: active change
  artifacts for the adoption experiment.
- `spec/`: existing normative SDD documents remain unchanged.

## New constructs

- SpecD default workspace:
  - workspace id: `default`
  - filesystem path: `specs/`
- SpecD storage paths:
  - active changes: `.specd/changes/`
  - drafts: `.specd/drafts/`
  - discarded changes: `.specd/discarded/`
  - archive: `.specd/archive/`
- Baseline steady-state specs:
  - `default:development-host-tooling`
  - `default:specd-sdd-integration`

## Approach

Use `specd init --schema @specd/schema-std --workspace default
--workspace-path specs/` to create the repository configuration. Keep the
standard schema for this experiment because it is available locally and already
provides proposal, spec, verification, design, task, validation, context, and
archive behavior.

Represent the project-specific SDD boundary in a SpecD spec instead of changing
the standard schema immediately. This keeps the current experiment reversible:
if the standard schema is too restrictive, a future change can introduce a local
schema that maps the repository SDD artifact roles more directly.

Create a direct baseline SpecD spec for development-host tooling so future
examples and changes, such as adding another development-only package, have a
concrete existing spec to attach to.

## Testing

- Run `specd specs list --format toon` to confirm steady-state specs are visible.
- Run `specd specs validate --format text` to confirm steady-state specs match
  the active schema.
- Run `specd changes validate adopt-specd-workflow --all` to confirm the change
  artifacts match the active schema.
- Run `specd project status --context --graph --format toon` to confirm agents
  can discover project state and lifecycle context.

## Open questions

_none_
