# Verification: SpecD SDD Integration

## Requirements

### Requirement: Existing SDD process remains authoritative

#### Scenario: SpecD does not replace the SDD process

- GIVEN `spec/sdd-process.md` defines the repository SDD process
- WHEN SpecD artifacts are added to the repository
- THEN the SDD process document remains the authoritative process definition
- AND SpecD artifacts do not silently redefine SDD artifact responsibilities

### Requirement: SpecD provides machine-readable workflow state

#### Scenario: Project status is discoverable

- GIVEN the repository contains `specd.yaml`
- WHEN an agent runs `specd project status --context --graph --format toon`
- THEN SpecD reports the configured workspace
- AND SpecD reports available specs and changes
- AND SpecD reports lifecycle context usable for the next action

#### Scenario: Change instructions are discoverable

- GIVEN an active SpecD change exists
- WHEN an agent runs `specd changes artifact-instruction <change-id>`
- THEN SpecD returns the next artifact to edit
- AND the instruction includes the relevant artifact rules

### Requirement: SpecD specs may mirror current SDD contracts

#### Scenario: Mirrored content defers to normative SDD artifacts

- GIVEN a SpecD steady-state spec mirrors content from `spec/`
- WHEN the mirror conflicts with a normative SDD artifact
- THEN the normative SDD artifact owns the correction
- AND the SpecD mirror is treated as stale until updated or removed

### Requirement: Changes that modify behavior pass through SpecD artifacts

#### Scenario: Behavior change has SpecD lifecycle artifacts

- GIVEN a future change modifies expected repository behavior
- WHEN the change is prepared through SpecD
- THEN the change has proposal, spec, verification, design, and task artifacts
- AND implementation starts only after the relevant blockers are resolved

### Requirement: Requirement validation may use scenario-style checks

#### Scenario: Scenario checks are local to SpecD verification

- GIVEN a SpecD verification artifact uses scenarios
- WHEN the scenario is read alongside `spec/sdd-process.md`
- THEN the scenario is treated as a SpecD verification unit
- AND it does not globally replace SDD acceptance criteria unless the SDD
  process is explicitly changed
