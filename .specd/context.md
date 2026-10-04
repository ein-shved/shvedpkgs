# Project Context

This repository uses SpecD as agent-assisted SDD tooling, not as the source of
truth for the whole SDD process.

## Process Model

- The repository SDD source material remains under `spec/`.
- SpecD operational specs live under `specs/`.
- The active SpecD schema is the local SDD schema at `schemas/sdd/schema.yaml`.
- The active SpecD artifact flow is `proposal -> requirements -> system -> verify -> plan`.
- `requirements.md` owns needs, obligations, rationale, and satisfaction conditions.
- `system.md` owns current contracts, concepts, interfaces, invariants, and constraints.
- `verify.md` owns concrete scenarios used to check requirements and system contracts.
- `inventory.md` owns optional non-normative orientation and must be refreshed,
  migrated, or removed when work makes it materially stale.
- `plan.md` owns implementation strategy, validation strategy, and top-level
  plan items for one change.
- `context.md` and `adr.md` are optional change-scoped artifacts.

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
- `spec/sdd-process.md` describes the repository's SDD process.
- `spec/requirements.md` captures broader process requirements.
- `specs/project-inventory/inventory.md` captures optional non-normative
  project inventory and orientation.
- `specs/specd-sdd-integration/` describes the SpecD integration.
- `specs/development-host-tooling/` describes development-host workflow tooling.
