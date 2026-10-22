# Plan: tighten-sdd-artifact-boundaries

## Goal

Implement the draft [system](deltas/default/000-sdd-process/system.md.delta.yaml)
and [REQ-008/009](deltas/default/000-sdd-process/requirements.md.delta.yaml).
Use the named checks in the merged validation artifact as completion evidence.
Items 1–6 retain the earlier completed scope; items 7–10 implement this revision.

## Assumptions and Constraints

- The owned `default` workspace contains all implementation targets.
  Disposable behavioral fixtures use separate projects under `/tmp`.
- Existing packages recursively copy schema and skill trees. Preserve delivery
  contracts, agent manifests, invocation syntax, artifact IDs, scopes, task
  checks, numeric spec ordering, and plan checkbox hashing.
- Keep useful contracts while replacing repetitions and conflicting guidance.
  Requirements 1–7 stay unchanged; the delta adds REQ-008 and REQ-009.
- During implementation, edit this plan only to mark completed checkboxes.
  Keep execution evidence elsewhere; actual design errors require decision-owner
  permission to return to design.
- English owns process changes; translate the full updated text into Russian.

## Current Implementation and Approach

Schema already implements removal of Context, artifact boundaries, review
before structural validation, self-review, plan preservation, and the separate
intent checkpoint. It does not implement the latest feedback or group workflow.
Existing skills contain lifecycle procedures in the executor's entry files.

Proceed through pending items in order. First align schema and prose with the
compact proposal and readability contracts. Then extract lifecycle procedures
into manager-loaded resources and switch all supported entry skills to the
role workflow in one coherent item. Then implement participation selection,
coordinator authority, group lifetimes, and subsystem resumption. Each item includes aligned
English/Russian/project guidance and its own validation.

## Minimal Change Set

- `schemas/sdd/schema.yaml`; existing proposal, requirements, system, validate,
  plan, and ADR templates under `schemas/sdd/templates/`.
- `.codex/skills/` and the three packaged trees:
  `pkgs/by-name/sp/specd-bootstrap-agent-{codex,opencode,kilocode}/src/skills/`.
  Update each SpecD entry skill and `_specd-shared/shared.md`; add
  `_specd-shared/manager.md`, `_specd-shared/arbiter.md`,
  `_specd-shared/coordinator.md`, and
  `_specd-shared/workflows/<skill>.md` for extracted procedures.
- `.specd/context.md`, and process `rules.md` plus `rules.ru.md` in
  `default:000-sdd-process`, read through SpecD.
- `tests/pkgs/specd-bootstrap.nix`: assert fresh/update delivery of new
  resources for every supported agent.

The change deltas supply requirements, system, validation, and ADR content for
archive. Do not manually replace steady-state SpecD artifacts during implement.
Change-local `.context` is support/continuation data produced by the workflow,
rather than a new schema artifact.

## Validation Strategy

Read the named checks with `specd changes spec-preview
tighten-sdd-artifact-boundaries default:000-sdd-process --artifact validate
--format text`. For each item run its listed subset on the payload it changes;
before the last item closes, account for all checks against the final payload.

Use isolated probes and actual tool/session records as specified in validate.
Inspecting instructions proves delivery, not behavioral compliance. Exercise
client-specific actions on supported tooling and record unavailable probes as
unexecuted; do not mark their owning item complete. Reuse prior evidence only
when the tested inputs and contracts are unchanged.

Optional diagnostics do not gate completion. Record a clean control as
non-diagnostic rather than evidence that the added instruction is effective;
report treatment defects even when the control is clean.

Preservation checks cover existing requirements: authoritative/discoverable
English rules and aligned translation (REQ-001/003), CLI state and artifact flow
(REQ-002/006), numeric reconstruction order (REQ-004), normative ownership
(REQ-005), and requirement-owned scenarios versus technical evidence (REQ-007).
REQ-008 is exercised by role, lifetime, resumption, and subsystem probes.
REQ-009 is exercised by participation/authority and delegated-orchestration probes.

Run `git diff --check`; inspect scope and local/packaged consistency. Build
`nix build --no-link .#specd-bootstrap.tests.vm` once the delivery assertions
are updated. Before completion, compare fresh and updated installed resources
against the final source trees; rerun affected probes after payload changes.

Graph queries report LOW impact with no dependents, but the index has zero
code symbols. Source inspection establishes the real coupling: packages copy
these trees and skills consume schema instructions. No claim of complete
code-graph coverage follows from LOW.

## Completed Plan Items

The following items retain their earlier completion record and original scope.
Their former intent-checkpoint and routine human-review wording is superseded
by pending items 7–9 as applicable.

- [x] 1. Remove the separate change Context artifact.
  Scope: schema definition, proposal references, Context template, and matching
  English/Russian/project guidance.
  Approach: remove the artifact and template while retaining project context
  compilation and discovery memory.
  Completion: schema validation and project inspection succeed; the six
  remaining artifacts and their templates are discoverable; bootstrap installs
  that artifact set; no guidance instructs agents to author change Context.

- [x] 2. Clarify artifact boundaries and traceability.
  Scope: schema authoring instructions, proposal/requirements/system/validate
  templates, and matching process/project guidance.
  Approach: clarify needs versus fixes and allow no-op requirements; describe
  architecture mechanisms, owner links, and concrete technical check fields.
  Completion: emitted instructions and templates match the approved ownership
  model; artifact/reference inspection passes for these changes; English and
  Russian descriptions agree; existing requirements remain unchanged.

