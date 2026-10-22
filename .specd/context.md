# Project Context

This repository uses SpecD as agent-assisted SDD tooling. The tool-independent
SDD artifact content and format rules live beside SpecD integration artifacts
in the indexed process section.

## Process Model

- The tool-independent SDD artifact rules live at `specs/000-sdd-process/rules.md`.
- Their full Russian translation lives at `specs/000-sdd-process/rules.ru.md`.
- Schema and skills own authoring, review, coordination, and lifecycle
  instructions. Workflow changes update those resources; changes to artifact
  content contracts also update the artifact rules and their translation.
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
- Surface an actual design error and wait for explicit design-decision-owner permission before
  returning to designing to correct the earliest affected artifact. Routine
  implementation choices do not trigger design revisions.
- Checkbox normalization preserves the approved plan hash for progress marks;
  other edits cause drift. This is not a filesystem write restriction.

## Design Coordination and Review

- Proposal owns the compact numbered allocation. Start with decision-scope
  category/reason and selected participation, then a very short problem and
  table, with at most two sentences of explanation per item. Detailed support
  lives in change-local `.context`. Preserve item numbers and replay the full
  corrected table. Requirements reuse it without a separate intent checkpoint;
  material intent changes return to proposal review.
- Offer involved/delegated participation once before proposal authoring, reusing
  explicit prior choices. Batching alone grants no authority. The user accepts
  content in involved mode; the persistent main coordinator does so in delegated
  mode. Mode changes hand unfinished drafts to a separate executor before
  coordinator acceptance; completed scopes stay closed. Human-only CLI approvals
  remain real-user actions.
- Entry skills check resolved exact paths before glob discovery, including shared
  resources and continuation. A separate manager loads the invoked procedure and
  assigns bounded author work. Independent arbiters read sources directly and
  never edit artifacts. Use scoped contexts without inherited discussion.
- Launch fresh arbiters only for first drafts, current-content owner acceptance,
  or explicit user/coordinator requests. Sequential comments use self-review;
  reuse an arbiter within its correction cycle. Final review and actual owner
  acceptance must cover the same revision before validation/subscope closure.
- Read drafts and merged deltas against ownership and delivered post-rules.
  Correct specific misplaced passages and remove wrong accounts plus dependent
  explanations, residual contrasts, contradictions and repetition. Negative
  contracts require an independent basis. Accept sufficient concrete text;
  expansion must resolve a named ambiguity. Keep routine self-assessment and
  correction history outside artifacts. Preserve genuine negative needs.
- Present current content (merged delta or unchanged no-op base), including
  optional artifacts, to the decision owner before structural validation.
  Mode choice, batching, intent allocation and arbiter success approve no draft.
  Show changed validation/upstream repair diffs and obtain acceptance and final
  review of that revision. Reuse unchanged-content approval for state-only
  repairs; never silently edit/validate unapproved upstream content. Technical
  inspections are separate from content acceptance.
- Small design may retain one executor/manager through plan. Large design uses
  fresh groups per artifact and system scope. In involved mode strongly
  recommend a new primary session with next invocation/context pointer and stop
  without a second permission question. Record explicit batch exceptions.
  In delegated mode the coordinator launches fresh groups. Run one group at a
  time within client capacity; report unsupported isolation/session controls
  with resumable state. Compaction and role labels provide no fresh context.
- For large system design, review overview/interfaces and pending subsystem
  skeletons first, then each subsystem in a fresh group, then integration.
  Revisit affected approved interfaces and dependent scopes when contradictions
  emerge. Whole-system validation and downstream authoring wait for completion
  and review of all affected sections. Keep one system artifact.
- Continuation in `.context` records current/next scope, input/revision pointers,
  participation/owner, author identity, actual review/acceptance states, active
  decisions/questions and ordered system scopes. Stop workers before handoff.
  New groups verify live state and source freshness; notes grant no approval
  or normative authority on their own.
- Keep requirements concise with nuance in scenarios. Define shared system
  contracts once and link uses; use tables for repeated states. Validate separates
  asserted automated coverage from concrete uncovered manual/conditional duties.
  Inspect runners/assertions before reducing recipes to references. Permanent
  checks work without change history; migration checks belong in plan.

## Useful Repository References

- `specs/000-sdd-process/rules.md` defines the tool-independent SDD artifact model.
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
