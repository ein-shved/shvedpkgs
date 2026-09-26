# Spec-Driven Development Process

## 0. Document Status

### 0.1 Scope

This document defines the project’s current working Spec-Driven
Development (SDD) process.

The process is under active development.

Until open changes are explicitly adopted, the rest of this document
defines the current working model.

### 0.2 English and Russian Versions

**Process changes are made only in this English document.** After an
accepted change, this document is translated in full into the
[Russian version](sdd-process.ru.md). The Russian document is not
developed independently.

If the English and Russian documents diverge, the divergence is a defect
and should be tracked and corrected as a bug. Until it is resolved,
**the English document is authoritative**.

### 0.3 Open Questions and TODO

The primary candidates for future revision are:

- **Requirement validation model.** Requirements currently use
  acceptance criteria (AC). A scenario-based model, similar in spirit to
  OpenSpec scenarios, is being considered as a replacement or
  refinement. A constrained scenario format may provide clearer
  validation units and reduce subjective judgement about whether an AC
  is well formed.
- **Artifact lifecycle and status model.** The process needs an explicit
  model for artifact states and transitions, such as draft, accepted,
  active, completed, superseded, archived, or equivalent project-specific
  states. OpenSpec may provide useful ideas here, but any borrowed model
  must preserve this document’s artifact responsibilities and dependency
  structure.
- **OpenSpec integration.** OpenSpec is being considered as tooling for
  agent-assisted SDD. Its standard workflow is not assumed to define
  this methodology. In particular, the separation between Requirements,
  System Specification, Plans, and other artifacts described here should
  be preserved unless deliberately revised.
- **Artifact formats and workflow automation.** File layout, syntax,
  identifiers, lifecycle states, traceability, and agent-facing workflow
  may evolve as tooling is introduced.

### 0.4 Examples and Technology-Specific Detail

Examples may use concrete technologies when doing so makes the process
boundary clearer. A reader must not need prior knowledge of that
technology to understand the example. If a technology-specific term is
important to the example, include enough local explanation for the
example to stand on its own.

Prefer the smallest concrete example that clarifies the process rule.
Do not let technology explanation grow until it obscures the SDD concept
being illustrated.

## 1. Purpose and Principles

The process makes project intent, the current system contract, important
decisions, implementation transitions, and executable work explicit
enough that humans and agents can reconstruct the project without
relying on accumulated conversation history.

Core principles:

1.  **Repository artifacts are the durable process context.**
    Conversation and agent context are temporary aids.
2.  **Artifacts have distinct responsibilities.** Requirements,
    Specification, ADRs, Plans, Tasks, Implementation, and any optional
    Context artifact must not silently absorb each other’s roles.
3.  **The main dependency direction is
    `REQ → SPEC → PLAN → TASKS → IMPLEMENTATION`.** This is a dependency
    model, not an irreversible waterfall.
4.  **Discovery may move upstream.** Downstream work can reveal that an
    earlier artifact is wrong, ambiguous, or incomplete.
5.  **Corrections propagate downstream.** Correct the earliest affected
    artifact, then reconsider dependent artifacts in order.
6.  **Significant decisions are explicit.** ADRs preserve important
    choices and their rationale.
7.  **Completed work ends in an agreed and validated state.** Validation
    establishes completion; it is not ceremony performed after
    completion.
8.  **Use the minimum useful ceremony.** An artifact or boundary should
    exist because it carries distinct useful information.

## 2. Process Model

The primary dependency flow is:

``` text
REQ -> SPEC -> PLAN -> TASKS -> IMPLEMENTATION
       ^       ^
       +-- ADR-+
```

An optional non-normative Context artifact may support discovery and
orientation, especially while introducing SDD to an existing project. It
is not part of the normative dependency chain.

ADR is not a fixed pipeline stage. It may arise while working at any
layer.

The arrows express dependency, not permitted direction of work. Later
work may expose missing information upstream:

``` text
REQ -> SPEC -> PLAN -> TASKS -> IMPLEMENTATION
       ^       ^       ^          |
       +-------+-------+----------+
                 discovery
```

When this happens, identify the earliest artifact whose correct content
should have prevented the problem. Correct it first, then reconsider
affected downstream artifacts.

> **Discovery moves upstream; corrections propagate downstream.**

### 2.1 Optional Discovery/Spike Branch

When the project has enough known or suspected need to investigate, but
the Requirements, system contract, or significant design direction are
still too uncertain to stabilize Specification responsibly, an optional
Discovery/Spike branch may appear:

