# Spec-Driven Development Artifact Rules

## Scope and authority

These rules define artifact meaning, content and relationships independently
of the tools and agents that produce them. Production roles, review routing and
CLI lifecycle mechanics belong in operational instructions and the schema.

Artifact-model changes are authored in this English document, and the accepted
content is translated in full into [Russian](rules.ru.md). English is authoritative
while a translation defect is being corrected.

The content model is `proposal → requirements → system ↔ implementation`.
System architecture and implementation develop together by work item. Proposal
and requirements may also be revisited and corrected when necessary. ADRs created
on explicit user request preserve significant decisions. The artifact dependency graph remains acyclic.
Requirements and system are the durable current truth; conversation and temporary
notes are supporting context.

## Proposal

A proposal explains the problem and affected scope briefly and contains the
ordered high-level work items for the change. Each item has a stable number, a
one-word name, one short sentence describing its purpose and a completion
checkbox, for example:

```markdown
- [ ] 1. **Interface** — Supported configuration becomes available to callers.
```

Item selection and allocation of needs to requirements and current interfaces
and architecture to system occur together. The proposal lists affected spec IDs
even when their requirements remain unchanged. Item identities remain stable on
correction. A small change may have one item. Supporting evidence, alternatives and temporary
continuation belong outside the normative artifact chain.

The proposal describes this change's intent and work. Requirements and system
own current needs and design. A completed checkbox means the item
has reached a checked, coherent state; required correctness checks cannot remain
pending. Completed proposals remain change history.

## Requirements

Requirements describe needs the system or project must satisfy.

A Requirement should be as independent as reasonably possible from the
current implementation mechanism and configuration model.

A useful test is:

> If the internal implementation or configuration interface were
> replaced while the underlying need remained, would the Requirement
> still make sense?

If yes, the statement is likely a Requirement. If no, it may be
System or Implementation detail instead.

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

Patch constraints, defect descriptions, and proposed fixes do not become
requirements merely because the user mentioned them. They belong in proposal,
system, or implementation according to their responsibility.

The core need is concise; nuance, examples and boundary cases belong in
scenarios. Genuinely imposed negative constraints retain their observable
violation and acceptance scenarios.

A statement that mainly refines an existing requirement usually belongs in an
acceptance scenario under that requirement.

### Acceptance Scenarios

The current process uses **requirement-owned acceptance scenarios** to
express conditions under which a Requirement is satisfied.

An acceptance scenario belongs inside the Requirement it validates. It
uses Requirement-level concepts and should test the need or obligation
rather than encode unnecessary implementation or system-design detail.

Scenario headings name the observable condition being covered; concise bullets
describe the trigger and expected outcome. The normal shape is:

``` text
### Scenario: <observable condition>

- WHEN <the requirement-relevant condition occurs>
- THEN <the required outcome is true>
- AND <any additional requirement-level outcome or boundary is true>
```

Scenarios must not duplicate technical validation commands, fixture
setup, package layout, module wiring, or other implementation mechanics
unless that detail is itself part of the Requirement's external contract.
Technical evidence for checking the scenario belongs in implementation
and its checks. Explicitly requested special-check descriptions in system
reference the owning requirement.

## System

System is the normative description of the current system contract. It owns:

- stable system concepts and definitions;
- system interfaces and configuration contracts;
- normative behavior and guarantees;
- relationships and invariants between concepts;
- relevant external contracts;
- mappings from requirement concepts to the current system model.

It answers:

> What must be true about this system, given its current model and interfaces?

A useful conformance criterion is:

> Given an implementation of the current system, can we determine whether it
> conforms to this statement?

Requirements express independent needs; system forms a coherent model capable of
satisfying their set. It explains how components, relationships, interactions and
mechanisms realize those needs, and identifies where contracts are defined.
Concrete arrangements make conformance assessable.

One system concept may satisfy several requirements, and one requirement may
depend on several system sections. Significant concepts have one owning
definition; other sections reference it. Tables support comparison of repeated
entities or states.

### Examples of system content

These examples use an illustrative host-update CLI with `cli`, `config`,
`deployment` and `completion` modules.

#### Good examples

- "`host-update <host> --config <path>` updates one configured target." This
  defines the utility's external interface and its target-selection contract.
- "`cli::Args` uses clap to parse the public command." This names a module's role
  and its key dependency, an argument-parsing library.
- "`config::load` produces `Target`; `deployment::run` consumes it; `completion`
  reads the shared command definition." This identifies relationships and data
  flow between key modules.
- "Deployment starts activation only after a successful build." This states a
  material ordering invariant against which implementation can be checked.
- "`Target` contains public target settings; credentials remain in the SSH agent."
  This defines a data boundary and its relationship with an external participant.
- "A lock file records the exact dependency revisions used by deployment builds."
  This identifies a mechanism for reproducibility; the underlying need can remain
  stable if that mechanism changes.

#### Bad examples

- "Users can update their hosts." This repeats a need without describing an
  interface, component or mechanism that realizes it.
- "Create a map, loop over hosts and append each result." This is a coding recipe
  whose ordinary implementation steps belong in code.
- "The utility prints usage for an invalid set of arguments." Conventional
  correct CLI behavior and recitals of a parsing library's facilities alone add
  no project-specific architecture.
- "The function returns the constructed object as `Result<Object, Error>`." This
  standalone Rust idiom does not itself expose a significant system contract;
  actual external API definitions and material error behavior can belong in system.
- "Deployment may use SSH or a new service; the choice comes later." This leaves
  a material choice unresolved in a finished item's contract; pending design
  questions belong with the unfinished work.
- "We first chose A, then the reviewer suggested B." This records discussion
  history; system describes the current contract and mechanism.
