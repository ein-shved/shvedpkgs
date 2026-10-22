# Plan: tighten-sdd-artifact-boundaries

## Goal

Align the local SpecD schema and process guidance with the approved
[system design](deltas/default/000-sdd-process/system.md.delta.yaml), keeping
requirements unchanged. Complete the eight checks in the
[validation design](deltas/default/000-sdd-process/validate.md.delta.yaml)
before marking implementation complete.

## Assumptions

- The `default` workspace owns the repository code root. Product changes stay
  inside that root; disposable probe projects live under `/tmp` as agreed.
- Ordered `rules.pre` and `rules.post` reach the existing skills through
  `changes artifact-instruction`. No skill or SpecD CLI changes are needed.
- The schema package already copies `schemas/sdd/`; bootstrap built from this
  checkout therefore installs the updated schema and templates.

## Constraints

- Preserve useful existing guidance. Add boundary clarification and workflow
  rules; correct conflicting text and remove the separate Context artifact.
- Keep the requirements delta `no-op`. Patch mechanics do not become needs.
- During implementation, change this plan only by marking completed checkboxes.
  Store execution evidence outside the plan. Surface actual design errors and
  obtain user permission before returning to design.
- Keep prose wrapped near 80 columns, allowing indivisible links to exceed it.
- Make process changes in English and translate the full result into Russian.

## Current Implementation Observations

- The schema still defines optional change Context and its template.
- The requirements instruction already distinguishes needs from implementation,
  but proposal template wording assumes modified specs change requirements.
- Review and boundary self-checks are not yet delivered as composition rules.
- Plan checkbox normalization already exists and should be retained.
- Graph impact for the ten paths below reports LOW risk with no symbols or
  dependents. The index has zero code files, so this does not establish complete
  impact coverage. Source inspection confirms bootstrap consumes this schema
  tree and skills consume its instructions.

## Implementation Approach

Execute the six items below in order. Each item includes its matching schema,
template, English/Russian process text, and project-guidance changes, keeping
the implemented subset aligned before it is marked complete. Retain existing
validation fields, the plan task model, context compilation, and discovery
memory.

Once an item's schema and template edits are stable, bootstrap its probes from
that checkout. Independent documentation work may continue while probes run.
If the tested payload changes, rerun affected probes against the new payload.

## Minimal Change Set

- `schemas/sdd/schema.yaml`
- `schemas/sdd/templates/proposal.md`
- `schemas/sdd/templates/requirements.md`
- `schemas/sdd/templates/system.md`
- `schemas/sdd/templates/validate.md`
- `schemas/sdd/templates/plan.md`
- `schemas/sdd/templates/context.md` — delete
- `.specd/context.md`
- `specs/000-sdd-process/rules.md`
- `specs/000-sdd-process/rules.ru.md`

Read spec content through the SpecD CLI. The existing requirements, system,
and validation deltas supply the normative changes for archive; do not
manually replace steady-state schema artifacts during implementation.

## Validation Plan

Use the named checks from the validation delta, rendered with:

```sh
specd changes spec-preview tighten-sdd-artifact-boundaries \
  default:000-sdd-process --artifact validate --format text
```

- Run schema/project discovery and inspect delivered instructions for all six
  artifact IDs, including rule ordering and lifecycle hook guidance.
- Exercise intent, self-review, and content approval with fresh sub-agents.
  Follow the bootstrap setup in the validation design: each probe has its own
  Git root, configuration, specs, changes, and locks. Set explicit fixture
  working directories and `--config` paths. Give sub-agents only fixture
  context and staged user messages; keep expected answers in the controller.
- Record CLI calls through the fixture-local wrapper, replies, and file
  snapshots at each stop. Simulated approvals apply only to test content.
  Check actual outcomes against the validation design before reporting pass.
- Exercise checkbox/hash preservation and prose drift in a disposable plan.
- Audit artifact boundaries, owner links, and English/Russian/project guidance.
  Record results and evidence locations in scratch output and the final report,
  without appending execution notes to this plan.
- Check `git diff --check`. Inspect the product diff for the ten-path scope;
  confirm skills and package definitions are unchanged. Compare bootstrapped
  schema/template contents with the source tree under test.

Each item checks the contracts it introduces and preserves. Do not report a
whole validation-design check as passed when only its item-specific subset was
exercised. Before the final item closes, account for all eight checks against
the final payload. Reuse earlier evidence only where the tested contracts and
fixture conditions remain applicable; rerun affected checks after changes.

Preservation checks for unchanged requirements:

- `REQ-001` and `REQ-003`: English rules remain authoritative, linked from
  contribution guidance, and aligned with schema and Russian text.
- `REQ-002` and `REQ-006`: project/change inspection and the required artifact
  flow remain usable; plan remains the only task-bearing artifact.
- `REQ-004`: keep capability directory identifiers and numeric section ordering;
  confirm the merged system retains its Ordered SpecD SDD Sections contract.
- `REQ-005` and `REQ-007`: current system truth stays with its normative owner;
  acceptance scenarios remain in requirements and technical checks in validate.

## Top-Level Plan Items

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

## Out Of Scope

- Local and reusable agent skill edits, SpecD CLI changes, and new CLI approval
  state or approval documents.
- Bootstrap delivery contracts, package definitions, and section 005 changes.
- Repository-wide spec retrofits, host configuration changes, commits, or
  additional permanent test infrastructure.