``` text
REQ -> [DISCOVERY/SPIKE] -> SPEC -> PLAN -> TASKS -> IMPLEMENTATION
```

Discovery/Spike is not a normal mandatory stage and is not production
implementation. It exists to compare alternatives, build limited
prototypes when useful, validate assumptions, and produce evidence for
Requirements, Specification, and ADRs.

Discovery/Spike may reveal that Requirements were incomplete, wrong, or
too vague. When that happens, use the same upstream discovery rule:
correct Requirements first, then reconsider Discovery/Spike outputs and
downstream artifacts.

## 3. Artifact Model

### 3.1 Context

Context is an optional, non-normative inventory and map of the project.
It may describe repository structure, entry points, system instances,
important layers, external/private boundaries, current implementation
observations, and useful historical notes.

Context does **not** define required behavior or system guarantees. It
may be incomplete or temporarily stale. When it conflicts with normative
artifacts, Requirements and System Specification take precedence.

Context is most useful during SDD adoption, project discovery, or work
on areas whose intent and system contract are not yet adequately covered
by normative artifacts. In the ideal steady state, once the project has
been fully brought under the SDD process, a separate Context artifact
should become unnecessary and may be absent.

Do not preserve Context as a parallel current-system description merely
for self-containment. When implementation changes make Context
materially stale, either refresh the still-useful non-normative
orientation, migrate durable knowledge to the proper owning artifact, or
remove the stale Context material.

### 3.2 Requirements

Requirements describe needs the system or project must satisfy.

A Requirement should be as independent as reasonably possible from the
current implementation mechanism and configuration model.

A useful test is:

> If the internal implementation or configuration interface were
> replaced while the underlying need remained, would the Requirement
> still make sense?

If yes, the statement is likely a Requirement. If no, it may be
Specification, Plan, or Implementation detail instead.

This test is not a ban on concrete technologies in Requirements. A
technology, file format, or interface may belong in a Requirement when
it is itself part of the user need, external contract, or compatibility
obligation.

Requirements own the need or obligation, its intended scope, rationale
when useful, and conditions used to determine satisfaction.

They do not own current internal interfaces merely because those
interfaces implement the need, package/module/file choices, migration
steps, architectural history, or implementation decomposition.

A Requirement may use domain concepts meaningful to its consumer. The
System Specification maps those concepts to the current system model
where necessary.

#### 3.2.1 Acceptance Criteria and Scenarios

The current process uses **acceptance criteria (AC)** to express
conditions under which a Requirement is satisfied.

AC should test the Requirement rather than encode unnecessary
implementation or system-design detail.

This part of the process is explicitly under review. A scenario-based
model is the leading candidate for replacing or refining AC. A formally
constrained scenario may provide a clearer unit of expected behavior and
reduce subjective debate over whether an individual AC is appropriately
formed.

Until a scenario model is explicitly adopted, AC remain the current
mechanism.

### 3.3 System Specification

The System Specification is the normative description of the current
system contract.

It owns:

- stable system concepts and definitions;
- system interfaces and configuration contracts;
- normative system behavior and guarantees;
- relationships and invariants between concepts;
- relevant external contracts;
- mappings from abstract Requirement concepts to the current system
  model.

It answers:

> **What must be true about this system, given its current model and
> interfaces?**

A useful conformance test is:

> Given an implementation of the current system, can we determine
> whether it conforms to this statement?

Specification is not a formal restatement of Requirements. Requirements
express independent needs; Specification forms a coherent system model
capable of satisfying their set.

For example, a Requirement may state that users must be able to
reproduce the same package or dependency set on another machine. That
need can remain stable if the project changes the mechanism used to
provide it.

The Specification describes the current system contract that satisfies
that need, such as a lock file that records exact dependency versions, a
generated package index that consumers read, or another current
interface. If that interface changes while the underlying need remains,
the Requirement may remain stable while the Specification changes.

The relationship is naturally many-to-many:

``` text
REQ-001 --+
REQ-002 --+--> System Concept / Contract A
REQ-003 --+              |
                          +--> Behavior X
REQ-004 -----------------+
```

One Specification concept may participate in satisfying several
independent Requirements, and one Requirement may depend on several
Specification sections.

Significant concepts should have one owning definition location. Other
sections reference them instead of redefining them.

The appropriate level of concreteness in Specification depends on the
kind of system and contract being defined. A concrete value is not
automatically Specification, and it is not automatically outside
Specification.

