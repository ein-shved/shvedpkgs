# Verification: Project Inventory

## Requirements

### Requirement: Project inventory remains non-normative orientation

#### Scenario: Inventory does not define normative behavior

- GIVEN `specs/project-inventory/inventory.md` describes repository orientation
- WHEN the inventory is read alongside requirements and system specifications
- THEN inventory is treated as non-normative orientation
- AND requirements and system specifications take precedence for durable system truth

### Requirement: Durable knowledge migrates to owning artifacts

#### Scenario: Stable inventory knowledge is promoted

- GIVEN inventory material describes knowledge that should remain true after a transition
- WHEN that knowledge becomes stable enough to guide future work
- THEN the knowledge is moved to the owning requirements, system, verification, or ADR artifact
- AND inventory is not the only place where durable system truth is preserved

### Requirement: Inventory freshness is checked during completed work

#### Scenario: Work that changes orientation checks inventory

- GIVEN a change modifies repository structure, entry points, hosts, module responsibilities, package inventory, or validation support
- WHEN the change is completed through SpecD
- THEN the agent checks whether `specs/project-inventory/inventory.md` became materially stale
- AND stale inventory is refreshed, migrated to the owning artifact, or removed before archive
