# Architecture Decision Records: Project Architecture

## ADR-0001: Preserve Document Order In SpecD Fragments

Status: Accepted.

### Context

The migrated SDD content is split across SpecD capability artifacts, but the
legacy documents were readable in a deliberate order from general to specific.
The migration must not make it impossible to reconstruct human-readable
document views.

### Decision

SpecD-owned SDD fragments must preserve enough ordering information for humans
to reconstruct readable SDD documents from general to specific.

Process-level SDD material uses the `000-` prefix. Migrated legacy
requirements and system sections use `001-` and later prefixes in the order
they should appear in reconstructed documents. New SpecD-only sections may use
later positions where they naturally belong and should appear as additions
when compared to legacy sources.

Validation and review present reconstructed document views using deterministic
numeric order, not incidental filesystem order.

### Rationale

Capability-oriented SpecD artifacts improve agent navigation, but humans still
need a coherent document reading order. Numeric ordering keeps the source
layout flat while making generated or reconstructed human documents
deterministic.

### Consequences

The ordered-fragment decision adds migration discipline: implementers must
choose paths or section identities that sort deterministically and must not
accept validation output dominated by reorder noise.

The steady-state normative contracts for this decision live in
`default:001-project-architecture`.