Ask whether the statement defines a reusable system contract, interface,
invariant, or guarantee, or whether it selects a value for a particular
instance, deployment, policy, dataset, package set, or other application
of that contract.

For universal systems and frameworks, concrete values usually belong to
instances of the system rather than to the system Specification. For
systems whose purpose is to define a concrete delivered instance, some
values may be part of the accepted contract. In both cases, avoid
letting the project’s dominant perspective decide the boundary
implicitly.

Specification does not own the rationale for choosing one significant
design over alternatives, the concrete transition from existing
implementation, file-by-file implementation instructions, or temporary
migration mechanics. Those belong to ADRs and Plans.

### 3.4 Implementation Plan

A Plan describes a concrete transition from the current implementation
to a state conforming to the relevant Requirements, Specification, and
accepted decisions.

A Plan may contain related artifacts, goal, assumptions, constraints,
current implementation observations, implementation approach, minimal
change set, scope/out-of-scope, migration order, risks, and validation
strategy.

It answers:

> **How will the current implementation be changed so that it conforms
> to the agreed system contract?**

Plans may name concrete files, modules, packages, configuration options,
commands, and migration steps.

A Plan must not silently introduce new normative system behavior. If
planning reveals a missing concept, interface, or guarantee, return to
Specification. If it reveals a previously unknown need, return to
Requirements. If it requires a significant choice whose rationale should
survive the change, create or update an ADR.

Use this boundary test:

> If a statement must remain true after the transition is complete, it
> should not live only in the Plan.

Plans may describe how the project reaches a target state, why a
particular transition order is safe, and what validation will prove the
transition. The durable target state belongs in Requirements and
Specification.

The Plan’s validation strategy describes evidence that the transition is
correct, including intended changes and preservation of behavior that
should remain unchanged.

A completed Plan is primarily transition history. Current system truth
remains in Requirements and Specification.

### 3.5 Tasks

Tasks decompose an accepted Plan into independently completable units of
work.

> **A Task is the minimum practically useful unit of work that can move
> the project from one agreed state to another agreed and validated
> state.**

Each Task is expected to leave the system in an agreed and validated
state. Validation is a completion criterion of the Task, not a separate
correctness-validation Task.

A Task may contain several implementation steps when splitting them
would intentionally create an invalid, inconsistent, or unvalidated
intermediate state.

Those steps may be written down as a checklist or executed as separate
commits, but they are not independently completed project Tasks. The
Task is marked complete only when the whole step sequence, including its
final validation, has reached one agreed and validated state.

A good Task boundary is a point at which work can safely stop.

Preparatory or non-mutating Tasks are valid when their result is
independently complete and they do not leave the project degraded.
Capturing a baseline for a later migration is one example.

Tasks derive decisions from the Plan rather than introducing new
significant design decisions. If execution exposes a missing decision,
work returns to the appropriate upstream layer.

If implementation work is committed, the execution artifact should be
either one atomic self-contained commit or a chain of atomic
self-contained commits. A Task does not have to equal one commit.

Repository Tasks are not an agent’s temporary TODO list. Agents may
split a Task into many ephemeral execution steps without persisting each
step as a project Task.

### 3.6 Implementation

Implementation executes Tasks in code, configuration, tests, generated
artifacts, or other project material.

Local decisions that do not alter the agreed system model or significant
design may be made during implementation.

Implementation must not hide upstream discoveries:

- new need → Requirements;
- missing system concept/contract → Specification;
- significant choice → appropriate owning layer and possibly ADR;
- wrong transition approach → Plan;
- unsafe work boundary → Tasks.

Implementation is complete only when the Task’s completion criteria,
including validation, are satisfied.

## 4. Architecture Decision Records

### 4.1 Role

An Architecture Decision Record (ADR) preserves a significant decision,
its context, relevant alternatives, and the rationale for the selected
direction.

It answers:

> **Why was this significant choice made?**

ADR is historical decision evidence, not the primary source of current
system truth.

### 4.2 When an ADR Appears

ADR is **not a pipeline stage**.

It may arise while defining Requirements, Specification, or a Plan, or
during Task execution when discovery exposes a previously unmade
significant decision.

In the latter case, do not bury the decision in code. Return to the
appropriate design level, record the decision, and update downstream
work as necessary.

Not every technical choice requires an ADR. Use ADRs when preserving the
rationale independently has value.

### 4.3 ADR vs Specification vs Plan

- **Specification:** what is true about the system.
- **ADR:** why a significant choice was made.
- **Plan:** how this particular implementation transition will be
  performed.

