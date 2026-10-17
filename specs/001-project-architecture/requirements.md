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

## REQ-002: Hosts select a primary user for user-facing behavior

When a host has a primary user, the repository must provide a stable way
to identify that account. Guarantees referring to tools, packages or an
environment for "the user" apply to that host's primary user within the
conditions of the owning requirement.

Such guarantees must not implicitly extend to unrelated users or every
host in the repository, or force a primary account onto a host that does
not need one.

Hosts must be able to configure the primary account's identity, home,
password and supplementary access, retaining established default
privileges. The account is created only when its login is configured.

### Scenario: User-facing guarantee applies to the host primary user

- WHEN an applicable requirement promises a tool, package or environment to
  "the user" on a host with a primary account
- THEN the promise applies to that host's primary user
- AND the host provides a stable way to identify that account

### Scenario: Other users are not implicitly covered

- WHEN a host has users other than the primary user
- THEN guarantees for "the user" do not automatically apply to those other
  users
- AND those users require separate requirements if they need the same
  guarantee

### Scenario: Other hosts are not implicitly covered

- WHEN another host has a different primary user environment or purpose
- THEN a guarantee for one host does not automatically require the same
  environment on the other host
- AND applicability is determined by that other host's requirements and
  purpose

### Scenario: Configured login selects the primary account

- WHEN a host configures a primary-user login
- THEN a normal-user account with that login is created
- AND its home directory is created
- AND that account is identified as the host's primary user

### Scenario: Account details are configurable

- WHEN a host specifies the primary user's display name, home directory,
  password, additional groups or personal metadata
- THEN the primary account and applicable user-facing functionality use
  those configured details
- AND a host can supply different details from another host

### Scenario: Default privileges preserve established access

- WHEN a primary account is created with default access settings
- THEN it receives administrative access and the established supplementary
  access for terminal, serial devices, keys, audio, Android debugging,
  containers, input devices and Nix builds
- AND explicitly configured additional groups extend that default access

### Scenario: No login means no primary account

- WHEN a host has no configured primary-user login
- AND no enabled functionality requires a primary account
- THEN no primary account or its home directory is created
- AND the host remains a valid configuration
- AND independently configured accounts and system functionality remain
  available

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

## REQ-004: Obtain host-available packages with a simple command

The user must be able to obtain any package available for use in any of
the repository's host configurations with a simple command, without
writing Nix snippets or changing a host configuration.

### Scenario: Obtain a package by name

- GIVEN a package is available for use in a repository host configuration
- WHEN the user requests that package by name with a single command
- THEN the user can obtain the package for that host's platform
- AND the user does not need to write a Nix expression or configuration file
- AND the user does not need to change or deploy the host configuration

### Scenario: Packages from different sources are accessible

- GIVEN host configurations can use packages from different package sources
- WHEN the user requests a package available from any of those sources
- THEN the user can obtain it with a single command
- AND the user does not need to write code to import or combine package sources

### Scenario: Select a host-specific package variant

- GIVEN the same package name refers to different variants in different host configurations
- WHEN the user requests the variant available to a particular host
- THEN the user can identify and obtain that variant with a single command
- AND the user does not need to reproduce the host's package configuration in a snippet

## REQ-006: Reusable modules are optional and disabled by default

Every reusable module provided under `modules/` must allow its
functionality to be disabled and must leave it disabled by default.
Making a module available must not by itself select its functionality.
Hosts must be able to select the functionality they need without
requiring dependencies of disabled functionality.

### Rationale

Reusing the module collection must not force an account, personal
environment, service or other optional capability onto every host.

### Scenario: Available modules do not activate functionality by default

- WHEN a host makes a reusable module available without enabling its
  functionality
- THEN that functionality remains disabled
- AND the module does not apply the effects of that functionality

### Scenario: Selected functionality can be disabled

- WHEN a host disables a reusable module's functionality
- THEN that functionality does not apply to the host
- AND the module can remain available for configuration

### Scenario: Disabled functionality does not require its dependencies

- WHEN functionality is disabled
- THEN it does not access or require dependencies needed only for that
  functionality
- AND absence of those dependencies does not prevent configuration assembly

### Scenario: Enabled functionality requires its dependencies

- WHEN enabled functionality requires an unavailable dependency
- THEN the host configuration is rejected as incomplete
- AND the functionality is not silently omitted

### Scenario: Independent functionality remains usable

- WHEN a host disables an optional capability
- AND other selected functionality does not depend on that capability
- THEN the other functionality remains available
