# Requirements

## REQ-001: Project supports multiple personal host configurations

The repository must support more than one concrete host configuration owned by
the same primary human user.

Each host may have a different purpose, hardware profile, deployment context,
and practical capability set. The project must not require every host to expose
the same user environment merely because the hosts are managed by the same
repository.

### Scenario: Multiple personal hosts coexist

- WHEN the repository contains multiple concrete host configurations for the same primary human user
- THEN each host can be represented as a distinct supported configuration
- AND the hosts are not required to share the same purpose, hardware profile, deployment context, or capability set

### Scenario: One host's environment does not define every host

- WHEN one personal host needs a user environment, package, or service that another personal host does not need
- THEN the project can support that difference between the host configurations
- AND the other host is not required to expose the same user environment merely because both hosts belong to the same repository

### Scenario: Shared behavior is not duplicated across hosts

- WHEN multiple personal host configurations need the same behavior or configuration
- THEN that shared behavior or configuration can be described once and applied to those hosts
- AND the same definition does not need to be duplicated in each host's code
- AND each host can still keep its own purpose, hardware profile, deployment context, and capability differences

## REQ-002: User-facing behavior is scoped to the host primary user

When a requirement refers to tools, packages, or environment visible to "the
user", the repository must have a stable way to identify the primary user for
the evaluated host.

User-facing guarantees apply to that primary user on that host. They must not
implicitly require the same environment for unrelated users or for every host in
the repository.

### Scenario: User-facing guarantee applies to the host primary user

- WHEN a requirement promises a tool, package, or environment to "the user" on an evaluated host
- THEN the promise applies to that host's primary user
- AND the evaluated host provides a stable way to identify that primary user

### Scenario: Other users are not implicitly covered

- WHEN a host has users other than the primary user
- THEN user-facing guarantees for "the user" do not automatically apply to those other users
- AND those users require separate requirements if they need the same guarantee

### Scenario: Other hosts are not implicitly covered

- WHEN another host in the repository has a different primary user environment or purpose
- THEN a user-facing guarantee for one host does not automatically require the same environment on that other host
- AND that other host requires its own applicable requirement or host-purpose selection

## REQ-003: Host environments are selected by purpose and capability

The repository must let host environments differ according to the host's
intended role and physical or operational capabilities.

Packages and services needed only for a particular class of host must be
selectable without forcing that environment onto hosts where it is unnecessary,
unsupported, or outside the host's purpose.

### Scenario: Host purpose selects relevant environment

- WHEN a host has an intended role that needs specific packages, services, or user-facing tools
- THEN the repository can select those environment elements for that host's role
- AND hosts with other roles are not forced to include them

### Scenario: Host capability limits environment selection

- WHEN a package, service, or user-facing environment depends on a physical or operational capability that a host lacks
- THEN the repository can avoid selecting that environment element for the incapable host
- AND the host remains supported for its own purpose

### Scenario: Unnecessary environments are not required globally

- WHEN a package or service is useful only for a particular class of host
- THEN that package or service can be selected for that class
- AND hosts outside the class are not required to expose it