An ADR may cause normative consequences in Specification and concrete
actions in a Plan.

### 4.4 Lifecycle and Supersession

ADRs preserve history. Do not rewrite old ADRs to pretend later
decisions were known earlier.

Clarifying an ADR is allowed when it preserves the decision and its
substantive rationale. Later work may uncover a concrete example,
evidence, or wording that better explains a rationale already present in
the ADR.

Such edits should not make later knowledge appear to have been known at
decision time. If the clarification materially changes the decision,
adds a new decisive rationale, or changes the trade-off being recorded,
create an amendment or superseding ADR instead.

When replaced, an ADR remains and is explicitly marked superseded,
preferably referencing its replacement.

Use Specification for current system truth; use ADRs for reasoning and
evolution.

### 4.5 Lightweight Discovery Inside an ADR

Small discovery work may be contained inside an ADR instead of becoming
a separate Discovery/Spike branch.

Use this when the question is narrow enough that the ADR can record the
alternatives, evidence, and decision without obscuring the decision
itself. For example, an ADR may compare two small performance examples
or prototype two localized API shapes before recording the selected
direction.

If the work needs multiple substantial prototypes, broad validation, or
may materially reshape Specification, use an explicit Discovery/Spike
process instead.

## 5. Discovery and Spike Process

Discovery/Spike is an optional process for high-uncertainty discovery
and design work. It is used when the project has enough known or
suspected need to investigate, but cannot yet responsibly stabilize the
Requirements, system contract, or significant design direction.

It answers:

> **What must we learn before choosing the system contract or design
> direction?**

Discovery/Spike may define candidate approaches, representative cases,
prototype scope, validation criteria, expected evidence, and explicit
stop conditions.

It may produce:

- explored alternatives;
- validation results;
- concrete findings and rejected assumptions;
- risks and open questions;
- prototype code;
- a recommendation for Specification and ADRs.

Discovery/Spike does **not** define normative behavior by itself.
Prototype code is not production implementation merely because it
exists. If prototype code is reused, it must be adopted through the
normal Specification, Plan, Tasks, and Implementation flow.

Completion of Discovery/Spike means that the agreed questions were
answered well enough to continue. The result should feed an ADR when a
significant direction is chosen, and should feed Specification when the
current system contract becomes clear.

If Discovery/Spike reveals that the underlying need was missing,
incomplete, or wrong, correct Requirements before using its results to
define Specification or downstream work.

## 6. Forward Flow

### 6.1 Optional Context → Requirements

When present, Context supplies orientation and evidence. It does not
turn existing behavior into a Requirement merely because that behavior
exists.

Requirements come from actual project or user needs.

### 6.2 Requirements → Optional Discovery/Spike

When Requirements or suspected needs identify an area of work but
competing system contracts or design directions remain plausible, use
Discovery/Spike before writing a normative Specification.

If uncertainty is narrow, it may be handled inside an ADR. If it is
broad, expensive, or likely to reshape Specification, make it an
explicit Discovery/Spike process.

### 6.3 Requirements and Discovery → Specification

Specification transforms independent needs into a coherent
current-system contract. It identifies shared concepts, maps
terminology, defines interfaces/invariants/behavior, avoids duplicating
shared design across Requirements, and surfaces ambiguity instead of
silently inventing mappings.

A significant choice needed to form the model may produce an ADR.

### 6.4 Specification → Plan

Planning compares the normative target with current implementation and
determines what changes, what must remain unchanged, which
implementation areas are affected, relevant assumptions/risks, and how
correctness will be demonstrated.

If Specification cannot adequately describe the intended result, correct
Specification before continuing the Plan.

### 6.5 Plan → Tasks

Decompose the Plan along safe execution boundaries.

Task granularity is determined by coherent validated states, not file
count, line count, or the desire to make every action a checkbox.

If two proposed Tasks cannot each independently finish in an agreed and
validated state, they are probably steps of one Task.

### 6.6 Tasks → Implementation

Normal Task execution is:

``` text
implement
   |
   v
validate
   |-- failure -> fix within the open Task -> validate again
   +-- success -> Task complete
```

A correctness validation failure does not create a separate validation
Task while the implementation Task is still open.

### 6.7 Completion and Optional Context

Normative artifacts should already describe the intended system before
implementation completes.

If non-normative Context exists, do not leave it misleading. Refresh the
still-useful orientation, migrate durable knowledge to the proper owning
artifact, or remove stale Context material.

Completed Plans and Tasks remain transition history, not alternative
current-system documentation.