- [x] 3. Preserve approved plans during implementation.
  Scope: plan instruction/template, implementing/verifying/archiving guidance,
  and matching process/project guidance.
  Approach: permit only completed checkbox marks; prohibit additions and
  requests to append; require an actual design error and user permission for
  return to design. Retain checkbox hash normalization.
  Completion: hook and template inspection confirms those rules; the disposable
  plan check preserves the validated hash for checkbox progress and detects
  prose drift; documentation agrees with the implemented restrictions.

- [x] 4. Require human review before structural validation.
  Scope: all artifact post-rules, designing repair guidance, and matching
  process/project guidance.
  Approach: put current-content review after composition checks; cover optional
  artifacts, no-op decisions, revisions, and upstream repairs. Reuse approval
  while reviewed content is unchanged.
  Completion: instruction delivery and the content-approval sub-agent probe
  confirm command ordering, revision/diff review, and repair handling; updated
  English/Russian/project guidance describes the same boundary.

- [x] 5. Add artifact-specific boundary self-review.
  Scope: all artifact post-rules and matching process/project guidance.
  Approach: insert boundary self-review after existing composition checks and
  before human review, using the approved per-artifact questions. Keep routine
  self-assessment prose outside artifacts.
  Completion: emitted rules have the intended order; fresh sub-agent probes
  correct the misplaced requirements/system/validate fragments and retain owner
  references; documentation matches the implemented self-review.

- [x] 6. Review a minimal intent before drafting requirements.
  Scope: requirements pre-rule and matching process/project guidance.
  Approach: show only short topic-to-artifact lines, redisplay the full corrected
  list after feedback, and wait for agreement. Reuse an already agreed intent;
  approval of intent alone does not approve later artifact content.
  Completion: the intent sub-agent probe passes, including correction replay
  and absence of premature drafts. All eight validation-design checks and the
  preservation/diff checks above pass for the final payload with recorded
  evidence. Keep this item open for failed or unexecuted required checks.

## Top-Level Plan Items

- [x] 7. Integrate compact proposal and artifact readability.
  Scope: schema instructions/rules, the six templates, and process/project
  guidance. Move allocation into proposal; add decision-scope classification,
  participation mode, numbered correction replay, and change-local support
  context. Apply concise
  requirements, legitimate-negative-need handling, concrete sufficient system
  text, replacement of errors without counterclaims or correction history,
  automated/manual separation, and preservation of uncovered manual duties.
  Completion: schema/lifecycle, proposal/intent, sufficiency/coverage, approval
  repair, and plan-integrity checks pass for the affected subset. The artifact
  graph is unchanged; no additional intent checkpoint remains.

- [x] 8. Establish manager and independent arbiter coordination.
  Scope: local and all three packaged skill trees, role/procedure resources,
  bootstrap test assertions, and aligned process/project guidance.
  Approach: extract current per-skill lifecycle procedures without dropping
  ownership, scope, hooks, review/approval, or graph/context guards; make entry
  skills start/resume a manager and execute its bounded assignments. Install
  the exact-path-first rule before any shared-notes lookup. Keep independent
  review assignments concise and artifact-specific; replace the mandatory
  generation-mode question with proposal-time participation selection.
  Apply the three arbiter triggers from system: first draft, decision-owner
  acceptance, and explicit request. Keep sequential owner edits with the
  executor until a trigger occurs; final review and approval cover one revision.
  Completion: shipped-resource, role/review, exact-source, and aligned-guidance
  checks pass. The same fixture lifecycle behavior remains available for every
  supported agent; client-specific limitations are recorded, not hidden.

- [x] 9. Implement participation, group lifetimes, and staged system design.
  Scope: manager/design workflow, system instruction/template, handoff support,
  client-specific entry guidance, and matching process/project text.
  Approach: offer involved/delegated design once during proposal. In involved
  mode, keep user content acceptance and fresh-primary-session recommendations;
  in delegated mode, make the main session a coordinator that accepts design
  revisions and launches scoped author groups. Select participation before
  proposal authoring; when entering delegated mode later, hand off the current
  unfinished scope and draft to a separate executor before acceptance.
  Apply the actual complexity
  category to group lifetimes and staged system design. Track participation,
  decision owner, overview/subsystem scopes, revisions, and integration in
  change-local context while keeping one system artifact.
  Completion: participation/authority, delegated-orchestration, lifetime/resumption,
  and subsystem/integration probes pass. Cover human-only CLI gates, independent
  role contexts, client capacity, stale notes, explicit batching, changed approved
  interfaces, and no premature complete-system validation.

- [x] 10. Reconcile final guidance and verify the complete delivered workflow.
  Scope: all touched schema, skill, template, and process resources.
  Approach: resolve remaining inconsistencies within the approved design and
  perform final preservation and delivery checks.
  Completion: every automated/manual validation entry has recorded evidence
  against the final payload; translation, links, ownership, and scope checks
  pass. No failed or unavailable required probe is reported as passed.
  Routine results stay outside this plan.

## Out Of Scope

SpecD CLI or approval-state changes, a mandatory session controller, bootstrap
package/manifest redesign, section 005 changes, unrelated host/spec retrofits,
metadata summaries, and resuming deferred `conditional-module-activation`.
Commits require a separate explicit user request.
