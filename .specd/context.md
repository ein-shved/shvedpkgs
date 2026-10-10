# Project Context

This repository uses SpecD as agent-assisted SDD tooling. The human-readable
SDD process rules live beside SpecD-owned artifacts in the indexed process
section.

## Process Model

- The repository SDD process document lives at `specs/000-sdd-process/rules.md`.
- The Russian process translation lives at `specs/000-sdd-process/rules.ru.md`.
- Current SDD requirements, system contracts, verification scenarios, optional
  inventory, and ADRs live in indexed SpecD specs under `specs/`.
- Historical legacy planning material may remain under `spec/`, but
  requirements, system contracts, and ADR decisions are owned by SpecD
  artifacts.
- The active SpecD schema is the local SDD schema at `schemas/sdd/schema.yaml`.
- The active SpecD artifact flow is `proposal -> requirements -> system -> verify -> plan`.
- `requirements.md` owns needs, obligations, rationale, and satisfaction conditions.
- `system.md` owns current contracts, concepts, interfaces, invariants, and constraints.
- `verify.md` owns concrete scenarios used to check requirements and system contracts.
- `inventory.md` owns optional non-normative orientation and must be refreshed,
  migrated, or removed when work makes it materially stale.
- `adrs.md` owns optional durable architecture decision records for significant
  spec decisions.
- `plan.md` owns implementation strategy, validation strategy, and top-level
  plan items for one change.
- `context.md` is an optional change-scoped artifact.

## Agent Rules

- In Codex, invoke SpecD skills with `$specd-*`, not `/specd-*`.
- Treat CLI `next action` as lifecycle guidance, but translate any slash skill name
  to the equivalent dollar skill name when working in Codex.
- Read specs through the SpecD CLI instead of guessing files under `specs/`.
- Prefer local schema instructions and artifact instructions over assumptions from
  the upstream standard schema.
- Do not commit changes unless the user explicitly asks.

## Useful Repository References

- `spec/agent.md` gives repository-level orientation for agents.
- `specs/000-sdd-process/rules.md` describes the repository's SDD process.
- `specs/000-sdd-process/` describes SpecD integration and process-facing
  contracts.
- `specs/001-project-architecture/` describes repository layer boundaries,
  primary-user semantics, package-source handling, and document-order ADRs.
- `specs/002-host-classification/` describes host role flags, package buckets,
  derived package-set flags, and migrated host-classification ADRs.
- `specs/003-testing-infrastructure/` describes validation-only configurations
  and test-only private-value stubs.
- `specs/004-generic-host-tooling/` describes configured generic host tools such
  as the user-facing `rg` wrapper.
- `specs/005-development-host-tooling/` describes development-host workflow
  tooling such as `codex` and `specd`.
