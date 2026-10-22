# Requirements

## REQ-001: Existing SDD process remains authoritative

The human-readable artifact rules define the meaning and boundaries of SDD
artifacts independently of the tools and agents used to produce them.

### Scenario: Artifact meaning is discoverable

- WHEN a developer interprets an SDD artifact
- THEN the artifact rules define its responsibility and content
- AND tooling instructions remain consistent with those rules

### Scenario: Artifact contracts change explicitly

- WHEN an accepted change revises an artifact's responsibility or format
- THEN its rules and dependent authoring instructions are updated together

## REQ-002: Artifacts are simple to understand

SDD artifacts intended for human consumption must be easy for the project
owner to understand.

### Scenario: The owner understands an artifact

- GIVEN the project owner is familiar with the project's domain
- WHEN the owner opens any SDD artifact other than code
- THEN the owner can easily and quickly understand what it says

### Scenario: A reader is unfamiliar with the domain

- GIVEN a reader is unfamiliar with the project's domain
- WHEN that reader opens an SDD artifact
- THEN the artifact may be entirely incomprehensible to that reader

### Scenario: Simplification makes an artifact easier to grasp

- WHEN simplifying an SDD artifact makes it easier for the owner to grasp
- THEN omissions and inaccuracies are permitted for that purpose

### Scenario: The project has distinctive key properties

- WHEN the project has distinctive key properties
- THEN those properties should be mentioned in SDD artifacts

### Scenario: Specification sections have a stable reading order

- WHEN the owner reads the specification
- THEN its sections follow a stable, predictable order
- AND that order goes from general concepts to details

## REQ-003: SDD minimally delays the start of coding

Using SDD must minimally delay the start of coding after a task is stated.

### Scenario: A specification artifact does not resolve a blocker to starting

- WHEN preparing a specification artifact does not resolve critical
  uncertainty that prevents coding from starting
- THEN coding can start without waiting for that artifact to be prepared

### Scenario: A large change has specification artifacts needed later

- WHEN a large change includes specification artifacts that are not needed
  to start coding
- THEN coding can start before those artifacts are prepared
