# System Specification

## Inventory Artifact

The project inventory is stored as:

```text
specs/project-inventory/inventory.md
```

It is a steady-state SpecD artifact named `inventory`, backed by the local SDD
schema.

## Inventory Role

Inventory is optional, non-normative orientation. It may describe current
repository entry points, host lists, layers, package inventories, validation
support, and other discovery findings that help agents and humans navigate the
project.

Inventory is not a source of required behavior, system guarantees, or process
rules.

## Migration Rule

When inventory contains knowledge that should remain true after a transition,
that durable knowledge must move to the owning artifact:

- requirements and obligations move to `requirements.md`;
- current system contracts, interfaces, invariants, and architecture boundaries
  move to `system.md`;
- verification expectations move to `verify.md`;
- significant decisions and rationale move to ADRs.

## Completion Check

Before a SpecD change is archived, agents must check whether the implemented
work made inventory stale when the work touched repository structure, entry
points, hosts, module boundaries, package inventory, validation support, or
other orientation material.

## Constraints

- `inventory.md` is non-normative.
- Requirements and System Specification take precedence over inventory.
- Stale inventory must not be preserved as a parallel current-system
  specification.
