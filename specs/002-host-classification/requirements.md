# Requirements

## REQ-001: System classifies hosts by hardware traits and purpose

The system must introduce host classes that describe relevant hardware traits,
operational roles, and intended purpose of evaluated host configurations.

Classification must be explicit enough for role-sensitive configuration,
package selection, and package build-time behavior to depend on the host class
without guessing from unrelated implementation details.

### Scenario: Host classification describes purpose and traits

- WHEN a host configuration is evaluated
- THEN its host classes describe relevant hardware traits, operational roles, and intended purpose
- AND role-sensitive behavior can depend on those classes without guessing from unrelated details

### Scenario: Role-sensitive system behavior can access host classification

- WHEN any part of the system needs behavior that differs by evaluated host purpose, role, or hardware trait
- THEN that part of the system can access the host classification needed for the difference
- AND the difference is not inferred from unrelated host implementation details

### Scenario: Class-specific behavior is limited to applicable hosts

- WHEN behavior belongs to a host class
- THEN that behavior is applied to hosts classified for that class
- AND hosts outside the class are not forced to carry that class-specific behavior merely because other hosts use it

## REQ-002: Host class membership is controlled by disabled-by-default boolean configuration

Each host class must be represented by an elementary boolean configuration
value.

The default value for each class flag must be `false`. A host belongs to a
class only when the evaluated host configuration sets that class flag to
`true`.

### Scenario: Class flags default to non-membership

- WHEN a host configuration does not explicitly enable a host class flag
- THEN the host does not belong to that class
- AND the class flag's default value is `false`

### Scenario: Explicit flag enables class membership

- WHEN an evaluated host configuration sets a host class flag to `true`
- THEN the host belongs to that class
- AND behavior for that class should apply to the host

## REQ-003: Host classes are composable unless incompatible

A host may belong to more than one class at the same time.

The system must not treat host classes as mutually exclusive unless the classes
are explicitly declared incompatible or are semantically incompatible by their
definitions.

### Scenario: Compatible classes can be combined

- WHEN a host's purpose and traits match more than one compatible host class
- THEN the host can belong to those classes at the same time
- AND behavior for each applicable class should apply to the host

### Scenario: Incompatible classes are not combined silently

- WHEN two host classes are explicitly or semantically incompatible
- THEN the system does not treat the host as a valid member of both classes without addressing the incompatibility
- AND the incompatibility is visible in the host classification model

## REQ-005: Host classes provide package buckets

Each host class must provide a host-specific package bucket that is merged into
`environment.systemPackages` when the host belongs to that class.

Package buckets must collect packages for a host class before those packages
are merged into the evaluated system package set.

### Scenario: Class package bucket applies to class members

- WHEN a host belongs to a host class
- THEN that class's package bucket is included in the host's system package selection
- AND the selected class packages are merged into `environment.systemPackages`

### Scenario: Class packages are collected before merge

- WHEN packages are associated with a host class
- THEN they are collected in that class's package bucket before system package merging
- AND the class bucket is the requirement-level grouping for those packages

## REQ-006: System introduces graphical host class

The graphical class represents hosts that provide a graphical shell for
interactive use.

### Rationale

Graphical hosts need classification because desktop or graphical interaction is
not universal across the repository. Server and validation hosts should not be
forced to carry graphical packages or services merely because some personal
machines need an interactive graphical environment.

### Scenario: Graphical hosts are identified

- WHEN a host is intended to provide a graphical shell for interactive use
- THEN the host can be classified as graphical
- AND graphical-host behavior can apply to that host

## REQ-007: System introduces laptop host class

The laptop class represents portable personal computers with integrated
display, battery, and input devices.

### Rationale

Laptop hosts need classification because portable machines often differ from
stationary machines in hardware capabilities, power behavior, input devices,
and package or service choices. The class lets the system express laptop-aware
behavior without assuming that every personal host is portable.

### Scenario: Laptop hosts are identified

- WHEN a host is a portable personal computer with integrated display, battery, and input devices
- THEN the host can be classified as laptop
- AND laptop-aware behavior can apply to that host

## REQ-008: System introduces development host class

The development class represents hosts intended to support repository
development and maintenance workflows.

### Rationale

Development hosts need classification because development tools are required on
machines used for project work, but they are not inherently required on storage
servers, VPS machines, validation-only configurations, or other hosts whose
purpose does not include development.

### Scenario: Development hosts are identified

- WHEN a host is intended to support repository development and maintenance workflows
- THEN the host can be classified as development
- AND development-host tooling and behavior can apply to that host

## REQ-009: System introduces NAS host class

The NAS class represents home media server and storage machines.

### Rationale

NAS hosts need classification because storage-oriented machines have a
different purpose from interactive workstations and cloud machines. Their
package and service needs are driven by storage, media, and server operation,
not by the primary user's interactive desktop or development workflow.

### Scenario: NAS hosts are identified

- WHEN a host is intended to operate as a home media server or storage machine
- THEN the host can be classified as NAS
- AND storage, media, and server-oriented behavior can apply to that host

## REQ-010: System introduces VPS host class

The VPS class represents machines running in a cloud or virtual private server
environment.

### Rationale

VPS hosts need classification because cloud or virtual server environments have
different operational constraints from local physical machines. They may need
server-oriented packages and services while lacking local hardware assumptions
that make sense for laptops, NAS machines, or graphical hosts.

### Scenario: VPS hosts are identified

- WHEN a host runs in a cloud or virtual private server environment
- THEN the host can be classified as VPS
- AND cloud or virtual-server behavior can apply to that host

## REQ-011: System introduces VPS client host class

The VPS client class represents hosts that use services provided by a VPS host.

### Rationale

VPS client hosts need classification because consuming services from a VPS is a
separate role from running the VPS itself. A host may be a client of remote VPS
services while also belonging to another class such as laptop, graphical, or
development.

### Scenario: VPS client hosts are identified

- WHEN a host is intended to use services provided by a VPS host
- THEN the host can be classified as a VPS client
- AND VPS-client behavior can apply to that host