## 7. Backward Flow and Upstream Discovery

Later work often reveals information that could not be confidently known
earlier. This is expected.

The governing rule is:

> **Find the first bad artifact.**

The first bad artifact is the earliest layer that is incorrect,
ambiguous, or incomplete with respect to the newly understood truth.

Examples:

``` text
Planning reveals a missing system contract
-> correct SPEC
-> reconsider PLAN
-> reconsider TASKS
```

``` text
Implementation reveals a significant unmade design decision
-> update PLAN and/or create ADR
-> reconsider TASKS
-> continue implementation
```

``` text
Implementation reveals a previously unknown project need
-> update REQ
-> update SPEC
-> update PLAN
-> update TASKS
-> implementation
```

Do not patch a downstream artifact merely because that is where the
problem became visible.

After correcting the earliest affected artifact, propagate consequences
downstream. A downstream artifact need not change if review confirms it
remains valid.

## 8. Defect and Bug Handling

### 8.1 Classification

A defect may be a:

- **Requirement defect** — need, scope, or satisfaction condition is
  wrong/incomplete;
- **Specification defect** — system contract/model is wrong, ambiguous,
  or incomplete;
- **decision/design defect** — a significant direction is wrong or its
  rationale/constraints are missing;
- **Plan defect** — transition approach, assumptions, scope, or
  validation strategy is insufficient;
- **Task defect** — decomposition creates an unsafe boundary or omits
  work;
- **implementation defect** — implementation violates correct upstream
  artifacts;
- **validation defect** — validation cannot detect a relevant violation.

Categories may overlap. The useful question is which earliest artifact
must change.

### 8.2 Defects Found During an Open Task

If validation fails, the Task remains open.

Fix implementation and validate again. If the failure reveals an
upstream defect, correct that artifact first and propagate the change
back to the Task.

Do not complete implementation and create a separate
correctness-validation Task.

### 8.3 Defects Found After Completion

A defect may appear after Tasks were completed, committed, pushed,
deployed, or integrated:

``` text
PLAN -> TASK -> validation OK -> commit/push -> deployment -> bug
```

Completion means work was agreed and validated against the knowledge and
validation model available at that time. It does not make completed
artifacts infallible.

Investigate using the same first-bad-artifact rule.

### 8.4 Correcting Completed Artifacts

Do not silently rewrite historical artifacts so that newly discovered
knowledge appears to have been known originally.

If the original approach remains valid but a completed Plan had
incomplete validation or needs a bounded correction, add an explicit
follow-up/amendment to that Plan and derive new Tasks from it.

The follow-up should record:

- what was discovered;
- what original assumption, implementation detail, or validation
  coverage was insufficient;
- what correction is required;
- what regression validation is required.

Do not reopen completed Tasks merely because new information appeared
later. They were completed according to their then-current definition of
done. Represent corrective work explicitly.

Create a new Plan when discovery requires a materially different
transition or implementation approach rather than a bounded correction.

If behavior was missing from Specification, correct Specification before
planning the fix. If the underlying need was missing, correct
Requirements first.

### 8.5 Regression Validation

A bug fix should close both the implementation defect and, when present,
the validation gap that allowed it to pass.

Regression validation should demonstrate the newly understood failure
case or an equivalent invariant so the same class of defect becomes
detectable.

## 9. Validation Model

Validation has different responsibilities at different layers.

### 9.1 Requirement Satisfaction

AC currently define evidence that a Requirement is satisfied. A
scenario-based replacement/refinement is under consideration.

### 9.2 Specification Conformance

Specification validation asks whether implementation conforms to the
normative contract. Evidence may include tests, evaluation, inspection,
static checks, runtime behavior, or other appropriate mechanisms.

### 9.3 Plan Validation Strategy

A Plan defines how correctness of its transition will be demonstrated.
It may verify intended new behavior, absence of unintended behavior,
preservation of unaffected behavior, migration safety, and assumptions.

For behavior-preserving transitions, use strong equivalence evidence
when it is cheap and its meaning is clear. For example, a reproducible
build system is expected to produce the same output for the same inputs,
so it may sometimes allow comparison of output hashes or other build
identities before and after a structural migration. This is
project-specific evidence, not a universal SDD requirement.

### 9.4 Task Completion Validation

Task validation is part of definition of done. A Task cannot be complete
while required correctness validation is pending.

### 9.5 Deployment and Operational Feedback

Deployment and operation provide additional evidence and may expose
cases earlier validation missed.