- "The process has no Plan and Validate steps." This describes absent entities
  rather than the current system.
- "A reusable deployment framework always updates `office` before `home`." This
  selects an installation's policy for a generic contract; that order may belong
  in the contract of a concrete delivered instance.

### Level of concreteness

The appropriate concreteness depends on the system and contract being defined.
The boundary question is:

> Does this statement define a reusable contract, interface, invariant or
> guarantee, or select a value for an instance, deployment, policy, dataset,
> package set or other application of that contract?

For a general system or framework, concrete values usually belong to its
instances. For a system whose purpose is to define a concrete delivered instance,
values that define that delivery may be part of its accepted contract. An explicit
definition of the entity being specified keeps this boundary independent of the
project's dominant perspective.

User-requested ADRs contain significant choice rationale and relevant alternatives. Concrete
coding steps, file-by-file instructions and temporary migration mechanics belong
to implementation. System retains the resulting current contract and the material
mechanisms needed to understand it.

### Work-item architecture and checks

The affected system content starts with the designed entity's external interface
and sections matching exactly the proposal's work-item names and order. The external
interface is relative to that entity: public library types/functions, REST, UI,
CLI, protobuf, IOCTL or another relevant boundary. Each item section records its
role, named key participants, relationships with other modules and material
external dependencies needed to understand the solution.

Architecture and implementation develop together by work item. Item sections may
initially be pending and become complete alongside implementation. References
preserve sufficient existing contracts; a narrow fix may leave system unchanged. Completed system content describes the implemented current design and
resolves the design needed by that change. It contains architectural decisions and
mechanisms that distinguish a conforming implementation; routine coding choices
remain in code. Additional text resolves a concrete ambiguity.

An explicit user request adds a brief special-check description to system. It
identifies the case and expected evidence and references its requirement or
system owner. Acceptance conditions remain in requirements. Ordinary tests and
correctness checks are part of implementation.

## Optional architecture decision records

An architecture decision record (ADR) is created only on explicit user request.
This applies to new records, amendments and superseding records. A requested ADR
preserves a significant decision, its context, relevant alternatives and the
rationale for the selected direction. It answers:

> Why was this significant choice made?

ADRs are optional historical decision evidence. Their value is the independent
preservation of a choice and its reasoning. Decisions can arise while working on
requirements, system architecture or implementation. Their current consequences
belong in requirements and system; an explicitly requested ADR records the choice
and its reasoning.

The responsibilities are distinct:

- Requirements express the need and its satisfaction conditions.
- System defines what is true about the current system and how it is realized.
- ADR explains why a significant direction was selected over relevant alternatives.
- Implementation realizes those contracts in code, configuration and tests.

Each decision has one section, including status, context, decision, rationale and
consequences. References identify current normative owners for behavior and
contracts. Relevant alternatives clarify a significant choice; ordinary local
coding choices remain in implementation.

### History and supersession

Existing ADRs preserve decision history. Clarifying an ADR may add an example,
evidence or wording that better explains the original decision and substantive
rationale. The time of that clarification remains clear so later knowledge is
attributed accurately. An amendment or superseding ADR created on explicit user
request records a material revision to the decision, a new decisive rationale or
a change to the recorded trade-off.

A replaced ADR remains in history, is marked superseded and references its
replacement. Requirements and system continue to describe the current accepted
needs and contracts; ADRs explain their reasoning and evolution.

### Focused discovery

An explicitly requested ADR may contain a narrow investigation when its
alternatives, evidence and decision fit clearly together. For example, it may
compare two small performance cases or prototype two localized API shapes before
recording the selected direction. Broader research and prototypes may use
temporary supporting material; their adopted conclusions enter the appropriate
normative owner.

## Traceability and ordering

Each coherent architecture point links to its owning requirement heading at its
section, definition or list item. Independent points need their own links.
For example, `[REQ-001](requirements.md#req-001-title)` identifies an owner without
copying its content; cross-spec links include the owning spec's relative path.
Anchors correspond to the actual target headings.

Relationships are naturally many-to-many: one requirement may need several
system sections, several requirements may share one system concept, and one
work item may affect several contracts. Coverage follows these relationships
without a forced one-to-one mapping or duplicate prose.

Links from code, docstrings and permanent code documentation resolve to existing
enduring documents and any named headings. Suitable targets include the owning
requirements and system under `specs/`. Targets remain meaningful after archive;
links support useful navigation.

Document views assembled from capability specs use stable three-digit numeric
capability prefixes in general-to-specific order, for example `000-sdd-process`
before project and host details. Each document kind follows that deterministic
order rather than filesystem or glob traversal order.

## Corrections, evidence and history

A defect belongs to its earliest incorrect, ambiguous or incomplete owner: need
or satisfaction condition → requirements; current contract or mechanism → system;
recorded significant-choice rationale → its ADR; incorrect realization →
implementation. A correction updates that owner and includes reconsideration of
affected dependents. A correct dependent need not change.

A correction replaces wrong current statements and their dependent explanations,
removing contradictions and obsolete rationale from the affected section.
Correction history belongs in change context or historical records. A correction
does not justify an unsupported counterclaim or new prohibition.

Tests, builds, static checks, inspection and runtime behavior may establish
requirement satisfaction and system conformance. A bug fix also closes a relevant
validation gap with regression evidence. Deployment and operation may supply
further evidence. Discoveries after completion receive explicit corrective work
while current contracts are updated as needed.

Requirements and system remain living current contracts. ADRs and completed
proposals preserve history. Temporary guidance and discovery notes may be
refreshed or removed when no longer useful; they must not become competing
sources of current system truth.
