# Agent Review Rules

Executors and independent arbiters use the same numbered rule catalogue.

Projects may extend the catalogue through applicable `AGENTS.md` files,
project context or other explicitly identified sources; executors and
arbiters receive the same combined set for the work's scope.

Review covers only the executor's changes and their effects.
Unchanged material provides context; unrelated existing issues are outside
the review's scope.

Arbiters apply every applicable rule at all relevant levels of the work,
from the whole through intermediate levels to individual elements, across
all artifacts and representations, considering their relationships and context.

Findings name the rule, affected part and location, with a brief explanation.
The original author corrects them; the same arbiter rechecks before user review.

If the executor doubts that an arbiter's finding is correct, it pauses work
and asks the user how to proceed, explaining the finding and its objection.
Work resumes after the user's decision.

## Common Rules

These rules apply to all artifacts, including code.

- **COMMON-01:** Do not change code or an artifact if the task can be
  satisfied without that change; code refactoring requires explicit
  user authorization.

- **COMMON-02:** Prefer a simpler, more obvious or smaller alternative
  for a design, code or architecture decision when it satisfies the
  same requirements and contracts without reducing clarity.

- **COMMON-03:** Do not add needs, guarantees or prohibitions unsupported by
  the user's request or the applicable contracts.

- **COMMON-04:** Do not repeat a shared definition or contract at each use;
  define it once and reference its owner.

- **COMMON-05:** Do not pack separate topics into a dense paragraph;
  separate them with headings, lists or focused paragraphs.

- **COMMON-06:** Do not exceed three source lines per prose paragraph or
  80 characters per prose line, including prose inside list items.

- **COMMON-07:** Exempt code blocks, standalone public signatures and
  indivisible path/URL spans from COMMON-06, but not surrounding prose.

- **COMMON-08:** Do not exceed 80 characters in any table row; use a list
  instead of compressing meaning or inserting cell line breaks.

- **COMMON-09:** In Markdown artifacts, separate sibling list items with
  blank lines when any item in that list spans multiple source lines.

## Requirements Rules

- **REQ-01:** Do not replace an independent need with its current internal
  mechanism; name a concrete technology only when the need or external
  contract requires it.
- **REQ-02:** Do not turn patch steps, defect descriptions, internal file
  choices or migration history into requirements.
- **REQ-03:** Do not combine independent needs into one requirement when
  they can reasonably be stated separately.
- **REQ-04:** Do not create a separate requirement for an example, nuance
  or boundary case of an existing need; put it in that need's scenarios.
- **REQ-05:** Do not replace observable acceptance conditions with build
  commands, fixture setup or wiring unless that detail is itself part of
  the required external contract.
- **REQ-06:** Do not impose a negative constraint without describing its
  observable violation and satisfaction conditions in acceptance scenarios.

## System Rules

- **SYS-01:** Do not repeat a need in place of architecture; describe the
  entity's external interface and the roles, relationships and material
  dependencies that realize its requirements.
- **SYS-02:** Do not narrate helper recipes, familiar language idioms or
  routine algorithms that add no material system contract; file-by-file
  implementation instructions belong in code.
- **SYS-03:** Do not present absent entities, rejected alternatives or
  author/reviewer discussion history as the current system contract.
- **SYS-04:** Do not leave a material design choice unresolved in a
  completed item; unfinished later items may remain pending.
- **SYS-05:** Do not put one instance's policy or selected values into a
  reusable framework contract; concrete delivery values belong in the
  contract of the instance being specified.
- **SYS-06:** Do not promote ordinary tests or usage documentation into
  architecture points or system sections; special-check descriptions
  require an explicit user request.
- **SYS-07:** Do not leave an independent architecture point without a
  link to its owning requirement's actual heading.
- **SYS-08:** Do not create, amend or supersede an ADR without an explicit
  user request; the current design remains in system.

## Code Rules

These rules apply to source, configuration, tests and executable guidance.

- **CODE-01:** Do not silently change a requirement or design to justify
  incorrect implementation; correct the earliest defective owner and
  align the affected dependents.
- **CODE-02:** Do not present a nonconforming stub, mock or substitute as
  the required capability; explicitly identified test doubles and
  alternatives permitted by the contract remain valid.
- **CODE-03:** Do not duplicate a shared mechanism when the existing
  implementation can serve the same contract.
- **CODE-04:** Do not embed a concrete host's or deployment's policy in a
  reusable mechanism; select instance values at the instance boundary.
- **CODE-05:** Do not ignore the language's and project's conventions in
  changed code or introduce an exception without a concrete need.
- **CODE-06:** Do not claim runtime or agent behavior was verified using
  only source-text matches or tests that merely repeat implementation steps.
- **CODE-07:** Do not link permanent code documentation to change-local
  artifacts or nonexistent headings; reference durable specification owners.
- **CODE-08:** With an agreed plan, implement only the current item's scope.
  Arbiters map changed functionality to plan items and reject violations.
  Authors remove other items' functionality until those items are reached.