This does not automatically make deployment a mandatory formal
validation stage. Classify the discovered gap and update the earliest
artifact that should contain the new knowledge.

> **Validation is part of establishing an agreed state, not a ceremonial
> phase following implementation.**

## 10. Artifact Evolution and History

Different artifacts have different lifetimes:

- **Requirements and Specification:** living normative artifacts
  describing current accepted needs and system contract.
- **ADRs:** historical decision artifacts preserving why significant
  choices were made; superseded ADRs remain history.
- **Plans:** transition artifacts describing how a particular
  implementation state was moved toward a target state.
- **Tasks:** execution work queue and execution history; not current
  system specification.
- **Context:** optional non-normative current-state inventory, useful
  during discovery or SDD adoption and removable when no longer needed.

This separation prevents Plans, Tasks, old ADRs, and historical
implementation notes from becoming competing sources of current truth.

## 11. Traceability

Traceability should expose relationships without forcing artificial
one-to-one mappings:

``` text
REQ --+
REQ --+--> SPEC concepts/contracts --> PLAN --> TASKS --> commits
REQ --+             ^
                     |
                    ADR
```

Valid relationships include:

- one Requirement → several Specification sections;
- several Requirements → one shared Specification concept;
- one Plan → changes arising from several Specification sections/ADRs;
- one Task → several tightly coupled Plan actions when separation would
  create an invalid intermediate state;
- one Task → several atomic commits.

Artifacts are organized by responsibility, **not to force one-to-one
correspondence between layers**.

Traceability should be sufficient to navigate causality without becoming
bureaucracy that duplicates artifact content.

## 12. Agent Interaction and Tooling

### 12.1 Repository State as Agent Context

Agents should primarily derive project intent and process state from
repository artifacts.

A healthy process should allow a fresh agent to continue without a large
handoff duplicating repository knowledge.

Prompts may therefore remain concise when conventions are established,
for example:

``` text
Create a Plan for REQ-001.
```

Quality should come from artifacts and process rules, not months of
conversation history.

### 12.2 Ambiguity and Discovery

Agents should not silently invent mappings or decisions to close
upstream gaps. Material ambiguity should be surfaced and resolved at the
owning layer.

### 12.3 Repository Tasks vs Agent Execution Steps

Repository Tasks are integration-safe units of project work. An agent
may use a much finer temporary TODO list internally; those steps are
execution mechanics, not automatically project Tasks.

### 12.4 Tooling

Tooling may assist artifact creation/navigation, dependencies and
traceability, structural validation, change/delta workflows, agent
context assembly, lifecycle, and archival operations.

**The methodology defines artifact semantics and responsibilities;
tooling implements or assists the workflow around them.**

OpenSpec is currently being considered in this role. Its standard
workflow is not currently adopted as the project’s process model.
Integration may require adapting the tool or deliberately revising this
methodology. Such revisions are made first in this English document
according to Section 0.

## 13. Practical Decision Guide

### 13.1 Where Does This Belong?

| Question                                                     | Primary artifact     |
|--------------------------------------------------------------|----------------------|
| Why does the project/user need this?                         | Requirement          |
| What need or obligation must be satisfied?                   | Requirement          |
| What does the current system guarantee?                      | System Specification |
| What system concept/interface does this map to?              | System Specification |
| What must be learned before choosing a system contract?      | Discovery/Spike      |
| Why was this significant design choice made?                 | ADR                  |
| How will current implementation be changed?                  | Plan                 |
| How will this transition be validated?                       | Plan                 |
| What independently completable work unit should be executed? | Task                 |
| What code/configuration realizes the change?                 | Implementation       |
| What temporary orientation is useful during discovery?        | Optional Context     |

### 13.2 I Found a Problem — Where Do I Return?

| Discovery                                               | Return to                                                     |
|---------------------------------------------------------|---------------------------------------------------------------|
| Underlying need is wrong or missing                     | Requirement                                                   |
| Required behavior/concept/interface is missing or wrong | Specification                                                 |
| A significant unresolved choice is required             | Owning layer + ADR                                            |
| Transition or validation strategy is wrong              | Plan                                                          |
| Work is decomposed across an unsafe boundary            | Tasks                                                         |
| Upstream artifacts are correct but code is wrong        | Implementation                                                |
| A completed change missed a relevant failure case       | Find first bad artifact; add regression validation downstream |

When uncertain, ask:

> **What is the earliest artifact which, if it had contained the truth I
> know now, would have prevented this problem?**

Correct that artifact first.
