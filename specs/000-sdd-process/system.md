# System Specification

## External Interface

The process is managed through the [specd](https://getspecd.dev) utility.
Agents use the SpecD skills and schema supplied by this project's
[`specd-bootstrap`](../005-development-host-tooling/system.md#specd-bootstrap-support)
utility.

## SDD Artifacts

`proposal → requirements → system → adrs (optional)`

- **Proposal:** change intent and allocation of content among artifacts.
  Deleted after change archiving.
- **Requirements:** independent needs and acceptance scenarios.
- **System:** current interfaces and architecture.
- **ADRs:** significant decisions and their rationale; optional, created
  only at the user's direction.

### Specification order

SpecD specification directory names begin with numeric prefixes that
define a stable, general-to-specific reading order.

[Artifact rules](rules.md).

## Change Types

- **Update:** applies established project mechanisms without requiring
  new architectural decisions. The proposal allocates needed changes
  to artifacts and code.
- **Architectural change:** requires new project architecture or a
  substantial change to its structure. The proposal adds a system outline
  whose points also serve as the implementation plan.

### Classification

1. Before drafting the proposal, the main agent examines the task and
   existing SDD artifacts.
2. It checks whether established mechanisms suffice or project architecture
   must be designed, then records the type. Feature novelty and code volume
   do not determine it.
3. The user reviews the type as part of proposal review. Discoveries that
   change the scope lead to revised classification and affected artifacts.

[REQ-003](requirements.md#req-003-sdd-minimally-delays-the-start-of-coding).

## Process

### Architectural change

1. **Proposal** contains:
   - Change type, a brief problem statement and scope.
   - A numbered topic-to-artifact table with one-sentence explanations.
   - A short proposed-system outline.
   - Affected spec IDs.
2. **Requirements** are written according to the [artifact rules](rules.md).
3. **Design**:
   1. Describe the external API and create the system skeleton from the
      proposal's outline; its items serve as the implementation plan.
   2. Develop each item's design together with its implementation;
      specification work for later items can wait until needed.

### Update

1. **Proposal** contains:
   - Change type, a brief problem statement and scope.
   - A numbered topic-to-artifact table with one-sentence explanations.
   - Affected spec IDs.
2. **Other SDD artifacts:** make any necessary changes; none may be needed.
3. **Code:** make any necessary changes.

Artifact and code changes take the form the user and/or agent deem
appropriate.

### Verification and archiving

A change is ready for archiving once all applicable checks required by
the project, change artifacts, SpecD processes and/or the user have passed.
It is archived only on the user's command.

[REQ-003](requirements.md#req-003-sdd-minimally-delays-the-start-of-coding).

## User Involvement

After the proposal is written, the user selects one of three involvement
levels. The user may change the selected level at any time.

### Full involvement

- Agents present artifacts one at a time and wait for user approval before
  proceeding.
- During design and implementation, the user reviews and approves each
  stage, including transitions from design to code and back.

### Partial involvement

1. Agents prepare the initial artifacts and design independently:
   - **Architectural change:** the external API and design skeleton/plan.
   - **Update:** necessary changes to design artifacts, if any.
2. The user reviews and approves the initial design.
3. Agents implement independently and return the implementation to the
   user.

### Full delegation

Agents develop artifacts and code independently and deliver a result ready
for archiving.

### Significant inconsistencies

At any involvement level, agents must stop when they discover a serious
inconsistency, explain it to the user and ask how to proceed. Work resumes
after the user's decision.

[REQ-003](requirements.md#req-003-sdd-minimally-delays-the-start-of-coding).

## Agent Review Rules

Executors and independent arbiters use the same numbered rule catalogue.
These rules make the [artifact rules](rules.md) concrete for their work.

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

[REQ-002](requirements.md#req-002-artifacts-are-simple-to-understand),
[REQ-003](requirements.md#req-003-sdd-minimally-delays-the-start-of-coding).

### Common Rules

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

### Requirements Rules

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

### System Rules

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

### Code Rules

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

## Validation and Subagents

### Proposal

The main agent uses only SDD artifacts. If they are insufficient, it
launches a research subagent to gather the necessary context.

### Before artifact review

Before submitting an SDD artifact for review, an independent nonauthor
arbiter checks both the diff against the original version and the complete
resulting artifact:

- Compliance with artifact requirements, including simplicity/readability.
- Consistency with other artifacts and user requests.
- Compliance with all applicable [Agent Review Rules](#agent-review-rules).

Findings are resolved before submission; the same arbiter rechecks both
views after corrections.

[REQ-002](requirements.md#req-002-artifacts-are-simple-to-understand),
[REQ-003](requirements.md#req-003-sdd-minimally-delays-the-start-of-coding).

### Design and implementation

Subagents write the code. For architectural changes, a separate subagent
develops the detailed design and implementation of each plan item.

For an Update, once the proposal is written:

- If the main agent understands what to change and where, it updates the
  design itself.
- Otherwise, a subagent researches and updates the design; the same
  subagent may then implement the change.

### Design and code validation

The same independent arbiters check design and code in this order:

1. **Design:** before implementation, check new or updated design for
   consistency with other subsystems' requirements and design.
2. **Code:** check that the implementation preserves those requirements
   and design.
3. **Cleanliness:** check code according to language and project conventions.

Design findings are resolved before coding; code findings before
implementation review.

### User review corrections

Changes requested during user review must be made by the original author.

## Process development and validation

### Testing

#### Coverage

Process changes must be tested against standard scenarios, with particular
attention to edge cases.

#### Execution

For each case, launch a separate tester subagent that:

1. Acts as the user and invents a task in a fictional project.
2. Launches an executor subagent to perform the task.
3. Monitors the executor's behaviour against the case's expectations.

The executor receives the task and normal working context, but must not
know it is being tested or receive the tester's expected behaviour.

#### Results

Keep all test artifacts after testing. Give the user a list of cases with
results and links to each test's root directory.

### Feedback

When process problems are discovered, prefer reporting them through
[this project's GitHub issues](https://github.com/ein-shved/shvedpkgs/issues).
