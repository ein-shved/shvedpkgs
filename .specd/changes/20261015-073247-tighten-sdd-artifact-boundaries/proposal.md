# Proposal: tighten-sdd-artifact-boundaries

## Motivation

Agents repeatedly blur SDD artifact responsibilities: architecture repeats
requirements, validation explains intent instead of specifying checks, and
implementation adds prose to an approved plan. Immediate SpecD validation
also precedes human review, making subsequent revisions invalidate dependent
artifact state. The local schema should give agents explicit boundaries and
preserve the user's control over the reviewed design.

## Current behaviour

- The schema includes an optional change-scoped `context` artifact that adds
  no distinct value to the agreed artifact flow.
- Implementation guidance tells agents to complete plan checkboxes but does
  not explicitly prohibit additions or rewrites to the approved plan.
- The design skill runs `specd changes validate` immediately after writing,
  before presenting the artifact for human review.
- System guidance emphasizes contracts and concepts without requiring an
  explanation of the mechanisms that realize requirements or explicit
  requirement references for every architecture point.
- Validation guidance separates technical evidence from acceptance scenarios
  but leaves room for abstract descriptions and motivation prose.

## Proposed solution

1. Remove the change-scoped `context` artifact, its template, and instructions
   to author it. Keep project context compilation and discovery memory.
2. Restrict implementation edits to the approved plan to marking completion
   checkboxes for completed work. Prohibit prose changes, extra steps, and
   requests or proactive proposals to append to the plan. If implementation
   reveals an actual design error, explain it and obtain the user's permission
   before returning to design.
3. Require agents to present each written or revised artifact for human
   review before invoking `specd changes validate`. Explicit user approval
   applies to the current content; choosing a generation mode does not grant
   approval. If validation requires content changes, present their diff and
   obtain renewed approval before validating the revised content. Apply the
   same boundary to upstream repairs and revalidation.
4. Clarify existing artifact boundaries while preserving their purposes.
   This should be a primarily additive patch to instructions, templates, and
   process guidance, retaining useful content rather than requiring artifacts
   to be rewritten. Make the existing ownership explicit: requirements
   describe WHAT is needed and own acceptance scenarios; system describes HOW
   components, relationships, and interactions realize those requirements;
   validation specifies concrete actions and expected results. Every
   architecture point references its owning requirement(s). Every validation
   check references a requirement or architecture point. Validation excludes
   purpose and motivation prose.

## Specs affected

### New specs

None.

### Modified specs

- `default:000-sdd-process`: update process requirements and acceptance
  scenarios, describe the schema mechanisms implementing these boundaries,
  and replace the validation placeholder with concrete checks.
  - Dependencies added: none.

### SDD artifacts affected

- `requirements.md`: artifact responsibilities, plan preservation, and human
  review before SpecD artifact validation.
- `system.md`: schema instruction placement, artifact removal, and explicit
  traceability conventions.
- `validate.md`: actions, expected results, and references covering the new
  process behaviour.
- Change-scoped `proposal.md` and `plan.md`: motivation and implementation
  transition respectively.
- The English process rules and their full Russian translation: align the
  human-readable process with the accepted changes.

## Impact

Implementation targets the local `schemas/sdd/schema.yaml`, affected templates
under `schemas/sdd/templates/`, the process rules in section 000, and
`.specd/context.md` where its binding guidance repeats obsolete artifact roles.
All targets belong to the owned `default` workspace.

Keep reusable and local skills unchanged. Section 005 and bootstrap delivery
contracts stay outside this change. Other specs are not retrofitted as part of
this work.

## Technical context

- `specd.yaml` selects the local SDD schema. Artifact instructions expose
  `rulesPre`, `instruction`, and `rulesPost` as a mandatory ordered block.
  The agreed approach is to put the review stop in schema post-rules so it
  runs before the skill reaches its validation step. This is an agent
  instruction mechanism, not a new CLI-enforced approval gate.
- The implementing pre-hook can express the plan editing restriction.
  Existing checkbox normalization already permits completion marks without
  treating them as design drift.
- Boundary clarification preserves existing artifact purposes and useful
  guidance. Add explicit rules and examples, correcting existing wording only
  where it conflicts with those boundaries.
- The schema package copies the complete local schema tree, so schema and
  template changes already reach bootstrap assets without delivery changes.
- `.specd/context.md`, `project context`, `changes context`, and
  `.specd-exploration.md` serve different roles from the removed artifact.
- English process rules own process changes; the Russian version follows
  them as a full translation.
- The fresh graph contains six specs and zero code symbols. It identifies
  the process spec but cannot establish code coupling; schema, template,
  skill, and package source inspection provides the relevant evidence.

## Open questions

None blocking this proposal. Exact instruction wording and traceability
syntax belong in the system design; concrete checks belong in validation.
