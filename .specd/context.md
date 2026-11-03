# Project Context

This repository uses SpecD for agent-assisted SDD. The tool-independent artifact
rules live in `specs/000-sdd-process/rules.md`, with their full Russian translation
in `rules.ru.md`. Rules own artifact meaning and format; the local schema and
skills own authoring, review and lifecycle operations. Update each affected owner
when behavior changes.

## Artifacts and lifecycle

- The local `specd.yaml` selects `schemas/sdd/schema.yaml`. The flow is
  `proposal → requirements → system ↔ code`: architecture and code develop
  together and stay aligned as each item evolves. Revisit proposal and
  requirements when necessary; significant inconsistencies need the user's
  decision.
- Proposal stays short and contains numbered high-level work items, each with a
  short name and one sentence of purpose, plus explicit allocation of content to
  artifacts. Choose allocation and work items together; preserve item numbers
  through corrections.
- Requirements retain their existing format: independent needs, rationale,
  satisfaction conditions and acceptance scenarios inside each requirement.
  Attach an existing owning spec and use a no-op delta when its needs are already
  covered. Absence of a need does not create a prohibition.
- System starts with the designed entity's external interface and the same
  work-item skeleton. Each executor briefly develops its item's roles, key
  participants and dependencies before coding it. Link architecture points to
  their owning requirements; record shared contracts once. Keep familiar idioms,
  rejected alternatives and routine implementation detail out of architecture.
- Ready and implementing require validated proposal and requirements. Later
  system sections may still be partial and unvalidated while reviewed items are
  implemented. Verifying and archiving require the complete validated system and
  completed proposal tasks. Completion marks preserve proposal validation;
  substantive changes require affected artifacts to be validated again.
- Describe a special technical check briefly in system only when the user
  explicitly asks. Implementation receives appropriate tests and code review.
- Create an ADR only on explicit user request; preserve existing ADR history.
  Current needs and mechanisms remain in requirements and system. A covered small
  fix uses one work item and may leave both contracts unchanged; avoid cosmetic
  spec rewrites.

## Agent work and review

- The main session creates the change with its proposal and coordinates the
  work. Optional research agents return concise context. Independent proposal
  review and corrections precede user proposal review and resolution of comments.
- After user proposal review is resolved, always ask the user's involvement and
  wait for their answer before requirements or system authoring. Offer full
  involvement (user reviews requirements, design and code), delegate only code
  (user reviews requirements and design; agents review code), or full delegation
  after proposal (agents handle requirements, design and code).
- In every mode, each item's original executor writes the brief design, an
  independent reviewer checks it, the same executor implements it, and a different
  reviewer checks the code. Complete agent review and corrections before any
  result is presented for human review. Review questions become system text only
  when the answer is architecturally significant.
- Retain the original executor through the end of human review.
  The orchestrator forwards user questions and findings to that executor,
  who answers and corrects its work. Report an unavailable original session
  explicitly; do not silently replace its author or make the corrections in the
  orchestrator.
- Correct minor issues in earlier items autonomously and align affected design.
  Pause for the user's decision on significant contradictions. Do not commit
  unless the user requests it or an applicable project rule requires it.
- Temporary continuation may record item ownership, progress and unresolved
  questions. It does not replace current artifacts or confer approval.
- Code, docstrings and permanent documentation link only to existing durable
  documents, with existing anchors when used, that remain meaningful after
  archive. Authors and code reviewers check links as part of their work.

## Repository conventions

- Read specs and merged deltas through the SpecD CLI. Use live status, artifact
  instructions and exact output paths; follow `rulesPre`, `instruction` and
  `rulesPost` in order. Prefer the local schema over upstream schema assumptions.
- Resolve referenced exact paths before glob discovery, including shared skill
  resources and continuation notes. Check the resolved source first; search only
  when it is absent. Read source content directly rather than relying on a
  participant's paraphrase when authoring or reviewing it.
- In Codex invoke skills as `$specd-*`; translate slash-style CLI suggestions to
  that syntax. A next-action suggestion guides lifecycle progress within the
  user's authorization.
- Specs use numeric section prefixes for deterministic general-to-specific
  document order. Preserve that ordering when reconstructing documents; do not
  rely on arbitrary glob or filesystem order.
- `specs/000-sdd-process/` owns the SDD process; `001-project-architecture/`
  covers repository layers and document ordering; `002-host-classification/`
  covers host roles and package sets; `003-testing-infrastructure/` covers
  validation configurations; `004-generic-host-tooling/` and
  `005-development-host-tooling/` cover their respective host tools.
- `specs/001-project-architecture/inventory.md` and `todo.md` are temporary
  migration aids for orientation. Project context and `.specd-exploration.md`
  remain orientation sources outside the artifact flow.
