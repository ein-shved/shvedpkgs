# ADR-0001: Explicit Host Classification

Status: Accepted

## Context

The system uses host classification flags to decide which host-specific
configuration and package buckets apply to an evaluated NixOS configuration.
Examples include graphical, development, NAS, VPS, laptop, and VPS-client
behavior.

Some of these flags currently rely on enabling defaults. That makes it too easy
for a new host or profile to receive role-sensitive behavior accidentally. It
also makes implementation bugs harder to see, because an omitted host
classification can look the same as an intentional role assignment after
evaluation.

The system specification should treat host classification as an explicit part
of each host or profile definition.

## Decision

All host classification flags are disabled by default.

Each concrete host or reusable host profile explicitly declares the complete
set of host classification flags that describe its intended role.

At minimum, this decision applies to these configuration flags:

* `hardware.isLaptop`
* `hardware.isNas`
* `hardware.isVps`
* `hardware.isVpsClient`
* `hardware.needGraphic`
* `hardware.development`

Host classification derived values, including package-set overlay flags such
as `pkgs.isLaptop`, `pkgs.isNas`, `pkgs.isVps`, `pkgs.isVpsClient`, and
other explicitly specified host-derived package flags, are derived from
explicit host classification. They do not define host roles independently.

## Consequences

New hosts and profiles must intentionally opt in to every role-sensitive
behavior they need.

Host definitions become more verbose, but the evaluated role set becomes easier
to audit and review.

Implementation should avoid defaults that enable host classification flags.
When migrating existing hosts, each host should be reviewed and assigned an
explicit classification set rather than relying on previous default behavior.

This decision does not by itself define which concrete hosts have which roles.
Those assignments belong in host or profile configuration and can be reviewed
separately.
