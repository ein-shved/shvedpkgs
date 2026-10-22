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

## Validation and Subagents

### Proposal

The main agent uses only SDD artifacts. If they are insufficient, it
launches a research subagent to gather the necessary context.

### Before artifact review

Before submitting an SDD artifact for review, an independent arbiter checks:

- Compliance with artifact requirements, including simplicity/readability.
- Consistency with other artifacts and user requests.

Findings are resolved before submission.

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
