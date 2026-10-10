# Requirements

## REQ-001: System classifies hosts by hardware traits and purpose

The system must introduce host classes that describe relevant hardware traits,
operational roles, and intended purpose of evaluated host configurations.

Classification must be explicit enough for role-sensitive configuration,
package selection, and package build-time behavior to depend on the host class
without guessing from unrelated implementation details.

## REQ-002: Host class membership is controlled by disabled-by-default boolean configuration

Each host class must be represented by an elementary boolean configuration
value.

The default value for each class flag must be `false`. A host belongs to a
class only when the evaluated host configuration sets that class flag to
`true`.

## REQ-003: Host classes are composable unless incompatible

A host may belong to more than one class at the same time.

The system must not treat host classes as mutually exclusive unless the classes
are explicitly declared incompatible or are semantically incompatible by their
definitions.

## REQ-004: Each host class has a derived package-set flag

Each host class must expose a corresponding derived flag in the root package
set, `pkgs`, when package expressions need to vary by evaluated host.

Package-set host flags must be derived from evaluated host configuration. They
must not define host classification independently.

## REQ-005: Host classes provide package buckets

Each host class must provide a host-specific package bucket that is merged into
`environment.systemPackages` when the host belongs to that class.

Package buckets must collect packages for a host class before those packages
are merged into the evaluated system package set.

## REQ-006: System introduces graphical host class

The graphical class represents hosts that provide a graphical shell for
interactive use.

### Rationale

Graphical hosts need classification because desktop or graphical interaction is
not universal across the repository. Server and validation hosts should not be
forced to carry graphical packages or services merely because some personal
machines need an interactive graphical environment.

## REQ-007: System introduces laptop host class

The laptop class represents portable personal computers with integrated
display, battery, and input devices.

### Rationale

Laptop hosts need classification because portable machines often differ from
stationary machines in hardware capabilities, power behavior, input devices,
and package or service choices. The class lets the system express laptop-aware
behavior without assuming that every personal host is portable.

## REQ-008: System introduces development host class

The development class represents hosts intended to support repository
development and maintenance workflows.

### Rationale

Development hosts need classification because development tools are required on
machines used for project work, but they are not inherently required on storage
servers, VPS machines, validation-only configurations, or other hosts whose
purpose does not include development.

## REQ-009: System introduces NAS host class

The NAS class represents home media server and storage machines.

### Rationale

NAS hosts need classification because storage-oriented machines have a
different purpose from interactive workstations and cloud machines. Their
package and service needs are driven by storage, media, and server operation,
not by the primary user's interactive desktop or development workflow.

## REQ-010: System introduces VPS host class

The VPS class represents machines running in a cloud or virtual private server
environment.

### Rationale

VPS hosts need classification because cloud or virtual server environments have
different operational constraints from local physical machines. They may need
server-oriented packages and services while lacking local hardware assumptions
that make sense for laptops, NAS machines, or graphical hosts.

## REQ-011: System introduces VPS client host class

The VPS client class represents hosts that use services provided by a VPS host.

### Rationale

VPS client hosts need classification because consuming services from a VPS is a
separate role from running the VPS itself. A host may be a client of remote VPS
services while also belonging to another class such as laptop, graphical, or
development.
