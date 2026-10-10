# Architecture Decision Records

## ADR-0001: Explicit Host Classification

Status: Accepted

### Context

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

### Decision

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

Note: in the current system specification, `hardware.needGraphic` is named
`hardware.isGraphic`, and `hardware.development` is named
`hardware.isDevelopment`. The rename keeps the same explicit-classification
decision and does not create a separate architecture decision.

### Consequences

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

## ADR-0002: Remove `pkgs.isDesktop`

Status: Accepted

### Context

The package set currently exposes a derived host flag named `pkgs.isDesktop`.
Its intended meaning is unclear in the current system design, and it appears to
be a remnant of older versions of the configuration.

The current host classification model is moving toward explicit, auditable host
role flags. Keeping an unclear derived desktop flag makes that model harder to
evolve because package expressions can depend on an implicit interpretation
that is not part of the intended classification vocabulary.

### Decision

Remove `pkgs.isDesktop` from the system specification and from the package set
interface.

New design work must use explicit host classification flags or introduce a
well-defined replacement through the SDD process.

### Consequences

The implementation in this repository must be reviewed and updated to remove
the `pkgs.isDesktop` overlay flag.

Other repositories and private extensions that depend on this package set must
also be reviewed for `pkgs.isDesktop` usage before or during migration.

Removing the flag may require replacing old package-level conditionals with
clearer configuration-level host classification rules.
