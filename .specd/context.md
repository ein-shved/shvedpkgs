# Project Context

This repository's SpecD configuration selects `schemas/sdd/schema.yaml`.
Artifact meaning is defined in `specs/000-sdd-process/rules.md`; its full
Russian translation is `rules.ru.md`. Reusable skill source lives in
`pkgs/by-name/sp/specd-bootstrap-agent-*/src/skills/`, not the root project's
installed runtime skill directory. Bootstrap owns delivery of those packages.

## Specification map

- `specs/000-sdd-process/` owns the SDD process.
- `001-project-architecture/` covers repository layers and document ordering.
- `002-host-classification/` covers host roles and package sets.
- `003-testing-infrastructure/` covers validation configurations.
- `004-generic-host-tooling/` and `005-development-host-tooling/` cover their
  respective host tools.
- `specs/001-project-architecture/inventory.md` and `todo.md` are temporary
  migration aids for orientation.
