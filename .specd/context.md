# Project Context

This repository uses SpecD as agent-assisted SDD tooling. The human-readable
SDD process rules live beside SpecD-owned artifacts in the indexed process
section.

## Process Model

- The repository SDD process document lives at `specs/000-sdd-process/rules.md`.
- The Russian process translation lives at `specs/000-sdd-process/rules.ru.md`.
- Current SDD requirements, acceptance scenarios, system contracts,
  validation design, and ADRs live in indexed SpecD specs under `specs/`.
- Temporary manual planning material may remain outside `specs/`, but
  requirements, system contracts, and ADR decisions are owned by SpecD
  artifacts.
- The active SpecD schema is the local SDD schema at `schemas/sdd/schema.yaml`.
- The active SpecD artifact flow is `proposal -> requirements -> system -> validate -> plan`.
- `requirements.md` owns needs, obligations, rationale, satisfaction
  conditions, and mandatory acceptance scenarios.
- Acceptance scenarios use requirement-level concepts and belong inside the
  owning requirement.
- `system.md` owns current contracts, concepts, interfaces, invariants, and constraints.
- `validate.md` owns technical validation design, checks, commands,
  inspections, and evidence for system conformance.
- `adrs.md` owns optional durable architecture decision records for significant
  spec decisions.
- `plan.md` owns implementation strategy, validation strategy, and top-level
  plan items for one change.
- The schema has no change-scoped Context artifact. Project context compilation,
  this `.specd/context.md`, and `.specd-exploration.md` discovery memory remain
  available for orientation outside the artifact flow.

## Artifact Boundaries

- Proposal owns motivation, direction, scope, and relevant technical context.
  Attach affected specs even when existing needs stay unchanged; use a `no-op`
  requirements delta rather than inventing a new need for every design fix.
- Requirements describe independent needs and own acceptance scenarios. Patch
  constraints, defect descriptions, and proposed fixes stay with their owners.
- System explains how components, relationships, interactions, and mechanisms
  realize requirements and where contracts are defined. Each architecture point
  links to its owning requirement at the section, definition, or list item.
  A section-level link covers one coherent point, not independent points.
- Validate gives each check a Covers owner link, concrete Method, and expected
  Evidence. Notes contain only setup, prerequisites, or execution limits.
  Coverage overviews list references only; omit purpose and motivation prose.
- Use resolvable Markdown links to owning requirement or system headings;
  cross-spec links include the owning spec's relative path. Do not copy owners.
- Plan owns the implementation transition; ADRs own significant choices and
  rationale. Keep current needs and mechanisms in requirements and system.

## Agent Rules

- In Codex, invoke SpecD skills with `$specd-*`, not `/specd-*`.
- Treat CLI `next action` as lifecycle guidance, but translate any slash skill name
  to the equivalent dollar skill name when working in Codex.
- Read specs through the SpecD CLI instead of guessing files under `specs/`.
- Prefer local schema instructions and artifact instructions over assumptions from
  the upstream standard schema.
- Do not commit changes unless the user explicitly asks.

## Approved Plan During Implementation

- Change the approved plan only by marking completed work from `[ ]` to `[x]`.
  Add no prose, steps, execution reports, or embellishments. Neither ask
  permission nor proactively propose to append to the plan. Keep temporary
  tracking and chat progress outside it; verification and archive respect this.
- Surface an actual design error and wait for explicit user permission before
  returning to designing to correct the earliest affected artifact. Routine
  implementation choices do not trigger design revisions.
- Checkbox normalization preserves the approved plan hash for progress marks;
  other edits cause drift. This is not a filesystem write restriction.

## Review Before Structural Validation

- Before human review, reread drafts and merged deltas against their ownership
  and any agreed intent allocation. Apply the artifact-specific self-review
  questions delivered in post-rules after composition checks and before review.
  Find and correct specific misplaced or unsupported passages; a generic
  compliance assertion is insufficient. Surface needed upstream changes rather
  than silently editing approved content. Revised content follows human review.
  Add no report, artifact section, or confirmation step; keep routine
  self-assessment out of artifacts and mention material corrections in chat.

- Present every authored artifact's current content and stop before
  `specd changes validate`, including optional ADRs, deltas, and no-op decisions.
  Review merged deltas or the unchanged base for a no-op.
- Explicit approval applies to current content. Revision requests, generation
  mode selection, and intent allocation alone do not approve later drafts.
- If validation repairs change content, including upstream content, present
  their diff and obtain approval before revalidation. Never silently edit or
  validate unapproved upstream artifacts to fix dependency state. Reuse approval
  while reviewed content stays unchanged, including state-only repairs.
- Schema post-rules deliver this after composition checks; designing hook
  guidance applies it to repairs. This adds no CLI approval state or document.
  Tests and technical inspections are distinct from content approval.

## Useful Repository References

- `specs/000-sdd-process/rules.md` describes the repository's SDD process.
- `specs/001-project-architecture/inventory.md` and
  `specs/001-project-architecture/todo.md` are temporary non-normative
  migration aids for humans and agents, not SpecD schema artifacts.
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
