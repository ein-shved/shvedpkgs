# Requirements

## Requirement: Project inventory remains non-normative orientation

The project inventory must remain a non-normative orientation aid for current
repository structure, entry points, host inventory, module layers, package
inventory, validation support, and other discovery material.

The inventory must not define required behavior, system guarantees, or process
rules. When inventory content conflicts with Requirements, System
Specification, ADRs, or the SDD process, the normative artifact owns the
correction.

## Requirement: Durable knowledge migrates to owning artifacts

When inventory material becomes stable system knowledge, it must be migrated to
the artifact that owns that knowledge rather than preserved only in inventory.

Stable needs belong in Requirements. Stable system contracts, architecture
boundaries, interfaces, invariants, and current implementation guarantees
belong in System Specification. Significant decisions and rationale belong in
ADRs.

## Requirement: Inventory freshness is checked during completed work

When a change modifies repository structure, entry points, host inventory,
module responsibilities, package inventory, validation support, or other
orientation material, the agent must check whether inventory became materially
stale before completing the change.

If inventory became stale, the still-useful orientation must be refreshed,
durable knowledge must be migrated to the owning artifact, or stale material
must be removed.
